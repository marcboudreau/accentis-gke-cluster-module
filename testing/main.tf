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

provider "google" {
    project = "accentis-288921"
    region  = "us-east1"
}

provider "google-beta" {
    project = "accentis-288921"
    region  = "us-east1"
}

module "mut" {
    source = "../"

    cluster_id = "test-${var.commit_hash}"
    base_cidr_block = cidrsubnet("10.0.0.0/8", 8, random_integer.network_num.result)
}

resource "random_integer" "network_num" {
    min = 0
    max = 255

    keepers = {
        hash = var.commit_hash
    }
}

resource "google_compute_firewall" "main" {
    name    = "test-${var.commit_hash}"
    network = module.mut.network

    allow {
        protocol = "tcp"
        ports    = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
    priority      = 1000
    target_tags   = ["bastion"]
}
