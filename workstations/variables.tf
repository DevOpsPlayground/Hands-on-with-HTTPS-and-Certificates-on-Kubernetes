variable "num_attendees" {
  default     = 1
  description = "Number of people attending DevOps Playground"
}

variable "prefix" {
  default = "dpg"
}

variable "environment" {
  default = "DevOps Playground"
}

variable "location" {
  description = "Azure location"
  default     = "West US 2"
}

variable "workstation_username" {
  default = "dpg-user"
}

variable "workstation_password" {
  default   = "Password1234!"
  sensitive = true
}

variable "vm_size" {
  description = "The size of the VMs for workstations"
  default     = "Standard_DS1_v2"
}

variable "app_password" {
  default   = "password"
  sensitive = true
}