output "k8s_host" {
  value = "${google_container_cluster.primary.endpoint}"
}

output "gke_node_pool_cluster" {
  value = "${google_container_node_pool.primary_pool.cluster}"
}
