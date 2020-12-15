variable "animal_names" {
  description = "List of animal names to assign to the instances"
  default     = []
}

variable "vpc_id" {
  description = "VPC to put the instances into"
}

variable "subnet_ids" {
  default     = []
  description = "List of Subnet IDs to put the instances into"
}

variable "default_security_group_id" {
  description = "ID of default security group in the vpc"
}

variable "count" {
  description = "Number of Linux EC2 instances to create"
  default     = 1
}

variable "instance_type" {
  default     = "t2.micro"
  description = "EC2 Instance type to use for the training instances"
}

variable "ssh_key_name" {
  default     = ""
  description = "SSH key name to be used for the instances. If not specified it'll be generated"
}

variable "stack_name" {
  description = "Prefix for the instance names"
}

variable "ssh_user" {
  description = "Limited SSH user account"
  default     = "playground"
}

variable "ssh_password" {
  default     = "PeoplesComputers1"
  description = "Limited SSH user's password"
}

variable "custom_install_scripts" {
  description = "List of rendered Bash scripts to customise your VMs with. Should be a list in case we deploy multiple instances"
  default     = []
}

# variable "instance_profile" {}