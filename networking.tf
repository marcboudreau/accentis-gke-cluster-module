################################################################################
#
# gke-cluster
#   A Terraform module that creates complete GKE cluster in its own VPC.
#
# networking.tf
#   The networking related resources.
#
################################################################################

#
# Creates a global VPC network without pre-populating it with subnetworks.
#
resource "google_compute_network" "main" {
  name = var.cluster_id

  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

#
# Creates a subnetwork within the global VPC network.  The subnetwork uses the 
# following IP ranges to allocate IP addresses to the following resources:
#   Instances: 10.x.64.0/18 (10.x.64.0 - 10.x.127.255)
#   Kubernetes Pods: 10.x.128.0/18 (10.x.128.0 - 10.x.191.255)
#   Kubernetes Services: 10.x.192.0/18 (10.x.192.0 - 10.x.255.255)
#
# This arrangement leaves the second octet open to be used to for additional
# subnetworks/GKE clusters.
#
resource "google_compute_subnetwork" "main" {
  ip_cidr_range = cidrsubnet(var.base_cidr_block, 2, 1)
  name          = var.cluster_id
  network       = google_compute_network.main.id

  private_ip_google_access = true

  secondary_ip_range {
    ip_cidr_range = cidrsubnet(var.base_cidr_block, 2, 2)
    range_name    = "pod-ip-range"
  }

  secondary_ip_range {
    ip_cidr_range = cidrsubnet(var.base_cidr_block, 2, 3)
    range_name    = "service-ip-range"
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "non_gke" {
  ip_cidr_range = cidrsubnet(var.base_cidr_block, 8, 63)
  name          = "${var.cluster_id}-other"
  network       = google_compute_network.main.id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

#
# Defining a Cloud Router needed by the Router NAT resource below.
#
resource "google_compute_router" "main" {
  name    = var.cluster_id
  network = google_compute_network.main.id

  bgp {
    asn = "64514"
  }
}

#
# The Router NAT resource provides NAT capabilities that allow devices within
# the subnetwork to establish connection outside of the VPC network.
#
resource "google_compute_router_nat" "main" {
  name                               = var.cluster_id
  router                             = google_compute_router.main.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "TRANSLATIONS_ONLY"
  }
}
