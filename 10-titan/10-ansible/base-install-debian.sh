#!/bin/bash
apt-get install --yes openssh-server
sed -i -E 's/^#?PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd.service
