################################################################################
#
# gke-cluster-module / testing
#   This project is used to run a system test for the module defined in the root
#   directory.
#
# main.tf
#   The main Terraform configuration file containing the Terraform settings and
#   resources.
#
################################################################################

terraform {
  required_version = "~> 0.14"

  required_providers {
    google = {
        source  = "hashicorp/google"
        version = "~> 3.64"
    }
  }
}

module "mut" {
    source = "../"

    cluster_id = var.cluster_id
    base_cidr_block = cidrsubnet("10.0.0.0/8", 8, random_integer.network_num.result)
}

variable "cluster_id" {
    description = "The name of the cluster to create.  A unique value should be picked from each CI build to avoid collisions in case multiple builds are running in parallel."
    type        = string
}

variable "commit_hash" {
    description = "The random number generator uses this value to determine if a new number should be generated or not."
    type        = string
}

resource "random_integer" "network_num" {
    min = 0
    max = 255

    keepers = {
        hash = var.commit_hash
    }
}