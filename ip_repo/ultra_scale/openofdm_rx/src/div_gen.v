//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
//Date        : Wed Apr 15 15:52:06 2020
//Host        : jxj-xps running 64-bit Ubuntu 18.04.4 LTS
//Command     : generate_target div_gen.bd
//Design      : div_gen
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "div_gen,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=div_gen,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "div_gen.hwdef" *) 
module div_gen
   (clk,
    dividend,
    divisor,
    input_strobe,
    output_strobe,
    quotient);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN div_gen_clk, FREQ_HZ 200000000, INSERT_VIP 0, PHASE 0.000" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.DIVIDEND DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.DIVIDEND, LAYERED_METADATA undef" *) input [31:0]dividend;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.DIVISOR DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.DIVISOR, LAYERED_METADATA undef" *) input [23:0]divisor;
  input input_strobe;
  output output_strobe;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.QUOTIENT DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.QUOTIENT, LAYERED_METADATA undef" *) output [31:0]quotient;

  wire clk_1;
  wire [55:0]div_gen_0_m_axis_dout_tdata;
  wire div_gen_0_m_axis_dout_tvalid;
  wire [31:0]dividend_1;
  wire [23:0]divisor_1;
  wire input_strobe_1;
  wire [31:0]xlslice_0_Dout;

  assign clk_1 = clk;
  assign dividend_1 = dividend[31:0];
  assign divisor_1 = divisor[23:0];
  assign input_strobe_1 = input_strobe;
  assign output_strobe = div_gen_0_m_axis_dout_tvalid;
  assign quotient[31:0] = xlslice_0_Dout;
  div_gen_div_gen_0_0 div_gen_0
       (.aclk(clk_1),
        .m_axis_dout_tdata(div_gen_0_m_axis_dout_tdata),
        .m_axis_dout_tvalid(div_gen_0_m_axis_dout_tvalid),
        .s_axis_dividend_tdata(dividend_1),
        .s_axis_dividend_tvalid(input_strobe_1),
        .s_axis_divisor_tdata(divisor_1),
        .s_axis_divisor_tvalid(input_strobe_1));
  div_gen_xlslice_0_0 xlslice_0
       (.Din(div_gen_0_m_axis_dout_tdata),
        .Dout(xlslice_0_Dout));
endmodule
