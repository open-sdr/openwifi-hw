
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2021.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_dma:7.1\
user.org:user:openofdm_rx:1.0\
user.org:user:openofdm_tx:1.0\
user.org:user:rx_intf:1.0\
user.org:user:side_ch:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
user.org:user:tx_intf:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlslice:1.0\
user.org:user:xpu:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: openwifi_ip
proc create_hier_cell_openwifi_ip { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_openwifi_ip() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk adc_clk
  create_bd_pin -dir I -from 63 -to 0 adc_data
  create_bd_pin -dir I -type rst adc_rst
  create_bd_pin -dir I adc_valid
  create_bd_pin -dir O channel_switch
  create_bd_pin -dir O -from 63 -to 0 dac_data
  create_bd_pin -dir I dac_ready
  create_bd_pin -dir O dac_valid
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O -from 3 -to 0 gpio_ctl
  create_bd_pin -dir O gpio_pmod1_0
  create_bd_pin -dir O gpio_pmod1_1
  create_bd_pin -dir O gpio_pmod1_2
  create_bd_pin -dir I -from 7 -to 0 gpio_status
  create_bd_pin -dir O led0
  create_bd_pin -dir O led1
  create_bd_pin -dir O led2
  create_bd_pin -dir O led3
  create_bd_pin -dir O led4
  create_bd_pin -dir O led5
  create_bd_pin -dir I -type clk m_axi_mm2s_aclk
  create_bd_pin -dir O -type intr mm2s_introut
  create_bd_pin -dir O -type intr mm2s_introut1
  create_bd_pin -dir I -type clk ps_clk
  create_bd_pin -dir O -type intr rx_pkt_intr
  create_bd_pin -dir O -type intr s2mm_introut
  create_bd_pin -dir O -type intr s2mm_introut1
  create_bd_pin -dir I spi0_csn
  create_bd_pin -dir I spi0_mosi
  create_bd_pin -dir I spi0_sclk
  create_bd_pin -dir O spi_csn
  create_bd_pin -dir O spi_mosi
  create_bd_pin -dir O spi_sclk
  create_bd_pin -dir O tx_itrpt

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {40} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_include_sg {1} \
   CONFIG.c_m_axi_mm2s_data_width {128} \
   CONFIG.c_m_axis_mm2s_tdata_width {64} \
   CONFIG.c_mm2s_burst_size {256} \
   CONFIG.c_s2mm_burst_size {256} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {40} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_include_sg {1} \
   CONFIG.c_m_axi_mm2s_data_width {128} \
   CONFIG.c_m_axis_mm2s_tdata_width {64} \
   CONFIG.c_mm2s_burst_size {256} \
   CONFIG.c_s2mm_burst_size {256} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_1

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {3} \
 ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.NUM_MI {8} \
 ] $axi_interconnect_1

  # Create instance: axi_interconnect_2, and set properties
  set axi_interconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_2 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {0} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {3} \
 ] $axi_interconnect_2

  # Create instance: openofdm_rx_0, and set properties
  set openofdm_rx_0 [ create_bd_cell -type ip -vlnv user.org:user:openofdm_rx:1.0 openofdm_rx_0 ]

  # Create instance: openofdm_tx_0, and set properties
  set openofdm_tx_0 [ create_bd_cell -type ip -vlnv user.org:user:openofdm_tx:1.0 openofdm_tx_0 ]

  # Create instance: rx_intf_0, and set properties
  set rx_intf_0 [ create_bd_cell -type ip -vlnv user.org:user:rx_intf:1.0 rx_intf_0 ]

  # Create instance: side_ch_0, and set properties
  set side_ch_0 [ create_bd_cell -type ip -vlnv user.org:user:side_ch:1.0 side_ch_0 ]

  # Create instance: sys_rstgen1, and set properties
  set sys_rstgen1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen1 ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen1

  # Create instance: tx_intf_0, and set properties
  set tx_intf_0 [ create_bd_cell -type ip -vlnv user.org:user:tx_intf:1.0 tx_intf_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {16} \
   CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DIN_TO {0} \
   CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_1

  # Create instance: xpu_0, and set properties
  set xpu_0 [ create_bd_cell -type ip -vlnv user.org:user:xpu:1.0 xpu_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_6 [get_bd_intf_pins axi_dma_1/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins tx_intf_0/s00_axis]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma_0/M_AXI_SG] [get_bd_intf_pins axi_interconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXIS_MM2S [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins side_ch_0/s00_axis]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_S2MM [get_bd_intf_pins axi_dma_1/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_2/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_SG [get_bd_intf_pins axi_dma_1/M_AXI_SG] [get_bd_intf_pins axi_interconnect_2/S02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins axi_interconnect_1/M01_AXI] [get_bd_intf_pins tx_intf_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_1_M02_AXI [get_bd_intf_pins axi_interconnect_1/M02_AXI] [get_bd_intf_pins openofdm_tx_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_1_M03_AXI [get_bd_intf_pins axi_dma_1/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_1/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M04_AXI [get_bd_intf_pins axi_interconnect_1/M04_AXI] [get_bd_intf_pins rx_intf_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_1_M05_AXI [get_bd_intf_pins axi_interconnect_1/M05_AXI] [get_bd_intf_pins openofdm_rx_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_1_M06_AXI [get_bd_intf_pins axi_interconnect_1/M06_AXI] [get_bd_intf_pins xpu_0/s00_axi]
  connect_bd_intf_net -intf_net axi_interconnect_1_M07_AXI [get_bd_intf_pins axi_interconnect_1/M07_AXI] [get_bd_intf_pins side_ch_0/s00_axi]
  connect_bd_intf_net -intf_net openwifi_ip_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins axi_interconnect_2/M00_AXI]
  connect_bd_intf_net -intf_net openwifi_ip_M00_AXI1 [get_bd_intf_pins M00_AXI1] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net rx_intf_0_m00_axis [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] [get_bd_intf_pins rx_intf_0/m00_axis]
  connect_bd_intf_net -intf_net side_ch_0_m00_axis [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins side_ch_0/m00_axis]
  connect_bd_intf_net -intf_net sys_ps7_M_AXI_GP1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_interconnect_1/S00_AXI]

  # Create port connections
  connect_bd_net -net adc_clk_1 [get_bd_pins adc_clk] [get_bd_pins rx_intf_0/adc_clk] [get_bd_pins tx_intf_0/dac_clk]
  connect_bd_net -net adc_data_1 [get_bd_pins adc_data] [get_bd_pins rx_intf_0/adc_data]
  connect_bd_net -net adc_rst_1 [get_bd_pins adc_rst] [get_bd_pins rx_intf_0/adc_rst] [get_bd_pins tx_intf_0/dac_rst]
  connect_bd_net -net adc_valid_1 [get_bd_pins adc_valid] [get_bd_pins rx_intf_0/adc_valid]
  connect_bd_net -net dac_ready_1 [get_bd_pins dac_ready] [get_bd_pins tx_intf_0/dac_ready]
  connect_bd_net -net gpio_status_1 [get_bd_pins gpio_status] [get_bd_pins rx_intf_0/gpio_status_rf]
  connect_bd_net -net openofdm_rx_0_byte_count [get_bd_pins openofdm_rx_0/byte_count] [get_bd_pins rx_intf_0/byte_count] [get_bd_pins xpu_0/byte_count]
  connect_bd_net -net openofdm_rx_0_byte_out [get_bd_pins openofdm_rx_0/byte_out] [get_bd_pins rx_intf_0/byte_in] [get_bd_pins xpu_0/byte_in]
  connect_bd_net -net openofdm_rx_0_byte_out_strobe [get_bd_pins openofdm_rx_0/byte_out_strobe] [get_bd_pins rx_intf_0/byte_in_strobe] [get_bd_pins xpu_0/byte_in_strobe]
  connect_bd_net -net openofdm_rx_0_csi [get_bd_pins openofdm_rx_0/csi] [get_bd_pins side_ch_0/csi]
  connect_bd_net -net openofdm_rx_0_csi_valid [get_bd_pins openofdm_rx_0/csi_valid] [get_bd_pins side_ch_0/csi_valid]
  connect_bd_net -net openofdm_rx_0_demod_is_ongoing [get_bd_pins gpio_pmod1_2] [get_bd_pins openofdm_rx_0/demod_is_ongoing] [get_bd_pins side_ch_0/demod_is_ongoing] [get_bd_pins xpu_0/demod_is_ongoing]
  connect_bd_net -net openofdm_rx_0_equalizer [get_bd_pins openofdm_rx_0/equalizer] [get_bd_pins side_ch_0/equalizer]
  connect_bd_net -net openofdm_rx_0_equalizer_valid [get_bd_pins openofdm_rx_0/equalizer_valid] [get_bd_pins side_ch_0/equalizer_valid]
  connect_bd_net -net openofdm_rx_0_fcs_ok [get_bd_pins openofdm_rx_0/fcs_ok] [get_bd_pins rx_intf_0/fcs_ok] [get_bd_pins side_ch_0/fcs_ok] [get_bd_pins xpu_0/fcs_ok]
  connect_bd_net -net openofdm_rx_0_fcs_out_strobe [get_bd_pins openofdm_rx_0/fcs_out_strobe] [get_bd_pins rx_intf_0/fcs_in_strobe] [get_bd_pins side_ch_0/fcs_in_strobe] [get_bd_pins tx_intf_0/fcs_in_strobe] [get_bd_pins xpu_0/fcs_in_strobe]
  connect_bd_net -net openofdm_rx_0_ht_aggr [get_bd_pins openofdm_rx_0/ht_aggr] [get_bd_pins rx_intf_0/ht_aggr] [get_bd_pins xpu_0/rx_ht_aggr]
  connect_bd_net -net openofdm_rx_0_ht_aggr_last [get_bd_pins openofdm_rx_0/ht_aggr_last] [get_bd_pins rx_intf_0/ht_aggr_last] [get_bd_pins xpu_0/rx_ht_aggr_last]
  connect_bd_net -net openofdm_rx_0_ht_sgi [get_bd_pins openofdm_rx_0/ht_sgi] [get_bd_pins rx_intf_0/ht_sgi]
  connect_bd_net -net openofdm_rx_0_ht_unsupport [get_bd_pins openofdm_rx_0/ht_unsupport] [get_bd_pins rx_intf_0/ht_unsupport] [get_bd_pins side_ch_0/ht_unsupport] [get_bd_pins xpu_0/ht_unsupport]
  connect_bd_net -net openofdm_rx_0_long_preamble_detected [get_bd_pins openofdm_rx_0/long_preamble_detected] [get_bd_pins side_ch_0/long_preamble_detected]
  connect_bd_net -net openofdm_rx_0_n_bit_in_last_sym [get_bd_pins openofdm_rx_0/n_bit_in_last_sym] [get_bd_pins xpu_0/n_bit_in_last_sym]
  connect_bd_net -net openofdm_rx_0_n_ofdm_sym [get_bd_pins openofdm_rx_0/n_ofdm_sym] [get_bd_pins xpu_0/n_ofdm_sym]
  connect_bd_net -net openofdm_rx_0_ofdm_symbol_eq_out_pulse [get_bd_pins openofdm_rx_0/ofdm_symbol_eq_out_pulse] [get_bd_pins side_ch_0/ofdm_symbol_eq_out_pulse]
  connect_bd_net -net openofdm_rx_0_phase_offset_taken [get_bd_pins openofdm_rx_0/phase_offset_taken] [get_bd_pins side_ch_0/phase_offset_taken]
  connect_bd_net -net openofdm_rx_0_phy_len_valid [get_bd_pins openofdm_rx_0/phy_len_valid] [get_bd_pins xpu_0/phy_len_valid]
  connect_bd_net -net openofdm_rx_0_pkt_header_valid [get_bd_pins openofdm_rx_0/pkt_header_valid] [get_bd_pins rx_intf_0/pkt_header_valid] [get_bd_pins side_ch_0/pkt_header_valid] [get_bd_pins xpu_0/pkt_header_valid]
  connect_bd_net -net openofdm_rx_0_pkt_header_valid_strobe [get_bd_pins openofdm_rx_0/pkt_header_valid_strobe] [get_bd_pins rx_intf_0/pkt_header_valid_strobe] [get_bd_pins side_ch_0/pkt_header_valid_strobe] [get_bd_pins xpu_0/pkt_header_valid_strobe]
  connect_bd_net -net openofdm_rx_0_pkt_len [get_bd_pins openofdm_rx_0/pkt_len] [get_bd_pins rx_intf_0/pkt_len] [get_bd_pins side_ch_0/pkt_len] [get_bd_pins xpu_0/pkt_len]
  connect_bd_net -net openofdm_rx_0_pkt_rate [get_bd_pins openofdm_rx_0/pkt_rate] [get_bd_pins rx_intf_0/pkt_rate] [get_bd_pins side_ch_0/pkt_rate] [get_bd_pins xpu_0/pkt_rate]
  connect_bd_net -net openofdm_rx_0_short_preamble_detected [get_bd_pins openofdm_rx_0/short_preamble_detected] [get_bd_pins side_ch_0/short_preamble_detected]
  connect_bd_net -net openofdm_tx_0_bram_addr [get_bd_pins openofdm_tx_0/bram_addr] [get_bd_pins tx_intf_0/bram_addr]
  connect_bd_net -net openofdm_tx_0_result_i [get_bd_pins openofdm_tx_0/result_i] [get_bd_pins tx_intf_0/rf_i_from_acc] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net openofdm_tx_0_result_iq_valid [get_bd_pins openofdm_tx_0/result_iq_valid] [get_bd_pins side_ch_0/openofdm_tx_iq_valid] [get_bd_pins tx_intf_0/rf_iq_valid_from_acc]
  connect_bd_net -net openofdm_tx_0_result_q [get_bd_pins openofdm_tx_0/result_q] [get_bd_pins tx_intf_0/rf_q_from_acc] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net openwifi_ip_mm2s_introut [get_bd_pins mm2s_introut] [get_bd_pins axi_dma_0/mm2s_introut]
  connect_bd_net -net openwifi_ip_mm2s_introut1 [get_bd_pins mm2s_introut1] [get_bd_pins axi_dma_1/mm2s_introut]
  connect_bd_net -net openwifi_ip_rx_pkt_intr [get_bd_pins rx_pkt_intr] [get_bd_pins rx_intf_0/rx_pkt_intr]
  connect_bd_net -net openwifi_ip_s2mm_introut [get_bd_pins s2mm_introut] [get_bd_pins axi_dma_1/s2mm_introut] [get_bd_pins rx_intf_0/s2mm_intr]
  connect_bd_net -net openwifi_ip_s2mm_introut1 [get_bd_pins s2mm_introut1] [get_bd_pins axi_dma_0/s2mm_introut]
  connect_bd_net -net phy_tx_0_phy_tx_done [get_bd_pins openofdm_tx_0/phy_tx_done] [get_bd_pins side_ch_0/phy_tx_done] [get_bd_pins tx_intf_0/tx_end_from_acc] [get_bd_pins xpu_0/phy_tx_done]
  connect_bd_net -net phy_tx_0_phy_tx_started [get_bd_pins openofdm_tx_0/phy_tx_started] [get_bd_pins side_ch_0/phy_tx_started] [get_bd_pins tx_intf_0/tx_start_from_acc] [get_bd_pins xpu_0/phy_tx_started]
  connect_bd_net -net ps_clk_1 [get_bd_pins ps_clk] [get_bd_pins xpu_0/ps_clk]
  connect_bd_net -net rx_intf_0_fcs_ok_led [get_bd_pins led2] [get_bd_pins rx_intf_0/fcs_ok_led]
  connect_bd_net -net rx_intf_0_gpio_status_bb [get_bd_pins rx_intf_0/gpio_status_bb] [get_bd_pins side_ch_0/gpio_status] [get_bd_pins xpu_0/gpio_status]
  connect_bd_net -net rx_intf_0_sample [get_bd_pins openofdm_rx_0/sample_in] [get_bd_pins rx_intf_0/sample0] [get_bd_pins side_ch_0/sample0_in] [get_bd_pins xlslice_0/Din] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net rx_intf_0_sample1 [get_bd_pins rx_intf_0/sample1] [get_bd_pins side_ch_0/sample1_in]
  connect_bd_net -net rx_intf_0_sample_strobe [get_bd_pins openofdm_rx_0/sample_in_strobe] [get_bd_pins rx_intf_0/sample_strobe] [get_bd_pins side_ch_0/sample_in_strobe] [get_bd_pins xpu_0/ddc_iq_valid]
  connect_bd_net -net rx_intf_0_trigger_out0 [get_bd_pins rx_intf_0/trigger_out0] [get_bd_pins side_ch_0/state_trace_reset_external]
  connect_bd_net -net rx_intf_0_trigger_out1 [get_bd_pins rx_intf_0/trigger_out1] [get_bd_pins side_ch_0/state_trace_stop_external]
  connect_bd_net -net s_axi_lite_aclk_1 [get_bd_pins m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] [get_bd_pins axi_dma_1/m_axi_sg_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_0/S02_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/M02_ACLK] [get_bd_pins axi_interconnect_1/M03_ACLK] [get_bd_pins axi_interconnect_1/M04_ACLK] [get_bd_pins axi_interconnect_1/M05_ACLK] [get_bd_pins axi_interconnect_1/M06_ACLK] [get_bd_pins axi_interconnect_1/M07_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_interconnect_2/ACLK] [get_bd_pins axi_interconnect_2/M00_ACLK] [get_bd_pins axi_interconnect_2/S00_ACLK] [get_bd_pins axi_interconnect_2/S01_ACLK] [get_bd_pins axi_interconnect_2/S02_ACLK] [get_bd_pins openofdm_rx_0/s00_axi_aclk] [get_bd_pins openofdm_tx_0/clk] [get_bd_pins openofdm_tx_0/s00_axi_aclk] [get_bd_pins rx_intf_0/m00_axis_aclk] [get_bd_pins rx_intf_0/s00_axi_aclk] [get_bd_pins side_ch_0/m00_axis_aclk] [get_bd_pins side_ch_0/s00_axi_aclk] [get_bd_pins side_ch_0/s00_axis_aclk] [get_bd_pins sys_rstgen1/slowest_sync_clk] [get_bd_pins tx_intf_0/s00_axi_aclk] [get_bd_pins tx_intf_0/s00_axis_aclk] [get_bd_pins xpu_0/s00_axi_aclk]
  connect_bd_net -net spi0_csn_1 [get_bd_pins spi0_csn] [get_bd_pins xpu_0/spi0_csn]
  connect_bd_net -net spi0_mosi_1 [get_bd_pins spi0_mosi] [get_bd_pins xpu_0/spi0_mosi]
  connect_bd_net -net spi0_sclk_1 [get_bd_pins spi0_sclk] [get_bd_pins xpu_0/spi0_sclk]
  connect_bd_net -net sys_ps7_FCLK_RESET2_N [get_bd_pins ext_reset_in] [get_bd_pins sys_rstgen1/ext_reset_in]
  connect_bd_net -net sys_rstgen1_peripheral_aresetn [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_0/S02_ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/M02_ARESETN] [get_bd_pins axi_interconnect_1/M03_ARESETN] [get_bd_pins axi_interconnect_1/M04_ARESETN] [get_bd_pins axi_interconnect_1/M05_ARESETN] [get_bd_pins axi_interconnect_1/M06_ARESETN] [get_bd_pins axi_interconnect_1/M07_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_interconnect_2/ARESETN] [get_bd_pins axi_interconnect_2/M00_ARESETN] [get_bd_pins axi_interconnect_2/S00_ARESETN] [get_bd_pins axi_interconnect_2/S01_ARESETN] [get_bd_pins axi_interconnect_2/S02_ARESETN] [get_bd_pins openofdm_rx_0/s00_axi_aresetn] [get_bd_pins openofdm_tx_0/phy_tx_arestn] [get_bd_pins openofdm_tx_0/s00_axi_aresetn] [get_bd_pins rx_intf_0/m00_axis_aresetn] [get_bd_pins rx_intf_0/s00_axi_aresetn] [get_bd_pins side_ch_0/m00_axis_aresetn] [get_bd_pins side_ch_0/s00_axi_aresetn] [get_bd_pins side_ch_0/s00_axis_aresetn] [get_bd_pins sys_rstgen1/peripheral_aresetn] [get_bd_pins tx_intf_0/s00_axi_aresetn] [get_bd_pins tx_intf_0/s00_axis_aresetn] [get_bd_pins xpu_0/s00_axi_aresetn]
  connect_bd_net -net tx_intf_0_bram_addr_to_xpu [get_bd_pins tx_intf_0/bram_addr_to_xpu] [get_bd_pins xpu_0/bram_addr]
  connect_bd_net -net tx_intf_0_channel_switch [get_bd_pins channel_switch] [get_bd_pins tx_intf_0/channel_switch]
  connect_bd_net -net tx_intf_0_cts_toself_bb_is_ongoing [get_bd_pins tx_intf_0/cts_toself_bb_is_ongoing] [get_bd_pins xpu_0/cts_toself_bb_is_ongoing]
  connect_bd_net -net tx_intf_0_cts_toself_rf_is_ongoing [get_bd_pins tx_intf_0/cts_toself_rf_is_ongoing] [get_bd_pins xpu_0/cts_toself_rf_is_ongoing]
  connect_bd_net -net tx_intf_0_dac_data [get_bd_pins dac_data] [get_bd_pins tx_intf_0/dac_data]
  connect_bd_net -net tx_intf_0_dac_valid [get_bd_pins dac_valid] [get_bd_pins tx_intf_0/dac_valid]
  connect_bd_net -net tx_intf_0_data_to_acc [get_bd_pins openofdm_tx_0/bram_din] [get_bd_pins tx_intf_0/data_to_acc]
  connect_bd_net -net tx_intf_0_douta [get_bd_pins tx_intf_0/douta] [get_bd_pins xpu_0/douta]
  connect_bd_net -net tx_intf_0_gpio_ctl [get_bd_pins gpio_ctl] [get_bd_pins tx_intf_0/gpio_ctl]
  connect_bd_net -net tx_intf_0_high_trigger [get_bd_pins side_ch_0/high_trigger] [get_bd_pins tx_intf_0/high_trigger] [get_bd_pins xpu_0/high_trigger]
  connect_bd_net -net tx_intf_0_high_tx_ctl_state [get_bd_pins side_ch_0/high_tx_ctl_state] [get_bd_pins tx_intf_0/high_tx_ctl_state]
  connect_bd_net -net tx_intf_0_iq0_for_check [get_bd_pins rx_intf_0/iq0_from_tx_intf] [get_bd_pins side_ch_0/tx_intf_iq0] [get_bd_pins tx_intf_0/iq0_for_check]
  connect_bd_net -net tx_intf_0_iq1_for_check [get_bd_pins rx_intf_0/iq1_from_tx_intf] [get_bd_pins side_ch_0/tx_intf_iq1] [get_bd_pins tx_intf_0/iq1_for_check]
  connect_bd_net -net tx_intf_0_iq_valid_for_check [get_bd_pins rx_intf_0/iq_valid_from_tx_intf] [get_bd_pins side_ch_0/tx_intf_iq_valid] [get_bd_pins tx_intf_0/iq_valid_for_check]
  connect_bd_net -net tx_intf_0_phy_tx_start [get_bd_pins openofdm_tx_0/phy_tx_start] [get_bd_pins side_ch_0/phy_tx_start] [get_bd_pins tx_intf_0/phy_tx_start] [get_bd_pins xpu_0/phy_tx_start]
  connect_bd_net -net tx_intf_0_quit_retrans [get_bd_pins tx_intf_0/quit_retrans] [get_bd_pins xpu_0/quit_retrans]
  connect_bd_net -net tx_intf_0_reset_backoff [get_bd_pins tx_intf_0/reset_backoff] [get_bd_pins xpu_0/reset_backoff]
  connect_bd_net -net tx_intf_0_tx_end_led [get_bd_pins led1] [get_bd_pins tx_intf_0/tx_end_led]
  connect_bd_net -net tx_intf_0_tx_hold [get_bd_pins openofdm_tx_0/result_iq_hold] [get_bd_pins tx_intf_0/tx_hold]
  connect_bd_net -net tx_intf_0_tx_iq_fifo_empty [get_bd_pins tx_intf_0/tx_iq_fifo_empty] [get_bd_pins xpu_0/tx_iq_fifo_empty]
  connect_bd_net -net tx_intf_0_tx_itrpt [get_bd_pins tx_itrpt] [get_bd_pins tx_intf_0/tx_itrpt]
  connect_bd_net -net tx_intf_0_tx_itrpt_led [get_bd_pins led0] [get_bd_pins tx_intf_0/tx_itrpt_led]
  connect_bd_net -net tx_intf_0_tx_pkt_need_ack [get_bd_pins side_ch_0/tx_pkt_need_ack] [get_bd_pins tx_intf_0/tx_pkt_need_ack] [get_bd_pins xpu_0/tx_pkt_need_ack]
  connect_bd_net -net tx_intf_0_tx_pkt_retrans_limit [get_bd_pins tx_intf_0/tx_pkt_retrans_limit] [get_bd_pins xpu_0/tx_pkt_retrans_limit]
  connect_bd_net -net tx_intf_0_tx_queue_idx_reg [get_bd_pins side_ch_0/tx_queue_idx_reg] [get_bd_pins tx_intf_0/tx_queue_idx_reg]
  connect_bd_net -net tx_intf_0_tx_queue_idx_to_xpu [get_bd_pins tx_intf_0/tx_queue_idx_to_xpu] [get_bd_pins xpu_0/tx_queue_idx]
  connect_bd_net -net tx_intf_0_use_ht_aggr [get_bd_pins tx_intf_0/use_ht_aggr] [get_bd_pins xpu_0/tx_ht_aggr]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins side_ch_0/openofdm_tx_iq0] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins xlslice_0/Dout] [get_bd_pins xpu_0/ddc_i]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins xlslice_1/Dout] [get_bd_pins xpu_0/ddc_q]
  connect_bd_net -net xpu_0_FC_DI [get_bd_pins side_ch_0/FC_DI] [get_bd_pins xpu_0/FC_DI]
  connect_bd_net -net xpu_0_FC_DI_valid [get_bd_pins side_ch_0/FC_DI_valid] [get_bd_pins xpu_0/FC_DI_valid]
  connect_bd_net -net xpu_0_ack_tx_flag [get_bd_pins tx_intf_0/ack_tx_flag] [get_bd_pins xpu_0/ack_tx_flag]
  connect_bd_net -net xpu_0_addr1 [get_bd_pins side_ch_0/addr1] [get_bd_pins xpu_0/addr1]
  connect_bd_net -net xpu_0_addr1_valid [get_bd_pins side_ch_0/addr1_valid] [get_bd_pins xpu_0/addr1_valid]
  connect_bd_net -net xpu_0_addr2 [get_bd_pins side_ch_0/addr2] [get_bd_pins xpu_0/addr2]
  connect_bd_net -net xpu_0_addr2_valid [get_bd_pins side_ch_0/addr2_valid] [get_bd_pins xpu_0/addr2_valid]
  connect_bd_net -net xpu_0_addr3 [get_bd_pins side_ch_0/addr3] [get_bd_pins xpu_0/addr3]
  connect_bd_net -net xpu_0_addr3_valid [get_bd_pins side_ch_0/addr3_valid] [get_bd_pins xpu_0/addr3_valid]
  connect_bd_net -net xpu_0_addra [get_bd_pins tx_intf_0/addra_from_xpu] [get_bd_pins xpu_0/addra]
  connect_bd_net -net xpu_0_backoff_done [get_bd_pins tx_intf_0/backoff_done] [get_bd_pins xpu_0/backoff_done]
  connect_bd_net -net xpu_0_backoff_state [get_bd_pins side_ch_0/backoff_state] [get_bd_pins xpu_0/backoff_state]
  connect_bd_net -net xpu_0_band [get_bd_pins tx_intf_0/band] [get_bd_pins xpu_0/band]
  connect_bd_net -net xpu_0_block_rx_dma_to_ps [get_bd_pins rx_intf_0/block_rx_dma_to_ps] [get_bd_pins side_ch_0/block_rx_dma_to_ps] [get_bd_pins xpu_0/block_rx_dma_to_ps]
  connect_bd_net -net xpu_0_block_rx_dma_to_ps_valid [get_bd_pins rx_intf_0/block_rx_dma_to_ps_valid] [get_bd_pins side_ch_0/block_rx_dma_to_ps_valid] [get_bd_pins xpu_0/block_rx_dma_to_ps_valid]
  connect_bd_net -net xpu_0_ch_idle_final [get_bd_pins side_ch_0/ch_idle_final] [get_bd_pins xpu_0/ch_idle_final]
  connect_bd_net -net xpu_0_channel [get_bd_pins tx_intf_0/channel] [get_bd_pins xpu_0/channel]
  connect_bd_net -net xpu_0_cw [get_bd_pins tx_intf_0/cw] [get_bd_pins xpu_0/cw]
  connect_bd_net -net xpu_0_demod_is_ongoing_led [get_bd_pins led3] [get_bd_pins xpu_0/demod_is_ongoing_led]
  connect_bd_net -net xpu_0_dina [get_bd_pins tx_intf_0/dina_from_xpu] [get_bd_pins xpu_0/dina]
  connect_bd_net -net xpu_0_gpio_status_lock_by_sig_valid [get_bd_pins rx_intf_0/gpio_status_lock_by_sig_valid] [get_bd_pins xpu_0/gpio_status_lock_by_sig_valid]
  connect_bd_net -net xpu_0_mac_addr [get_bd_pins tx_intf_0/mac_addr] [get_bd_pins xpu_0/mac_addr]
  connect_bd_net -net xpu_0_mute_adc_out_to_bb [get_bd_pins rx_intf_0/mute_adc_out_to_bb] [get_bd_pins xpu_0/mute_adc_out_to_bb]
  connect_bd_net -net xpu_0_nav_state [get_bd_pins side_ch_0/nav_state] [get_bd_pins xpu_0/nav_state]
  connect_bd_net -net xpu_0_num_slot_random [get_bd_pins tx_intf_0/num_slot_random] [get_bd_pins xpu_0/num_slot_random]
  connect_bd_net -net xpu_0_pkt_for_me [get_bd_pins side_ch_0/pkt_for_me] [get_bd_pins xpu_0/pkt_for_me]
  connect_bd_net -net xpu_0_retrans_in_progress [get_bd_pins side_ch_0/retrans_in_progress] [get_bd_pins tx_intf_0/retrans_in_progress] [get_bd_pins xpu_0/retrans_in_progress]
  connect_bd_net -net xpu_0_retrans_trigger [get_bd_pins side_ch_0/retrans_trigger] [get_bd_pins xpu_0/retrans_trigger]
  connect_bd_net -net xpu_0_rssi_half_db [get_bd_pins openofdm_rx_0/rssi_half_db] [get_bd_pins side_ch_0/rssi_half_db] [get_bd_pins xpu_0/rssi_half_db]
  connect_bd_net -net xpu_0_rssi_half_db_lock_by_sig_valid [get_bd_pins rx_intf_0/rssi_half_db_lock_by_sig_valid] [get_bd_pins xpu_0/rssi_half_db_lock_by_sig_valid]
  connect_bd_net -net xpu_0_slice_en [get_bd_pins side_ch_0/slice_en] [get_bd_pins tx_intf_0/slice_en] [get_bd_pins xpu_0/slice_en]
  connect_bd_net -net xpu_0_spi_csn [get_bd_pins spi_csn] [get_bd_pins xpu_0/spi_csn]
  connect_bd_net -net xpu_0_spi_mosi [get_bd_pins spi_mosi] [get_bd_pins xpu_0/spi_mosi]
  connect_bd_net -net xpu_0_spi_sclk [get_bd_pins spi_sclk] [get_bd_pins xpu_0/spi_sclk]
  connect_bd_net -net xpu_0_start_retrans [get_bd_pins tx_intf_0/start_retrans] [get_bd_pins xpu_0/start_retrans]
  connect_bd_net -net xpu_0_start_tx_ack [get_bd_pins tx_intf_0/start_tx_ack] [get_bd_pins xpu_0/start_tx_ack]
  connect_bd_net -net xpu_0_tsf_pulse_1M [get_bd_pins rx_intf_0/tsf_pulse_1M] [get_bd_pins tx_intf_0/tsf_pulse_1M] [get_bd_pins xpu_0/tsf_pulse_1M]
  connect_bd_net -net xpu_0_tsf_runtime_val [get_bd_pins rx_intf_0/tsf_runtime_val] [get_bd_pins side_ch_0/tsf_runtime_val] [get_bd_pins tx_intf_0/tsf_runtime_val] [get_bd_pins xpu_0/tsf_runtime_val]
  connect_bd_net -net xpu_0_tx_bb_is_ongoing [get_bd_pins gpio_pmod1_0] [get_bd_pins side_ch_0/tx_bb_is_ongoing] [get_bd_pins tx_intf_0/tx_bb_is_ongoing] [get_bd_pins xpu_0/tx_bb_is_ongoing]
  connect_bd_net -net xpu_0_tx_control_state [get_bd_pins side_ch_0/tx_control_state] [get_bd_pins xpu_0/tx_control_state]
  connect_bd_net -net xpu_0_tx_control_state_idle [get_bd_pins tx_intf_0/tx_control_state_idle] [get_bd_pins xpu_0/tx_control_state_idle]
  connect_bd_net -net xpu_0_tx_rf_is_ongoing [get_bd_pins gpio_pmod1_1] [get_bd_pins side_ch_0/tx_rf_is_ongoing] [get_bd_pins xpu_0/tx_rf_is_ongoing]
  connect_bd_net -net xpu_0_tx_status [get_bd_pins tx_intf_0/tx_status] [get_bd_pins xpu_0/tx_status]
  connect_bd_net -net xpu_0_tx_try_complete [get_bd_pins side_ch_0/tx_try_complete] [get_bd_pins tx_intf_0/tx_try_complete] [get_bd_pins xpu_0/tx_try_complete]
  connect_bd_net -net xpu_0_wea [get_bd_pins tx_intf_0/wea_from_xpu] [get_bd_pins xpu_0/wea]

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_openwifi_ip parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs
