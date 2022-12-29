resource "google_compute_global_address" "redis_private_ip" {
  name          = "address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.redis_private_ip.name]
}

resource "google_redis_instance" "redis" {
  depends_on = [google_service_networking_connection.private_service_connection]

  name               = "${var.project_name}-redis"
  display_name       = "Redis instance for the Hands-on"
  redis_version      = "REDIS_4_0"
  tier               = "BASIC"
  memory_size_gb     = 1
  auth_enabled       = true
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  authorized_network = google_compute_network.vpc.id
}