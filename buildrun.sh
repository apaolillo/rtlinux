#!/bin/sh
set -ex

export DOCKER_BUILDKIT=0

docker build --tag rtwannes .
