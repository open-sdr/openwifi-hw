#!/bin/bash

# Author: Xianjun jiao
# SPDX-FileCopyrightText: 2022 UGent
# SPDX-License-Identifier: AGPL-3.0-or-later

print_usage () {
  echo "usage:"
  echo "create_ip_repo.sh \$XILINX_DIR"
  echo "or"
  echo "create_ip_repo.sh \$XILINX_DIR \$IP1_NAME \$DEF1 \$DEF2 ... \$IP2_NAME \$DEF1 ..."
  echo " -IP_NAME: only xpu/tx_intf/rx_intf/openofdm_tx/openofdm_rx/side_ch are allowed"
  echo " -   DEFx: will be \"\`define IP_NAME_DEFx\" in ip_name_pre_def.v for \$IP_NAME"
  echo " "
}

print_usage

if [ "$#" -lt 1 ]; then
    exit 1
fi

XILINX_DIR=$1

start_to_write=0
mkdir -p ip_config
rm -rf ip_config/*

IP_NAME_ALL="xpu tx_intf rx_intf openofdm_tx openofdm_rx side_ch"
for IP_NAME in $IP_NAME_ALL
do
    filename_to_write=ip_config/$IP_NAME"_pre_def.v"
    echo "//Naming pre_def.v differently for all IPs." > $filename_to_write
    echo "//Multiple pre_def.v with different content for different IP are not allowed in the final signle Vivado project!" >> $filename_to_write
done

MODULE_NAME=""
for ARGUMENT in "$@"
do
    # echo "$ARGUMENT"
    
    if [ "$ARGUMENT" = "xpu" ] || [ "$ARGUMENT" = "tx_intf" ] || [ "$ARGUMENT" = "rx_intf" ] || [ "$ARGUMENT" = "openofdm_tx" ] || [ "$ARGUMENT" = "openofdm_rx" ] || [ "$ARGUMENT" = "side_ch" ]; then
        start_to_write=1
    fi

    if [ $start_to_write == "1" ]; then
        if [ "$ARGUMENT" = "xpu" ] || [ "$ARGUMENT" = "tx_intf" ] || [ "$ARGUMENT" = "rx_intf" ] || [ "$ARGUMENT" = "openofdm_tx" ] || [ "$ARGUMENT" = "openofdm_rx" ] || [ "$ARGUMENT" = "side_ch" ]; then
            filename_to_write=ip_config/$ARGUMENT"_pre_def.v"
            echo "" >> $filename_to_write
            echo "//Pre defines for IP $ARGUMENT. Please align with those when you design/customize/modify the IP" >> $filename_to_write
            
            echo ""
            MODULE_NAME=${ARGUMENT^^}
            echo "$MODULE_NAME:"
        else
            echo "\`define ${MODULE_NAME}_${ARGUMENT}" >> $filename_to_write

            echo "\`define ${MODULE_NAME}_${ARGUMENT}"
        fi
    fi
done

source $XILINX_DIR/SDK/2018.3/settings64.sh

set -x
vivado -source ./ip_repo_gen.tcl
set +x
