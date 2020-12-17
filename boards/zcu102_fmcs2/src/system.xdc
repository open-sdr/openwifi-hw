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



connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/m_axis_data_count[13]}]]
connect_debug_port u_ila_0/probe26 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[13]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[14]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1[15]}]]
connect_debug_port u_ila_0/probe31 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_capture]]
connect_debug_port u_ila_0/probe32 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_strobe]]
connect_debug_port u_ila_0/probe46 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/phy_tx_started]]




connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_wait_timer[11]}]]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav[14]}]]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_for_mac[14]}]]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/eifs_time[11]}]]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/longest_ack_time[11]}]]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/difs_time[11]}]]
connect_debug_port u_ila_0/probe18 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_state_old[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_state_old[1]}]]
connect_debug_port u_ila_0/probe19 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/num_slot_random[7]}]]
connect_debug_port u_ila_0/probe20 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_state[1]}]]
connect_debug_port u_ila_0/probe21 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_timer[12]}]]
connect_debug_port u_ila_0/probe22 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state_old[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state_old[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state_old[2]}]]
connect_debug_port u_ila_0/probe23 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_state[2]}]]
connect_debug_port u_ila_0/probe27 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/bb_rf_delay_count[13]}]]
connect_debug_port u_ila_0/probe30 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/ch_idle_final]]
connect_debug_port u_ila_0/probe38 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_set]]
connect_debug_port u_ila_0/probe47 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/pulse_tx_bb_end]]
connect_debug_port u_ila_0/probe48 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/pulse_tx_bb_start]]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 32768 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps8/inst/pl_clk2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/gpio_status[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 15 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[10]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[11]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[12]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[13]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[14]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq1_i_abs[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 2 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 11 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[1]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[3]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[4]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[5]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[6]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[7]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[8]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[9]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/rssi_half_db[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 3 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[0]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[2]} {i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/side_ch_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 10 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[3]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[4]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[5]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[6]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[7]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[8]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/addra[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 64 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[3]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[4]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[5]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[6]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[7]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[8]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[9]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[10]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[11]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[12]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[13]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[14]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[15]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[16]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[17]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[18]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[19]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[20]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[21]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[22]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[23]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[24]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[25]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[26]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[27]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[28]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[29]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[30]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[31]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[32]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[33]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[34]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[35]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[36]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[37]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[38]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[39]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[40]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[41]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[42]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[43]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[44]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[45]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[46]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[47]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[48]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[49]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[50]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[51]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[52]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[53]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[54]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[55]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[56]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[57]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[58]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[59]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[60]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[61]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[62]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/dina[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 3 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 15 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_new[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_abs_avg_i/i_dc_rm[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_abs_avg_i/q_dc_rm[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 15 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_to_db_i/iq_rssi_reg[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[14]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 16 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[11]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[12]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[13]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[14]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_q[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 4 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_pkt_retrans_limit[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_pkt_retrans_limit[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_pkt_retrans_limit[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_pkt_retrans_limit[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/backoff_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/ddc_iq_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/first_try_failed]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_abs_avg_i/iq_dc_rm_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/rssi_i/iq_rssi_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/iq_trigger]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/last_fcs_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/m00_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/nav_reset]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_demod_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_ht_unsupport]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_rx_0_pkt_header_valid_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list i_system_wrapper/system_i/openwifi_ip/phy_tx_0_phy_tx_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0/phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/quit_retrans]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/retrans_started]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/start_retrans]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/start_tx_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/csma_ca_i/take_new_random_number]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/tx_bb_is_ongoing_negedge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list i_system_wrapper/system_i/openwifi_ip/side_ch_0/inst/side_ch_control_i/tx_bb_is_ongoing_posedge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_fail_lock]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_iq_fifo_empty]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_on_detection_i/tx_iq_running]]
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
connect_debug_port u_ila_0/probe47 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/wea]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_ack_tx_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_high_tx_allowed0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 1 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_high_tx_allowed1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 1 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_high_tx_allowed2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 1 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_high_tx_allowed3]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe53]
set_property port_width 1 [get_debug_ports u_ila_0/probe53]
connect_debug_port u_ila_0/probe53 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_retrans_in_progress]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe54]
set_property port_width 1 [get_debug_ports u_ila_0/probe54]
connect_debug_port u_ila_0/probe54 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe55]
set_property port_width 1 [get_debug_ports u_ila_0/probe55]
connect_debug_port u_ila_0/probe55 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_rf_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe56]
set_property port_width 1 [get_debug_ports u_ila_0/probe56]
connect_debug_port u_ila_0/probe56 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_try_complete]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_pl_clk2]
