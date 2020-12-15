resource "aws_route53_record" "playground" {
  count   = "${var.count}"
  zone_id = "${var.r53_zone_id}"
  name    = "${lower(element(var.animal_names,count.index))}"
  type    = "A"
  ttl     = "60"
  records = ["${element(var.ip_addresses,count.index)}"]
}
