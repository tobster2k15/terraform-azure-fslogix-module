resource "azurerm_resource_group" "myrg_shd" {
  name     = local.rg_name_shd
  location = var.region
  tags     = var.tags
}

# resource "azurerm_windows_virtual_machine" "temp_vm_for_st_join" {
#   name                  = "vmstjoin001"
#   resource_group_name   = azurerm_resource_group.myrg_shd.name
#   location              = azurerm_resource_group.myrg_shd.location
#   network_interface_ids = azurerm_network_interface.temp_nic.*.id
#   admin_username        = var.local_admin
#   admin_password        = var.local_pass
#   size                  = "Standard_D4s_v4"
#   tags = merge(var.tags, {
#     Automation = "Temp Deploy for Storage Account Domain Join"
#   })
#   os_disk {
#     name                 = "osdisk"
#     caching              = "ReadWrite"
#     storage_account_type = var.os_disk_type
#   }
#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2022-Datacenter"
#     version   = "latest"
#   }
#   depends_on = [
#     azurerm_network_interface.temp_nic
#   ]
# }

# resource "azurerm_network_interface" "temp_nic" {
#   name                = "${local.nic_name}-temp"
#   resource_group_name = azurerm_resource_group.myrg_shd.name
#   location            = azurerm_resource_group.myrg_shd.location
#   tags                = var.tags
#   ip_configuration {
#     name                          = "testconfiguration1"
#     subnet_id                     = var.subnet_id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_virtual_machine_extension" "domain_join_vm" {
#   name                       = "join-domain"
#   virtual_machine_id         = azurerm_windows_virtual_machine.temp_vm_for_st_join.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "JsonADDomainExtension"
#   type_handler_version       = "1.3"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#     {
#       "Name": "${var.domain}",
#       "OUPath": "${var.ou_path}",
#       "User": "${var.domain_user}@${var.domain}",
#       "Restart": "true",
#       "Options": "3"
#     }
# SETTINGS
#   protected_settings         = <<PROTECTED_SETTINGS
#     {
#       "Password": "${var.domain_pass}"
#     }
# PROTECTED_SETTINGS
#   lifecycle {
#     ignore_changes = [settings, protected_settings, tags]
#   }
#   depends_on = [
#     azurerm_windows_virtual_machine.temp_vm_for_st_join
#   ]
# }

# resource "azurerm_virtual_machine_extension" "st_domain_join" {
#   name                 = "storage_account_domain_join"
#   virtual_machine_id   = azurerm_windows_virtual_machine.temp_vm_for_st_join.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   settings = <<SETTINGS
#   {
#     "fileUris": ["${var.baseScriptUri}"],
#     "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File \"${path.module}/scripts/Configuration.ps1\" ${local.storage_to_domain_script_args} -AdminUserPassword ${var.domain_pass} -verbose"
#   }
#   SETTINGS
#     depends_on = [
#     azurerm_virtual_machine_extension.domain_join_vm,
#     azurerm_storage_share.FSShare
#   ]
# }


# resource "azurerm_virtual_machine_extension" "st_domain_join" {
#   name                 = "AzureFilesDomainJoin"
#   virtual_machine_id   = azurerm_windows_virtual_machine.temp_vm_for_st_join.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"

#   settings = jsonencode({})
#    # fileUris: array(baseScriptUri)
#   protected_settings = jsonencode({
#     "fileUris"         : [var.baseScriptUri],
#     "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File "(${path.module}/scripts/Configuration.ps1)" ${local.storage_to_domain_script_args} -AdminUserPassword ${var.domain_pass} -verbose"
#   })

#   depends_on = [
#     azurerm_virtual_machine_extension.domain_join_vm,
#     azurerm_storage_share.FSShare
#   ]
# }
    # -ExecutionPolicy Unrestricted -File /scripts/Configuration.ps1\" ${local.storage_to_domain_script_args} -AdminUserPassword ${var.domain_pass} -verbose
# "commandToExecute": 'powershell -ExecutionPolicy Unrestricted -File "$${path.module(scripts/Configuration.ps1)}" ${local.storage_to_domain_script_args} -AdminUserPassword ${var.domain_pass} -verbose'

# resource "null_resource" "join_st_account" {
#   provisioner "remote-exec" {
#     connection {
#       type        = "winrm"
#       host        = azurerm_network_interface.temp_nic.private_ip_address
#       user        = var.local_admin
#       password    = var.local_pass
#       timeout     = "30m"
#       insecure    = true
#     }
#     inline = [
#       "powershell Get-Date"
#     ]
#   }
#   depends_on = [
#     azurerm_virtual_machine_extension.domain_join_vm,
#     azurerm_storage_share.FSShare
#   ]
# }

resource "null_resource" "domain_join_from_local_machine" {

  provisioner "local-exec" {
    command = <<EOF
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
    Invoke-WebRequest "https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.3.2/AzFilesHybrid.zip" -OutFile "${var.download_path}"
    Expand-Archive -Path "${var.download_path}" -DestinationPath "${var.destination_path}"
    $SecurePassword = ConvertTo-SecureString -String '${var.ARM_CLIENT_SECRET}' -AsPlainText -Force
    $TenantId = '${var.ARM_TENANT_ID}'
    $ApplicationId = '${var.ARM_CLIENT_ID}'
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
    $SubscriptionId = '${var.ARM_SUBSCRIPTION_ID}'
    Select-AzSubscription -SubscriptionId $SubscriptionId
    EOF
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    command = <<EOF
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
    cd "${var.destination_path}"
    .\CopyToPSPath.ps1
    Import-Module -Name AzFilesHybrid -Force
    Import-Module -Name Az.Network -Force
    Import-Module -Name Az.Storage -Force
    Import-Module -Name Az.Resources -Force
    $ResourceGroupName = "${azurerm_resource_group.myrg_shd.name}"
    $StorageAccountName = "${azurerm_storage_account.storage.name}"
    $SamAccountName = "${azurerm_storage_account.storage.name}"
    $DomainAccountType = "ComputerAccount"
    $OuDistinguishedName = "${var.avd_ou_path}"
    Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -SamAccountName $SamAccountName `
        -DomainAccountType $DomainAccountType `
        -OrganizationalUnitDistinguishedName $OuDistinguishedName
    EOF  
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [azurerm_storage_account.storage]
}


#### Delete Temp VM via Azure CLI ###
# resource "null_resource" "install_az_cli" {
#   provisioner "local-exec" {
#     command = <<EOF
#      terraform --version
#     EOF
#   }
#   depends_on = [
#     azurerm_virtual_machine_extension.domain_join_st,
#   ]
# }
resource "azurerm_private_dns_zone" "dnszone_st" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.vnet_rg == null ? azurerm_resource_group.myrg_shd.name : var.vnet_rg
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "dnszone_st" {
  name                = var.st_name == null ? "${local.st_name}" : "${var.st_name}"
  zone_name           = azurerm_private_dns_zone.dnszone_st.name
  resource_group_name = var.vnet_rg == null ? azurerm_resource_group.myrg_shd.name : var.vnet_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint_st.private_service_connection.0.private_ip_address]
  tags                = var.tags
}

resource "azurerm_private_endpoint" "endpoint_st" {
  name                = "${local.pep_name}-st"
  location            = azurerm_resource_group.myrg_shd.location
  resource_group_name = var.vnet_rg == null ? azurerm_resource_group.myrg_shd.name : var.vnet_rg
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = local.psc_name
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name                 = "dns-file-${var.business_unit}"
    private_dns_zone_ids = azurerm_private_dns_zone.dnszone_st[*].id
  }
}

# Deny Traffic from Public Networks with white list exceptions
resource "azurerm_storage_account_network_rules" "stfw" {
  storage_account_id = azurerm_storage_account.storage.id
  default_action     = var.public_access == false ? "Deny" : "Allow"
  bypass             = ["AzureServices"]
  depends_on = [
    azurerm_private_endpoint.endpoint_st
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "filelink" {
  name                  = "azfilelink-${var.business_unit}"
  resource_group_name   = var.vnet_rg == null ? azurerm_resource_group.myrg_shd.name : var.vnet_rg
  private_dns_zone_name = azurerm_private_dns_zone.dnszone_st.name
  virtual_network_id    = var.vnet_id

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_storage_account" "storage" {
  name                             = var.st_name == null ? local.st_name : var.st_name #"${lower(random_string.random.result)}-st"
  resource_group_name              = azurerm_resource_group.myrg_shd.name
  location                         = azurerm_resource_group.myrg_shd.location
  min_tls_version                  = "TLS1_2"
  account_kind                     = var.st_account_kind
  account_tier                     = var.st_account_tier
  account_replication_type         = var.st_replication
  public_network_access_enabled    = var.public_access #Needs to be changed later on (portal), otherwise share can't be created
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
#   enable_https_traffic_only        = true
  large_file_share_enabled         = true
  tags                             = var.tags
  identity {
    type = "SystemAssigned"
  }
  ## lifecylce block needed for if your storage account already is domain joined ##
#   lifecycle {
#     ignore_changes = [azure_files_authentication]
#   }
}

resource "azurerm_storage_share" "FSShare" {
  name             = "fslogix"
  quota            = var.share_size
  # enabled_protocol = var.share_protocol
  storage_account_id = azurerm_storage_account.storage.id
}

resource "azurerm_storage_share" "additional_shares" {
  count                = var.additional_shares != null ? var.additional_shares : 0
  name                 = "share${format("%03d", count.index + 1)}"
  quota                = var.share_size
  enabled_protocol     = var.share_protocol
  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]
}

resource "azurerm_role_assignment" "af_role_prd" {
 for_each            = toset(var.st_access)
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = data.azuread_group.fslogix_group_prd[each.value].object_id
}
