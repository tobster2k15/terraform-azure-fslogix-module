<#
	.SYNOPSIS
		Domain Join Storage Account

	.DESCRIPTION
		In case of AD_DS scenario, domain join storage account as a machine on the domain.
#>
# param(
# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $StorageAccountName,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $StorageAccountRG,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $ClientId,

# 	[Parameter(Mandatory = $false)]
# 	[ValidateNotNullOrEmpty()]
# 	[string]$SecurityPrincipalName,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $SubscriptionId,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $ShareName,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $CustomOuPath,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $IdentityServiceProvider = "ADDS",

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $DomainName,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $OUName,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $StoragePurpose = "fslogix",

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $StorageAccountFqdn,

# 	[Parameter(Mandatory = $true)]
# 	[ValidateNotNullOrEmpty()]
# 	[string] $AzureCloudEnvironment = "AzureCloud"
# )
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Restart-Computer -Force
$modules = @{
    PowershellGet = '2.8.5.201'
    "Az.Accounts" = '4.0.1'
    "Az.Storage" = '7.5.0'
    "Az.Network" = '7.12.0'
    "Az.Resources" = '7.7.0'
}
$modules.GetEnumerator() | ForEach-Object {
    Install-Module -Name $_.Name -MinimumVersion $_.Value -Force
}

Restart-Computer -Force

Import-Module Az.Accounts
Start-Sleep -Seconds 5
Import-Module Az.Storage
Start-Sleep -Seconds 5
Import-Module Az.Network
Start-Sleep -Seconds 5
Import-Module Az.Resources
Start-Sleep -Seconds 5

$AzFilesZipLocation = Get-ChildItem -Path $PSScriptRoot -Filter "AzFilesHybrid*.zip"
	Expand-Archive $AzFilesZipLocation.FullName -DestinationPath $PSScriptRoot -Force
	Set-Location $PSScriptRoot
	$AzFilesHybridPath = (Join-Path $PSScriptRoot "CopyToPSPath.ps1")
	& $AzFilesHybridPath

# $modules = @{
#     PowershellGet = '2.8.5.201'
#     "Az.Accounts" = '4.0.1'
#     "Az.Storage" = '7.5.0'
#     "Az.Network" = '7.12.0'
#     "Az.Resources" = '7.7.0'
# }

# $modules.GetEnumerator() | ForEach-Object {
#     Install-Module -Name $_.Name -MinimumVersion $_.Value -Force
# }
