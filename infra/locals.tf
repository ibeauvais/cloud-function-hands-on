locals {
  enabled_services = toset([
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "redis.googleapis.com"
  ])
}
