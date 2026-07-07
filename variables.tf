variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string

}

variable "helm_release_name" {
  description = "helm release name."
  type        = string
 
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "us-central1"
}

variable "gcp_location" {
  description = "The GCP zone to deploy resources in."
  type        = string
  default     = "us-central1"
}

variable "cluster_id" {
  description = "ID of the cluster"
  type        = string
}

variable "helm_namespace" {
  description = "GKE name space"
  type        = string
}


variable "set_inputs" {
  description = "List of set inputs (e.g. name1:val1,name2:value2)"
  type        = string
  default = "replicaCount:1"
}

variable "chart" {
  description = "chart"
  type        = string
  default = "https://raw.githubusercontent.com/raj-830/simple-helm-app/main/simple-app-0.1.0.tgz"
}
