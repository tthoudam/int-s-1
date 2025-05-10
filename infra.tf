resource "google_project_service" "enable_cas" {
  service = "privateca.googleapis.com"
}
