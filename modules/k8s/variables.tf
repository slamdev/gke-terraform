variable "k8s_host" {
  type = "string"
  description = "Kubernetes master host"
}

variable "k8s_username" {
  type = "string"
  description = "Kubernetes master username"
}

variable "k8s_password" {
  type = "string"
  description = "Kubernetes master password"
}

variable "gce_credentials" {
  type = "string"
  description = "Path to service account credentials file"
}


variable "gke_node_pool_ready" {
  type = "string"
  description = "GKE node pool ready"
}
