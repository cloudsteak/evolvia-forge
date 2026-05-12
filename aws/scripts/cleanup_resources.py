import boto3
import os
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

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python cleanup_resources.py <username> <region>")
        sys.exit(1)
    
    username = sys.argv[1]
    region = sys.argv[2]
    delete_resources(username, region)
