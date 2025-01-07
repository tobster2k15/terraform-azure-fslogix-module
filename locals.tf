locals {
  rg_name_shd        = "rg-${var.usecase}-shd-001"
  st_name            = "st${var.usecase}vdi${var.environment}001"
  st_share_name      = "share${var.usecase}fslogix01"
  nic_name           = "nic-${var.usecase}-shd-001"
  pep_name           = "pep-${var.usecase}-shd-${var.region}-001"
  psc_name           = "psc-${var.usecase}-${var.environment}-${var.region}-001"
}

#### Experimental ####

locals {
  varStorageToDomainScriptArgs = "-DscPath ${var.dscAgentPackageLocation} -StorageAccountName ${var.storageAccountName} -StorageAccountRG ${var.storageObjectsRgName} -StoragePurpose ${var.storagePurpose} -DomainName ${var.identityDomainName} -IdentityServiceProvider ${var.identityServiceProvider} -AzureCloudEnvironment ${var.varAzureCloudName} -SubscriptionId ${var.workloadSubsId} -AdminUserName ${var.varAdminUserName} -CustomOuPath ${var.storageCustomOuPath} -OUName ${var.ouStgPath} -ShareName ${var.fileShareName} -ClientId ${var.managedIdentityClientId} -SecurityPrincipalName \"${var.varSecurityPrincipalName}\" -StorageAccountFqdn ${var.storageAccountFqdn}"
}