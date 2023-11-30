#!/bin/bash

apt install gdisk lvm2
sed -i -E 's/^#?\s*scan_lvs.*$/\tscan_lvs = 1/' "/etc/lvm/lvm.conf"
