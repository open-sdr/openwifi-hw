# // Author: Fu Wenbo
# // SPDX-FileCopyrightText: 2026 Fu Wenbo
# // SPDX-License-Identifier: AGPL-3.0-or-later

# Vivado 2020.2 entry point for the PlutoSky R2 OpenWiFi project.
#
# The ADI HDL IP comes from the adi-hdl submodule, like every other board.
# This script only supplies Git's POSIX utilities to Vivado on Windows, then
# starts the regular OpenWiFi generator. The board and packaged-IP run
# settings are stored as Vivado 2020 flow names in their respective Tcl files.

set script_dir [file dirname [file normalize [info script]]]
cd $script_dir

if {$::tcl_platform(platform) eq "windows"} {
  set git_usr_bin {C:/Program Files/Git/usr/bin}
  if {[file isdirectory $git_usr_bin]} {
    set ::env(PATH) "$git_usr_bin;$::env(PATH)"
  }
}

if {![file exists ../../adi-hdl/library/axi_ad9361/component.xml]} {
  error "The ADI HDL library is not packaged yet.\
         From the repository root run:\
         git submodule update --init adi-hdl\
         then ./prepare_adi_lib.sh <XILINX_DIR> on Linux,\
         or .\\prepare_adi_lib.ps1 -Vivado <path to vivado.bat> on Windows."
}

puts "PlutoSky R2: starting the Vivado 2020 OpenWiFi build."
source ../ip_repo_gen.tcl
