output "fqdns" {
  value       = "${aws_route53_record.playground.*.fqdn}"
  description = "List of Fully Qualified Domain Names for the Playground attendees."
}
