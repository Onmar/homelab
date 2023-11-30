#!/bin/bash
set -e  # Exit on error

read -p "THIS WILL WIPE YOUR DISKS, DO YOU WANT TO CONTINUE? [y/N] " yn
case "$yn" in
    [Yy]*) ;;
    *) exit 0;;
esac

CACHE_DISKS=(
    "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W905595N"
    "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W953931E"
)

HDD_AMOUNT=8
CACHE_SIZE_PER_DISK="128GB"  # Gibibyte

CACHE_VG_NAME="vg_fast"

echo "Wiping & Partitioning Drives"
sleep 1
for disk in ${CACHE_DISKS[@]}; do
    wipefs -a "$disk"
    blkdiscard -f "$disk"
    sgdisk --zap-all "$disk"
    sgdisk -n1:: -t1:8E00 "$disk"
    sleep 1
    wipefs -a "${disk}-part1"
done
CACHE_DISKS=("${CACHE_DISKS[@]/%/-part1}")

echo "Setting up cache LVs"
sleep 1
pvcreate ${CACHE_DISKS[@]}
vgcreate "$CACHE_VG_NAME" ${CACHE_DISKS[@]}

cache_disk_nr=${#CACHE_DISKS[@]}
for index in $(seq 0 $(($HDD_AMOUNT - 1))); do
    lvcreate \
        --type raid1 --mirrors $(($cache_disk_nr-1)) \
        --size "${CACHE_SIZE_PER_DISK}" \
        --name "hdd$(printf "%02d" $index)_cache" \
        "$CACHE_VG_NAME" ${CACHE_DISKS[@]}
done

echo "CACHE_DISKS=("
for index in $(seq 0 $(($HDD_AMOUNT - 1))); do
echo "    /dev/${CACHE_VG_NAME}/hdd$(printf "%02d" $index)_cache"
done
echo ")"
