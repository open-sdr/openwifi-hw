#set_clock_groups -asynchronous -group [get_clocks [list i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_out]] -group [get_clocks [list i_system_wrapper/system_i/sys_ps8/inst/pl_clk2]]
#set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O]] -to [get_clocks clk_pl_2]
#set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O]] -to [get_clocks clk_pl_2]

## relax cross rf and bb domain control of adc_intf
#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/wren_count_reg[0]/R}]
#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/wren_count_reg[1]/R}]
#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/wren_count_reg[2]/R}]
#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/wren_count_reg[3]/R}]

#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/fifo32_2clk_dep32_i/fifo_generator_0/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/C] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/FULL_internal_in_bb_domain_reg/D]

#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_decimate_reg_reg/D]
#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica/C] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_decimate_reg_reg/D]
#set_false_path -from [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica_1/C] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_decimate_reg_reg/D]

#set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/D]
#set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/D]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/C]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/D]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/Q]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/R]

#set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_adc_pack/inst/i_cpack/packed_fifo_wr_en_reg/C] -to [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/D]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/C]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/D]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/Q]
#set_false_path -through [get_pins i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/R]

# relax cross rf and bb domain control of dac_intf
set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/syncstages_ff_reg[3][0]/C}]
# set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/syncstages_ff_reg[3][0]/D}]
# set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/syncstages_ff_reg[3][0]/Q}]
# set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/syncstages_ff_reg[3][0]/R}]

set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/syncstages_ff_reg[3][0]/C}]
# set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/syncstages_ff_reg[3][0]/D}]
# set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/syncstages_ff_reg[3][0]/Q}]
# set_false_path -through [get_pins {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/syncstages_ff_reg[3][0]/R}]


# iic

set_property  -dict {PACKAGE_PIN  U7   IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_scl]           ; 
set_property  -dict {PACKAGE_PIN  V7   IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports iic_sda]           ; 
set_property  -dict {PACKAGE_PIN  W6   IOSTANDARD LVCMOS33} [get_ports gpio_clksel]                       ; 


#################################################################################################################
#
# AD9361
#
#################################################################################################################
set_property  -dict {PACKAGE_PIN   V13    IOSTANDARD LVCMOS25} [get_ports gpio_status[7]]                    ; 
set_property  -dict {PACKAGE_PIN   U13    IOSTANDARD LVCMOS25} [get_ports gpio_status[6]]                    ; 
set_property  -dict {PACKAGE_PIN   T20    IOSTANDARD LVCMOS25} [get_ports gpio_status[5]]                    ; 
set_property  -dict {PACKAGE_PIN   T19    IOSTANDARD LVCMOS25} [get_ports gpio_status[4]]                    ; 
set_property  -dict {PACKAGE_PIN   T17    IOSTANDARD LVCMOS25} [get_ports gpio_status[3]]                    ; 
set_property  -dict {PACKAGE_PIN   T15    IOSTANDARD LVCMOS25} [get_ports gpio_status[2]]                    ; 
set_property  -dict {PACKAGE_PIN   T14    IOSTANDARD LVCMOS25} [get_ports gpio_status[1]]                    ; 
set_property  -dict {PACKAGE_PIN   T11    IOSTANDARD LVCMOS25} [get_ports gpio_status[0]]                    ; 
set_property  -dict {PACKAGE_PIN   M20    IOSTANDARD LVCMOS18} [get_ports gpio_ctl[3]]                       ; 
set_property  -dict {PACKAGE_PIN   M19    IOSTANDARD LVCMOS18} [get_ports gpio_ctl[2]]                       ; 
set_property  -dict {PACKAGE_PIN   F17    IOSTANDARD LVCMOS18} [get_ports gpio_ctl[1]]                       ; 
set_property  -dict {PACKAGE_PIN   T10    IOSTANDARD LVCMOS25} [get_ports gpio_ctl[0]]                       ; 
set_property  -dict {PACKAGE_PIN   P16    IOSTANDARD LVCMOS25} [get_ports gpio_en_agc]                       ; 
set_property  -dict {PACKAGE_PIN   U20    IOSTANDARD LVCMOS25} [get_ports gpio_sync]                         ; 
set_property  -dict {PACKAGE_PIN   N17    IOSTANDARD LVCMOS25} [get_ports gpio_resetb]                       ; 
set_property  -dict {PACKAGE_PIN   R18    IOSTANDARD LVCMOS25} [get_ports enable]                            ; 
set_property  -dict {PACKAGE_PIN   P14    IOSTANDARD LVCMOS25} [get_ports txnrx]                             ; 

set_property  -dict {PACKAGE_PIN   P18    IOSTANDARD LVCMOS25  PULLTYPE PULLUP} [get_ports spi_csn]          ; 
set_property  -dict {PACKAGE_PIN   R14    IOSTANDARD LVCMOS25} [get_ports spi_clk]                           ; 
set_property  -dict {PACKAGE_PIN   P15    IOSTANDARD LVCMOS25} [get_ports spi_mosi]                          ; 
set_property  -dict {PACKAGE_PIN   R19    IOSTANDARD LVCMOS25} [get_ports spi_miso]                          ; 


set_property  -dict {PACKAGE_PIN N18   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_clk_in_p]       ; 
set_property  -dict {PACKAGE_PIN P19   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_clk_in_n]       ; 
set_property  -dict {PACKAGE_PIN N20   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_frame_in_p]     ; 
set_property  -dict {PACKAGE_PIN P20   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_frame_in_n]     ; 
set_property  -dict {PACKAGE_PIN W18   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_p[5]]   ; 
set_property  -dict {PACKAGE_PIN W19   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_n[5]]   ; 
set_property  -dict {PACKAGE_PIN Y18   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_p[4]]   ; 
set_property  -dict {PACKAGE_PIN Y19   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_n[4]]   ; 
set_property  -dict {PACKAGE_PIN V20   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_p[3]]   ; 
set_property  -dict {PACKAGE_PIN W20   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_n[3]]   ; 
set_property  -dict {PACKAGE_PIN V17   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_p[2]]   ; 
set_property  -dict {PACKAGE_PIN V18   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_n[2]]   ; 
set_property  -dict {PACKAGE_PIN T16   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_p[1]]   ; 
set_property  -dict {PACKAGE_PIN U17   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_n[1]]   ; 
set_property  -dict {PACKAGE_PIN V15   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_p[0]]   ; 
set_property  -dict {PACKAGE_PIN W15   IOSTANDARD LVDS_25      DIFF_TERM TRUE} [get_ports rx_data_in_n[0]]   ; 
set_property  -dict {PACKAGE_PIN Y16   IOSTANDARD LVDS_25}     [get_ports tx_clk_out_p]                      ; 
set_property  -dict {PACKAGE_PIN Y17   IOSTANDARD LVDS_25}     [get_ports tx_clk_out_n]                      ; 
set_property  -dict {PACKAGE_PIN W14   IOSTANDARD LVDS_25}     [get_ports tx_frame_out_p]                    ; 
set_property  -dict {PACKAGE_PIN Y14   IOSTANDARD LVDS_25}     [get_ports tx_frame_out_n]                    ; 
set_property  -dict {PACKAGE_PIN U14   IOSTANDARD LVDS_25}     [get_ports tx_data_out_p[5]]                  ; 
set_property  -dict {PACKAGE_PIN U15   IOSTANDARD LVDS_25}     [get_ports tx_data_out_n[5]]                  ; 
set_property  -dict {PACKAGE_PIN R16   IOSTANDARD LVDS_25}     [get_ports tx_data_out_p[4]]                  ; 
set_property  -dict {PACKAGE_PIN R17   IOSTANDARD LVDS_25}     [get_ports tx_data_out_n[4]]                  ; 
set_property  -dict {PACKAGE_PIN V16   IOSTANDARD LVDS_25}     [get_ports tx_data_out_p[3]]                  ; 
set_property  -dict {PACKAGE_PIN W16   IOSTANDARD LVDS_25}     [get_ports tx_data_out_n[3]]                  ; 
set_property  -dict {PACKAGE_PIN V12   IOSTANDARD LVDS_25}     [get_ports tx_data_out_p[2]]                  ; 
set_property  -dict {PACKAGE_PIN W13   IOSTANDARD LVDS_25}     [get_ports tx_data_out_n[2]]                  ; 
set_property  -dict {PACKAGE_PIN U18   IOSTANDARD LVDS_25}     [get_ports tx_data_out_p[1]]                  ; 
set_property  -dict {PACKAGE_PIN U19   IOSTANDARD LVDS_25}     [get_ports tx_data_out_n[1]]                  ; 
set_property  -dict {PACKAGE_PIN T12   IOSTANDARD LVDS_25}     [get_ports tx_data_out_p[0]]                  ; 
set_property  -dict {PACKAGE_PIN U12   IOSTANDARD LVDS_25}     [get_ports tx_data_out_n[0]]                  ; 



# clocks

create_clock -name rx_clk       -period  4 [get_ports rx_clk_in_p]





#################################################################################################################
#
# VCTCXO and reference clock
#
#################################################################################################################
set_property  -dict {PACKAGE_PIN  T9    IOSTANDARD LVCMOS33} [get_ports CLK_40M_DAC_nSYNC]  ;
set_property  -dict {PACKAGE_PIN  V5    IOSTANDARD LVCMOS33} [get_ports CLK_40M_DAC_SCLK]   ;
set_property  -dict {PACKAGE_PIN  U10   IOSTANDARD LVCMOS33} [get_ports CLK_40M_DAC_DIN]    ;
set_property  -dict {PACKAGE_PIN  Y7    IOSTANDARD LVCMOS33} [get_ports PPS_IN]             ;
set_property  -dict {PACKAGE_PIN  L16   IOSTANDARD LVCMOS18} [get_ports CLK_40MHz_FPGA]     ;
set_property  -dict {PACKAGE_PIN  J18   IOSTANDARD LVCMOS18} [get_ports CLKIN_10MHz]       ;

#################################################################################################################
#
# RF switch and PA
#
#################################################################################################################
set_property  -dict {PACKAGE_PIN  V6    IOSTANDARD LVCMOS33} [get_ports FE_TXRX2_SEL1 ]     ;
set_property  -dict {PACKAGE_PIN  V11   IOSTANDARD LVCMOS33} [get_ports FE_TXRX1_SEL1 ]     ;
set_property  -dict {PACKAGE_PIN  Y12   IOSTANDARD LVCMOS33} [get_ports FE_RX2_SEL1 ]       ;
set_property  -dict {PACKAGE_PIN  T5    IOSTANDARD LVCMOS33} [get_ports FE_RX1_SEL1 ]       ;
set_property  -dict {PACKAGE_PIN  W11   IOSTANDARD LVCMOS33} [get_ports tx_amp_en1]         ;
set_property  -dict {PACKAGE_PIN  Y11   IOSTANDARD LVCMOS33} [get_ports tx_amp_en2]         ;

#################################################################################################################
#
#GPS MISC
#
#################################################################################################################
set_property  -dict {PACKAGE_PIN W8	   IOSTANDARD LVCMOS33}     [get_ports GPS_RSTN]        ; 
set_property  -dict {PACKAGE_PIN W9	   IOSTANDARD LVCMOS33}     [get_ports GPS_PWEN]        ; 
set_property  -dict {PACKAGE_PIN U9	   IOSTANDARD LVCMOS33}     [get_ports GPS_PPS]         ; 


set_property  -dict {PACKAGE_PIN Y6	   IOSTANDARD LVCMOS33}     [get_ports REF_PPS_LOCK]        ; 
set_property  -dict {PACKAGE_PIN Y9	   IOSTANDARD LVCMOS33}     [get_ports REF_10M_LOCK]         ; 
set_property  -dict {PACKAGE_PIN Y8	   IOSTANDARD LVCMOS33}     [get_ports PPS_LED]         ; 
set_property  -dict {PACKAGE_PIN Y13   IOSTANDARD LVCMOS33}     [get_ports  GPS_RXD]  ;
set_property  -dict {PACKAGE_PIN W10   IOSTANDARD LVCMOS33}     [get_ports  GPS_TXD]  ;





#################################################################################################################
#
# ethernet
#
#################################################################################################################
set_property  -dict {PACKAGE_PIN  C20   IOSTANDARD  LVCMOS18} [get_ports  rgmii_td[3]]          ;
set_property  -dict {PACKAGE_PIN  D19   IOSTANDARD  LVCMOS18} [get_ports  rgmii_td[2]]          ;
set_property  -dict {PACKAGE_PIN  D20   IOSTANDARD  LVCMOS18} [get_ports  rgmii_td[1]]          ;
set_property  -dict {PACKAGE_PIN  F19   IOSTANDARD  LVCMOS18} [get_ports  rgmii_td[0]]          ;
set_property  -dict {PACKAGE_PIN  E18   IOSTANDARD  LVCMOS18} [get_ports  rgmii_rd[3]]          ;
set_property  -dict {PACKAGE_PIN  E19   IOSTANDARD  LVCMOS18} [get_ports  rgmii_rd[2]]          ;
set_property  -dict {PACKAGE_PIN  E17   IOSTANDARD  LVCMOS18} [get_ports  rgmii_rd[1]]          ;
set_property  -dict {PACKAGE_PIN  F16   IOSTANDARD  LVCMOS18} [get_ports  rgmii_rd[0]]          ;

set_property  -dict {PACKAGE_PIN  F20   IOSTANDARD  LVCMOS18} [get_ports  rgmii_tx_ctl]         ;
set_property  -dict {PACKAGE_PIN  D18   IOSTANDARD  LVCMOS18} [get_ports  rgmii_txc]            ;
set_property  -dict {PACKAGE_PIN  G17   IOSTANDARD  LVCMOS18} [get_ports  rgmii_rx_ctl]         ;
set_property  -dict {PACKAGE_PIN  H16   IOSTANDARD  LVCMOS18} [get_ports  rgmii_rxc]            ;
set_property  -dict {PACKAGE_PIN  B19   IOSTANDARD  LVCMOS18} [get_ports  phy_rst_n]            ;
set_property  -dict {PACKAGE_PIN  A20   IOSTANDARD  LVCMOS18} [get_ports  mdio_phy_mdio_io]     ;
set_property  -dict {PACKAGE_PIN  B20   IOSTANDARD  LVCMOS18} [get_ports  mdio_phy_mdc]         ;


create_clock -period  8.000          [get_ports rgmii_rxc] 

