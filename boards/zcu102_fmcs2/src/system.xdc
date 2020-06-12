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
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps8/inst/pl_clk2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/linux_prio[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/linux_prio[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_queue_idx[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_queue_idx[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 10 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[0]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[1]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[2]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[3]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[4]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[5]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[6]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[7]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[8]} {i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0_bram_addr[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 64 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[2]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[3]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[4]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[5]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[6]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[7]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[8]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[9]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[10]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[11]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[12]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[13]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[14]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[15]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[16]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[17]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[18]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[19]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[20]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[21]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[22]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[23]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[24]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[25]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[26]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[27]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[28]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[29]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[30]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[31]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[32]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[33]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[34]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[35]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[36]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[37]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[38]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[39]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[40]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[41]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[42]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[43]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[44]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[45]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[46]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[47]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[48]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[49]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[50]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[51]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[52]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[53]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[54]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[55]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[56]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[57]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[58]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[59]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[60]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[61]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[62]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0_data_to_acc[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 5 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_status[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_status[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_status[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_status[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_status[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_intf_s_axi_i/axi_arready0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_intf_s_axi_i/axi_rvalid_i_1_n_2]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_status_fifo_i/empty_reg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/fcs_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list i_system_wrapper/system_i/openwifi_ip_tx_itrpt1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0/phy_tx_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list i_system_wrapper/system_i/openwifi_ip/openofdm_tx_0/inst/dot11_tx/reset_int]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_intf_s_axi_i/S_AXI_ARREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list i_system_wrapper/system_i/openwifi_ip/rx_intf_0/inst/sig_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list i_system_wrapper/system_i/openwifi_ip/rx_intf_0/trigger_out1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/tx_end_from_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0_tx_hold]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_pkt_need_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/tx_start_from_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_status_fifo_i/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_status_fifo_i/tx_try_complete_reg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_bb_is_ongoing]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0_tx_try_complete]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_pl_clk2]
