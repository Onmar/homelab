#!/bin/bash
cd ~/.gnupg ; wget https://raw.githubusercontent.com/drduh/config/master/gpg.conf
chmod 600 gpg.conf

sudo apt update && sudo apt install -y gnupg2 gnupg-agent gnupg-curl scdaemon pcscd

echo "Edit ~/.gnupg/gpg.conf and enable keyserver url"
read -p "Press any key to continue..." -n1 -s
nano ~/.gnupg/gpg.conf


cd ~/.gnupg ; wget https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf
chmod 600 gpg-agent.conf


cat << EOF >> ~/.bashrc
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
EOF

