#!/bin/bash

# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

if [ "$#" -ne 1 ]; then
    echo "You must enter the BOARD_NAME as argument"
    echo "Like: antsdr adrv9364z7020 adrv9361z7035 zc706_fmcs2 zed_fmcs2 zc702_fmcs2 zcu102_fmcs2 zcu102_9371"
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
# git add $BOARD_NAME/sdk/*
if [ -f "$BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx" ]; then
    cp $BOARD_NAME/openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx $BOARD_NAME/sdk/
else
    echo "No debug probe file found."
fi

tar -zcvf $BOARD_NAME/sdk/system_top_hw_platform_0/hdf_and_bit.tar.gz $BOARD_NAME/sdk/system_top_hw_platform_0/system.hdf $BOARD_NAME/sdk/system_top_hw_platform_0/system_top.bit
rm $BOARD_NAME/sdk/system_top_hw_platform_0/system.hdf $BOARD_NAME/sdk/system_top_hw_platform_0/system_top.bit

rm -rf $BOARD_NAME/sdk/git_info.txt
echo "openwifi-hw-git-branch" >> $BOARD_NAME/sdk/git_info.txt
git branch >> $BOARD_NAME/sdk/git_info.txt
echo " " >> $BOARD_NAME/sdk/git_info.txt
echo "openwifi-hw-git-commit" >> $BOARD_NAME/sdk/git_info.txt
git log -3 >> $BOARD_NAME/sdk/git_info.txt
echo " " >> $BOARD_NAME/sdk/git_info.txt
echo "openofdm_rx-git-branch" >> $BOARD_NAME/sdk/git_info.txt
git --git-dir ../ip/openofdm_rx/.git branch >> $BOARD_NAME/sdk/git_info.txt
echo " " >> $BOARD_NAME/sdk/git_info.txt
echo "openofdm_rx-git-commit" >> $BOARD_NAME/sdk/git_info.txt
git --git-dir ../ip/openofdm_rx/.git log -3 >> $BOARD_NAME/sdk/git_info.txt
echo " " >> $BOARD_NAME/sdk/git_info.txt

# git add $BOARD_NAME/sdk/*


