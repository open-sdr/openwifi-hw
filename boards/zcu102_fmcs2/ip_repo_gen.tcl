# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# ------------------setup ip_repo directory and board files---------------------
exec rm -rf ip_repo
exec mkdir ip_repo
exec cp ../../ip/board_def.v ./ip_repo/ -f

# -----------generate git rev info------------------------
set  fd  [open  "./ip_repo/openwifi_hw_git_rev.v"  w]
set HASHCODE [exec ../../get_git_rev.sh]
puts $fd "`define OPENWIFI_HW_GIT_REV (32'h$HASHCODE)"
close $fd
# ----end of generate generate git rev info---------------

# -----------generate has_side_ch_flag.v------------------
# if you want NO side_ch, please use set has_side_ch 0
set has_side_ch 1 
set  fd  [open  "./ip_repo/has_side_ch_flag.v"  w]
if {$has_side_ch > 0} {
  puts $fd "`define HAS_SIDE_CH 1"
} else {
  puts $fd "`define NO_SIDE_CH 1"
}
close $fd
# ----end of generate has_side_ch_flag.v------------------

# ---------generate fpga_scale.v---------------------------
# set small_fpga 1 for 7020 FPGA, set small_fpga 0 for the rest
set small_fpga 0
set  fd  [open  "./ip_repo/fpga_scale.v"  w]
if {$small_fpga == 1} {
  puts $fd "`define SIDE_CH_LESS_BRAM 1"
}
close $fd
# ---------end of generate fpga_scale.v--------------------

# --------generate clock_speed.v for xpu/tx_intf/rx_intf---
set NUM_CLK_PER_US 240
set  fd  [open  "./ip_repo/clock_speed.v"  w]
puts $fd "`define NUM_CLK_PER_US $NUM_CLK_PER_US"
if {$small_fpga == 1} {
  puts $fd "`define SMALL_FPGA 1"
}
close $fd
# --end of generate clock_speed.v for xpu/tx_intf/rx_intf--

# ---------generate spi_command.v---------------------------
# set grounded_rf_port 1 for port control, set 0 for lo control
set grounded_rf_port 0
set  fd  [open  "./ip_repo/spi_command.v"  w]
if {$grounded_rf_port == 1} {
  puts $fd "`define SPI_HIGH 24'hC22001"
  puts $fd "`define SPI_LOW 24'hC02001"
} else {
  puts $fd "`define SPI_HIGH 24'h088A01"
  puts $fd "`define SPI_LOW 24'h008A01"
}
close $fd
# ---------end of generate spi_command.v--------------------

# ------------------end of setup ip_repo directory and board files--------------

# -------------------get BOARD_NAME (for openofdm_rx) via the current dir-------
set BOARD_NAME [lindex [split [exec pwd] /] end]
puts $BOARD_NAME
# ------------end of get BOARD_NAME (for openofdm_rx) via the current dir-------

# --------------------------------generate ip repo------------------------------
set ultra_scale_flag 1
set part_string xczu9eg-ffvb1156-2-e
set argc 4

set ip_name openofdm_rx
if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
exec rm -rf project_1
set current_dir [pwd]
set argv [list $ultra_scale_flag $current_dir/../../ip/$ip_name $current_dir/ip_repo/$ip_name $BOARD_NAME]
source ../package_ip_openofdm_rx.tcl
exec cat ./ip_config/$ip_name\_pre_def.v >> ./ip_repo/$ip_name/src/$ip_name\_pre_def.v
exec rm -rf ./ip_repo/$ip_name/xgui

set ip_name openofdm_tx
if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
exec rm -rf project_1
exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
source ../package_ip.tcl
exec rm -rf ./ip_repo/$ip_name/xgui

set ip_name rx_intf
if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
exec rm -rf project_1
exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
source ../package_ip.tcl
exec rm -rf ./ip_repo/$ip_name/xgui

set ip_name tx_intf
if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
exec rm -rf project_1
exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
source ../package_ip.tcl
exec rm -rf ./ip_repo/$ip_name/xgui

set ip_name xpu
if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
exec rm -rf project_1
exec cp ./ip_repo/openwifi_hw_git_rev.v ../../ip/$ip_name/src/ -f
exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
exec cp ./ip_repo/spi_command.v ../../ip/$ip_name/src/ -f
exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
source ../package_ip.tcl
exec rm -rf ./ip_repo/$ip_name/xgui

set ip_name side_ch
if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
exec rm -rf project_1
exec cp ./ip_repo/fpga_scale.v ../../ip/$ip_name/src/ -f
exec cp ./ip_repo/has_side_ch_flag.v ../../ip/$ip_name/src/ -f
exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
source ../package_ip.tcl
exec rm -rf ./ip_repo/$ip_name/xgui
# ---------------------------------end of generate ip repo-----------------------

# exit
