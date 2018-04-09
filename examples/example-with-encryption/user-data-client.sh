#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode. Note that this script assumes it's running in an AMI
# built from the Packer template in examples/consul-ami/consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# These variables are passed in via Terraform template interplation
if [[ "${enable_gossip_encryption}" == "true" && ! -z "${gossip_encryption_key}" ]]; then
  # We're setting the encryption key in plain text here to simplify the example, but in production you should inject it more securely, e.g. retrieving it from KMS.
  gossip_encryption_configuration="--enable-gossip-encryption --gossip-encryption-key ${gossip_encryption_key}"
fi

if [[ "${enable_rpc_encryption}" == "true" && ! -z "${ca_path}" && ! -z "${cert_file_path}" && ! -z "${key_file_path}" ]]; then
  rpc_encryption_configuration="--enable-rpc-encryption --ca-path ${ca_path} --cert-file-path ${cert_file_path} --key-file-path ${key_file_path}"
fi

/opt/consul/bin/run-consul --client --cluster-tag-key "${cluster_tag_key}" --cluster-tag-value "${cluster_tag_value}" $gossip_encryption_configuration $rpc_encryption_configuration

# You could add commands to boot your other apps here