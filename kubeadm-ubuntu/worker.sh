#!/bin/bash -v
#sudo su
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update -y 
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo curl -sSL https://get.docker.com/ | sh
sudo systemctl start docker


# # Install Docker CE
# ## Set up the repository:
# ### Install packages to allow apt to use a repository over HTTPS
# apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common

# ### Add Docker’s official GPG key
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# ### Add Docker apt repository.
# add-apt-repository \
#   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) \
#   stable"

# ## Install Docker CE.
# apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu

# # Setup daemon.
# cat > /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2"
# }
# EOF

# mkdir -p /etc/systemd/system/docker.service.d

# # Restart docker.
# systemctl daemon-reload
# systemctl restart docker


#Due to terraform conflicts conmmenting this
for i in {1..50}; do kubeadm join --token=${k8stoken} ${masterIP} && break || sleep 15; done
