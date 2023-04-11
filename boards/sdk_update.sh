#!/bin/bash

# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

if [ "$#" -ne 2 ]; then
    echo "You must enter the \$BOARD_NAME and \$OPENWIFI_HW_IMG_DIR as argument"
    echo "Like: antsdr antsdr_e200 sdrpi e310v2 adrv9364z7020 adrv9361z7035 zc706_fmcs2 zed_fmcs2 zc702_fmcs2 zcu102_fmcs2 zcu102_9371 neptunesdr"
    exit 1
fi

set -ex

BOARD_NAME=$1
OPENWIFI_HW_IMG_DIR=$2
echo $BOARD_NAME
echo $OPENWIFI_HW_IMG_DIR

TARGET_SDK_DIR=$OPENWIFI_HW_IMG_DIR/boards/$BOARD_NAME/sdk/
if test -d "$TARGET_SDK_DIR"; then
    echo "Found $TARGET_SDK_DIR"
else
    echo "Create $TARGET_SDK_DIR"
    mkdir $TARGET_SDK_DIR -p
fi

rm -rf $TARGET_SDK_DIR/*
cp $BOARD_NAME/openwifi_$BOARD_NAME/system_top.xsa $TARGET_SDK_DIR/ -rf
if [ -f "$BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx" ]; then
    cp $BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx $TARGET_SDK_DIR/ -rf
else
    echo "No debug probe file found."
fi

echo "openwifi-hw-git-branch" >> $TARGET_SDK_DIR//git_info.txt
git branch >> $TARGET_SDK_DIR//git_info.txt
echo " " >> $TARGET_SDK_DIR//git_info.txt
echo "openwifi-hw-git-commit" >> $TARGET_SDK_DIR//git_info.txt
git log -3 >> $TARGET_SDK_DIR//git_info.txt
echo " " >> $TARGET_SDK_DIR//git_info.txt
echo "openofdm_rx-git-branch" >> $TARGET_SDK_DIR//git_info.txt
git --git-dir ../ip/openofdm_rx/.git branch >> $TARGET_SDK_DIR//git_info.txt
echo " " >> $TARGET_SDK_DIR//git_info.txt
echo "openofdm_rx-git-commit" >> $TARGET_SDK_DIR//git_info.txt
git --git-dir ../ip/openofdm_rx/.git log -3 >> $TARGET_SDK_DIR//git_info.txt
echo " " >> $TARGET_SDK_DIR//git_info.txt
