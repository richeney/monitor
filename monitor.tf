resource "azurerm_resource_group" "monitor" {
  name     = "nps-monitor"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "monitor" {
  name                = "nps-workspace"
  location            = azurerm_resource_group.monitor.location
  resource_group_name = azurerm_resource_group.monitor.name

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "local_file" "linux_workspace_settings" {
  content  = templatefile("${path.root}/scripts/linux_workspace_settings.tpl", { wid = azurerm_log_analytics_workspace.monitor.workspace_id })
  filename = "${path.root}/scripts/linux_workspace_settings.sh"
}

resource "null_resource" "cowboy_software" {
  triggers = {
    workspace_id = azurerm_log_analytics_workspace.monitor.workspace_id
  }

  provisioner "local-exec" {
    command = "${path.root}/scripts/linux_workspace_settings.sh > workspace_id"
  }
}

/*

//##########################################################

resource "azurerm_log_analytics_datasource_windows_event" "application" {
  name                = "datasource_windows_application"
  resource_group_name = azurerm_resource_group.monitor.name
  workspace_name      = azurerm_log_analytics_workspace.monitor.name
  event_log_name      = "Application"
  event_types         = ["error"]
}

resource "azurerm_log_analytics_datasource_windows_event" "system" {
  name                = "datasource_windows_system"
  resource_group_name = azurerm_resource_group.monitor.name
  workspace_name      = azurerm_log_analytics_workspace.monitor.name
  event_log_name      = "System"
  event_types         = ["error", "warning"]
}

//##########################################################

resource "azurerm_log_analytics_datasource_windows_performance_counter" "cpu" {
  name                = "datasource_windows_performance_counter_cpu"
  resource_group_name = azurerm_resource_group.monitor.name
  workspace_name      = azurerm_log_analytics_workspace.monitor.name
  object_name         = "CPU"
  instance_name       = "*"
  counter_name        = "CPU"
  interval_seconds    = 10
}

*/