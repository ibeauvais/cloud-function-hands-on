provider "google" {
  project = var.GCP_PROJECT_ID
  region  = "europe-west1"
}

terraform {

  backend "gcs" {
    prefix  = "base_infra"
  }

}
