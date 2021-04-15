
variable "cluster_id" {
    type        = string
    description = "A unique value that identifies this cluster among all other clusters that may also appear in the same GCP project."
}

variable "base_cidr_block" {
    type        = string
    description = "The base CIDR block to use for calculating the subnetwork IP ranges."
    default     = "10.0.0.0/16"
}