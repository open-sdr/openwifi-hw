  
#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "You must enter exactly 1 arguments: \$XILINX_DIR"
    exit 1
fi

XILINX_DIR=$1

if [ -d "$XILINX_DIR/Vivado" ]; then
    echo "\$XILINX_DIR is found!"
else
    echo "\$XILINX_DIR is not correct. Please check!"
    exit 1
fi

home_dir=$(pwd)

set -x

git submodule init adi-hdl
git submodule update adi-hdl
cd ./adi-hdl/library
git reset --hard 2018_r1
source $XILINX_DIR/Vivado/2017.4/settings64.sh
make

cd $home_dir
