resource "azurerm_resource_group" "vms" {
  name     = "nps-vms"
  location = "West Europe"
}

resource "azurerm_ssh_public_key" "richeney" {
  name                = "richeney"
  location            = azurerm_resource_group.vms.location
  resource_group_name = azurerm_resource_group.vms.name
  public_key          = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_virtual_network" "vms" {
  name                = "nps_virtual_network"
  location            = azurerm_resource_group.vms.location
  resource_group_name = azurerm_resource_group.vms.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "vms" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.vms.name
  virtual_network_name = azurerm_virtual_network.vms.name
  address_prefixes     = ["10.0.0.0/25"]
}

module "linux" {
  source              = "./linux"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  tags                = var.tags

  name                 = "nps-linux"
  subnet_id            = azurerm_subnet.vms.id
  admin_username       = "richeney"
  admin_ssh_public_key = azurerm_ssh_public_key.richeney.public_key
}

module "windows" {
  source              = "./windows"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  tags                = var.tags

  name           = "nps-windows"
  subnet_id      = azurerm_subnet.vms.id
  admin_username = "richeney"
  admin_password = "Saints76!citadel"
}
