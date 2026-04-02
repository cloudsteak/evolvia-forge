output "trainee_username" {
  value = module.trainee.trainee_username
}


output "aws_console_url" {
  value = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}
