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
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps7/inst/FCLK_CLK2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 9 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[3]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[4]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[5]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[6]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[7]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 64 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[3]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[4]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[5]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[6]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[7]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[8]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[9]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[10]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[11]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[12]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[13]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[14]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[15]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[16]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[17]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[18]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[19]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[20]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[21]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[22]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[23]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[24]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[25]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[26]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[27]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[28]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[29]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[30]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[31]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[32]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[33]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[34]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[35]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[36]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[37]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[38]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[39]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[40]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[41]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[42]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[43]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[44]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[45]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[46]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[47]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[48]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[49]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[50]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[51]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[52]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[53]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[54]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[55]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[56]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[57]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[58]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[59]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[60]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[61]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[62]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 13 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[3]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[4]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[5]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[6]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[7]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[8]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[9]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[10]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[11]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wr_counter[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[0]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[1]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[2]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[3]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[4]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[5]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[6]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[7]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[8]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[9]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[10]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[11]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[12]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[13]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[14]} {i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0/inst/dot11_i/sample_in[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 15 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/ack_timeout_count[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 15 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/recv_ack_timeout_top[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_dpram_op_counter[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_dpram_op_counter[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 10 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[0]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[1]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[2]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[3]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[4]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[5]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[6]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[7]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[8]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/ack_tx_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/cts_toself_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/cts_toself_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/cts_toself_rf_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/fcs_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/high_tx_allowed0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_rden0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_result_iq_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/retrans_in_progress]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/s2mm_intr]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/s_axis_recv_data_from_high]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/search_indication]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/tx_end_from_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_fail_lock]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0_phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_hold]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_iq_fifo_empty]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_rf_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wea]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_bb_is_ongoing]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_FCLK_CLK2]
