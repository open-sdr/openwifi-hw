



set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS25} [get_ports {gpio_status[0]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {gpio_status[1]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {gpio_status[2]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS25} [get_ports {gpio_status[3]}]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS25} [get_ports {gpio_status[4]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS25} [get_ports {gpio_status[5]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS25} [get_ports {gpio_status[6]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS25} [get_ports {gpio_status[7]}]

set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[0]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[1]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[2]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[3]}]



set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS25} [get_ports gpio_en_agc]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS25} [get_ports gpio_sync]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS25} [get_ports gpio_resetb]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS25} [get_ports enable]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS25} [get_ports txnrx]





set_property PACKAGE_PIN P18 [get_ports spi_csn]
set_property IOSTANDARD LVCMOS25 [get_ports spi_csn]
set_property PULLUP true [get_ports spi_csn]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS25} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS25} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS25} [get_ports spi_miso]

set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS25} [get_ports tx1_en]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS25} [get_ports tx2_en]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS25} [get_ports sel_clk_src]


set_false_path -from [get_clocks phy_rx_clk] -to [get_clocks -of_objects [get_pins clk_wiz_v3_6/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks clk_wiz_v3_6/mmcm_adv_inst/CLKOUT1 ] -to [get_clocks -of_objects [get_pins phy_rx_clk]]





set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_0_5/RAMA/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[0]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_0_5/RAMC/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[4]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_0_5/RAMB/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[2]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_6_7/RAMA/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[6]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_0_5/RAMA_D1/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[1]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_6_7/RAMA_D1/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[7]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_0_5/RAMB_D1/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[3]/D}]
set_false_path -from [get_pins sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/mem_reg_0_15_0_5/RAMC_D1/CLK] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/u0/dout_reg[5]/D}]
set_false_path -from [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/wp_gray_reg[1]/C}] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/wp_s_reg[1]/D}]
set_false_path -from [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/wp_gray_reg[5]/C}] -to [get_pins {sdrpi_gpsdo_ether_socket_eeprom/sdrpi_gpsdo_udp_eeprom/cdc_rx_incoming/cdc_fifo_phy2fpga/generic_fifo_dc_gray/wp_s_reg[5]/D}]