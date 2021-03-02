
# Resource group
variable "resource_group_name" {
  description = "Aks resource group"
  type        = string
}

variable "location" {
  description = "Location where the resources will be created"
  type        = string
}

# Virtual machine
variable "vm_number" {
  description = "Number of virtual machine"
  type        = number
}

# Tags
variable "owner" {
  description = "Tag owner"
  type        = string
}

variable "project" {
  description = "Tag project"
  type        = string
}

variable "environment" {
  description = "Tag environment"
  type        = string
}
