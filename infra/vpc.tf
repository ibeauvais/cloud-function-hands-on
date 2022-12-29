resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  description             = "Regional project VPC"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.project_name}-private-subnet"
  description   = "Public subnet"
  stack_type    = "IPV4_ONLY"
  ip_cidr_range = var.public_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${var.project_name}-private-subnet"
  description              = "Private subnet"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true
  ip_cidr_range            = var.public_cidr
  region                   = var.gcp_region
  network                  = google_compute_network.vpc.id
}
