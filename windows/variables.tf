variable "name" {
  description = "Hostname for the VM."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID for a subnet."
  type        = string
}

variable "asg_id" {
  description = "Optional resource ID for an application security group"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name for the resource group. Required."
  type        = string
  default     = "arc-onprem-servers"
}

//=============================================================

variable "size" {
  description = "Azure virtual machine size."
  default     = "Standard_D2s_v3"
}

variable "location" {
  description = "Azure region for the on prem VM."
  default     = "UK South"
}

variable "tags" {
  description = "Map of tags for the resources created by this module. Use arc.tags for the Arc Connected Server tags if onboarding."
  type        = map(string)
  default     = {}
}

//=============================================================

variable "admin_username" {
  default = "arcadmin"
}

variable "admin_password" {
  description = "Administrator password."
  type        = string
  sensitive   = true
}

variable "dns_label" {
  description = "Shortname for the public IP's FQDN."
  type        = string
  default     = null
}
