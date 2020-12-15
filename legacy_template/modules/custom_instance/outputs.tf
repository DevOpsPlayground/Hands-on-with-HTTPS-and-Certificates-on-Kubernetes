output "ip_addresses" {
  value       = "${aws_instance.linux_instances.*.public_ip}"
  description = "List of IP addresses for the linux instances"
}
