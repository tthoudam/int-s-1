// Configures the GCP Cloud Provider with default project and region
provider "google" {
  project = var.project_id
  region  = var.region
}