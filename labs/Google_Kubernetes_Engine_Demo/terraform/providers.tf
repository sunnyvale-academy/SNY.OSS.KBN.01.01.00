provider "google" {
    credentials = "${file("${var.credentials}")}"
    project     = "${var.project_id}"
    region      = "${var.region}"
}

provider "google-beta" {
    credentials = "${file("${var.credentials}")}"
    project     = "${var.project_id}"
    region      = "${var.region}"
}