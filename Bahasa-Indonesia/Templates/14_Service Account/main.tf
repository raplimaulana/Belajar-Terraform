provider "google" {
    #memberi tahu google cloud untuk terhubung ke project yang kita buat
    project = "raplima-labs"
    region = "asia-southeast2"
    credentials = var.google-credentials
} 

variable "google-credentials" {
    description = "credential dari service account GCP saya"
  
}
