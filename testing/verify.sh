#!/bin/bash
set -eu${DEBUG:+x}o pipefail

#
# verify.sh
#   This script is run once the gke-cluster-module has been provisioned.  It
#   relies on gcloud being installed and configured with appropriate
#   credentials.  It also relies on kubectl being installed, but this script
#   handles configuring it to interact with the cluster being verified.
#

# The commit abbreviated hash must be passed as an argument.
commit_hash=${1:?"The abbreviated commit hash must be passed as an argument to this script."}

# Increase the size of the bastion IGM to 1.
echo "Creating bastion instance" ; gcloud compute instance-groups managed resize "test-$commit_hash-bastion" --region=us-east1 --size=1 2>&1 >/dev/null

# Retrieving the name of the bastion Instance.
echo "Retrieving bastion instance name" ; instance="$(gcloud compute instance-groups managed list-instances "test-$commit_hash-bastion" --region=us-east1 --format='value(instance)')" 2> /dev/null 

# Retrieving the zone where the bastion Instance is provisioned.
echo "Retrieving bastion instance zone" ; instance_zone="$(gcloud compute instance-groups managed list-instances "test-$commit_hash-bastion" --region=us-east1 --format='value(instance.scope("zones").segment(0))')" 2> /dev/null

# Retrieving the IP address of the bastion Instance.
echo "Retrieving bastion instance IP address" ; instance_ip="$(gcloud compute instances describe "$instance" --zone="$instance_zone" --format='value(networkInterfaces[0].accessConfigs[0].natIP)')" 2> /dev/null

# Configuring kube config file.
echo "Configuring kube config file" ; gcloud container clusters get-credentials "test-$commit_hash" --region=us-east1 2>&1 > /dev/null

# Extracting the Kubernetes API endpoint.
echo "Extracting kubernetes api endpoint" ; kubernetes_endpoint="$(kubectl config view -o jsonpath='{.clusters[?(@.name == "gke_accentis-288921_us-east1_test-'$commit_hash'")].cluster.server}')" 2> /dev/null

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/google_compute_engine ]; then
    echo "Generating ssh key" ; ssh-keygen -q -t rsa -b 2048 -N '' -f ~/.ssh/google_compute_engine 2>&1 > /dev/null
fi

# Waiting for bastion Instance SSH port
echo "Waiting for bastion instance ssh port"
i=0
while ! nc -z "$instance_ip" 22 ; do
    if [ $i -eq 100 ]; then
        echo "Bastion instance ssh port unreachable"
        exit 1
    fi

    sleep 1
    i=$((i+1))
done

# Establishing SSH tunnel
echo "Establishing ssh tunnel" ; gcloud compute ssh "$instance" --zone="$instance_zone" --strict-host-key-checking=no -- -L "9443:${kubernetes_endpoint:8}:443" -N &

# Waiting for ssh tunnel
echo "Waiting for ssh tunnel"
i=0
while ! nc -z localhost 9443 ; do
    if [ $i -eq 100 ]; then
        echo "SSH tunnel unavailable"
        exit 1
    fi

    sleep 1
    i=$((i+1))
done

# Updating kube config file
echo "Updating kube config file" ; kubectl config set-cluster "gke_accentis-288921_us-east1_test-$commit_hash" --server https://localhost:9443 --insecure-skip-tls-verify=true 2>&1 > /dev/null

# Count reported nodes
echo "Counting reported kubernetes nodes" ; node_count="$(kubectl get nodes --no-headers | wc -l)" 2> /dev/null

# Verify non-zero number of nodes
test "$node_count" -gt 0
