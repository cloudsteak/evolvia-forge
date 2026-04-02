variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"

}

variable "trainee_username" {
  description = "The trainee username"
  type        = string

}

variable "trainee_password" {
  description = "The trainee password"
  type        = string
  sensitive   = true
}


variable "tags" {
  description = "Tags to be assigned to the resources"
  type        = map(string)
  default = {
    environment = "training"
    owner       = "cloudmentor"
    trainee     = "true"
    lab         = "basic"
  }
}
