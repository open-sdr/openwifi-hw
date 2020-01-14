//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4.1 (lin64) Build 2117270 Tue Jan 30 15:31:13 MST 2018
//Date        : Fri Nov 22 22:51:09 2019
//Host        : jxj-xps running 64-bit Ubuntu 18.04.3 LTS
//Command     : generate_target ddc_bank_core.bd
//Design      : ddc_bank_core
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "ddc_bank_core,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ddc_bank_core,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=1,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "ddc_bank_core.hwdef" *) 
module ddc_bank_core
   (bw02_data_tdata,
    bw02_data_tvalid,
    bw20_data_tdata,
    bw20_data_tvalid,
    cfg0,
    clk,
    iq_empty_n,
    iq_rd_data,
    iq_rd_en,
    rstn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw02_data TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME bw02_data, CLK_DOMAIN ddc_bank_core_clk, FREQ_HZ 200000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 91} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 96} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 91} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value path} size {attribs {resolve_type generated dependency path_size format long minimum {} maximum {}} value 4} stride {attribs {resolve_type generated dependency path_stride format long minimum {} maximum {}} value 24} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency out_width format long minimum {} maximum {}} value 19} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency out_fractwidth format long minimum {} maximum {}} value 0} signed {attribs {resolve_type generated dependency out_signed format bool minimum {} maximum {}} value true}}}}}}}}} TDATA_WIDTH 96 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_data_valid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data_valid} enabled {attribs {resolve_type generated dependency data_valid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency data_valid_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency chanid_bitoffset format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_bitoffset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.000, TDATA_NUM_BYTES 12, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [95:0]bw02_data_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw02_data TVALID" *) output bw02_data_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw20_data TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME bw20_data, CLK_DOMAIN ddc_bank_core_clk, FREQ_HZ 200000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 91} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 96} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 91} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value path} size {attribs {resolve_type generated dependency path_size format long minimum {} maximum {}} value 4} stride {attribs {resolve_type generated dependency path_stride format long minimum {} maximum {}} value 24} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency out_width format long minimum {} maximum {}} value 19} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency out_fractwidth format long minimum {} maximum {}} value 0} signed {attribs {resolve_type generated dependency out_signed format bool minimum {} maximum {}} value true}}}}}}}}} TDATA_WIDTH 96 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_data_valid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data_valid} enabled {attribs {resolve_type generated dependency data_valid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency data_valid_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency chanid_bitoffset format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_bitoffset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.000, TDATA_NUM_BYTES 12, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [95:0]bw20_data_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw20_data TVALID" *) output bw20_data_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.CFG0 DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.CFG0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}" *) input [31:0]cfg0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, ASSOCIATED_BUSIF iq:bw20_data:bw02_data, ASSOCIATED_RESET rstn, CLK_DOMAIN ddc_bank_core_clk, FREQ_HZ 200000000, PHASE 0.000" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_fifo_read:1.0 iq EMPTY_N" *) input iq_empty_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_fifo_read:1.0 iq RD_DATA" *) input [63:0]iq_rd_data;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_fifo_read:1.0 iq RD_EN" *) output iq_rd_en;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RSTN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RSTN, POLARITY ACTIVE_LOW" *) input rstn;

  wire ap_clk_1;
  wire [31:0]cfg0_1;
  wire [95:0]fir_compiler_0_M_AXIS_DATA_TDATA;
  wire fir_compiler_0_M_AXIS_DATA_TVALID;
  wire fir_compiler_0_s_axis_data_tready;
  wire [95:0]fir_compiler_1_M_AXIS_DATA_TDATA;
  wire fir_compiler_1_M_AXIS_DATA_TVALID;
  wire fir_compiler_1_s_axis_data_tready;
  wire mixer_ddc_0_d_i_V_EMPTY_N;
  wire [63:0]mixer_ddc_0_d_i_V_RD_DATA;
  wire mixer_ddc_0_d_i_V_RD_EN;
  wire [63:0]mixer_ddc_0_d_o0_V_TDATA;
  wire mixer_ddc_0_d_o0_V_TVALID;
  wire [127:0]mixer_ddc_0_d_o1_V_TDATA;
  wire mixer_ddc_0_d_o1_V_TVALID;
  wire rstn_1;

  assign ap_clk_1 = clk;
  assign bw02_data_tdata[95:0] = fir_compiler_1_M_AXIS_DATA_TDATA;
  assign bw02_data_tvalid = fir_compiler_1_M_AXIS_DATA_TVALID;
  assign bw20_data_tdata[95:0] = fir_compiler_0_M_AXIS_DATA_TDATA;
  assign bw20_data_tvalid = fir_compiler_0_M_AXIS_DATA_TVALID;
  assign cfg0_1 = cfg0[31:0];
  assign iq_rd_en = mixer_ddc_0_d_i_V_RD_EN;
  assign mixer_ddc_0_d_i_V_EMPTY_N = iq_empty_n;
  assign mixer_ddc_0_d_i_V_RD_DATA = iq_rd_data[63:0];
  assign rstn_1 = rstn;
  ddc_bank_core_fir_compiler_0_0 fir_compiler_0
       (.aclk(ap_clk_1),
        .aresetn(rstn_1),
        .m_axis_data_tdata(fir_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_compiler_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(mixer_ddc_0_d_o0_V_TDATA),
        .s_axis_data_tready(fir_compiler_0_s_axis_data_tready),
        .s_axis_data_tvalid(mixer_ddc_0_d_o0_V_TVALID));
  ddc_bank_core_fir_compiler_1_0 fir_compiler_1
       (.aclk(ap_clk_1),
        .aresetn(rstn_1),
        .m_axis_data_tdata(fir_compiler_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_compiler_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(mixer_ddc_0_d_o1_V_TDATA[63:0]),
        .s_axis_data_tready(fir_compiler_1_s_axis_data_tready),
        .s_axis_data_tvalid(mixer_ddc_0_d_o1_V_TVALID));
  ddc_bank_core_mixer_ddc_0_0 mixer_ddc_0
       (.ap_clk(ap_clk_1),
        .ap_rst_n(rstn_1),
        .cfg0_V(cfg0_1),
        .d_i_V_dout(mixer_ddc_0_d_i_V_RD_DATA),
        .d_i_V_empty_n(mixer_ddc_0_d_i_V_EMPTY_N),
        .d_i_V_read(mixer_ddc_0_d_i_V_RD_EN),
        .d_o0_V_TDATA(mixer_ddc_0_d_o0_V_TDATA),
        .d_o0_V_TREADY(fir_compiler_0_s_axis_data_tready),
        .d_o0_V_TVALID(mixer_ddc_0_d_o0_V_TVALID),
        .d_o1_V_TDATA(mixer_ddc_0_d_o1_V_TDATA),
        .d_o1_V_TREADY(fir_compiler_1_s_axis_data_tready),
        .d_o1_V_TVALID(mixer_ddc_0_d_o1_V_TVALID));
endmodule
