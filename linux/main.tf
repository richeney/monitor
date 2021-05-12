terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.51.0"
    }
  }
}

locals {}

resource "azurerm_public_ip" "linux" {
  for_each            = toset(var.dns_label != null ? [var.name] : [])
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  domain_name_label = var.dns_label
}

resource "azurerm_network_interface" "linux" {
  name                = "${var.name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    primary                       = true
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.dns_label != null ? azurerm_public_ip.linux[var.name].id : null
  }
}

resource "azurerm_network_interface_application_security_group_association" "linux" {
  for_each                      = toset(var.asg_id != null ? [var.name] : [])
  network_interface_id          = azurerm_network_interface.linux.id
  application_security_group_id = var.asg_id
}

resource "azurerm_linux_virtual_machine" "linux" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  computer_name                   = var.name
  admin_username                  = var.admin_username
  disable_password_authentication = true
  size                            = var.size

  network_interface_ids = [azurerm_network_interface.linux.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.name}-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  // custom_data = filebase64("${path.module}/example_cloud_init")
  // custom_data = base64encode(templatefile("${path.module}/azure_arc_cloud_init.tpl", { hostname = var.name }))
  // custom_data = base64encode(data.template_cloudinit_config.multipart.rendered)

  admin_ssh_key {
    username   = var.admin_username
    public_key = length(var.admin_ssh_public_key) > 0 ? var.admin_ssh_public_key : file(var.admin_ssh_public_key_file)
  }
}
