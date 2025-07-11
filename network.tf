variable "project_id" {
  description = "project id"
}

variable "ip_cidr_range" {
  description = "The VPC cidr block"
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-gke-vpc-${var.environment}"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "cluster_subnet" {
  name          = "${var.project_id}-subnet-${var.environment}"
  region        = var.location
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.ip_cidr_range
}
