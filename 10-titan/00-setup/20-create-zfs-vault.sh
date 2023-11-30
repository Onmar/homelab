#!/bin/bash

DISKS=(
    "/dev/vg_slow/hdd00"
    "/dev/vg_slow/hdd01"
    "/dev/vg_slow/hdd02"
    "/dev/vg_slow/hdd03"
    "/dev/vg_slow/hdd04"
    "/dev/vg_slow/hdd05"
    "/dev/vg_slow/hdd06"
    "/dev/vg_slow/hdd07"
)
SPECIAL_DISKS=(
    "/dev/vg_fast/spec0"
    "/dev/vg_fast/spec1"
)
BASE_DIR="/mnt/vault"

POOL_NAME="vault"

mkdir -p "$BASE_DIR"
zpool create \
    -m "$BASE_DIR" \
    -o ashift=12 \
    -o autoexpand=on \
    -o autoreplace=on \
    -O atime=off \
    -O canmount=off \
    -O compression=lz4 \
    -O xattr=sa \
    ${POOL_NAME} raidz2 ${DISKS[@]}

zpool add ${POOL_NAME} \
    -f \  # Override for redundancy level mismatch
    -o ashift=12 \
    special mirror ${SPECIAL_DISKS[@]}
