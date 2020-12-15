variable "count" {
  description = "Number of dns records to be created"
}

variable "animal_names" {
  description = "List of animal names the domains to be created from"
  default     = []
}

variable "r53_zone_id" {
  description = "AWS Route53 Zone ID for the hosted domain we're using"
}

variable "ip_addresses" {
  description = "List of IP addresses to assign to animal names"
  default     = []
}
