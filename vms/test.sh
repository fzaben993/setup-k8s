#!/bin/bash

echo "All arguments: $1 $2"

if [[ "$1" == "username="* && "$2" == "password="* ]]; then
  username="${1#*=}"
  password="${2#*=}"
  echo "Username: ${username}"
  echo "Password: ${password}"
else
  echo "Usage: $0 username=<username> password=<password>"
  exit 1
fi

# Set the locale
export LC_ALL=en_US.UTF-8

# Subscription Manager
echo "Registering system with Subscription Manager..."
sudo subscription-manager register --username="${username}" --password="${password}"
sudo yum update -y
sudo yum clean all -y; sudo yum makecache -y

sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
suod dnf install docker-ce
sudo systemctl enable docker
sudo systemctl start docker

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
  [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

dnf install kubeadm -y


# Clean and update YUM cache
# echo "Cleaning and updating YUM cache..."
# sudo yum clean all -y; sudo yum makecache -y

# Install EPEL repository
# echo "Installing EPEL repository..."
# sudo yum install -y epel-release

# # Install essential packages
# echo "Installing essential packages..."
# sudo yum install -y vim git curl wget

# Update and upgrade packages
# echo "Updating and upgrading packages..."
# sudo yum update -y; sudo yum upgrade -y


