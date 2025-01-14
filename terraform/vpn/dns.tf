data "azurerm_dns_zone" "nateisthename" {
  name                = var.domain_name
  resource_group_name = "dnszones"
}

resource "azurerm_dns_a_record" "vm_a_record" {
  name                = "vpn"
  zone_name           = data.azurerm_dns_zone.nateisthename.name
  resource_group_name = data.azurerm_dns_zone.nateisthename.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.my_ip.ip_address]
}
