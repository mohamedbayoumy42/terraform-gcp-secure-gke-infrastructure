output "cluster_connect_command" {
  value = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "load_balancer_ip" {
  value = google_compute_global_address.ingress_ip.address
}

output "waf_policy_name" {
  value = google_compute_security_policy.waf_policy.name
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/sela-repo"
}