#!/bin/sh
set -ex

TAG="buildrtlinux"
DOCKER_USER="rtuser"
SD_FAT="/media/${USER}/bootfs/"
SD_EXT4="/media/${USER}/rootfs/"

#export BUILDKIT_PROGRESS=plain
export DOCKER_BUILDKIT=0

docker build --build-arg USER_NAME=${DOCKER_USER} --tag ${TAG} .

docker run --volume ${SD_FAT}:/home/${DOCKER_USER}/workspace/linux/mnt/fat32 --volume ${SD_EXT4}:/home/${DOCKER_USER}/workspace/linux/mnt/ext4 ${TAG} ./copy-to-sd.sh
