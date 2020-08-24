#!/bin/bash -v
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# ### Install packages to allow apt to use a repository over HTTPS

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# # Install Docker CE
# ## Set up the repository:

sudo curl -sSL https://get.docker.com/ | sh

# # Restart docker.
sudo systemctl start docker


sudo kubeadm reset -y
#sudo kubeadm token list
#sudo kubeadm init --pod-network-cidr 10.244.0.0/16=${k8stoken}
#kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml


##https://www.linode.com/docs/applications/containers/kubernetes/getting-started-with-kubernetes/