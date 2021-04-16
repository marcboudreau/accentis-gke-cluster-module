################################################################################
#
# gke-cluster-module / testing
#   This project is used to run a system test for the module defined in the root
#   directory.
#
# outputs.tf
#   Defines output variables for the testing project.
#
################################################################################

output "k8s_api_endpoint" {
    description = "The endpoint address for the Kubernetes API Server"
    value       = module.mut.k8s_api_endpoint
}

output "k8s_cluster_ca" {
    description = "The certificate of the certificate authority that issued the Kubernetes API Server certificate."
    value       = module.mut.k8s_cluster_ca
}
