locals {
  rg_name_shd        = "rg-${var.usecase}-shd-001"
  st_name            = "st${var.usecase}vdi${var.environment}001"
  st_share_name      = "share${var.usecase}fslogix01"
  nic_name           = "nic-${var.usecase}-shd-001"
  pep_name           = "pep-${var.usecase}-shd-${var.region}-001"
  psc_name           = "psc-${var.usecase}-${var.environment}-${var.region}-001"
}

#### Experimental ####

# locals {
#   varStorageToDomainScriptArgs = "-DscPath ${var.dscAgentPackageLocation} -StorageAccountName ${var.storageAccountName} -StorageAccountRG ${var.storageObjectsRgName} -StoragePurpose ${var.storagePurpose} -DomainName ${var.identityDomainName} -IdentityServiceProvider ${var.identityServiceProvider} -AzureCloudEnvironment ${var.varAzureCloudName} -SubscriptionId ${var.workloadSubsId} -AdminUserName ${var.varAdminUserName} -CustomOuPath ${var.storageCustomOuPath} -OUName ${var.ouStgPath} -ShareName ${var.fileShareName} -ClientId ${var.managedIdentityClientId} -SecurityPrincipalName \"${var.varSecurityPrincipalName}\" -StorageAccountFqdn ${var.storageAccountFqdn}"
# }

locals {
  directory_service_options       = var.identityServiceProvider == "EntraDS" ? "AADDS" : var.identityServiceProvider == "EntraID" ? "AADKERB" : "None"
  security_principal_name         = length(var.securityPrincipalName) > 0 ? var.securityPrincipalName : "none"
  admin_user_name                 = var.identityServiceProvider == "EntraID" ? var.local_pass : var.domain_pass
  storage_to_domain_script_args   = "-DscPath ${var.dscAgentPackageLocation} -StorageAccountName ${azurerm_storage_account.storage.name} -StorageAccountRG ${azurerm_resource_group.myrg_shd.name} -StoragePurpose fslogix -DomainName ${var.domain} -IdentityServiceProvider ${var.identityServiceProvider} -AzureCloudEnvironment ${var.azure_cloud_name} -SubscriptionId ${data.azurerm_subscription.current.subscription_id} -AdminUserName ${local.admin_user_name} -CustomOuPath ${var.ou_path} -OUName ${var.ou_path} -ShareName ${azurerm_storage_share.FSShare.name} -ClientId ${var.ARM_CLIENT_ID} -SecurityPrincipalName '${local.security_principal_name}' -StorageAccountFqdn ${azurerm_private_dns_a_record.dnszone_st.name}"
}