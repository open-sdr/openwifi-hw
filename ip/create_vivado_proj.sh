#!/bin/bash

# Author: Xianjun jiao
# SPDX-FileCopyrightText: 2025 UGent
# SPDX-License-Identifier: AGPL-3.0-or-later

print_usage () {
  echo "usage:"
  echo "Need at least 2 arguments: \$XILINX_DIR \$TCL_FILENAME"
  echo "More arguments (max 7) will be passed as arguments to the .tcl script to create ip_name_pre_def.v"
  echo "Among these max 7 arguments:"
  echo "- the 1st:     BOARD_NAME (antsdr antsdr_e200 e310v2 sdrpi zc706_fmcs2 zed_fmcs2 zc702_fmcs2 adrv9361z7035 adrv9364z7020 zcu102_fmcs2 neptunesdr)"
  echo "- the 2nd:     NUM_CLK_PER_US (for example: input 100 for 100MHz)"
  echo "- the 3rd-7th: User pre defines (assume it is ABC) for conditional compiling. Will be \`define IP_NAME_ABC in ip_name_pre_def.v"
  echo "  - the 3rd exception: in the case of openofdm_rx, it indicates SAMPLE_FILE for simulation. Can be changed later in openofdm_rx_pre_def.v"
}

print_usage

if [ "$#" -lt 2 ]; then
    exit 1
fi

XILINX_DIR=$1
TCL_FILENAME=$2

echo XILINX_DIR $XILINX_DIR
echo TCL_FILENAME $TCL_FILENAME

if [ -d "$XILINX_DIR/Vivado" ]; then
    echo "$XILINX_DIR is found!"
else
    echo "$XILINX_DIR is not correct. Please check!"
    exit 1
fi

if [ -f "$TCL_FILENAME" ]; then
    echo "$TCL_FILENAME is found!"
else
    echo "$TCL_FILENAME does NOT exist. Please check!"
    exit 1
fi

source $XILINX_DIR/Vivado/2022.2/settings64.sh

ARG1=""
ARG2=""
ARG3=""
ARG4=""
ARG5=""
ARG6=""
ARG7=""

if [[ -n $3 ]]; then
    ARG1=$3
fi
if [[ -n $4 ]]; then
    ARG2=$4
fi
if [[ -n $5 ]]; then
    ARG3=$5
fi
if [[ -n $6 ]]; then
    ARG4=$6
fi
if [[ -n $7 ]]; then
    ARG5=$7
fi
if [[ -n $8 ]]; then
    ARG6=$8
fi
if [[ -n $9 ]]; then
    ARG7=$9
fi

set -x
vivado -source $TCL_FILENAME -tclargs $ARG1 $ARG2 $ARG3 $ARG4 $ARG5 $ARG6 $ARG7
set +x

