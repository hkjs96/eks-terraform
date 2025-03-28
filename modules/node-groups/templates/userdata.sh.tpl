#!/bin/bash
set -o xtrace

/etc/eks/bootstrap.sh ${cluster_name} \
  --apiserver-endpoint ${cluster_endpoint} \
  ${bootstrap_extra_args} \
  --kubelet-extra-args "${kubelet_extra_args}"
