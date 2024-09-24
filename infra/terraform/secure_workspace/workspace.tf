# Dependent resources for Azure Machine Learning

# App Insights
# Naming: appi-<project, app or service>
resource "azurerm_application_insights" "appi" {
  name                = module.naming.application_insights.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = local.tags
}

######### KeyVault
######### Naming(Global): kv-<project, app or service>-<environment>-<###>
resource "azurerm_key_vault" "kv" {
  name                = module.naming.key_vault.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
  tags                = local.tags
  # purge_protection_enabled = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_private_endpoint" "kv_ple" {
  name                = "${module.naming.private_endpoint.name}-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsvault.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-kv"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

######### Storage Account
######### Naming(Global): st<project, app or service><###>
resource "azurerm_storage_account" "sa" {
  name                     = module.naming.storage_account.name_unique
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = local.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_private_endpoint" "st_ple_blob" {
  name                = "${module.naming.private_endpoint.name}-st-blob"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstorageblob.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-st"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "storage_ple_file" {
  name                = "${module.naming.private_endpoint.name}-st-file"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstoragefile.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-st"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "st_ple_queue" {
  name                = "${module.naming.private_endpoint.name}-st-queue"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_storage_queue.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-st"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "st_ple_table" {
  name                = "${module.naming.private_endpoint.name}-st-table"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_storage_table.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-st"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }
}

######### Storage Account - Data Science
######### Naming(Global): st<project, app or service><###>
resource "azurerm_storage_account" "sa_ds" {
  name                     = lower("${module.naming.storage_account.slug}${var.deployment_name}ds")
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = local.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_private_endpoint" "st_ple_blob_ds" {
  name                = "${module.naming.private_endpoint.name}-st-ds-blob"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstorageblob.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-st-ds"
    private_connection_resource_id = azurerm_storage_account.sa_ds.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "st_ple_file_ds" {
  name                = "${module.naming.private_endpoint.name}-st-ds-file"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstoragefile.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-st-ds"
    private_connection_resource_id = azurerm_storage_account.sa_ds.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}


######### Azure Container Registry
######### Naming(Global): acr<project, app or service><environment><###>
resource "azurerm_container_registry" "cr" {
  name                = module.naming.container_registry.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Premium"
  admin_enabled       = true
  tags                = local.tags

  network_rule_set {
    default_action = "Deny"
  }
  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "cr_ple" {
  name                = "${module.naming.private_endpoint.name}-cr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnscontainerregistry.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-cr"
    private_connection_resource_id = azurerm_container_registry.cr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

######### Machine Learning workspace
######### Naming(Global): mlw-<project, app or service>-<environment>-###
resource "azurerm_machine_learning_workspace" "mlw" {
  name                    = module.naming.machine_learning_workspace.name_unique
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.appi.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.sa.id
  container_registry_id   = azurerm_container_registry.cr.id

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = true
  image_build_compute_name      = var.aml_image_build_compute.name
  depends_on = [
    azurerm_private_endpoint.kv_ple,
    azurerm_private_endpoint.st_ple_blob,
    azurerm_private_endpoint.storage_ple_file,
    azurerm_private_endpoint.cr_ple,
    azurerm_subnet.snet-training
  ]

}

resource "azurerm_private_endpoint" "mlw_ple" {
  name                = "${module.naming.private_endpoint.name}-mlw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet-workspace.id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsazureml.id, azurerm_private_dns_zone.dnsnotebooks.id]
  }

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-mlw"
    private_connection_resource_id = azurerm_machine_learning_workspace.mlw.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }
}

# Compute cluster for image building required since the workspace is behind a vnet.
# For more details, see https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-create-secure-workspace#configure-image-builds.
resource "azurerm_machine_learning_compute_cluster" "image-builder" {
  name                          = var.aml_image_build_compute.name
  location                      = azurerm_resource_group.rg.location
  vm_priority                   = var.aml_image_build_compute.vm_priority
  vm_size                       = var.aml_image_build_compute.vm_size
  machine_learning_workspace_id = azurerm_machine_learning_workspace.mlw.id
  subnet_resource_id            = azurerm_subnet.snet-training.id

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 1
    scale_down_nodes_after_idle_duration = "PT15M" # 15 minutes
  }

  identity {
    type = "SystemAssigned"
  }
}