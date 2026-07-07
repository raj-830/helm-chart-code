
locals{

cluster_name = reverse(split("/", var.cluster_id))[0]
raw_input = var.set_inputs
# 2. Convert to a list of objects
  helm_sets = [
    for pair in split(",", local.raw_input) : {
      name  = trimspace(split(":", pair)[0])
      value = trimspace(split(":", pair)[1])
    }
  ]
}
data "google_client_config" "default" {}

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.helm_namespace
  }
}

resource "helm_release" "main" {
  name      = var.helm_release_name 
  namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  timeout   = 600
  replace   = true

  # Pass the direct HTTPS download link to the raw tarball file on GitHub
  chart = "https://raw.githubusercontent.com/raj-830/simple-helm-app/main/simple-app-0.1.0.tgz"

  set = local.helm_sets
}