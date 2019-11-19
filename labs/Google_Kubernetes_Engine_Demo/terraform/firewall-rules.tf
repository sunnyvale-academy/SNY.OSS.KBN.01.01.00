resource "google_compute_firewall" "allow-mysql-nodeport" {
    name    = "allow-mysql-nodeport"
    allow {
        protocol = "tcp"
        ports    = ["30100"]
    }    
    network = "default"
    source_ranges = [
        "${var.onprem-net-cdir}"
    ] 
}

resource "google_compute_firewall" "allow-scairus-configserver-nodeport" {
    name    = "allow-scairus-configserver-nodeport"
    allow {
        protocol = "tcp"
        ports    = ["30101"]
    }    
    network = "default"
    source_ranges = [
        "${var.onprem-net-cdir}"
    ] 
}

resource "google_compute_firewall" "allow-service-registry-nodeport" {
    name    = "allow-service-registry-nodeport"
    allow {
        protocol = "tcp"
        ports    = ["30102"]
    }    
    network = "default"
    source_ranges = [
        "${var.onprem-net-cdir}"
    ] 
}


resource "google_compute_firewall" "allow-service-gateway-nodeport" {
    name    = "allow-service-gateway-nodeport"
    allow {
        protocol = "tcp"
        ports    = ["30103"]
    }    
    network = "default"
    source_ranges = [
        "${var.onprem-net-cdir}"
    ] 
}

resource "google_compute_firewall" "allow-service-frontend-nodeport" {
    name    = "allow-service-frontend-nodeport"
    allow {
        protocol = "tcp"
        ports    = ["30104"]
    }    
    network = "default"
    source_ranges = [
        "${var.onprem-net-cdir}"
    ] 
}