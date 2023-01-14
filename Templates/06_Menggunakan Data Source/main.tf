provider "google" {
    #memberi tahu google cloud untuk terhubung ke project yang kita buat
    project = "raplima-labs"
    region = "asia-southeast2"
}

##membuat subnet baru menggunakan network yang sudah ada
##menggunakan data source untuk mengambil nilai ID network yang digunakan oleh project infrastruktur kita
data "google_compute_network" "existing_default_network"{
    name = "default"
}

resource "google_compute_subnetwork" "dev-subnet-02"{
    name = "dev-subnet-02"
    ip_cidr_range = "10.110.0.0/16"
    network = data.google_compute_network.existing_default_network.id
    region = "asia-southeast2"
}