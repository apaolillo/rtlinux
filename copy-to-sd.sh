#!/bin/sh 
set -ex

# Gets executed inside the buildrtlinux Docker image, so $USER points to the Docker user

sd_card_fs=$(readlink -e ~/workspace/sdcard)

echo "-- starting deploying on SD card --"
echo "KERNEL = ${KERNEL}"
echo "PATH = ${PATH}"
echo "SD_CARD location = ${sd_card_fs}"

## Install stock kernel modules to SD
cd ~/workspace/linux-stock
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${sd_card_fs}/ext4 modules_install
## Install rt kernel modules to SD
cd ~/workspace/linux-rt
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${sd_card_fs}/ext4 modules_install

## Copy kernel and device Tree blobs to SD
if [ -f "${sd_card_fs}/fat32/$KERNEL.img" ]
then
  sudo cp ${sd_card_fs}/fat32/$KERNEL.img ${sd_card_fs}/fat32/$KERNEL-backup.img
fi
sudo cp ${HOME}/kernels/${KERNEL}-stock.img ${sd_card_fs}/fat32/$KERNEL-v8-16k-stock.img # TODO not tested, check if both images are correctly copied to sd card
sudo cp ${HOME}/kernels/${KERNEL}-rt.img ${sd_card_fs}/fat32/$KERNEL-v8-16k-rt.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb ${sd_card_fs}/fat32/
if [ ! -d "${sd_card_fs}/fat32/overlays/" ]
then
  mkdir -p ${sd_card_fs}/fat32/overlays/
fi
sudo cp arch/arm64/boot/dts/overlays/*.dtb* ${sd_card_fs}/fat32/overlays/
sudo cp arch/arm64/boot/dts/overlays/README ${sd_card_fs}/fat32/overlays/
