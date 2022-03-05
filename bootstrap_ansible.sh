#!/bin/bash

set -e
# echo "nameserver 1.1.1.1" > /etc/resolv.conf
apt-get update
apt-get upgrade -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install -y software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update --fix-missing
apt install -y \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    wget \
    curl \
    python3-pip \
    python3-setuptools \
    python-dev \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    ansible \
    dnsmasq \
    net-tools
#pip3 install ansible==2.9.6
mkdir -p /etc/ansible
touch /etc/ansible/hosts
