//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
//Date        : Fri Apr 10 17:51:50 2020
//Host        : jxj-xps running 64-bit Ubuntu 18.04.4 LTS
//Command     : generate_target fifo32_2clk_dep32.bd
//Design      : fifo32_2clk_dep32
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "fifo32_2clk_dep32,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=fifo32_2clk_dep32,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "fifo32_2clk_dep32.hwdef" *) 
module fifo32_2clk_dep32
   (DATAO,
    DI,
    EMPTY,
    FULL,
    RDCLK,
    RDEN,
    RD_DATA_COUNT,
    RST,
    WRCLK,
    WREN,
    WR_DATA_COUNT);
  output [31:0]DATAO;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.DI DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.DI, LAYERED_METADATA undef" *) input [31:0]DI;
  output EMPTY;
  output FULL;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.RDCLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.RDCLK, CLK_DOMAIN fifo32_2clk_dep32_RDCLK, FREQ_HZ 200000000, INSERT_VIP 0, PHASE 0.000" *) input RDCLK;
  input RDEN;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.RD_DATA_COUNT DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.RD_DATA_COUNT, LAYERED_METADATA undef" *) output [4:0]RD_DATA_COUNT;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RST, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input RST;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.WRCLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.WRCLK, CLK_DOMAIN fifo32_2clk_dep32_WRCLK, FREQ_HZ 200000000, INSERT_VIP 0, PHASE 0.000" *) input WRCLK;
  input WREN;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.WR_DATA_COUNT DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.WR_DATA_COUNT, LAYERED_METADATA undef" *) output [4:0]WR_DATA_COUNT;

  wire [31:0]DI_1;
  wire RDCLK_1;
  wire RDEN_1;
  wire RST_1;
  wire WRCLK_1;
  wire WREN_1;
  wire [31:0]fifo_generator_0_dout;
  wire fifo_generator_0_empty;
  wire fifo_generator_0_full;
  wire [4:0]fifo_generator_0_rd_data_count;
  wire [4:0]fifo_generator_0_wr_data_count;

  assign DATAO[31:0] = fifo_generator_0_dout;
  assign DI_1 = DI[31:0];
  assign EMPTY = fifo_generator_0_empty;
  assign FULL = fifo_generator_0_full;
  assign RDCLK_1 = RDCLK;
  assign RDEN_1 = RDEN;
  assign RD_DATA_COUNT[4:0] = fifo_generator_0_rd_data_count;
  assign RST_1 = RST;
  assign WRCLK_1 = WRCLK;
  assign WREN_1 = WREN;
  assign WR_DATA_COUNT[4:0] = fifo_generator_0_wr_data_count;
  fifo32_2clk_dep32_fifo_generator_0_0 fifo_generator_0
       (.din(DI_1),
        .dout(fifo_generator_0_dout),
        .empty(fifo_generator_0_empty),
        .full(fifo_generator_0_full),
        .rd_clk(RDCLK_1),
        .rd_data_count(fifo_generator_0_rd_data_count),
        .rd_en(RDEN_1),
        .rst(RST_1),
        .wr_clk(WRCLK_1),
        .wr_data_count(fifo_generator_0_wr_data_count),
        .wr_en(WREN_1));
endmodule
