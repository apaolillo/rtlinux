#!/bin/sh
set -ex

TAG = "rtwannes"
USER_NAME = "wannes"
SD_FAT = "/media/wannes/bootfs/"
SD_EXT4 = "/media/wannes/rootfs/"

export DOCKER_BUILDKIT=0

docker build --build-arg USER_NAME=${USER_NAME} --tag ${TAG} .

docker run --volume ${SD_FAT}:/home/${USER_NAME}/linux/mnt/fat32 --volume ${SD_EXT4}:/home/${USER_NAME}/linux/mnt/ext4 ${TAG} ./copy-to-sd.sh
