# 1. Public IP Address
resource "google_compute_global_address" "ingress_ip" {
  name = "sela-ingress-ip"
}

# 2. Cloud Armor Policy (WAF)
resource "google_compute_security_policy" "waf_policy" {
  name = "sela-waf-policy"
  
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow"
  }
}
