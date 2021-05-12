terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.51.0"
    }
  }
}

locals {}

resource "azurerm_public_ip" "windows" {
  for_each            = toset(var.dns_label != null ? [var.name] : [])
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  domain_name_label = var.dns_label
}

resource "azurerm_network_interface" "windows" {
  name                = "${var.name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    primary                       = true
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.dns_label != null ? azurerm_public_ip.windows[var.name].id : null
  }
}

resource "azurerm_network_interface_application_security_group_association" "windows" {
  for_each                      = toset(var.asg_id != null ? [var.name] : [])
  network_interface_id          = azurerm_network_interface.windows.id
  application_security_group_id = var.asg_id
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  computer_name  = var.name
  admin_username = var.admin_username
  admin_password = var.admin_password
  size           = var.size

  network_interface_ids = [azurerm_network_interface.windows.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Upload winrm PowerShell script via the custom data - enables winrm and blocks IMDS
  // custom_data = base64encode(local.custom_data)

}
