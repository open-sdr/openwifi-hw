connect_bd_intf_net -boundary_type upper [get_bd_intf_pins openwifi_ip/M00_AXI] [get_bd_intf_pins sys_ps8/S_AXI_ACP_FPD]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins openwifi_ip/M00_AXI1] [get_bd_intf_pins sys_ps8/S_AXI_HP3_FPD]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins openwifi_ip/S00_AXI] [get_bd_intf_pins sys_ps8/M_AXI_HPM0_FPD]
connect_bd_net [get_bd_pins openwifi_ip/adc_clk] [get_bd_pins util_ad9361_divclk/clk_out]
connect_bd_net [get_bd_pins openwifi_ip/adc_rst] [get_bd_pins util_ad9361_divclk_reset/peripheral_reset]
connect_bd_net [get_bd_pins openwifi_ip/ext_reset_in] [get_bd_pins sys_ps8/pl_resetn2]

connect_bd_net [get_bd_pins openwifi_ip/gpio_status] [get_bd_pins xlslice_0/Dout]

connect_bd_net [get_bd_pins openwifi_ip/m_axi_mm2s_aclk] [get_bd_pins sys_ps8/pl_clk2]
connect_bd_net [get_bd_pins sys_ps8/saxihp3_fpd_aclk] [get_bd_pins sys_ps8/pl_clk2]
connect_bd_net [get_bd_pins sys_ps8/saxiacp_fpd_aclk] [get_bd_pins sys_ps8/pl_clk2]
connect_bd_net [get_bd_pins sys_ps8/maxihpm0_fpd_aclk] [get_bd_pins sys_ps8/pl_clk2]

# delete_bd_objs [get_bd_nets ps_intr_04_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In4] [get_bd_pins openwifi_ip/tx_itrpt0]
# delete_bd_objs [get_bd_nets ps_intr_05_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In5] [get_bd_pins openwifi_ip/tx_itrpt1]
# delete_bd_objs [get_bd_nets ps_intr_06_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In6] [get_bd_pins openwifi_ip/mm2s_introut]
# delete_bd_objs [get_bd_nets ps_intr_02_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In2] [get_bd_pins openwifi_ip/mm2s_introut1]
# delete_bd_objs [get_bd_nets ps_intr_01_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In1] [get_bd_pins openwifi_ip/rx_pkt_intr]
# delete_bd_objs [get_bd_nets ps_intr_03_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In3] [get_bd_pins openwifi_ip/s2mm_introut]
# delete_bd_objs [get_bd_nets ps_intr_07_1]
# connect_bd_net [get_bd_pins sys_concat_intc_0/In7] [get_bd_pins openwifi_ip/s2mm_introut1]
save_bd_design

