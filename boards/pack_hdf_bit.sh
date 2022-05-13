#!/bin/bash

# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

BOARD_NAME_ALL="antsdr zc706_fmcs2 zed_fmcs2 zc702_fmcs2 adrv9361z7035 adrv9364z7020 zcu102_fmcs2"
for BOARD_NAME in $BOARD_NAME_ALL
do
    tar -zcvf $BOARD_NAME/sdk/system_top_hw_platform_0/hdf_and_bit.tar.gz $BOARD_NAME/sdk/system_top_hw_platform_0/system.hdf $BOARD_NAME/sdk/system_top_hw_platform_0/system_top.bit
    rm $BOARD_NAME/sdk/system_top_hw_platform_0/system.hdf $BOARD_NAME/sdk/system_top_hw_platform_0/system_top.bit
done
