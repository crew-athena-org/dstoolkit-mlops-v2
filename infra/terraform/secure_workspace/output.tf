output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "application_insights_name" {
  value = azurerm_application_insights.appi.name
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_name_ds" {
  value = azurerm_storage_account.sa_ds.name
}

output "container_registry_name" {
  value = azurerm_container_registry.cr.name
}

output "machine_learning_workspace_name" {
  value = azurerm_machine_learning_workspace.mlw.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}