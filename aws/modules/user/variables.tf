variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string

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

variable "trainee_group_name" {
  description = "The trainee group name"
  type        = string
  default     = "evolvia-trainees"
}

variable "tags" {
  description = "The tags to apply to resources"
  type        = map(string)
}

