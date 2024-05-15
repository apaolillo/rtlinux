#!/bin/sh
set -ex

venv_dir=${HOME}/workspace/ospert/venv

if [ -d "${venv_dir}" ]
then
    ${HOME}/workspace/ospert/venv/bin/jupyter notebook
else
    bash
fi
