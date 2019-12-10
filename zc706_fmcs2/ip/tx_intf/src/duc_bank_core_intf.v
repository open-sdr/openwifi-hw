// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ps / 1 ps

module duc_bank_core_intf
   (ant_data_full_n,
 ant_data_wr_data,
 ant_data_wr_en,
 cfg0,
 clk,
 rstn,
 bw20_data_tdata,
 bw20_data_tready,
 bw20_data_tvalid,
 bw02_data_tdata,
 bw02_data_tready,
 bw02_data_tvalid);
input ant_data_full_n;
output [63:0]ant_data_wr_data;
output ant_data_wr_en;
input [31:0]cfg0;
input clk;
input rstn;
input [63:0]bw20_data_tdata;
output bw20_data_tready;
input bw20_data_tvalid;
input [63:0]bw02_data_tdata;
output bw02_data_tready;
input bw02_data_tvalid;

wire ant_data_full_n;
wire [63:0]ant_data_wr_data;
wire ant_data_wr_en;
wire [31:0]cfg0;
wire clk;
wire rstn;
wire [63:0]bw20_data_tdata;
wire bw20_data_tready;
wire bw20_data_tvalid;
wire bw02_data_tready;
wire bw02_data_tvalid;

duc_bank_core duc_bank_core_i
    (.ant_data_full_n(ant_data_full_n),
     .ant_data_wr_data(ant_data_wr_data),
     .ant_data_wr_en(ant_data_wr_en),
     .cfg0(cfg0),
     .clk(clk),
     .rstn(rstn),
     .bw20_data_tdata(bw20_data_tdata),
     .bw20_data_tready(bw20_data_tready),
     .bw20_data_tvalid(bw20_data_tvalid),
     .bw02_data_tdata(bw02_data_tdata),
     .bw02_data_tready(bw02_data_tready),
     .bw02_data_tvalid(bw02_data_tvalid));
endmodule