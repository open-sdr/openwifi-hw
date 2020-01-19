set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg0_reg[0]/Q}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg7_reg[1]/Q}]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_wider_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/D]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/R]

set_false_path -from [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg0_reg[0]/C}] -to [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/R]
set_false_path -from [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg7_reg[1]/C}] -to [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/R]
set_false_path -from [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_wider_reg/C] -to [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/D]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps7/inst/FCLK_CLK1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 64 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[0]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[1]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[2]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[3]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[4]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[5]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[6]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[7]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[8]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[9]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[10]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[11]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[12]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[13]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[14]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[15]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[16]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[17]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[18]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[19]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[20]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[21]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[22]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[23]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[24]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[25]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[26]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[27]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[28]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[29]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[30]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[31]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[32]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[33]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[34]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[35]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[36]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[37]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[38]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[39]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[40]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[41]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[42]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[43]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[44]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[45]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[46]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[47]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[48]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[49]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[50]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[51]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[52]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[53]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[54]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[55]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[56]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[57]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[58]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[59]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[60]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[61]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[62]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/num_dma_symbol_total_current[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[0]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[1]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state_old[0]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state_old[1]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state_old[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/pkt_filter_ctl_i/filter_state[0]} {i_system_wrapper/system_i/xpu_0/inst/pkt_filter_ctl_i/filter_state[1]} {i_system_wrapper/system_i/xpu_0/inst/pkt_filter_ctl_i/filter_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 3 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/rx_state[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/rx_state[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/rx_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 3 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/old_rx_state[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/old_rx_state[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/old_rx_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe6]
set_property port_width 5 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[4]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[5]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[6]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[7]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[0]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[1]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[2]} {i_system_wrapper/system_i/openofdm_tx_0_bram_addr[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/FC_DI[0]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[1]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[2]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[3]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[4]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[5]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[6]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[7]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[8]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[9]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[10]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[11]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[12]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[13]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[14]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[15]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[16]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[17]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[18]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[19]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[20]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[21]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[22]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[23]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[24]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[25]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[26]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[27]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[28]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[29]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[30]} {i_system_wrapper/system_i/xpu_0/inst/FC_DI[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 8 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/gpio_status[0]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[1]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[2]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[3]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[4]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[5]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[6]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 11 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[0]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[1]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[2]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[3]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[4]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[5]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[6]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[7]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[8]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[9]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 5 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_status[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[2]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[3]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[0]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[1]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[2]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[3]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[4]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[5]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[6]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[7]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[8]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[9]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[10]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[11]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[12]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[13]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[14]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe13]
set_property port_width 16 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[0]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[1]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[2]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[3]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[4]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[5]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[6]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[7]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[8]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[9]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[10]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[11]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[12]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[13]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[14]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 64 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[0]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[1]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[2]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[3]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[4]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[5]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[6]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[7]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[8]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[9]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[10]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[11]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[12]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[13]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[14]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[15]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[16]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[17]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[18]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[19]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[20]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[21]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[22]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[23]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[24]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[25]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[26]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[27]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[28]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[29]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[30]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[31]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[32]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[33]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[34]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[35]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[36]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[37]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[38]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[39]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[40]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[41]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[42]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[43]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[44]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[45]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[46]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[47]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[48]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[49]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[50]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[51]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[52]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[53]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[54]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[55]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[56]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[57]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[58]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[59]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[60]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[61]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[62]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 3 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state_priv[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state_priv[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state_priv[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 3 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 2 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/csma_ca_i/backoff_state[0]} {i_system_wrapper/system_i/xpu_0/inst/csma_ca_i/backoff_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe18]
set_property port_width 32 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[0]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[1]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[2]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[3]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[4]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[5]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[6]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[7]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[8]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[9]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[10]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[11]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[12]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[13]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[14]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[15]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[16]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[17]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[18]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[19]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[20]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[21]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[22]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[23]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[24]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[25]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[26]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[27]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[28]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[29]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[30]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 5 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[0]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[1]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[2]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[3]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 12 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[0]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[1]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[2]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[3]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[4]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[5]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[6]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[7]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[8]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[9]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[10]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/ack_tx_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/block_rx_dma_to_ps]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/block_rx_dma_to_ps_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/demod_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/emptyn_from_adc_to_ddc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/FC_DI_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/fulln_from_dac_to_duc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/fulln_from_m_axis_to_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/high_tx_allowed0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/high_tx_allowed1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/ht_unsupport]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/mute_adc_out_to_bb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/phy_tx_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_header_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_header_valid_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/pulse_tx_bb_end_almost]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/tx_control_i/retrans_in_progress]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/rf_iq_valid_from_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/s2mm_intr]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/start_m_axis]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/tx_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list i_system_wrapper/system_i/tx_intf_0_phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/tx_iq_intf_i/tx_iq_fifo_full]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/tx_pkt_need_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/tx_try_complete]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_FCLK_CLK1]
