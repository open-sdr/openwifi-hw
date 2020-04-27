  
#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "You must enter exactly 2 arguments: \$XILINX_DIR \$BOARD_NAME"
    exit 1
fi

XILINX_DIR=$1

if [ -d "$XILINX_DIR/Vivado" ]; then
    echo "\$XILINX_DIR is found!"
else
    echo "\$XILINX_DIR is not correct. Please check!"
    exit 1
fi

BOARD_NAME=$2

# [ "$BOARD_NAME" != "zc706_fmcs2" ] && [ "$BOARD_NAME" != "zc702_fmcs2" ] && [ "$BOARD_NAME" != "zed_fmcs2" ] && [ "$BOARD_NAME" != "adrv9361z7035" ] && [ "$BOARD_NAME" != "adrv9361z7035_fmc" ] && [ "$BOARD_NAME" != "adrv9364z7020" ] && [ "$BOARD_NAME" != "zcu102_fmcs2" ] && [ "$BOARD_NAME" != "zcu102_9371" ]; then

if [ "$BOARD_NAME" == "zcu102_fmcs2" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/fmcomms2/zcu102/
elif [ "$BOARD_NAME" == "zcu102_9371" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/fmcomms2/zcu102/
elif [ "$BOARD_NAME" == "zc706_fmcs2" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/fmcomms2/zc706/
elif [ "$BOARD_NAME" == "zc702_fmcs2" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/fmcomms2/zc702/
elif [ "$BOARD_NAME" == "zed_fmcs2" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/fmcomms2/zed/
elif [ "$BOARD_NAME" == "adrv9361z7035" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/adrv9361z7035/ccbob_lvds/
#elif [ "$BOARD_NAME" == "adrv9361z7035_fmc" ]; then
#    ADI_PROJECT_DIR=./adi-hdl/projects/adrv9361z7035/ccfmc_lvds/
elif [ "$BOARD_NAME" == "adrv9364z7020" ]; then
    ADI_PROJECT_DIR=./adi-hdl/projects/adrv9364z7020/ccbob_lvds/
else
    echo "\$BOARD_NAME is not correct. Please check!"
    exit 1
fi

echo $ADI_PROJECT_DIR

home_dir=$(pwd)

set -x

source $XILINX_DIR/Vivado/2018.3/settings64.sh

cd $ADI_PROJECT_DIR
make

cd $home_dir
