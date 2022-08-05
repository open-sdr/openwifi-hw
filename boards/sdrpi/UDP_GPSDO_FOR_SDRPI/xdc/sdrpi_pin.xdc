

set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS25} [get_ports pps_in]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS25} [get_ports clk_40m]
create_clock -period 25.000 -name clk_40m [get_ports clk_40m]


set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS25} [get_ports dac_nsyc]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS25} [get_ports dac_din]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS25} [get_ports dac_clk]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS25} [get_ports gps_pl_led]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS25} [get_ports sel_clk_src]




set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS25} [get_ports phy_tx_en]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS25} [get_ports phy_tx_err]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS25} [get_ports phy_reset_n]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[0]}]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[1]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[2]}]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[3]}]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[4]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[5]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[6]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS25} [get_ports {phy_tx_dout[7]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS25} [get_ports phy_tx_clk]

set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS25} [get_ports phy_rx_err]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS25} [get_ports phy_rx_clk]


create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[0]}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[1]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[2]}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[3]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[4]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[5]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[6]}]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS25} [get_ports {phy_rx_din[7]}]


set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS25} [get_ports phy_rx_dv]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS25} [get_ports phy_gtx_clk]

set_property PACKAGE_PIN M14 [get_ports scl]
set_property IOSTANDARD LVCMOS25 [get_ports scl]
set_property PULLUP true [get_ports scl]
set_property PACKAGE_PIN M15 [get_ports sda]
set_property IOSTANDARD LVCMOS25 [get_ports sda]
set_property PULLUP true [get_ports sda]

