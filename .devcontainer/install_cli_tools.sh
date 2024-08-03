#!/bin/bash

# Install yq
sudo apt update
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
sudo apt-get install -y autojump
sudo apt-get install -y ansible-lint
sudo apt-get install -y python3.10-venv