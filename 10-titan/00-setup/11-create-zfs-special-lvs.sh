#!/bin/bash

PV_NAMES=(
    "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W905595N-part1"
    "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W953931E-part1"
)
VG_NAME="vg_fast"
LV_SIZE="768G"

for index in ${!PV_NAMES[@]}; do
    lvcreate \
        --size "${LV_SIZE}" \
        --name "spec${index}" \
        "$VG_NAME" "${PV_NAMES[$index]}"
done
