variable "st_ou_path" {
  type        = string
  description = "The OU path of the storage account."
  default     = ""
}

variable "region" {
  type        = string
  description = "The Azure region where the resources will be deployed."
  validation {
    condition = anytrue([
      lower(var.region) == "northcentralus",
      lower(var.region) == "southcentralus",
      lower(var.region) == "westcentral",
      lower(var.region) == "centralus",
      lower(var.region) == "westus",
      lower(var.region) == "eastus",
      lower(var.region) == "northeurope",
      lower(var.region) == "westeurope",
      lower(var.region) == "norwayeast",
      lower(var.region) == "norwaywest",
      lower(var.region) == "swedencentral",
      lower(var.region) == "switzerlandnorth",
      lower(var.region) == "uksouth",
      lower(var.region) == "ukwest"
    ])
    error_message = "Please select one of the approved regions: northcentralus, southcentralus, westcentral, centralus, westus, eastus, northeurope, westeurope, norwayeast, norwaywest, swedencentral, switzerlandnorth, uksouth, or ukwest."
  }
}

variable "region_prefix_map" {
  type        = map(any)
  description = "A list of prefix strings to concat in locals. Can be replaced or appended."
  default = {
    northcentralus   = "ncu"
    southcentralus   = "scu"
    westcentral      = "wcu"
    centralus        = "usc"
    westus           = "usw"
    eastus           = "use"
    northeurope      = "eun"
    westeurope       = "euw"
    norwayeast       = "nwe"
    norwaywest       = "nwn"
    swedencentral    = "swc"
    switzerlandnorth = "sln"
    uksouth          = "uks"
    ukwest           = "ukw"
  }
}

variable "environment" {
  type        = string
  description = "The environment of the pool."
  default     = "prd"
}

variable "business_unit" {
  description = "Business unit"
  type        = string
  default     = ""
}

variable "usecase" {
  description = "Usecase"
  type        = string
  default     = "fslogix"
}

variable "share_size" {
  type        = number
  description = "The size of the share."
  default     = 100
}

variable "ARM_CLIENT_ID" {
  type        = string
  description = "Client ID"
  default     = null
}

variable "ARM_TENANT_ID" {
  type        = string
  description = "Tenant ID"
  default     = null
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "Client Secret"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet."
  default     = ""
}

variable "domain" {
  type        = string
  description = "Domain Suffix for ADDS. Example: contoso.com"
  default     = ""
}

variable "domain_user" {
  type        = string
  description = "The identity that will join the VM to the domain. Please use the UPN Prefix."
  default     = ""
  sensitive   = true
}

variable "domain_pass" {
  type        = string
  description = "Password for var.domain_user"
  sensitive   = true
  default     = ""
}

variable "local_admin" {
  type        = string
  description = "The local administrator username."
  default     = ""
}
variable "local_pass" {
  type        = string
  description = "The local administrator password."
  default     = ""
  sensitive   = true
}

variable "tags" {
  type        = map(any)
  description = "A map of tags to add to all resources."
  default     = { "DeployedBy" = "Terraform" }
}

variable "vnet_rg" {
  type        = string
  description = "The resource group of the virtual network."
  default     = ""
}

variable "st_name" {
  type        = string
  description = "Optional Name of Storage Account, if null a predefinied name will be generated."
  default     = null
}

variable "additional_shares" {
  type        = number
  description = "Additional shares to create."
  default     = 0
}

variable "share_protocol" {
  type        = string
  description = "The protocol of the share."
  default     = "SMB"
}

variable "st_account_kind" {
  type        = string
  description = "The kind of storage account."
  default     = "StorageV2"
}

variable "st_account_tier" {
  type        = string
  description = "The tier of the storage account."
  default     = "Standard"
}

variable "st_replication" {
  type        = string
  description = "The replication of the storage account."
  default     = "LRS"
}

variable "public_access" {
    type        = bool
    description = "Enable public access to the storage account."
    default     = false
}

variable "vnet_id" {
  type        = string
  description = "The ID of the virtual network."
  default     = ""
}

variable "st_access" {
  type        = list(string)
  description = "Assign role to storage account for production."
  default     = null
}

variable "os_disk_type" {
  type        = string
  description = "The type of the OS disk."
  default     = "Standard_LRS"
}

variable "ou_path" {
  type        = string
  description = "The OU path of the storage account."
  default     = ""
}

#### Experimental ####
variable "dscAgentPackageLocation" {
    type        = string
    description = "The location of the DSC agent package."
    default     = "./scripts/DSCStorageScripts.zip"
}

variable "azure_cloud_name" {
    type    = string
    default = "AzurePublicCloud"
}
variable "identityServiceProvider" {
    type    = string
    default = "ADDS"
}

variable "baseScriptUri" {
    type        = string
    description = "The base URI of the script."
    default     = "./scripts/Configuration.ps1"
}
variable "file" {
    type        = string
    description = "The file to execute."
    default     = "./scripts/Script-DomainJoinStorage.ps1"
}
# variable "scriptArguments" {}

variable "securityPrincipalName" {
    type        = string
    description = "The security principal name."
    default     = ""
}

variable "download_path" {
    type        = string
    description = "The local download path for AzFilesHybrid.zip your pc."
    default     = "C:\\temp"
}

variable "destionation_path" {
    type        = string
    description = "The path where your AzFilesHybrid.zip will be extracted on your local machine."
    default     = "C:\\temp"
}