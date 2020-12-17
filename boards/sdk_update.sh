#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "You must enter the BOARD_NAME as argument"
    echo "Like: adrv9364z7020 adrv9361z7035 zc706_fmcs2 zed_fmcs2 zc702_fmcs2 zcu102_fmcs2 zcu102_9371"
    exit 1
fi

set -ex

BOARD_NAME=$1
echo $BOARD_NAME

if test -d "$BOARD_NAME/sdk"; then
    echo "Found $BOARD_NAME/sdk"
else
    echo "Create $BOARD_NAME/sdk"
    mkdir $BOARD_NAME/sdk
fi

cp $BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.sdk/system_top_hw_platform_0 $BOARD_NAME/sdk/ -rf
git add $BOARD_NAME/sdk/*
if [ -f "$BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx" ]; then
    cp $BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx $BOARD_NAME/sdk/
else
    echo "No debug probe file found."
fi
git add $BOARD_NAME/sdk/*


