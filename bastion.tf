################################################################################
#
# gke-cluster
#   A Terraform module that creates complete GKE cluster in its own VPC.
#
# bastion.tf
#   Resources related to providing a bastion GCE Instance.
#
################################################################################

#
# Defines an Instance Group Manager.  This manager will maintain the specified
# target_size number of Instances.  This configuration specifies 0 as the number
# of instances.  When the bastion is needed, the target_size will be increased
# to 1 by some other process and restored to 0 once the instance is no longer
# needed.
#
resource "google_compute_region_instance_group_manager" "bastion" {
  base_instance_name = "${var.cluster_id}-bastion"
  name               = "${var.cluster_id}-bastion"

  version {
    name              = "bastion-version"
    instance_template = google_compute_instance_template.bastion.id
  }

  named_port {
    name = "ssh"
    port = 22
  }

  target_size = 0

  auto_healing_policies {
    health_check      = google_compute_health_check.bastion.id
    initial_delay_sec = 15
  }
}

#
# This Instance Template defines the specifications for the bastion GCE Instance.
#
resource "google_compute_instance_template" "bastion" {
  machine_type = "n1-standard-1"

  disk {
    boot         = true
    source_image = "family/ubuntu-2004-lts"
    disk_type    = "pd-ssd"
    disk_size_gb = 10
  }

  name_prefix = "${var.cluster_id}-bastion"
  network_interface {
    subnetwork = google_compute_subnetwork.non_gke.self_link
    access_config {
    }
  }

  scheduling {
    automatic_restart = false
    preemptible       = true
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  tags = ["bastion"]

  lifecycle {
    create_before_destroy = true
  }
}

#
# The health check resource used to monitor the health of the bastion instance,
# when it is in use.
#
resource "google_compute_health_check" "bastion" {
  provider = google-beta

  name = "${var.cluster_id}-bastion"

  check_interval_sec  = 5
  healthy_threshold   = 1
  unhealthy_threshold = 3
  timeout_sec         = 5

  tcp_health_check {
    port = 22
  }

  log_config {
    enable = true
  }
}
