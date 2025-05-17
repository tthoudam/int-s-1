data "google_container_engine_versions" "gke_version" {
  location       = var.location
  version_prefix = var.gke_version
}

resource "google_container_cluster" "primary" {
  name                     = "${var.project_id}-gke-${var.environment}"
  project                  = var.project_id
  location                 = var.location
  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.cluster_subnet.name

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name     = google_container_cluster.primary.name
  location = var.location
  cluster  = google_container_cluster.primary.name

  version    = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "${var.project_id}-${var.environment}"
    }

    machine_type = var.machine_type
    tags         = ["gke-node", "${var.project_id}-gke", var.environment]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}