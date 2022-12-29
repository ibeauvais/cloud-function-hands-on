resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  description             = "Regional project VPC"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.project_name}-private-subnet"
  description              = "Public subnet"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true
  ip_cidr_range            = var.cidr
  region                   = var.gcp_region
  network                  = google_compute_network.vpc.id
}
