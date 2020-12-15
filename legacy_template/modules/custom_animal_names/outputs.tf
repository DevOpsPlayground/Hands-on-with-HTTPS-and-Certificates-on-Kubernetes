output "names" {
  value       = "${slice("${distinct(random_pet.master.*.id)}", 0, "${var.count}")}"
  description = "List of (hopefully) unique animal names to be used elsewhere"
}
