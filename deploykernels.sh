#!/bin/sh
set -e

bootfs=$1
rootfs=$2

if [ -z "${bootfs}" ] || [ -z "${rootfs}" ]
then
  echo "Usage: $0 <path_mounted_bootfs> <path_mounted_rootfs>" >&2
  exit 1
fi

script_dir=$(readlink -e "$(dirname "$0")")
export DOCKER_TAG="buildrtlinux"
export DOCKER_USER="rtuser"

"${script_dir}/buildimage.sh"

SD_FAT=$(readlink -e "${bootfs}")
SD_EXT4=$(readlink -e "${rootfs}")

docker run \
    --volume "${SD_FAT}:/home/${DOCKER_USER}/workspace/sdcard/fat32" \
    --volume "${SD_EXT4}:/home/${DOCKER_USER}/workspace/sdcard/ext4" \
    "${DOCKER_TAG}" \
    ./copy-to-sd.sh
