#!/bin/sh
set -ex

if [ -z "$1" ]
  then
		echo -n "Please enter the name of the inserted SD card: "
		read cardname
	else
		cardname=$1
fi

TAG="buildrtlinux"
DOCKER_USER="rtuser"
SD_FAT="/media/${cardname}/bootfs/"
SD_EXT4="/media/${cardname}/rootfs/"

#export BUILDKIT_PROGRESS=plain
export DOCKER_BUILDKIT=0

docker build --build-arg USER_NAME=${DOCKER_USER} --tag ${TAG} .

docker run --volume ${SD_FAT}:/home/${DOCKER_USER}/workspace/linux/mnt/fat32 --volume ${SD_EXT4}:/home/${DOCKER_USER}/workspace/linux/mnt/ext4 ${TAG} ./copy-to-sd.sh
