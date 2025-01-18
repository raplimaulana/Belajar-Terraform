provider "google" {
    #memberi tahu google cloud untuk terhubung ke project yang kita buat
    project = "raplima-labs"
    region = "asia-southeast2"
} 

#membuat variable tipe data list
variable "subnet-ip-cidr-range"{
    description = "subnet untuk dev environment"
    #default = "10.150.0.0/16"
    type = list(string)
}

#membuat variable tipe data map
variable "subnet-ip-cidr-range"{
    description = "subnet untuk dev environment"
    #default = "10.150.0.0/16"
    type = list(object({name = string, range = string}))
}

resource "google_compute_network" "development-network" {                                              
    name = "development-network"                                                                     
    auto_create_subnetworks = false                                                                    #jika true, google akan memberi IP range tertentu (subnet). Jika false, kita akan membuat subnet secara manual
}

#mengambil variabel tipe data list
resource "google_compute_subnetwork" "dev-subnet-01"{
    name = "dev-subnet-01"
    ip_cidr_range = var.subnet-ip-cidr-range[0]
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
}

resource "google_compute_subnetwork" "dev-subnet-02"{
    name = "dev-subnet-02"
    ip_cidr_range = var.subnet-ip-cidr-range[1]
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
}

#mengambil variabel tipe data object
resource "google_compute_subnetwork" "dev-subnet-01"{
    name = var.subnet-ip-cidr-range[0].name
    ip_cidr_range = var.subnet-ip-cidr-range[0].range
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
}

resource "google_compute_subnetwork" "dev-subnet-02"{
    name = var.subnet-ip-cidr-range[1].name
    ip_cidr_range = var.subnet-ip-cidr-range[1].name
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
}