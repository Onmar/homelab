#!/bin/bash
set -e  # Exit on error

read -p "THIS WILL WIPE YOUR DISKS, DO YOU WANT TO CONTINUE? [y/N] " yn
case "$yn" in
    [Yy]*) ;;
    *) exit 0;;
esac

HDDS=(
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0EJRLM"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0EXZ7M"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0EYKDM"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0EZXXM"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0G0KEM"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0G2V2M"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0G3MEM"
    "/dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH0G64TM"
)
CACHE_DISKS=(
    /dev/vg_fast/hdd00_cache
    /dev/vg_fast/hdd01_cache
    /dev/vg_fast/hdd02_cache
    /dev/vg_fast/hdd03_cache
    /dev/vg_fast/hdd04_cache
    /dev/vg_fast/hdd05_cache
    /dev/vg_fast/hdd06_cache
    /dev/vg_fast/hdd07_cache
)

HDD_VG_NAME="vg_slow"


echo "Wiping & Partitioning Drives"
sleep 1
for disk in ${HDDS[@]}; do
    wipefs -a "$disk"
    sgdisk --zap-all "$disk"
    sgdisk -n1:: -t1:8E00 "$disk"
    sleep 1
    wipefs -a "${disk}-part1"
done
HDDS=("${HDDS[@]/%/-part1}")

echo "Wiping & Partitioning Cache"
for disk in ${CACHE_DISKS[@]}; do
    wipefs -a "$disk"
    blkdiscard -f "$disk"
done

echo "Setting up HDD LVs"
sleep 1
pvcreate ${HDDS[@]}
pvcreate ${CACHE_DISKS[@]}
vgcreate "$HDD_VG_NAME" ${HDDS[@]} ${CACHE_DISKS[@]}

for index in ${!HDDS[@]}; do
    lvcreate \
        --activate n \
        --contiguous y \
        --extents "100%PVS" \
        --name "hdd$(printf "%02d" $index)_cache" \
        "$HDD_VG_NAME" "${CACHE_DISKS[$index]}"
        
    lvcreate \
        --type writecache --cachevol "hdd$(printf "%02d" $index)_cache" \
        --cachesettings 'high_watermark=90' \
        --cachesettings 'low_watermark=0' \
        --contiguous y \
        --extents "100%PVS" \
        --name "hdd$(printf "%02d" $index)" \
        "$HDD_VG_NAME" "${HDDS[$index]}"
done

echo "DISKS=("
for index in ${!HDDS[@]}; do
echo "    /dev/${HDD_VG_NAME}/hdd$(printf "%02d" $index)"
done
echo ")"
