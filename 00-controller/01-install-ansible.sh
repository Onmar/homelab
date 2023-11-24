#!/bin/bash
sudo apt update
sudo apt install --yes software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install --yes ansible
sudo apt install --yes python3-pip
pip3 install passlib ansible-lint
