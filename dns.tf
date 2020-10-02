resource "aws_route53_record" "alias" {
  count = var.parent_blocks.subdomain == "" ? 0 : 1

  zone_id = local.subdomain_zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
    evaluate_target_health = false
  }
}