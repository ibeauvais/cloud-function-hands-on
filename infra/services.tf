locals {

  enabled_services = toset([
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
  ])
}

resource "google_project_service" "service_enabled" {
  for_each = local.enabled_services
  service  = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy         = true
  disable_dependent_services = false
}
