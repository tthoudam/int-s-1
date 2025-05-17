**Task (INT-S-1): Istio Ingress with CAS-Managed Certificate via Cert-Manager**

*   **Use Case:** Route ingress traffic for an application in GKE via an Istio Ingress Gateway. The TLS certificate for the gateway should be automatically issued by your own private CA managed via Google Cloud Certificate Authority Service (CAS) and obtained using Cert-Manager. Istio performs TLS termination at the gateway (TLS Origination).
*   **Steps:**
    1.  **Terraform:** Write Terraform code to:
        *   Provision a GKE cluster (with Workload Identity).
        *   Enable the Google CAS API.
        *   Create KMS KeyRing/CryptoKey for CAS.
        *   Create a CAS CA Pool.
        *   Create a simple self-signed CA within the pool. Output the CA Pool resource name.
        *   Create a dedicated GCP Service Account (`cert-manager-cas-issuer-sa`).
        *   Grant this SA the `roles/privateca.certificateRequester` role on the CA Pool.
        *   Set up the `roles/iam.workloadIdentityUser` binding for the Cert-Manager KSA to impersonate the GCP SA.
    2.  **Helm:** Create/modify a Helm chart to include:
        *   (Assume Cert-Manager & Istio are installed or handle installation).
        *   A `ClusterIssuer` (using the `google-cas-issuer`, requires a specific CRD/controller like Jetstack's) configured with CAS Pool details and Workload Identity authentication.
        *   An Istio `Gateway` for `istio-ingressgateway` listening on port 443 for a specific hostname, configured for `SIMPLE` TLS using a `credentialName` (e.g., `myapp-ingress-tls`).
        *   An Istio `VirtualService` routing traffic for that hostname to a backend service.
        *   A Cert-Manager `Certificate` resource requesting a certificate for the hostname from the CAS issuer, storing it in the Secret specified by `credentialName`.
    3.  **GitHub Actions:** Create a workflow that:
        *   Authenticates securely to GCP (WIF).
        *   Runs `terraform apply` for the infrastructure (GKE, KMS, CAS, IAM), obtaining the CA Pool ID output.
        *   Configures `kubectl` and `helm`.
        *   Ensures Istio and Cert-Manager are present.
        *   Installs/upgrades the Helm chart from step 2, passing necessary values (Project ID, Region, CA Pool ID, Hostname, etc.).
