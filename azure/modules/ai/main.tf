# Random name for AI stuff
resource "random_string" "this" {
  length  = 10
  upper   = false
  special = false
}

locals {
  deployment_data      = jsondecode(file("../../files/openai_deployments.json"))
  foundry_user_role_id = "53ca6127-db72-4b80-b1b0-d745d6d5456d"
  doc_directory        = abspath("${path.module}/../../files/docs")
}

data "azurerm_client_config" "current" {}

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

resource "azurerm_role_assignment" "deployer_foundry_user" {
  scope                            = azurerm_cognitive_account.this.id
  role_definition_id               = data.azurerm_role_definition.foundry_user.id
  principal_id                     = data.azurerm_client_config.current.object_id
  skip_service_principal_aad_check = true
}

resource "terraform_data" "project_files" {
  depends_on = [
    azurerm_role_assignment.deployer_foundry_user,
    azurerm_cognitive_deployment.this,
  ]

  triggers_replace = {
    endpoint     = "https://${azurerm_cognitive_account.this.custom_subdomain_name}.services.ai.azure.com/api/projects/${azurerm_cognitive_account_project.this.name}/openai/v1"
    vector_store = "ceges-dokumentumok"
    docs = sha256(join("", [
      for name in sort(fileset(local.doc_directory, "*")) : filesha256("${local.doc_directory}/${name}")
    ]))
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/upload-docs.sh"
    environment = {
      DOC_DIR                 = local.doc_directory
      PROJECT_OPENAI_ENDPOINT = "https://${azurerm_cognitive_account.this.custom_subdomain_name}.services.ai.azure.com/api/projects/${azurerm_cognitive_account_project.this.name}/openai/v1"
    }
  }
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
