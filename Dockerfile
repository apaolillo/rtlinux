FROM debian:stable
# hoe sd card toegankelijk maken?

RUN apt update && \
		apt upgrade && \
		apt install sudo -y

RUN useradd bench -sm /bin/bash
# geen --password bench, ik denk dat dit niet nodig is
# -m = create home directory, -s bin bash is use bash als shell
RUN newgrp sudo && \
		usermod -aG sudo bench
RUN su - wannes
RUN sudo apt install -y git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 wget kmod

# Get the kernel sources
RUN git clone --depth=1 https://github.com/raspberrypi/linux
RUN cd linux
ARG KERNEL=kernel_2712

## Custom kernel
# Configs

RUN make -j16 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
# Build kernel
RUN make -j16 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

## Patched kernel
# We're installing 6.1.77 since this is the kernel version of our raspbian image. This was checked by running head Makefile -n 4 in the ~/linux directory.
# Actually installing 6.6.20 since custom kernel is v6.6.21.
RUN wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/patch-6.6.20-rt25.patch.gz
RUN gunzip patch-6.6.20-rt25.patch.gz
RUN cat patch-6.6.20-rt25.patch | patch -p1
# Apply regular configs
RUN make -j16 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
# Select Fully Preemptible kernel in menuconfig
RUN make -j16 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
# Build the newly configured kernel
RUN make -j16 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

## Install kernel modules to SD
RUN sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/mnt/ext4 modules_install
# Copy kernel and device Tree blobs to SD (backup in -original)
RUN sudo cp /mnt/fat32/$KERNEL.img /mnt/fat32/$KERNEL-backup.img
RUN sudo cp arch/arm64/boot/Image /mnt/fat32/$KERNEL.img
RUN sudo cp arch/arm64/boot/dts/broadcom/*.dtb /mnt/fat32/
RUN sudo cp arch/arm64/boot/dts/overlays/*.dtb* /mnt/fat32/overlays/
RUN sudo cp arch/arm64/boot/dts/overlays/README /mnt/fat32/overlays/






# 1 voor custom en 1 dockerfile voor patched te builden? of beiden builden in zelfde file en dan twee images en switchen op raspi?

# 2 .img dan dat is ok maar ik ben gwn niet zo zeker van al de rest er rond. moet ik eens uitproberen.
