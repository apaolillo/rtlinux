FROM debian:stable

RUN apt-get update && \
    apt-get install -y sudo git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 wget kmod
RUN apt-get install -y vim
RUN apt-get install -y python3 python3-venv

# Username passed as build-arg
ARG USER_NAME
ARG UID=1000
ARG GID=1000
RUN addgroup --gid 1000 ${USER_NAME} 
RUN adduser --disabled-password --uid $UID --gid $GID --gecos "" ${USER_NAME}
RUN newgrp sudo && \
    usermod -aG sudo ${USER_NAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10-docker
USER ${USER_NAME}

# Configure git
RUN git config --global init.defaultBranch main
RUN git config --global user.email "rtuser@vub.be"
RUN git config --global user.name "RT User"

# Get the kernel sources
RUN mkdir -p /home/${USER_NAME}/workspace
WORKDIR /home/${USER_NAME}/workspace
RUN git clone https://github.com/raspberrypi/linux.git
WORKDIR /home/${USER_NAME}/workspace/linux
# Commit of bumped kernel to 6.6.21:
RUN git checkout fc59dcb071ed17605d39565d2ec02ae0917529fd
ARG KERNEL_VERSION=6.6.21
WORKDIR /home/${USER_NAME}/workspace
RUN cp -a linux linux-rt
RUN mv linux linux-stock
WORKDIR /home/${USER_NAME}/workspace/linux-stock
RUN git checkout -b "stock-${KERNEL_VERSION}"

RUN mkdir -p /home/${USER_NAME}/workspace/patch
WORKDIR /home/${USER_NAME}/workspace/patch
# We're installing rt patch v6.6.21 since the built custom kernel is v6.6.21.
# This was the latest available custom kernel and patch at time of benchmarking.
ARG PATCH_NAME=patch-${KERNEL_VERSION}-rt26
RUN wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/6.6/older/${PATCH_NAME}.patch.gz
RUN gunzip ${PATCH_NAME}.patch.gz

# Rpi5
# ENV KERNEL=kernel_2712
# ENV DEFCONFIG=bcm2712_defconfig

# Rpi4
ENV KERNEL=kernel8
ENV DEFCONFIG=bcm2711_defconfig

## Stock kernel
WORKDIR /home/${USER_NAME}/workspace/linux-stock
# Configs
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ${DEFCONFIG}
RUN ./scripts/config --set-str CONFIG_LOCALVERSION "-v8-16k-stock"
# Build kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

## Patched kernel
WORKDIR /home/${USER_NAME}/workspace/linux-rt
RUN patch -p1 < /home/${USER_NAME}/workspace/patch/${PATCH_NAME}.patch
RUN git checkout -b "rtpatch-${KERNEL_VERSION}" && git add -A && git commit -m "RT patch"
# Apply regular configs + enable Fully Preemptive Kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ${DEFCONFIG}
RUN ./scripts/config \
        --disable PREEMPT \
        --enable PREEMPT_RT \
        --enable RCU_BOOST \
        --set-val RCU_BOOST_DELAY 500 \
        --set-val COMPACT_UNEVICTABLE_DEFAULT 0 \
        --set-str CONFIG_LOCALVERSION "-v8-16k-rt"
# Build the newly configured kernel
RUN make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

WORKDIR /home/${USER_NAME}/workspace
COPY --chown=${USER_NAME}:${USER_NAME} copy-to-sd.sh .
RUN mkdir -p /home/${USER_NAME}/workspace/sdcard
