# data "template_file" "st_join" {
#   template = file("${path.root}/scripts/Configuration.ps1")
#   vars = {
#     StorageAccountName = "${local.st_name}"
#     StorageAccountRG   = "${azurerm_resource_group.myrg_shd.name}"
#     ClientId           = "${var.ARM_CLIENT_ID}"
#     # SecurityPrinicipalName  = "${data.azuread_group.avd_group_prd.display_name.each.value}"
#     SubscriptionId          = "${var.ARM_SUBSCRIPTION_ID}"
#     ShareName               = "fslogix"
#     CustomOuPath            = "${var.st_ou_path}"
#     IdentityServiceProvider = "${var.identity_provider}"
#     DomainName              = "${var.domain}"
#     OUName                  = "${var.st_ou_path}"
#     StoragePurpose          = "fslogix"
#     StorageAccountFqdn      = "${local.st_name}"
#     DomainAccountType       = "ComputerAccount"
#     IdentityServiceProvider = "ADDS"
#     StorageAccountFqdn      = "${azurerm_private_dns_a_record.dnszone_st.name}"
#     AdminUserName           = "${var.domain_user}"
#     AdminUserPassword       = "${var.domain_pass}"
#   }
# }

data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azuread_group" "fslogix_group_prd" {
  for_each         = toset(var.st_access)
  display_name     = each.value
  security_enabled = true
}

data "azuread_group" "fslogix_group_adm" {
  for_each         = toset(var.st_admins)
  display_name     = each.value
  security_enabled = true
}

data "azurerm_role_definition" "storage_role_adm" {
  name = "Storage File Data SMB Share Elevated Contributor"
}