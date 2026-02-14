provider "google" {
  project = var.project_id
  region  = var.region
}

# ---------------------------------------------------------
# 1. NETWORK & NAT
# ---------------------------------------------------------
resource "google_compute_network" "vpc" {
  name                    = "sela-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "sela-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.0.0.0/16"
  private_ip_google_access = true

  # GKE (Pods & Services)
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.1.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Cloud Router & NAT 
resource "google_compute_router" "router" {
  name    = "sela-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "sela-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall for GKE Health Checks
resource "google_compute_firewall" "allow_health_checks" {
  name          = "allow-gke-healthchecks"
  network       = google_compute_network.vpc.name
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["gke-node"]
}

# ---------------------------------------------------------
# 2. ARTIFACT REGISTRY
# ---------------------------------------------------------
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "sela-repo"
  description   = "Docker repository"
  format        = "DOCKER"
}

# ---------------------------------------------------------
# 3. GKE PRIVATE CLUSTER
# ---------------------------------------------------------
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  

  deletion_protection = false 

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  private_cluster_config {
    enable_private_nodes    = true   
    enable_private_endpoint = false  
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "sela-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "e2-medium"
    tags         = ["gke-node"] 
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
