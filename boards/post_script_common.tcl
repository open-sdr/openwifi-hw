# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2025 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# common operations for all boards at the end of openwifi.tcl

open_bd_design {./src/system.bd}

if {$BOARD_NAME!="rfsoc4x2"} {
  set_property CONFIG.FREQ_HZ 40000000 [get_bd_pins /util_ad9361_divclk/clk_out]
}

update_compile_order -fileset sources_1

report_ip_status -name ip_status 
upgrade_ip [get_ips  {system_rx_intf_0_0 system_tx_intf_0_0 system_openofdm_tx_0_0 system_xpu_0_0 system_side_ch_0_0}] -log ip_upgrade.log
export_ip_user_files -of_objects [get_ips {system_rx_intf_0_0 system_tx_intf_0_0 system_openofdm_tx_0_0 system_xpu_0_0 system_side_ch_0_0}] -no_script -sync -force -quiet
report_ip_status -name ip_status 

save_bd_design
