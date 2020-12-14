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

<<<<<<< HEAD
=======




>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
<<<<<<< HEAD
set_property C_DATA_DEPTH 32768 [get_debug_cores u_ila_0]
=======
set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_0]
>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps8/inst/pl_clk2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
<<<<<<< HEAD
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_state[1]}]]
=======
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[7]}]]
>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[13]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[14]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
<<<<<<< HEAD
set_property port_width 48 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[14]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[15]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[16]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[17]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[18]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[19]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[20]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[21]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[22]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[23]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[24]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[25]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[26]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[27]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[28]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[29]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[30]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[31]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[32]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[33]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[34]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[35]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[36]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[37]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[38]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[39]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[40]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[41]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[42]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[43]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[44]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[45]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[46]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 48 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[14]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[15]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[16]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[17]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[18]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[19]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[20]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[21]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[22]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[23]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[24]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[25]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[26]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[27]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[28]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[29]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[30]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[31]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[32]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[33]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[34]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[35]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[36]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[37]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[38]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[39]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[40]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[41]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[42]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[43]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[44]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[45]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[46]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 14 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[13]}]]
=======
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[16]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[17]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[18]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[19]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[20]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[21]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[22]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[23]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[24]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[25]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[26]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[27]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[28]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[29]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[30]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq0[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[13]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[14]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[15]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[16]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[17]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[18]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[19]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[20]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[21]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[22]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[23]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[24]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[25]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[26]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[27]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[28]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[29]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[30]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_capture_cfg[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_capture_cfg[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 14 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_len_target[13]}]]
>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 14 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
<<<<<<< HEAD
set_property port_width 11 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 9 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_reg[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 14 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_cfg[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 3 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_state_pre[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_state_pre[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_state_pre[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 3 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/filter_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 9 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/high_priority_discard_mask[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 3 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 2 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_type[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_type[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 4 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_subtype[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_subtype[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_subtype[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_subtype[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 48 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[14]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[15]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[16]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[17]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[18]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[19]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[20]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[21]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[22]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[23]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[24]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[25]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[26]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[27]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[28]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[29]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[30]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[31]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[32]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[33]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[34]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[35]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[36]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[37]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[38]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[39]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[40]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[41]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[42]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[43]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[44]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[45]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[46]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/phy_rx_parse_i/self_mac_addr[47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 14 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/allow_rx_dma_to_ps_reg[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 2 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_tofrom_ds[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/FC_tofrom_ds[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pkt_filter_ctl_i/abnormal_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_capture]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_trigger]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi_valid]]
=======
set_property port_width 2 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/ofdm_rx_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/ofdm_rx_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 11 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 11 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db_reg[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 14 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_m_axis_i/m_axis_xpm_fifo_sync0/wr_data_count[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 3 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 3 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 3 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 4 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cw_exp_dynamic[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cw_exp_dynamic[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cw_exp_dynamic[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cw_exp_dynamic[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/ch_idle_final]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/first_try_failed]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_capture]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_trigger]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_csi_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_demod_is_ongoing]]
>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
<<<<<<< HEAD
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_demod_is_ongoing]]
=======
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer_valid]]
>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
<<<<<<< HEAD
connect_debug_port u_ila_0/probe29 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_equalizer_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_ht_unsupport]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list i_system_wrapper/system_i/openwifi_ip/phy_tx_0_phy_tx_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0/phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_pkt_need_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_addr1_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_addr2_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_block_rx_dma_to_ps]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_block_rx_dma_to_ps_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_FC_DI_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_rf_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_try_complete]]
=======
connect_debug_port u_ila_0/probe29 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_ht_unsupport]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list i_system_wrapper/system_i/openwifi_ip/phy_tx_0_phy_tx_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0/phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/phy_tx_started]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/quit_retrans]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/retrans_started]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/start_retrans]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/start_tx_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/start_tx_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/tx_bb_is_ongoing_negedge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/tx_bb_is_ongoing_posedge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_pkt_need_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/tx_rf_is_ongoing_negedge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/tx_rf_is_ongoing_posedge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_rf_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_try_complete]]
>>>>>>> 17819554db3683081a5d00669743d95acfc4660c
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_pl_clk2]
