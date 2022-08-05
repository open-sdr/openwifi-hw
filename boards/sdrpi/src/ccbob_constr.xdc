
## constraints (ccbrk.c + ccbrk_lb.a)
## ad9361 clkout forward

set_property  -dict {PACKAGE_PIN   J18    IOSTANDARD  LVCMOS33} [get_ports  clkout_out]  
set_property  -dict {PACKAGE_PIN   H17    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[0]]  
set_property  -dict {PACKAGE_PIN   H15    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[1]]  
set_property  -dict {PACKAGE_PIN   L19    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[2]]  
set_property  -dict {PACKAGE_PIN   L16    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[3]]  
set_property  -dict {PACKAGE_PIN   K14    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[4]]  
set_property  -dict {PACKAGE_PIN   L17    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[5]]  
set_property  -dict {PACKAGE_PIN   M17    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[6]]  
set_property  -dict {PACKAGE_PIN   M18    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[7]]  
set_property  -dict {PACKAGE_PIN   F19    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[8]]  
set_property  -dict {PACKAGE_PIN   F20    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[9]]  
set_property  -dict {PACKAGE_PIN   G19    IOSTANDARD  LVCMOS33} [get_ports  gpio_bd[10]] 

set_property  -dict {PACKAGE_PIN  G14  IOSTANDARD LVCMOS33} [get_ports rx1_band_sel_h]
set_property  -dict {PACKAGE_PIN  C20  IOSTANDARD LVCMOS33} [get_ports rx1_band_sel_l]
set_property  -dict {PACKAGE_PIN  B19  IOSTANDARD LVCMOS33} [get_ports tx1_band_sel_h]
set_property  -dict {PACKAGE_PIN  B20  IOSTANDARD LVCMOS33} [get_ports tx1_band_sel_l]
set_property  -dict {PACKAGE_PIN  E17  IOSTANDARD LVCMOS33} [get_ports rx2_band_sel_h]
set_property  -dict {PACKAGE_PIN  A20  IOSTANDARD LVCMOS33} [get_ports rx2_band_sel_l]
set_property  -dict {PACKAGE_PIN  D18  IOSTANDARD LVCMOS33} [get_ports tx2_band_sel_h]
set_property  -dict {PACKAGE_PIN  D19  IOSTANDARD LVCMOS33} [get_ports tx2_band_sel_l]
