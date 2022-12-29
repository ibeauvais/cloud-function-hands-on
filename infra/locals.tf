locals {
  enabled_services = toset([
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "vpcaccess.googleapis.com"
  ])
}
