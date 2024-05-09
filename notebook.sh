#!/bin/sh
set -ex

docker run --rm -ti --network=host --volume $(readlink -e ospert/):/home/wannes/workspace/ospert --workdir /home/wannes/workspace/ospert buildrtlinux /home/wannes/workspace/ospert/venv/bin/jupyter notebook
