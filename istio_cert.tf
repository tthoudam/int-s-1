# Enable CAS
resource "google_project_service" "enable_cas" {
  service = "privateca.googleapis.com"
}
# Enable kms
resource "google_project_service" "enable_kms" {
  service = "cloudkms.googleapis.com"
}

# Create CAS ca pool
resource "google_privateca_ca_pool" "cas_pool" {
  name     = "istio-ca-pool"
  location = "europe-west1"
  tier     = "ENTERPRISE"

  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}

# Create a simple/basic self-signed CA within the pool. Output the CA Pool resource name.
resource "google_privateca_certificate_authority" "root_ca" {
  certificate_authority_id = "istio-root-ca"
  location                 = google_privateca_ca_pool.cas_pool.location
  pool                     = google_privateca_ca_pool.cas_pool.name
  type                     = "SELF_SIGNED"
  deletion_protection      = false
  key_spec {
    algorithm = "RSA_PKCS1_2048_SHA256"
  }

  config {
    subject_config {
      subject {
        common_name  = "istio-root-ca"
        organization = "Example Corp"
        country_code = "GB"
      }
      subject_alt_name {
        dns_names = ["istio.example.com"]
      }
    }
    x509_config {
      ca_options {
        # is_ca *MUST* be true for certificate authorities
        is_ca = true
      }
      key_usage {
        base_key_usage {
          # cert_sign and crl_sign *MUST* be true for certificate authorities
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {
        }
      }
    }
  }
}

# Create a dedicated GCP Service Account (`cert-manager-cas-issuer-sa`).
resource "google_service_account" "cert_manager_cas_issuer_sa" {
  account_id   = "cert-manager-cas-issuer-sa"
  display_name = "SA for Istio Google CAS integration"
}

resource "google_project_iam_member" "iam_cas_requester" {
  project = var.project_id
  role    = "roles/privateca.certificateRequester"
  member  = "serviceAccount:${google_service_account.cert_manager_cas_issuer_sa.email}"
}

# Bind the cas issuer SA to kubernetes
resource "kubernetes_service_account" "istio_cas_ksa" {
  metadata {
    name      = "istio-cas-ksa"
    namespace = "istio-system"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.cert_manager_cas_issuer_sa.email
    }
  }
}

# Set up the `roles/iam.workloadIdentityUser` binding for the Cert-Manager KSA to impersonate the GCP SA.
resource "google_service_account_iam_member" "ksa_binding" {
  service_account_id = google_service_account.cert_manager_cas_issuer_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[istio-system/istio-cas-ksa]"
}

