set_clock_groups -async -group [get_clocks [list i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_out]] -to [get_clocks [list i_system_wrapper/system_i/sys_ps7/inst/FCLK_CLK2]]
set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O]] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O]] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O]]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O]]

# set_false_path -from [get_pins {i_system_wrapper/system_i/ila_1/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/allx_typeA_match_detection.ltlib_v1_0_0_allx_typeA_inst/DUT/u_srl_drive/CLK}] -to [get_pins {i_system_wrapper/system_i/ila_1/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/yes_output_reg.dout_reg_reg/D}]
# set_false_path -from [get_pins {i_system_wrapper/system_i/ila_0/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/allx_typeA_match_detection.ltlib_v1_0_0_allx_typeA_inst/DUT/u_srl_drive/CLK}] -to [get_pins {i_system_wrapper/system_i/ila_0/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/yes_output_reg.dout_reg_reg/D}]

# relax cross rf and bb domain control of adc_intf
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[0]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[1]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[2]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[3]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[0]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[1]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[2]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[3]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica_1/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[0]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica_1/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[1]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica_1/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[2]/R}]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica_1/C] -to [get_pins {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count_reg[3]/R}]

set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/fifo32_2clk_dep32_i/fifo_generator_0/U0/inst_fifo_gen/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_reg/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/FULL_internal_in_bb_domain_reg/D]

set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_decimate_reg_reg/D]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_decimate_reg_reg/D]
set_false_path -from [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_count_reg_replica_1/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_decimate_reg_reg/D]

set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_adc_pack/inst/adc_valid_reg/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/D]
set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_adc_pack/inst/adc_valid_reg_replica/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/D]
set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_adc_pack/inst/adc_valid_reg_replica_1/C] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain_reg/D]

set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/D]
set_false_path -from [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O] -to [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/D]

set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/C]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/D]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain_reg/R]

set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out_reg/C]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out_reg/D]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out_reg/R]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out1_reg/C]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out1_reg/D]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out1_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/rx_intf_0/inst/trigger_out1_reg/R]

# relax cross rf and bb domain control of dac_intf
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/C}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/D}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/Q}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_src_sel/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/R}]

set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/C}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/D}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/Q}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/xpm_cdc_array_single_inst_ant_flag/single_array[0].xpm_cdc_single_inst/syncstages_ff_reg[3]/R}]

connect_debug_port dbg_hub/clk [get_nets clk]

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
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/sys_ps7/inst/FCLK_CLK2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/gpio_status[0]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[1]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[2]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[3]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[4]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[5]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[6]} {i_system_wrapper/system_i/xpu_0/inst/gpio_status[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 11 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[0]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[1]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[2]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[3]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[4]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[5]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[6]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[7]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[8]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[9]} {i_system_wrapper/system_i/xpu_0/inst/rssi_half_db[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[0]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[1]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[2]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[3]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[4]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[5]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[6]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 13 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[0]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[1]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[2]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[3]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[4]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[5]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[6]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[7]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[8]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[9]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[10]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[11]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_len[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[16]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[17]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[18]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[19]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[20]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[21]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[22]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[23]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[24]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[25]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[26]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[27]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[28]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[29]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[30]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 5 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[0]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[1]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[2]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[3]} {i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_rate[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count[0]} {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count[1]} {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count[2]} {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/wren_count[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/rden_count[0]} {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/rden_count[1]} {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/rden_count[2]} {i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/rden_count[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 5 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_status[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[2]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[3]} {i_system_wrapper/system_i/xpu_0/inst/tx_status[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 4 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/rden_count[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/rden_count[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/rden_count[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/rden_count[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[3]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[4]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[5]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[6]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[7]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[8]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[9]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[10]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[11]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[12]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[13]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[14]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/bw20_i0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/wren_count[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/wren_count[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/wren_count[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/wren_count[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe12]
set_property port_width 4 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 6 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/data_count[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/data_count[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/data_count[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/data_count[3]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/data_count[4]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/data_count[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 4 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 3 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[0]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[1]} {i_system_wrapper/system_i/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 3 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/rx_state[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/rx_state[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/rx_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe17]
set_property port_width 13 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[3]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[4]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[5]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[6]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[7]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[8]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[9]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[10]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[11]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/timeout_timer_1M[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe18]
set_property port_width 16 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[0]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[1]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[2]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[3]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[4]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[5]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[6]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[7]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[8]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[9]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[10]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[11]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[12]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[13]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[14]} {i_system_wrapper/system_i/tx_intf_0/inst/ant_data[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe19]
set_property port_width 16 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[0]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[1]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[2]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[3]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[4]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[5]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[6]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[7]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[8]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[9]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[10]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[11]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[12]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[13]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[14]} {i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_pack[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe20]
set_property port_width 16 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[0]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[1]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[2]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[3]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[4]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[5]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[6]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[7]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[8]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[9]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[10]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[11]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[12]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[13]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[14]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_i_from_acc[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe21]
set_property port_width 8 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[0]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[1]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[2]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[3]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[4]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[5]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[6]} {i_system_wrapper/system_i/tx_intf_0/inst/data_to_acc[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe22]
set_property port_width 16 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[0]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[1]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[2]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[3]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[4]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[5]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[6]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[7]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[8]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[9]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[10]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[11]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[12]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[13]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[14]} {i_system_wrapper/system_i/tx_intf_0/inst/rf_q_from_acc[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 6 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/send_ack_count[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/send_ack_count[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/send_ack_count[2]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/send_ack_count[3]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/send_ack_count[4]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/send_ack_count[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 3 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/ack_tx_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_clk_in_bb_domain]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/adc_valid_in_bb_domain]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/ant_data_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/bw20_iq_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/byte_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/empty]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/EMPTY_internal]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/FC_DI_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/full]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/adc_intf_i/FULL_internal_in_bb_domain]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/fulln_from_dac_to_duc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/high_tx_allowed0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/phy_tx_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/phy_tx_started]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_header_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/pkt_header_valid_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/pulse_tx_bb_end_almost]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/retrans_in_progress]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/rf_iq_valid_from_acc]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/rx_pkt_intr]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/sample_in_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/rx_intf_pl_to_m_axis_i/start_m_axis]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 1 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/trigger_out]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 1 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/trigger_out1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 1 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/tx_iq_intf_i/tx_iq_fifo_full]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe53]
set_property port_width 1 [get_debug_ports u_ila_0/probe53]
connect_debug_port u_ila_0/probe53 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/tx_pkt_need_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe54]
set_property port_width 1 [get_debug_ports u_ila_0/probe54]
connect_debug_port u_ila_0/probe54 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/tx_try_complete]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe55]
set_property port_width 1 [get_debug_ports u_ila_0/probe55]
connect_debug_port u_ila_0/probe55 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe56]
set_property port_width 1 [get_debug_ports u_ila_0/probe56]
connect_debug_port u_ila_0/probe56 [get_nets [list i_system_wrapper/system_i/tx_intf_0/inst/wifi_iq_valid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_FCLK_CLK2]
