output "k8s_api_endpoint" {
  description = "The endpoint address for the Kubernetes API Server"
  value       = google_container_cluster.main.endpoint
}

output "network" {
  description = "The self_link of the VPC network created for this GKE cluster"
  value       = google_compute_network.main.self_link
}

output "k8s_cluster_ca" {
  description = "The certificate of the certificate authority that issued the Kubernetes API Server certificate."
  value       = google_container_cluster.main.master_auth.0.cluster_ca_certificate
}
