output "acr_id" {
  value = module.acr-example.container_registry_id
  description = "Container registry ID"
}

output "acr_admin_username" {
  value = module.acr-example.container_registry_admin_username
  description = "Container registry admin username"
}
