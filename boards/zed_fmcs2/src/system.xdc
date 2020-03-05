set_clock_groups -async -group [get_clocks [list i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_out]] -to [get_clocks [list i_system_wrapper/system_i/sys_ps7/inst/FCLK_CLK2]]
set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O]] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O]] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_0/O]]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_divide_sel_1/O]]

#set_false_path -from [get_pins {i_system_wrapper/system_i/ila_1/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/allx_typeA_match_detection.ltlib_v1_0_0_allx_typeA_inst/DUT/u_srl_drive/CLK}] -to [get_pins {i_system_wrapper/system_i/ila_1/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/yes_output_reg.dout_reg_reg/D}]
#set_false_path -from [get_pins {i_system_wrapper/system_i/ila_0/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/allx_typeA_match_detection.ltlib_v1_0_0_allx_typeA_inst/DUT/u_srl_drive/CLK}] -to [get_pins {i_system_wrapper/system_i/ila_0/inst/ila_core_inst/u_trig/N_DDR_TC.N_DDR_TC_INST[0].U_TC/yes_output_reg.dout_reg_reg/D}]

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
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[0]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[1]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[2]} {i_system_wrapper/system_i/rx_intf_0/inst/rx_iq_intf_i/counter_top[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/fcs_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list i_system_wrapper/system_i/openofdm_rx_0/inst/dot11_i/fcs_out_strobe]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/phy_tx_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list i_system_wrapper/system_i/xpu_0/inst/phy_tx_started]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list i_system_wrapper/system_i/rx_intf_0/inst/trigger_out]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_FCLK_CLK2]
