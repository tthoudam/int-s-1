variable "gke_version" {
  description = "The GKE version"
}
variable "environment" {
  description = "GKE Environment"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "location" {
  description = "GCP Location"
}

variable "machine_type" {
  default     = "n2-standard-4"
  description = "The machine type"
}