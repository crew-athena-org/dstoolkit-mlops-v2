# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.virtual_network.name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet-training" {
  name                 = "snet-training"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.training_subnet_address_space
}

resource "azurerm_subnet" "snet-workspace" {
  name                 = "snet-workspace"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.ml_subnet_address_space
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "dnsvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkvault" {
  name                  = "dnsvaultlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsvault.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dnsstorageblob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkblob" {
  name                  = "dnsblobstoragelink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsstorageblob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dnsstoragefile" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkfile" {
  name                  = "dnsfilestoragelink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsstoragefile.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dns_storage_queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkqueue" {
  name                  = "dnsqueuetoragelink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_storage_queue.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dns_storage_table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinktable" {
  name                  = "dnstablestoragelink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_storage_table.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dnscontainerregistry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkcr" {
  name                  = "dnscrlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnscontainerregistry.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dnsazureml" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkml" {
  name                  = "dnsazuremllink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsazureml.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "dnsnotebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinknbs" {
  name                  = "dnsnotebookslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsnotebooks.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg-training" {
  name                = "nsg-training"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "BatchNodeManagement"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "29876-29877"
    source_address_prefix      = "BatchNodeManagement"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AzureMachineLearning"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "44224"
    source_address_prefix      = "AzureMachineLearning"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-training-link" {
  subnet_id                 = azurerm_subnet.snet-training.id
  network_security_group_id = azurerm_network_security_group.nsg-training.id
}

# User Defined Routes for compute instance and compute clusters
resource "azurerm_route_table" "rt-training" {
  name                = "rt-training"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_route" "training-Internet-Route" {
  name                = "Internet"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.rt-training.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "training-AzureMLRoute" {
  name                = "AzureMLRoute"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.rt-training.name
  address_prefix      = "AzureMachineLearning"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "training-BatchRoute" {
  name                = "BatchRoute"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.rt-training.name
  address_prefix      = "BatchNodeManagement"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "rt-training-link" {
  subnet_id      = azurerm_subnet.snet-training.id
  route_table_id = azurerm_route_table.rt-training.id
}