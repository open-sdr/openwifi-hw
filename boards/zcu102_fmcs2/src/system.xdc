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

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 65536 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps8/inst/pl_clk2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/ofdm_rx_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/ofdm_rx_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[13]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[14]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[15]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[16]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[17]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[18]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[19]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[20]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[21]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[22]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[23]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[24]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[25]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[26]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[27]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[28]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[29]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[30]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[13]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[14]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[0]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[1]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[2]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[3]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[4]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[5]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[6]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[7]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[8]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[9]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[10]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[11]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[12]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[13]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[14]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[0]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[1]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[2]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[3]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[4]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[5]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[6]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[7]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[8]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[9]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[10]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[11]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[12]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[13]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[14]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe7]
set_property port_width 24 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[16]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[17]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[18]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[19]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[20]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[21]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[22]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[23]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[32]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[33]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[34]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[35]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[36]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[37]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[38]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[39]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/data_to_ps_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_demod_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_ht_unsupport]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0/phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/tx_end_from_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_pkt_need_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_FC_DI_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_try_complete]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_pl_clk2]
