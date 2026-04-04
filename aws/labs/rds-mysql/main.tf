provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "trainee" {
  source           = "../../modules/user"
  trainee_username = var.trainee_username
  aws_region       = var.aws_region
  tags             = var.tags
}

module "network" {
  source           = "../../modules/network"
  trainee_username = var.trainee_username
  aws_region       = var.aws_region
  tags             = var.tags
}



