resource "azurerm_public_ip" "jumpbox" {
  for_each = local.jumpbox_public_ip_enabled ? { this = var.jumpbox } : {}

  name                = each.value.public_ip_name
  location            = var.primary_location
  resource_group_name = var.access_ops_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_network_security_group" "jumpbox" {
  for_each = local.jumpbox_enabled ? { this = var.jumpbox } : {}

  name                = coalesce(each.value.network_security_group_name, "nsg-${each.value.name}")
  location            = var.primary_location
  resource_group_name = var.access_ops_resource_group_name

  tags = local.common_tags
}

resource "azurerm_network_security_rule" "jumpbox_ssh" {
  for_each = local.jumpbox_enabled ? {
    for index, prefix in local.jumpbox_ssh_source_prefixes : tostring(index) => prefix
  } : {}

  name                        = "AllowSshFromApprovedSource${each.key}"
  priority                    = 100 + tonumber(each.key)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = var.access_ops_resource_group_name
  network_security_group_name = azurerm_network_security_group.jumpbox["this"].name
}

resource "azurerm_network_interface" "jumpbox" {
  for_each = local.jumpbox_enabled ? { this = var.jumpbox } : {}

  name                = coalesce(each.value.network_interface_name, "nic-${each.value.name}")
  location            = var.primary_location
  resource_group_name = var.access_ops_resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.jumpbox_public_ip_enabled ? azurerm_public_ip.jumpbox["this"].id : null
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  for_each = local.jumpbox_enabled ? { this = var.jumpbox } : {}

  network_interface_id      = azurerm_network_interface.jumpbox["this"].id
  network_security_group_id = azurerm_network_security_group.jumpbox["this"].id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  for_each = local.jumpbox_enabled ? { this = var.jumpbox } : {}

  name                            = each.value.name
  location                        = var.primary_location
  resource_group_name             = var.access_ops_resource_group_name
  size                            = each.value.vm_size
  admin_username                  = each.value.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.jumpbox["this"].id]
  custom_data                     = each.value.custom_data_base64

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.admin_ssh_public_key
  }

  os_disk {
    name                 = coalesce(each.value.os_disk_name, "osdisk-${each.value.name}")
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  tags = local.common_tags
}
