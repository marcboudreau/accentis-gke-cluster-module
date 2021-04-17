output "k8s_api_endpoint" {
  description = "The endpoint address for the Kubernetes API Server"
  value       = google_container_cluster.main.endpoint
}

output "k8s_cluster_ca" {
  description = "The certificate of the certificate authority that issued the Kubernetes API Server certificate."
  value       = google_container_cluster.main.master_auth.0.cluster_ca_certificate
}
