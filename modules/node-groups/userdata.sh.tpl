#!/bin/bash
set -o xtrace

/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca '${cluster_ca_base64}' \
  --apiserver-endpoint '${cluster_endpoint}' \
  ${bootstrap_extra_args}
