# Random name for AI stuff
resource "random_string" "this" {
  length  = 10
  upper   = false
  special = false
}

locals {
  deployment_data      = jsondecode(file("../../files/openai_deployments.json"))
  foundry_user_role_id = "53ca6127-db72-4b80-b1b0-d745d6d5456d"
}

data "azurerm_role_definition" "foundry_user" {
  role_definition_id = local.foundry_user_role_id
}

# Microsoft Foundry account. A project is required for the current Foundry portal.
resource "azurerm_cognitive_account" "this" {
  name                       = "foundry-${random_string.this.result}"
  custom_subdomain_name      = "foundry-${random_string.this.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  kind                       = "AIServices"
  sku_name                   = "S0"
  project_management_enabled = true
  tags                       = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_account_project" "this" {
  name                 = "projekt"
  cognitive_account_id = azurerm_cognitive_account.this.id
  location             = var.location
  display_name         = "Projekt"
  description          = "Microsoft Foundry projekt a képzéshez."
  tags                 = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "student_foundry_user" {
  scope              = azurerm_cognitive_account.this.id
  role_definition_id = data.azurerm_role_definition.foundry_user.id
  principal_id       = var.student_principal_id
}

resource "azurerm_cognitive_deployment" "this" {
  for_each             = local.deployment_data
  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.scale_type
    capacity = each.value.capacity
  }

  depends_on = [azurerm_cognitive_account_project.this]
}

resource "azurerm_search_service" "this" {
  name                = "search-${random_string.this.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "basic"

  local_authentication_enabled = true
  authentication_failure_mode  = "http403"
}

resource "azurerm_storage_container" "this" {
  count                 = var.is_rag_files ? 1 : 0
  name                  = var.doc_container_name
  storage_account_name  = var.rag_storage_account_name
  container_access_type = var.doc_container_access_type
  depends_on            = [var.rag_storage_account_name]
}

resource "azurerm_storage_blob" "this" {
  for_each               = var.is_rag_files ? fileset(var.local_doc_directory_path, "*.*") : []
  name                   = each.value
  storage_account_name   = var.rag_storage_account_name
  storage_container_name = azurerm_storage_container.this[0].name
  type                   = "Block"
  source                 = "${var.local_doc_directory_path}/${each.value}"
  depends_on             = [azurerm_storage_container.this]
}
