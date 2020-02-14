#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "You must enter the BOARD_NAME as argument"
    echo "Like: adrv9361z7035/adrv9361z7035_fmc/zc706_fmcs2/zed_fmcs2"
    exit 1
fi

set -ex

BOARD_NAME=$1
echo $BOARD_NAME

cp $BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.sdk/system_top_hw_platform_0 $BOARD_NAME/sdk/ -rf
cp $BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx $BOARD_NAME/sdk/
git add $BOARD_NAME/sdk/*


