output "app_name" {
  description = "Helm release name"
  value = helm_release.main.name
}

