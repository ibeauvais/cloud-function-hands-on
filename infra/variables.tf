variable "GCP_PROJECT_ID" {
  description = "GCP project ID"
  type = string
  default = ""
}

variable "gcp_region" {
  description = "GCP region"
  type = string
  default = "europe-west1"
}

variable "project_name" {
  description = "Project name"
  type = string
  default = "gcfn-handson"
}

variable "public_cidr" {
  description = "Subnet CIDR"
  type = string
  default = "10.1.0.0/16"
}

variable "private_cidr" {
  description = "Subnet CIDR"
  type = string
  default = "10.2.0.0/16"
}

