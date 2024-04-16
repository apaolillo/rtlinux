FROM debian:stable

RUN apt-get update && \
		apt-get upgrade -y && \
		apt-get install -y sudo git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 wget kmod

ARG USER_NAME=wannes
ARG UID=1000
ARG GID=1000
# TODO right mgmnt
RUN addgroup --gid 1000 wannes
RUN adduser --disabled-password --uid $UID --gid $GID --gecos "" ${USER_NAME}
RUN newgrp sudo && \
		usermod -aG sudo ${USER_NAME}
USER wannes

# Get the kernel sources
RUN mkdir -p /home/wannes/workspace
WORKDIR /home/wannes/workspace
RUN git clone --depth=1 https://github.com/raspberrypi/linux
WORKDIR linux
ENV KERNEL=kernel_2712

## Custom kernel
# Configs
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
# Build kernel
RUN ./scripts/config --set-str CONFIG_LOCALVERSION "-v8-16k-stock"
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

## Patched kernel
# We're installing rt patch v6.6.20 since the built custom kernel is v6.6.21. This was the latest available custom kernel at time of writing.
RUN wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/patch-6.6.20-rt25.patch.gz
RUN gunzip patch-6.6.20-rt25.patch.gz
RUN cat patch-6.6.20-rt25.patch | patch -p1
RUN git checkout -b rtpatch && git add -A && git commit -m "RT patch"
RUN ./scripts/config --set-str CONFIG_LOCALVERSION "-v8-16k-rt"
# Apply regular configs
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
# Select Fully Preemptible kernel in menuconfig
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
# Build the newly configured kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

## Install kernel modules to SD
#RUN sudo env PATH=$PATH make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/mnt/ext4 modules_install
## Copy kernel and device Tree blobs to SD (backup in -original)
#RUN sudo cp /mnt/fat32/$KERNEL.img /mnt/fat32/$KERNEL-backup.img
#RUN sudo cp arch/arm64/boot/Image /mnt/fat32/$KERNEL.img
#RUN sudo cp arch/arm64/boot/dts/broadcom/*.dtb /mnt/fat32/
#RUN sudo cp arch/arm64/boot/dts/overlays/*.dtb* /mnt/fat32/overlays/
#RUN sudo cp arch/arm64/boot/dts/overlays/README /mnt/fat32/overlays/
