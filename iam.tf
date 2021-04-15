################################################################################
#
# gke-cluster
#   A Terraform module that creates complete GKE cluster in its own VPC.
#
# iam.tf
#   The IAM related resources.
#
################################################################################

#
# The ServiceAccount used by the GKE cluster worker nodes.
#
resource "google_service_account" "main" {
  account_id = "${var.cluster_id}-sa"
  display_name = "${var.cluster_id} Worker Node Service Account"
}

