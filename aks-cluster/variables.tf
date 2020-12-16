variable "app_password" {
  description = "Azure Kubernetes Service Cluster service principal password"
}

variable "environment" {
  default = "dev"
}

variable "location" {
  description = "Azure location"
  default     = "West US 2"
}

variable "label" {
  default = "vault"
}