  
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
cd ./adi-hdl/
# git reset --hard 2019_r1
# git reset --hard f61d9707eb0a62533efd6facab59ab2444da94c9
git reset --hard
git fetch
git checkout 2022_R2
git reset --hard 2022_R2

# # the lib need to be built!
source $XILINX_DIR/Vivado/2022.2/settings64.sh
cd library/
make

cd $home_dir
