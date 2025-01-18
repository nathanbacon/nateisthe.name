resource "azurerm_network_security_rule" "ssh" {
  name                        = "myssh"
  resource_group_name         = azurerm_resource_group.vpn_rg.name
  network_security_group_name = azurerm_network_security_group.primary.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_network_interface.main.private_ip_address
}

resource "azurerm_network_security_rule" "wireguard" {
  name                        = "mywireguard"
  resource_group_name         = azurerm_resource_group.vpn_rg.name
  network_security_group_name = azurerm_network_security_group.primary.name
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "51820"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_network_interface.main.private_ip_address
}
