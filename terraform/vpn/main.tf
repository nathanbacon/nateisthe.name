# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

variable "domain_name" {
  type = string
}

variable "region" {
  type = string
}

locals {
  username = "nathan"
}

resource "azurerm_resource_group" "vpn_rg" {
  name     = "myvpn"
  location = var.region
}

resource "azurerm_public_ip" "my_ip" {
  name                = "myip"
  resource_group_name = azurerm_resource_group.vpn_rg.name
  location            = azurerm_resource_group.vpn_rg.location
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "vpn_network" {
  name                = "myvirtualnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
}

resource "azurerm_subnet" "vpn_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vpn_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "myvpn-nic1"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.vpn_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_ip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                = "myvpn-nic2"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vpn_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "primary" {
  name                = "primary"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
}

resource "azurerm_network_interface_security_group_association" "primary" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.primary.id
}

resource "azurerm_linux_virtual_machine" "vpn_vm" {
  name                = "myvpn-machine"
  resource_group_name = azurerm_resource_group.vpn_rg.name
  location            = azurerm_resource_group.vpn_rg.location
  size                = "Standard_B1s"
  admin_username      = local.username
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  admin_ssh_key {
    username   = local.username
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
