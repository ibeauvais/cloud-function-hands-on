resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  description             = "Regional project VPC"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.project_name}-subnet"
  description              = "Public subnet"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true
  ip_cidr_range            = var.cidr
  region                   = var.gcp_region
  network                  = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "vpc_connector" {
  name                     = "${var.project_name}-connectors"
  description              = "VPC access connectors subnet"
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true
  ip_cidr_range            = var.connector_cidr
  region                   = var.gcp_region
  network                  = google_compute_network.vpc.id
}

resource "google_vpc_access_connector" "gcfn_connector" {
  name         = "${var.project_name}-connectors"
  machine_type = "e2-standard-4"

  subnet {
    name = google_compute_subnetwork.vpc_connector.name
  }
}