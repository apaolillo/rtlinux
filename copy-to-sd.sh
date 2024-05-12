#!/bin/sh 
set -ex

# Gets executed inside the buildrtlinux Docker image, so $USER points to the Docker user

sd_card_fs=$(readlink -e ~/workspace/sdcard)

echo "-- starting deploying on SD card --"
echo "KERNEL = ${KERNEL}"
echo "PATH = ${PATH}"
echo "SD_CARD location = ${sd_card_fs}"

cd ~/workspace/linux

## Install kernel modules to SD
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${sd_card_fs}/ext4 modules_install

## Copy kernel and device Tree blobs to SD
sudo cp ${sd_card_fs}/fat32/$KERNEL.img ${sd_card_fs}/fat32/$KERNEL-backup.img
sudo cp arch/arm64/boot/Image-v8-16k-stock ${sd_card_fs}/fat32/$KERNEL-v8-16k-stock.img # TODO not tested, check if both images are correctly copied to sd card
sudo cp arch/arm64/boot/Image-v8-16k-rt ${sd_card_fs}/fat32/$KERNEL-v8-16k-rt.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb ${sd_card_fs}/fat32/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* ${sd_card_fs}/fat32/overlays/
sudo cp arch/arm64/boot/dts/overlays/README ${sd_card_fs}/fat32/overlays/
