terraform {
  backend "gcs" {
    prefix = "base_infra"
    bucket = "cloud-function-hands-on-terraform-state"
  }
}
