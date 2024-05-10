#!/bin/sh
set -ex

DOCKER_USER="rtuser"

host_ospert_dir=$(readlink -e ospert/)

host_gen_dir=$(readlink -f ~/Dropbox/Applications/ShareLaTeX/ospert24_rtlinux_dewit/figures)
[ -d "${host_gen_dir}" ] || host_gen_dir=$(readlink -f ./notebook_generated_figures)
mkdir -p ${host_gen_dir}

docker run \
    --rm \
    -ti \
    --network=host \
    --volume "${host_ospert_dir}":/home/$DOCKER_USER/workspace/ospert \
    --volume "${host_gen_dir}":/home/$DOCKER_USER/workspace/generated_figures \
    --workdir /home/$DOCKER_USER/workspace/ospert \
    buildrtlinux \
    /home/$DOCKER_USER/workspace/ospert/run-notebook.sh
