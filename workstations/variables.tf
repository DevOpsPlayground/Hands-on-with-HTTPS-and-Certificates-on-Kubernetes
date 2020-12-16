variable "num_attendees" {
  default = 2
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
  default = "Password1234!"
}