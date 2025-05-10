provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

data "google_client_config" "default" {}

resource "google_service_account" "gcp_sa" {
  account_id   = "${var.project_id}-gcp-sa"
  display_name = "GCP Service Account for KSA binding"
}

resource "kubernetes_service_account" "ksa" {
  metadata {
    name      = "${var.project_id}-k8s-sa"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.gcp_sa.email
    }
  }
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gcp_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/${kubernetes_service_account.ksa.metadata[0].name}]"
}

