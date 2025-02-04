terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.17.0"
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

variable "account_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

resource "azurerm_resource_group" "storage" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_storage_account" "storage" {
  name                     = var.account_name
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "my_storage_share" {
  name               = "mystorageshare"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 1
  access_tier        = "Hot"
  enabled_protocol   = "SMB"
}
