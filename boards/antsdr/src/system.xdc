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


connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/tx_control_i/tx_control_state[2]}]]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[0]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[1]} {i_system_wrapper/system_i/openwifi_ip/tx_intf_0/inst/tx_bit_intf_i/high_tx_ctl_state[2]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_count[11]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[0]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[1]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[2]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[3]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[4]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[5]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[6]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[7]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[8]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[9]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[10]} {i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/wait_after_decode_top_scale[11]}]]
connect_debug_port u_ila_0/probe5 [get_nets [list i_system_wrapper/system_i/openwifi_ip/xpu_0/inst/cca_i/ch_idle]]

