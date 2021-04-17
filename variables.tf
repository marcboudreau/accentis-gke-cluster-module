
variable "cluster_id" {
  type        = string
  description = "A unique value that identifies this cluster among all other clusters that may also appear in the same GCP project."

  validation {
    condition     = (length(var.cluster_id) < 26 && length(var.cluster_id) > 4 && regex("^[a-z][-a-z0-9]{4,24}"))
    error_message = "The cluster_id must begin with a letter and can only contain lowercase letters, digits, and hyphens.  The length must be between 5 and 25."
  }
}

variable "base_cidr_block" {
  type        = string
  description = "The base CIDR block to use for calculating the subnetwork IP ranges."
  default     = "10.0.0.0/16"

  validation {
    condition     = (cidrnetmask(var.base_cidr_block) == "255.255.0.0")
    error_message = "The base_cidr_block must be a /16 range."
  }
}
