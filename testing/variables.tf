################################################################################
#
# gke-cluster-module / testing
#   This project is used to run a system test for the module defined in the root
#   directory.
#
# variables.tf
#   Defines input variables for the testing project.
#
################################################################################

variable "commit_hash" {
    description = "The commit hash of the current branch. This value is used to generate a unique name for resources within this project."
    type        = string
}
