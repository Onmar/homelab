#!/bin/bash
echo "Type fetch then quit in the gpg utility"
read -p "Press any key to continue..." -n1 -s
gpg --edit-card

echo "Copy key id, then run \"gpg --edit-key \$KEYID\" -> trust -> 5 -> quit"
read -p "Press any key to continue..." -n1 -s

mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-add -L | grep "cardno" > ~/.ssh/id_ed25519_yubikey.pub
chmod 600 ~/.ssh/id_ed25519_yubikey.pub

