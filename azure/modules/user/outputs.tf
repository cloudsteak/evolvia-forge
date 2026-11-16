output "username" {
  value = azuread_user.user.user_principal_name
}

output "object_id" {
  value = azuread_user.user.object_id
}

output "portal_url" {
  value = "https://portal.azure.com"
}
