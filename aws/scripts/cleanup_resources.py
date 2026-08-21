import boto3
import sys
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def delete_resources(username, region):
    session = boto3.Session(region_name=region)
    tagging_client = session.client('resourcegroupstaggingapi')
    s3_client = session.client('s3')
    ec2_client = session.client('ec2')
    rds_client = session.client('rds')
    lambda_client = session.client('lambda')
    apigw_client = session.client('apigateway')

    def retry_delete(func, *args, **kwargs):
        for attempt in range(1, 11):
            try:
                func(*args, **kwargs)
                logger.info(f"Successfully executed {func.__name__}")
                return True
            except Exception as e:
                logger.warning(f"Attempt {attempt}/10 failed for {func.__name__}: {e}")
                if attempt < 10:
                    time.sleep(30)
                else:
                    logger.error(f"Failed to execute {func.__name__} after 10 attempts.")
                    return False

    delete_ec2_key_pairs(ec2_client, username, retry_delete)

    # 1. Delete resources by 'owner' tag
    logger.info(f"Searching for resources with tag 'owner={username}' in region {region}...")
    try:
        resources = tagging_client.get_resources(
            TagFilters=[{'Key': 'owner', 'Values': [username]}]
        )['ResourceTagMappingList']
    except Exception as e:
        logger.error(f"Failed to list resources by tag: {e}")
        resources = []

    for r in resources:
        arn = r['ResourceARN']
        logger.info(f"Found tagged resource: {arn}")
        # Logic to delete by ARN type (simplified for common types)
        if ':ec2:' in arn and ':instance/' in arn:
            instance_id = arn.split('/')[-1]
            retry_delete(ec2_client.terminate_instances, InstanceIds=[instance_id])
        elif ':s3:::' in arn:
            bucket_name = arn.split(':::')[-1]
            empty_and_delete_s3(s3_client, bucket_name, retry_delete)
        elif ':rds:' in arn and ':db:' in arn:
            db_id = arn.split(':')[-1]
            retry_delete(rds_client.delete_db_instance, DBInstanceIdentifier=db_id, SkipFinalSnapshot=True, DeleteAutomatedBackups=True)
        elif ':lambda:' in arn and ':function:' in arn:
            func_name = arn.split(':')[-1]
            retry_delete(lambda_client.delete_function, FunctionName=func_name)
        elif ':ec2:' in arn and ':image/' in arn:
            image_id = arn.split('/')[-1]
            retry_delete(ec2_client.deregister_image, ImageId=image_id)
        elif ':ec2:' in arn and ':snapshot/' in arn:
            snapshot_id = arn.split('/')[-1]
            retry_delete(ec2_client.delete_snapshot, SnapshotId=snapshot_id)
        # Add more types as needed...

    # 2. Delete S3 buckets by prefix
    logger.info(f"Searching for S3 buckets with prefix '{username}'...")
    try:
        all_buckets = s3_client.list_buckets()['Buckets']
        for b in all_buckets:
            name = b['Name']
            if name.startswith(username):
                logger.info(f"Found bucket by prefix: {name}")
                empty_and_delete_s3(s3_client, name, retry_delete)
    except Exception as e:
        logger.error(f"Failed to list S3 buckets: {e}")

    delete_ec2_amis_and_snapshots(ec2_client, username, retry_delete)

def empty_and_delete_s3(client, bucket_name, retry_func):
    def empty_bucket():
        logger.info(f"Emptying bucket {bucket_name}...")
        paginator = client.get_paginator('list_object_versions')
        for page in paginator.paginate(Bucket=bucket_name):
            delete_list = []
            for item in page.get('Versions', []) + page.get('DeleteMarkers', []):
                delete_list.append({'Key': item['Key'], 'VersionId': item['VersionId']})
            if delete_list:
                client.delete_objects(Bucket=bucket_name, Delete={'Objects': delete_list})

    retry_func(empty_bucket)
    retry_func(client.delete_bucket, Bucket=bucket_name)

def delete_ec2_key_pairs(client, username, retry_func):
    logger.info(f"Searching for EC2 Key Pairs with tag 'owner={username}'...")

    key_names = set()

    try:
        tagged = client.describe_key_pairs(
            Filters=[{'Name': 'tag:owner', 'Values': [username]}]
        ).get('KeyPairs', [])
        for key in tagged:
            key_name = key.get('KeyName')
            if key_name:
                key_names.add(key_name)
    except Exception as e:
        logger.warning(f"Failed to list tagged EC2 Key Pairs for owner '{username}': {e}")

    if not key_names:
        logger.info(f"No EC2 Key Pairs found with tag 'owner={username}'.")
        return

    for key_name in sorted(key_names):
        logger.info(f"Deleting EC2 Key Pair '{key_name}'...")
        retry_func(client.delete_key_pair, KeyName=key_name)

def _collect_user_ec2_ids(client, username):
    instance_ids = set()
    volume_ids = set()

    try:
        paginator = client.get_paginator('describe_instances')
        for page in paginator.paginate(
            Filters=[{'Name': 'tag:owner', 'Values': [username]}],
        ):
            for reservation in page.get('Reservations', []):
                for instance in reservation.get('Instances', []):
                    instance_id = instance.get('InstanceId')
                    if instance_id:
                        instance_ids.add(instance_id)
                    for mapping in instance.get('BlockDeviceMappings', []):
                        volume_id = mapping.get('Ebs', {}).get('VolumeId')
                        if volume_id:
                            volume_ids.add(volume_id)
    except Exception as e:
        logger.warning(f"Failed to list EC2 instances for owner '{username}': {e}")

    try:
        paginator = client.get_paginator('describe_volumes')
        for page in paginator.paginate(
            Filters=[{'Name': 'tag:owner', 'Values': [username]}],
        ):
            for volume in page.get('Volumes', []):
                volume_id = volume.get('VolumeId')
                if volume_id:
                    volume_ids.add(volume_id)
    except Exception as e:
        logger.warning(f"Failed to list EC2 volumes for owner '{username}': {e}")

    return instance_ids, volume_ids

def _snapshot_belongs_to_user(snapshot, username, instance_ids, volume_ids):
    tags = {tag['Key']: tag['Value'] for tag in snapshot.get('Tags', [])}
    if tags.get('owner') == username:
        return True

    volume_id = snapshot.get('VolumeId')
    if volume_id and volume_id in volume_ids:
        return True

    description = snapshot.get('Description') or ''
    for instance_id in instance_ids:
        if instance_id in description:
            return True

    return False

def _image_belongs_to_user(image, username, snapshot_ids):
    tags = {tag['Key']: tag['Value'] for tag in image.get('Tags', [])}
    if tags.get('owner') == username:
        return True

    for mapping in image.get('BlockDeviceMappings', []):
        snapshot_id = mapping.get('Ebs', {}).get('SnapshotId')
        if snapshot_id and snapshot_id in snapshot_ids:
            return True

    return False

def _snapshot_ids_from_image(image):
    snapshot_ids = set()
    for mapping in image.get('BlockDeviceMappings', []):
        snapshot_id = mapping.get('Ebs', {}).get('SnapshotId')
        if snapshot_id:
            snapshot_ids.add(snapshot_id)
    return snapshot_ids

def delete_ec2_amis_and_snapshots(client, username, retry_func):
    logger.info(f"Searching for EC2 AMIs and snapshots owned by '{username}'...")

    instance_ids, volume_ids = _collect_user_ec2_ids(client, username)
    ami_ids = set()
    snapshot_ids = set()
    images = []

    try:
        paginator = client.get_paginator('describe_snapshots')
        for page in paginator.paginate(OwnerIds=['self']):
            for snapshot in page.get('Snapshots', []):
                if _snapshot_belongs_to_user(snapshot, username, instance_ids, volume_ids):
                    snapshot_id = snapshot.get('SnapshotId')
                    if snapshot_id:
                        snapshot_ids.add(snapshot_id)
    except Exception as e:
        logger.warning(f"Failed to list EC2 snapshots for owner '{username}': {e}")

    try:
        paginator = client.get_paginator('describe_images')
        for page in paginator.paginate(Owners=['self']):
            images.extend(page.get('Images', []))
    except Exception as e:
        logger.warning(f"Failed to list EC2 AMIs for owner '{username}': {e}")

    for image in images:
        if _image_belongs_to_user(image, username, snapshot_ids):
            image_id = image.get('ImageId')
            if image_id:
                ami_ids.add(image_id)
                snapshot_ids.update(_snapshot_ids_from_image(image))

    if not ami_ids and not snapshot_ids:
        logger.info(f"No EC2 AMIs or snapshots found for owner '{username}'.")
        return

    for image_id in sorted(ami_ids):
        logger.info(f"Deregistering EC2 AMI '{image_id}'...")
        retry_func(client.deregister_image, ImageId=image_id)

    for snapshot_id in sorted(snapshot_ids):
        logger.info(f"Deleting EC2 snapshot '{snapshot_id}'...")
        retry_func(client.delete_snapshot, SnapshotId=snapshot_id)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python cleanup_resources.py <username> <region>")
        sys.exit(1)
    
    username = sys.argv[1]
    region = sys.argv[2]
    delete_resources(username, region)
