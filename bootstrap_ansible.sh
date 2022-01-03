#!/bin/bash

set -e

echo "Installing Ansible..."
apt-get install -y software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update --fix-missing
apt-get install -y ansible net-tools
# apt-get update -y
# apt-get install -y python-pip python-dev
# pip install ansible==1.9.2
mkdir -p /etc/ansible
touch /etc/ansible/hosts