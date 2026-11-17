# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.student_username
  location = var.location
  tags     = local.tags
  timeouts {
    create = "60m"
    delete = "60m"
  }
}

module "USER" {
  source              = "../../modules/user"
  location            = var.location
  username            = var.student_username
  password            = var.student_password
  resource_group_id   = azurerm_resource_group.rg.id
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

module "AI" {
  source               = "../../modules/ai"
  subscription_id      = var.subscription_id
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  student_principal_id = module.USER.object_id
  tags                 = local.tags
}
