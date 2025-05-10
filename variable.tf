variable "gke_version" {
  description = "The GKE version"
}
variable "environment" {
  description = "GKE Environment"
}
variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "machine_type" {
  default     = "n1-standard-1"
  description = "The machine type"
}