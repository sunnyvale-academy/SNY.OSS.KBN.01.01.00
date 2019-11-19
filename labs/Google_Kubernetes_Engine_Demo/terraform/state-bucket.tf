resource "google_storage_bucket" "trfstate" {
  force_destroy = true
  name     = "${var.backend_bucket_name}"

  lifecycle {
            prevent_destroy = true
    }
}