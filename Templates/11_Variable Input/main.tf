provider "google" {
    #memberi tahu google cloud untuk terhubung ke project yang kita buat
    project = "raplima-labs"
    region = "asia-southeast2"
} 

variable "subnet-ip-cidr-range"{
    description = "subnet untuk dev environment"
    default = "10.150.0.0/16"
}

variable "subnet-secondary-ip-cidr-range"{
    description = "secondary IP range untuk dev environment"
    default = "192.168.10.0/24"                                                                        #jika tidak diisi value-nya, secara default variable akan diisi dengan input 192.168.10.0/124
}

variable "network-name"{
    description = "nama network kita"
}

variable "subnet-01-name"{
    description = "nama subnet 01"
}

resource "google_compute_network" "development-network" {                                              
    name = var.network-name                                                                     
    auto_create_subnetworks = false                                                                    #jika true, google akan memberi IP range tertentu (subnet). Jika false, kita akan membuat subnet secara manual
}

resource "google_compute_subnetwork" "dev-subnet-01"{
    name = var.subnet-01-name
    ip_cidr_range = var.subnet-ip-cidr-range
    network = google_compute_network.development-network.id
    region = "asia-southeast2"
    secondary_ip_range {
        range_name = "secondary-range-01"
        ip_cidr_range = var.subnet-secondary-ip-cidr-range
    }
}

output "development-network-id"{
    value = google_compute_network.development-network.id
}
