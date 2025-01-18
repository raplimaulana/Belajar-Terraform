provider "google" {
    #memberi tahu google cloud untuk terhubung ke project yang kita buat
    project = "raplima-labs"
    region = "asia-southeast2"
}

resource "google_compute_network" "development-network" {                                              
    name = "development-network"                                                                       
    auto_create_subnetworks = false                                                                 
}

#mengupdate resource subnet "dev_subnet_01"
resource "google_compute_subnetwork" "dev-subnet-01"{
    name = "dev-subnet-01"
    ip_cidr_range = "10.100.0.0/16"
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
    secondary_ip_range {
        range_name = "secondary-range-01"
        ip_cidr_range = "192.168.10.0/24"
    }
}

#menghapus rs