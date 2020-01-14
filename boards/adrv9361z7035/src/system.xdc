set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg0_reg[0]/Q}]
set_false_path -through [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg7_reg[1]/Q}]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_wider_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/D]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/Q]
set_false_path -through [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/R]

set_false_path -from [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg0_reg[0]/C}] -to [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/R]
set_false_path -from [get_pins {i_system_wrapper/system_i/tx_intf_0/inst/tx_intf_s_axi_i/slv_reg7_reg[1]/C}] -to [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/R]
set_false_path -from [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_wider_reg/C] -to [get_pins i_system_wrapper/system_i/tx_intf_0/inst/dac_intf_i/src_sel_in_dac_domain_reg/D]

