################################################################################
#
# gke-cluster
#   A Terraform module that creates complete GKE cluster in its own VPC.
#
# gke.tf
#   The Google Kubernetes Engine related resources.
#
################################################################################

resource "google_container_cluster" "main" {
    name       = var.cluster_id
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.main.self_link

    remove_default_node_pool = true
    initial_node_count       = 1

    ip_allocation_policy {
      services_secondary_range_name = google_compute_subnetwork.main.secondary_ip_range[0].range_name
      cluster_secondary_range_name  = google_compute_subnetwork.main.secondary_ip_range[1].range_name
    }

    master_auth {
        client_certificate_config {
          issue_client_certificate = false
        }
    }

    private_cluster_config {
      enable_private_nodes = true
      enable_private_endpoint = true
      master_ipv4_cidr_block = cidrsubnet(var.base_cidr_block, 2, 0)
    }

    release_channel {
      channel = "REGULAR"
    }
}


resource "google_container_node_pool" "main" {
    name_prefix = var.cluster_id
    cluster     = google_container_cluster.main.name
    node_count  = 1

    management {
      auto_repair  = true
      auto_upgrade = true
    }

    upgrade_settings {
        max_surge       = 1
        max_unavailable = 0
    }

    node_config {
      disk_size_gb = 10
      machine_type = "n1-standard-2"
      service_account = google_service_account.main.email
      oauth_scopes = [ "cloud-platform" ]
      metadata = {
          disable-legacy-endpoints = true
          block-project-ssh-keys = true
      }
    }
}

