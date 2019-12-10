//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4.1 (lin64) Build 2117270 Tue Jan 30 15:31:13 MST 2018
//Date        : Fri Nov 22 22:52:02 2019
//Host        : jxj-xps running 64-bit Ubuntu 18.04.3 LTS
//Command     : generate_target duc_bank_core.bd
//Design      : duc_bank_core
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "duc_bank_core,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=duc_bank_core,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=1,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "duc_bank_core.hwdef" *) 
module duc_bank_core
   (ant_data_full_n,
    ant_data_wr_data,
    ant_data_wr_en,
    bw02_data_tdata,
    bw02_data_tready,
    bw02_data_tvalid,
    bw20_data_tdata,
    bw20_data_tready,
    bw20_data_tvalid,
    cfg0,
    clk,
    rstn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_fifo_write:1.0 ant_data FULL_N" *) input ant_data_full_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_fifo_write:1.0 ant_data WR_DATA" *) output [63:0]ant_data_wr_data;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_fifo_write:1.0 ant_data WR_EN" *) output ant_data_wr_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw02_data TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME bw02_data, CLK_DOMAIN duc_bank_core_clk, FREQ_HZ 200000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 16, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [63:0]bw02_data_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw02_data TREADY" *) output bw02_data_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw02_data TVALID" *) input bw02_data_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw20_data TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME bw20_data, CLK_DOMAIN duc_bank_core_clk, FREQ_HZ 200000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [63:0]bw20_data_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw20_data TREADY" *) output bw20_data_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bw20_data TVALID" *) input bw20_data_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.CFG0 DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.CFG0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}" *) input [31:0]cfg0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, ASSOCIATED_BUSIF bw20_data:bw02_data, ASSOCIATED_RESET rstn, CLK_DOMAIN duc_bank_core_clk, FREQ_HZ 200000000, PHASE 0.000" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RSTN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RSTN, POLARITY ACTIVE_LOW" *) input rstn;

  wire [31:0]cfg0_1;
  wire clk_1;
  wire [63:0]fir_compiler_0_M_AXIS_DATA_TDATA;
  wire fir_compiler_0_M_AXIS_DATA_TREADY;
  wire fir_compiler_0_M_AXIS_DATA_TVALID;
  wire [63:0]fir_compiler_1_M_AXIS_DATA_TDATA;
  wire fir_compiler_1_M_AXIS_DATA_TREADY;
  wire fir_compiler_1_M_AXIS_DATA_TVALID;
  wire mixer_duc_0_d_o_V_FULL_N;
  wire [63:0]mixer_duc_0_d_o_V_WR_DATA;
  wire mixer_duc_0_d_o_V_WR_EN;
  wire rstn_1;
  wire [63:0]wifi_data_1_TDATA;
  wire wifi_data_1_TREADY;
  wire wifi_data_1_TVALID;
  wire [63:0]zigbee_data_1_TDATA;
  wire zigbee_data_1_TREADY;
  wire zigbee_data_1_TVALID;

  assign ant_data_wr_data[63:0] = mixer_duc_0_d_o_V_WR_DATA;
  assign ant_data_wr_en = mixer_duc_0_d_o_V_WR_EN;
  assign bw02_data_tready = zigbee_data_1_TREADY;
  assign bw20_data_tready = wifi_data_1_TREADY;
  assign cfg0_1 = cfg0[31:0];
  assign clk_1 = clk;
  assign mixer_duc_0_d_o_V_FULL_N = ant_data_full_n;
  assign rstn_1 = rstn;
  assign wifi_data_1_TDATA = bw20_data_tdata[63:0];
  assign wifi_data_1_TVALID = bw20_data_tvalid;
  assign zigbee_data_1_TDATA = bw02_data_tdata[63:0];
  assign zigbee_data_1_TVALID = bw02_data_tvalid;
  duc_bank_core_fir_compiler_0_0 fir_compiler_0
       (.aclk(clk_1),
        .aresetn(rstn_1),
        .m_axis_data_tdata(fir_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(fir_compiler_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(fir_compiler_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(wifi_data_1_TDATA),
        .s_axis_data_tready(wifi_data_1_TREADY),
        .s_axis_data_tvalid(wifi_data_1_TVALID));
  duc_bank_core_fir_compiler_1_0 fir_compiler_1
       (.aclk(clk_1),
        .aresetn(rstn_1),
        .m_axis_data_tdata(fir_compiler_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(fir_compiler_1_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(fir_compiler_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(zigbee_data_1_TDATA),
        .s_axis_data_tready(zigbee_data_1_TREADY),
        .s_axis_data_tvalid(zigbee_data_1_TVALID));
  duc_bank_core_mixer_duc_0_0 mixer_duc_0
       (.ap_clk(clk_1),
        .ap_rst_n(rstn_1),
        .cfg0_V(cfg0_1),
        .d_i0_V_TDATA(fir_compiler_0_M_AXIS_DATA_TDATA),
        .d_i0_V_TREADY(fir_compiler_0_M_AXIS_DATA_TREADY),
        .d_i0_V_TVALID(fir_compiler_0_M_AXIS_DATA_TVALID),
        .d_i1_V_TDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,fir_compiler_1_M_AXIS_DATA_TDATA}),
        .d_i1_V_TREADY(fir_compiler_1_M_AXIS_DATA_TREADY),
        .d_i1_V_TVALID(fir_compiler_1_M_AXIS_DATA_TVALID),
        .d_o_V_din(mixer_duc_0_d_o_V_WR_DATA),
        .d_o_V_full_n(mixer_duc_0_d_o_V_FULL_N),
        .d_o_V_write(mixer_duc_0_d_o_V_WR_EN));
endmodule
