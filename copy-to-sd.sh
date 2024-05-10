#!/bin/sh 

# Gets executed inside the buildrtlinux Docker image, so $USER points to the Docker user

cd /home/${USER}/linux/

## Install kernel modules to SD
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/mnt/ext4 modules_install

## Copy kernel and device Tree blobs to SD
sudo cp /mnt/fat32/$KERNEL.img /mnt/fat32/$KERNEL-backup.img
sudo cp arch/arm64/boot/Image-v8-16k-stock /mnt/fat32/$KERNEL-v8-16k-stock.img # TODO not tested, check if both images are correctly copied to sd card
sudo cp arch/arm64/boot/Image-v8-16k-rt /mnt/fat32/$KERNEL-v8-16k-rt.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /mnt/fat32/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /mnt/fat32/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /mnt/fat32/overlays/
