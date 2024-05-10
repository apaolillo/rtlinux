#!/bin/sh
set -ex

host_ospert_dir=$(readlink -e ospert/)

host_gen_dir=$(readlink -f ~/Dropbox/Applications/ShareLaTeX/ospert24_rtlinux_dewit/figures)
[ -d "${host_gen_dir}" ] || host_gen_dir=$(readlink -f ./notebook_generated_figures)
mkdir -p ${host_gen_dir}

docker run \
    --rm \
    -ti \
    --network=host \
    --volume "${host_ospert_dir}":/home/wannes/workspace/ospert \
    --volume "${host_gen_dir}":/home/wannes/workspace/generated_figures \
    --workdir /home/wannes/workspace/ospert \
    buildrtlinux \
    /home/wannes/workspace/ospert/run-notebook.sh
