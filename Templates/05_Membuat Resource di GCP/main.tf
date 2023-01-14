provider "google" {
    #memberi tahu google cloud untuk terhubung ke project yang kita buat
    project = "raplima-labs"
    region = "asia-southeast2"
}

##membuat resource dengan menggunakan input "google_NAMA RESOURCE", "NAMA VARIABEL BEBAS" 
#membuat resource network yang disediakan oleh GCP dengan nama "development-network"
resource "google_compute_network" "development-network" {                                              
    name = "development-network"                                                                       #nama diisi dengan nama resource yang diberikan sebelumnya
    auto_create_subnetworks = false                                                                    #jika true, google akan memberi IP range tertentu (subnet). Jika false, kita akan membuat subnet secara manual
}

#membuat resource subnetwork yang disediakan oleh GCP dengan nama "dev_subnet_01"
resource "google_compute_subnetwork" "dev-subnet-01"{
    name = "dev-subnet-01"
    ip_cidr_range = "10.100.0.0/16"
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
}