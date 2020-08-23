#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${cluster-endpoint}' --b64-cluster-ca '${cluster-certificate-authority}' '${cluster-name}'