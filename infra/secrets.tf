resource "google_secret_manager_secret" "secret-store" {
  secret_id = "${var.project_name}-redis-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "redis-auth-string" {
  secret      = google_secret_manager_secret.secret-store.id
  secret_data = google_redis_instance.redis.auth_string
}

resource "google_secret_manager_secret" "host-store" {
  secret_id = "${var.project_name}-redis-host"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "redis-host" {
  secret      = google_secret_manager_secret.host-store.id
  secret_data = google_redis_instance.redis.host
}
