#!/bin/sh
set -ex

venv_dir=/home/wannes/workspace/ospert/venv

if [ -d "${venv_dir}" ]
then
    /home/wannes/workspace/ospert/venv/bin/jupyter notebook
else
    bash
fi
