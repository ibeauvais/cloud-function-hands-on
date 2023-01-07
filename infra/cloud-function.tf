locals {
  cloud_function_name                          = "redis-function"
  cloud_function_source_code_bucket            = "${var.GCP_PROJECT_ID}-${local.cloud_function_name}-source"
  cloud_function_source_code_archive_file_name = "${local.cloud_function_name}.zip"
}

resource "google_storage_bucket" "function_source_code" {
  name          = local.cloud_function_source_code_bucket
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true
}

data "archive_file" "cloud_function_source_code" {
  type        = "zip"
  source_dir  = "redis-function"
  output_path = ".terraform/tmp/${local.cloud_function_source_code_archive_file_name}"
}

resource "google_storage_bucket_object" "cloud_function_source_code_archive" {
  name                = "${data.archive_file.cloud_function_source_code.output_md5}-${local.cloud_function_source_code_archive_file_name}"
  bucket              = google_storage_bucket.function_source_code.name
  source              = data.archive_file.cloud_function_source_code.output_path
  content_disposition = "attachment"
  content_encoding    = "gzip"
  content_type        = "application/zip"
}

resource "google_cloudfunctions_function" "cloud_function" {
  name                = local.cloud_function_name
  runtime             = "python310"
  available_memory_mb = "256"
  entry_point         = "handle_request"

  environment_variables = {
    REDISPORT = "6379"
  }
  trigger_http = true

  secret_environment_variables {
    key    = "REDISHOST"
    secret = google_secret_manager_secret.host-store.secret_id
    version = element(
      split("/", google_secret_manager_secret_version.redis-host.name),
      5
    )
  }

  secret_environment_variables {
    key    = "REDIS_PASSWORD"
    secret = google_secret_manager_secret.secret-store.secret_id
    version = element(
      split("/", google_secret_manager_secret_version.redis-auth-string.name),
      5
    )
  }
  vpc_connector         = google_vpc_access_connector.gcfn_connector.name
  source_archive_bucket = google_storage_bucket_object.cloud_function_source_code_archive.bucket
  source_archive_object = google_storage_bucket_object.cloud_function_source_code_archive.name

  timeout = 540
}
