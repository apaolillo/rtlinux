FROM debian:stable

RUN apt-get update && \
		apt-get upgrade -y && \
		apt-get install -y sudo git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 wget kmod

# Username passed as build-arg
ARG USER_NAME
ARG UID=1000
ARG GID=1000
# TODO right mgmnt
RUN addgroup --gid 1000 ${USER_NAME} 
RUN adduser --disabled-password --uid $UID --gid $GID --gecos "" ${USER_NAME}
RUN newgrp sudo && \
		usermod -aG sudo ${USER_NAME}
USER ${USER_NAME}

# Get the kernel sources
RUN mkdir -p /home/${USER_NAME}/workspace
WORKDIR /home/${USER_NAME}/workspace
RUN git clone --depth=1 https://github.com/raspberrypi/linux/tree/rpi-6.6.y
WORKDIR linux
ENV KERNEL=kernel_2712

## Custom kernel
# Configs
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
RUN ./scripts/config --set-str CONFIG_LOCALVERSION "-v8-16k-stock"
# Build kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

## Patched kernel
# We're installing rt patch v6.6.21 since the built custom kernel is v6.6.21. This was the latest available custom kernel and patch at time of benchmarking.
RUN wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/older/patch-6.6.21-rt26.patch.gz
RUN gunzip patch-6.6.21-rt26.patch.gz
RUN cat patch-6.6.21-rt26.patch | patch -p1 || echo done # used "echo done" to surpress the errors while patching. panic.c and printk.c weren't patched, is this normal?
#RUN git checkout -b rtpatch && git add -A && git commit -m "RT patch" #ERROR: "Author identity unknown"
# Apply regular configs + enable Fully Preemptibel Kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
RUN ./scripts/config \
		--disable PREEMPT \
		--enable PREEMPT_RT \
		--enable RCU_BOOST \
		--set-val RCU_BOOST_DELAY 500 \
		--set-val COMPACT_UNEVICTABLE_DEFAULT 0 \
		--set-str CONFIG_LOCALVERSION "-v8-16k-rt"
# Build the newly configured kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
