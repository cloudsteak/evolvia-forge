variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "trainee_username" {
  description = "The trainee username"
  type        = string
}

variable "tags" {
  description = "The tags to apply to resources"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}
