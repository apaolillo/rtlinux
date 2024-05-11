#!/bin/sh
set -ex

export DOCKER_BUILDKIT=0

DOCKER_TAG=${DOCKER_TAG}
[ -z "${DOCKER_TAG}" ] && DOCKER_TAG="buildrtlinux"
DOCKER_USER=${DOCKER_USER}
[ -z "${DOCKER_USER}" ] && DOCKER_USER="rtuser"

docker build --build-arg USER_NAME="${DOCKER_USER}" --tag "${DOCKER_TAG}" .
