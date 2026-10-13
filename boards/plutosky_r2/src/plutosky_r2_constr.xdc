# constraints
# ad9361 (SWAP == 0x1)
set_property  -dict {PACKAGE_PIN  B15   IOSTANDARD  LVCMOS25} [get_ports  MDIO_PHY_mdio_io]   ;
set_property  -dict {PACKAGE_PIN  C15   IOSTANDARD  LVCMOS25} [get_ports  MDIO_PHY_mdc]       ;
set_property  -dict {PACKAGE_PIN  B16   IOSTANDARD  LVCMOS25} [get_ports  RGMII_td[3]]  ;
set_property  -dict {PACKAGE_PIN  A16   IOSTANDARD  LVCMOS25} [get_ports  RGMII_td[2]]  ;
set_property  -dict {PACKAGE_PIN  B17   IOSTANDARD  LVCMOS25} [get_ports  RGMII_td[1]]  ;
set_property  -dict {PACKAGE_PIN  A17   IOSTANDARD  LVCMOS25} [get_ports  RGMII_td[0]]  ;
set_property  -dict {PACKAGE_PIN  A22   IOSTANDARD  LVCMOS25} [get_ports  RGMII_rd[3]]  ;
set_property  -dict {PACKAGE_PIN  A18   IOSTANDARD  LVCMOS25} [get_ports  RGMII_rd[2]]  ;
set_property  -dict {PACKAGE_PIN  A19   IOSTANDARD  LVCMOS25} [get_ports  RGMII_rd[1]]  ;
set_property  -dict {PACKAGE_PIN  A21   IOSTANDARD  LVCMOS25} [get_ports  RGMII_rd[0]]  ;

set_property  -dict {PACKAGE_PIN  C17   IOSTANDARD  LVCMOS25} [get_ports  RGMII_tx_ctl]  ;
set_property  -dict {PACKAGE_PIN  D18   IOSTANDARD  LVCMOS25} [get_ports  RGMII_txc]     ;
set_property  -dict {PACKAGE_PIN  C18   IOSTANDARD  LVCMOS25} [get_ports  RGMII_rx_ctl]  ;
set_property  -dict {PACKAGE_PIN  B19   IOSTANDARD  LVCMOS25} [get_ports  RGMII_rxc]     ;

set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports rx_clk_in_p]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports rx_clk_in_n]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports rx_frame_in_p]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports rx_frame_in_n]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_p[0]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_n[0]}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_p[1]}]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_n[1]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_p[2]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_n[2]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_p[3]}]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_n[3]}]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_p[4]}]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_n[4]}]
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_p[5]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports {rx_data_in_n[5]}]
set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVDS_25} [get_ports tx_clk_out_p]
set_property -dict {PACKAGE_PIN Y5 IOSTANDARD LVDS_25} [get_ports tx_clk_out_n]
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVDS_25} [get_ports tx_frame_out_p]
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVDS_25} [get_ports tx_frame_out_n]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[0]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[0]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[1]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[1]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[2]}]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[2]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[3]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[3]}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[4]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[4]}]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVDS_25} [get_ports {tx_data_out_p[5]}]
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVDS_25} [get_ports {tx_data_out_n[5]}]

set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS25} [get_ports {gpio_status[0]}]
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS25} [get_ports {gpio_status[1]}]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS25} [get_ports {gpio_status[2]}]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS25} [get_ports {gpio_status[3]}]
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS25} [get_ports {gpio_status[4]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS25} [get_ports {gpio_status[5]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS25} [get_ports {gpio_status[6]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS25} [get_ports {gpio_status[7]}]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[0]}]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[1]}]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[2]}]
set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS25} [get_ports {gpio_ctl[3]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS25} [get_ports gpio_en_agc]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS25} [get_ports gpio_sync]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS25} [get_ports gpio_resetb]
set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS25} [get_ports enable]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS25} [get_ports txnrx]


set_property  -dict {PACKAGE_PIN  V10  IOSTANDARD LVCMOS25  PULLTYPE PULLUP} [get_ports spi_csn]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS25} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS25} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS25} [get_ports spi_miso]

set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports pll_le]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports pll_clk]
set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33} [get_ports pll_mosi]
set_property -dict {PACKAGE_PIN Y19  IOSTANDARD LVCMOS33} [get_ports i_clk]


set_property  -dict {PACKAGE_PIN  H17  IOSTANDARD LVCMOS25 PULLTYPE PULLUP} [get_ports iic_scl]
set_property  -dict {PACKAGE_PIN  F16  IOSTANDARD LVCMOS25 PULLTYPE PULLUP} [get_ports iic_sda]

create_clock -period 4.000 -name rx_clk [get_ports rx_clk_in_p]
create_clock -period  8.000          [get_ports RGMII_rxc]

# probably gone in 2016.4

create_clock -name clk_fpga_0 -period 10 [get_pins "i_system_wrapper/system_i/sys_ps7/inst/PS7_i/FCLKCLK[0]"]
create_clock -name clk_fpga_1 -period  5 [get_pins "i_system_wrapper/system_i/sys_ps7/inst/PS7_i/FCLKCLK[1]"]

create_clock -name spi0_clk      -period 40   [get_pins -hier */EMIOSPI0SCLKO]

set_input_jitter clk_fpga_0 0.3
set_input_jitter clk_fpga_1 0.15


# On-board reference clock on Y19, feeding the ADF4001 initialisation logic in
# system_top.v. Without these constraints that logic is not timed at all.
create_clock -name i_clk -period 25.000 [get_ports i_clk]

# system_top.v divides i_clk by 8 in fabric to clock ADF4001_init.
create_generated_clock -name adf4001_spi_clk -source [get_ports i_clk] \
	-divide_by 8 [get_pins -hier -filter {NAME =~ *adf4001_spi_clk_reg/Q}]

# The ADF4001 block is self-contained: it has no data path to or from the rest
# of the design, and its SPI output pins have no timing relation to any clock.
set_clock_groups -asynchronous -group [get_clocks {i_clk adf4001_spi_clk}]
set_false_path -to [get_ports {pll_le pll_clk pll_mosi}]
