#!/bin/sh 

cd /home/${USER}/linux/

## Install kernel modules to SD
sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/mnt/ext4 modules_install

## Copy kernel and device Tree blobs to SD
sudo cp /mnt/fat32/$KERNEL.img /mnt/fat32/$KERNEL-backup.img
sudo cp arch/arm64/boot/Image /mnt/fat32/$KERNEL.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /mnt/fat32/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /mnt/fat32/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /mnt/fat32/overlays/

# -v8-16k-stock -v8-16k-rt ??
