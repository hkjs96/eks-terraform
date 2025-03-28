MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace

/etc/eks/bootstrap.sh ${cluster_name} \
  --apiserver-endpoint ${cluster_endpoint} \
  ${bootstrap_extra_args} \
  --kubelet-extra-args "${kubelet_extra_args}"

--==MYBOUNDARY==--
