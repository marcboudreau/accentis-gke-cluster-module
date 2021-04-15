################################################################################
#
# gke-cluster
#   A Terraform module that creates complete GKE cluster in its own VPC.
#
# main.tf
#   The main Terraform code file.
#
################################################################################

#
# The resources have been organized into files by areas of concern:
#   bastion.tf: contains a bastion GCE instance used to establish SSH tunnels into the VPC
#   gke.tf: contains the GKE cluster and Node Pools
#   iam.tf: contains the IAM related resources
#   networking.tf: contains the Network, Subnetworks, Routers, etc...
#
