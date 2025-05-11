output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

# The CA Pool resource name
output "ca_pool_resource_name" {
  value = google_privateca_ca_pool.cas_pool.name
}

output "google_cloud_sa_email" {
  value = google_service_account.cert_manager_cas_issuer_sa.email
}