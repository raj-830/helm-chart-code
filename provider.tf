# 1. CORRECTED DATA SOURCE: Use "id" instead of "name"

data "google_container_cluster" "primary" {
  name     = reverse(split("/", var.cluster_id))[0]
  #name     = var.cluster_id
  location = var.gcp_location
  project  = var.gcp_project_id
}


/*
data "google_container_cluster" "primary" {
  name     = var.cluster_id
  location = var.gcp_zone
  project  = var.gcp_project_id
}
*/
# 2. KUBERNETES PROVIDER CONFIGURATION
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.primary.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
  token                  = data.google_client_config.default.access_token 
  insecure = true
  # cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# 3. HELM PROVIDER CONFIGURATION
provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.primary.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
    token                  = data.google_client_config.default.access_token
    insecure = true
    #   cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}
