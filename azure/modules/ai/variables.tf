################
# Basic Inputs #
################
variable "subscription_id" {
  type        = string
  description = "value of the Azure subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "value of the Azure resource group name"
}

variable "location" {
  type        = string
  description = "value of the Azure location"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default = {
    owner   = "Evolvia"
    purpose = "Practice"
  }

}

#############
# AI Inputs #
#############

variable "is_rag_files" {
  type    = bool
  default = false
}

variable "doc_container_name" {
  type        = string
  description = "value of the Azure container name for AI"
  default     = "dokumentumok"
}

variable "doc_container_access_type" {
  type        = string
  description = "value of the Azure container access type for AI"
  default     = "private"
}

variable "local_doc_directory_path" {
  type        = string
  description = "value of the local document directory path for RAG"
  default     = "../../files/docs"
}

variable "rag_storage_account_name" {
  type        = string
  description = "value of the Azure storage account suffix for RAG"
  default     = "fake"
}

variable "student_principal_id" {
  type        = string
  description = "Entra object ID of the lab user. Foundry User is assigned on this lab's Foundry account."
}
