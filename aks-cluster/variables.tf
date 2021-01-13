variable "app_password" {
  description = "Azure Kubernetes Service Cluster - Service Principal password"
  sensitive   = true
}

variable "environment" {
  default = "dev"
}

variable "location" {
  description = "Azure location"
  default     = "West US 2"
}

variable "num_nodes" {
  description = "Number of nodes for Kubernetes cluster"
  default     = "1"
}

variable "vm_size" {
  description = "The size of the VMs that make up the cluster nodes"
  default     = "Standard_D2_v2"
}