#!/bin/bash

home_dir=$(pwd)

set -x
cd ip/
git submodule init openofdm_rx
git submodule update openofdm_rx
cd openofdm_rx
git checkout dot11zynq
git pull

cd $home_dir
