output "workspace_id" {
  value = azurerm_log_analytics_workspace.monitor.workspace_id
}

output "workspace_primary_key" {
  value     = azurerm_log_analytics_workspace.monitor.primary_shared_key
  sensitive = true
}

output "windows_admin_password" {
  value     = local.windows_admin_password
  sensitive = true
}
