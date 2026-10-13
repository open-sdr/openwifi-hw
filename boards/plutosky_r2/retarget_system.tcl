# // Author: Fu Wenbo
# // SPDX-FileCopyrightText: 2026 Fu Wenbo
# // SPDX-License-Identifier: AGPL-3.0-or-later

# Apply PlutoSky R2 board settings without modifying the upstream OpenWiFi BD.

set system_bd [get_files -quiet "${origin_dir}/src/system.bd"]
if {[llength $system_bd] != 1} {
  error "Cannot find ${origin_dir}/src/system.bd"
}

open_bd_design $system_bd
set ps7 [get_bd_cells -quiet sys_ps7]
if {[llength $ps7] != 1} {
  error "OpenWiFi system.bd does not contain sys_ps7"
}

# Values are taken from the vendor PlutoSky R2 Vivado project. Existing AXI
# ports and clock outputs remain unchanged, so OpenWiFi address maps are kept.
set_property -dict [list \
  CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
  CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 3.3V} \
  CONFIG.PCW_PACKAGE_NAME {clg484} \
  CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_ENET0_ENET0_IO {EMIO} \
  CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
  CONFIG.PCW_ENET0_GRP_MDIO_IO {EMIO} \
  CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
  CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
  CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
  CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
  CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
  CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
  {CONFIG.PCW_UIPARAM_DDR_PARTNO} {MT41K256M16 RE-125} \
  {CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH} {32 Bit} \
  CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
  CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
  CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
  CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
  CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.048} \
  CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.050} \
  CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.241} \
  CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.240} \
] $ps7

# The R2 AD9361 divider drives the OpenWiFi baseband clock at 40 MHz.  Keep
# the upstream clock-wizard's 100 MHz output while matching that input clock.
set clk_wiz [get_bd_cells -quiet clk_wiz_0]
if {[llength $clk_wiz] != 1} {
  error "OpenWiFi system.bd does not contain clk_wiz_0"
}
set_property -dict [list \
  CONFIG.PRIM_IN_FREQ {40.000} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
] $clk_wiz

# The AD9361 divider output feeds clk_wiz. The shared zc702-derived BD still
# declares the upstream 100 MHz on that pin, which makes validate_bd_design
# fail against the 40 MHz input configured above.
set_property -dict [list CONFIG.FREQ_HZ {40000000}] \
  [get_bd_pins /util_ad9361_divclk/clk_out]

# R2 routes GEM0 through an external GMII-to-RGMII bridge. The upstream ZC702
# design has no board Ethernet ports, so add them only once during recreation.
if {[llength [get_bd_cells -quiet sys_rgmii]] == 0} {
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 MDIO_PHY
  create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII
  create_bd_cell -type ip -vlnv xilinx.com:ip:gmii_to_rgmii:4.1 sys_rgmii
  set_property -dict [list CONFIG.SupportLevel {Include_Shared_Logic_in_Core}] [get_bd_cells sys_rgmii]
  connect_bd_net [get_bd_pins sys_rstgen/peripheral_reset] [get_bd_pins sys_rgmii/tx_reset]
  connect_bd_net [get_bd_pins sys_rstgen/peripheral_reset] [get_bd_pins sys_rgmii/rx_reset]
  connect_bd_net [get_bd_pins sys_ps7/FCLK_CLK1] [get_bd_pins sys_rgmii/clkin]
  connect_bd_intf_net [get_bd_intf_pins sys_ps7/MDIO_ETHERNET_0] [get_bd_intf_pins sys_rgmii/MDIO_GEM]
  connect_bd_intf_net [get_bd_intf_pins sys_ps7/GMII_ETHERNET_0] [get_bd_intf_pins sys_rgmii/GMII]
  connect_bd_intf_net [get_bd_intf_pins sys_rgmii/MDIO_PHY] [get_bd_intf_ports MDIO_PHY]
  connect_bd_intf_net [get_bd_intf_pins sys_rgmii/RGMII] [get_bd_intf_ports RGMII]
}

validate_bd_design
save_bd_design
close_bd_design [current_bd_design]
