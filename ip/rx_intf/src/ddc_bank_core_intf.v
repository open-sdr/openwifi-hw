
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ps / 1 ps

module ddc_bank_core_intf #
	(
    parameter integer IQ_DATA_WIDTH	=     16,
    parameter integer C_S00_AXI_DATA_WIDTH	= 32,
    parameter integer ADC_PACK_DATA_WIDTH	= 64,
    parameter integer C_M00_AXIS_TDATA_WIDTH	= 64
    )
   (cfg0,
    clk,
    iq_empty_n,
    iq_rd_data,
    iq_rd_en,
    rstn,
    bw20_data_tvalid,

//    gain_cfg,

    bw20_i0,
    bw20_q0,
    bw20_i1,
    bw20_q1,
    
    bw02_i0,
    bw02_q0,
    bw02_i1,
    bw02_q1,
    bw02_data_tvalid);
  input [(C_S00_AXI_DATA_WIDTH-1):0] cfg0;
  input clk;
  input iq_empty_n;
  input [(ADC_PACK_DATA_WIDTH-1):0] iq_rd_data;
  output iq_rd_en;
  input rstn;
  output bw20_data_tvalid;
  
//   input  [1:0] gain_cfg;

//   output reg [(IQ_DATA_WIDTH-1):0] bw20_i0;
//   output reg [(IQ_DATA_WIDTH-1):0] bw20_q0;
//   output reg [(IQ_DATA_WIDTH-1):0] bw20_i1;
//   output reg [(IQ_DATA_WIDTH-1):0] bw20_q1;
  output [(IQ_DATA_WIDTH-1):0] bw20_i0;
  output [(IQ_DATA_WIDTH-1):0] bw20_q0;
  output [(IQ_DATA_WIDTH-1):0] bw20_i1;
  output [(IQ_DATA_WIDTH-1):0] bw20_q1;

  output [(IQ_DATA_WIDTH-1):0] bw02_i0;
  output [(IQ_DATA_WIDTH-1):0] bw02_q0;
  output [(IQ_DATA_WIDTH-1):0] bw02_i1;
  output [(IQ_DATA_WIDTH-1):0] bw02_q1;
  output bw02_data_tvalid;

  wire [95:0] bw20_data_tdata;
  wire [95:0] bw02_data_tdata;
  
  assign bw20_i0 = bw20_data_tdata[15:0];
  assign bw20_q0 = bw20_data_tdata[39:24];
  assign bw20_i1 = bw20_data_tdata[63:48];
  assign bw20_q1 = bw20_data_tdata[87:72];
  
//   assign bw20_i0 = bw20_data_tdata[(15+5):(0+5)];
//   assign bw20_q0 = bw20_data_tdata[(39+5):(24+5)];
//   assign bw20_i1 = bw20_data_tdata[(63+5):(48+5)];
//   assign bw20_q1 = bw20_data_tdata[(87+5):(72+5)];

  assign bw02_i0 = bw02_data_tdata[15:0];
  assign bw02_q0 = bw02_data_tdata[39:24];
  assign bw02_i1 = bw02_data_tdata[63:48];
  assign bw02_q1 = bw02_data_tdata[87:72];
  
//   always @( bw20_data_tdata,gain_cfg )
//   begin
//       case (gain_cfg)
//         2'b00 : begin
//                 bw20_i0 = bw20_data_tdata[(15+6):(0+6)];
//                 bw20_q0 = bw20_data_tdata[(39+6):(24+6)];
//                 bw20_i1 = bw20_data_tdata[(63+6):(48+6)];
//                 bw20_q1 = bw20_data_tdata[(87+6):(72+6)];
//                 end
//         2'b01 : begin
//                 bw20_i0 = bw20_data_tdata[(15+5):(0+5)];
//                 bw20_q0 = bw20_data_tdata[(39+5):(24+5)];
//                 bw20_i1 = bw20_data_tdata[(63+5):(48+5)];
//                 bw20_q1 = bw20_data_tdata[(87+5):(72+5)];
//                 end
//         2'b10 : begin
//                 bw20_i0 = bw20_data_tdata[(15+4):(0+4)];
//                 bw20_q0 = bw20_data_tdata[(39+4):(24+4)];
//                 bw20_i1 = bw20_data_tdata[(63+4):(48+4)];
//                 bw20_q1 = bw20_data_tdata[(87+4):(72+4)];
//                 end
//         2'b11 : begin
//                 bw20_i0 = bw20_data_tdata[(15+3):(0+3)];
//                 bw20_q0 = bw20_data_tdata[(39+3):(24+3)];
//                 bw20_i1 = bw20_data_tdata[(63+3):(48+3)];
//                 bw20_q1 = bw20_data_tdata[(87+3):(72+3)];
//                 end
//         default: begin
//                 bw20_i0 = bw20_data_tdata[(15+5):(0+5)];
//                 bw20_q0 = bw20_data_tdata[(39+5):(24+5)];
//                 bw20_i1 = bw20_data_tdata[(63+5):(48+5)];
//                 bw20_q1 = bw20_data_tdata[(87+5):(72+5)];
//                 end
//       endcase
//   end

  ddc_bank_core ddc_bank_core_i
    (.cfg0(cfg0),
    .clk(clk),
    .iq_empty_n(iq_empty_n),
    .iq_rd_data(iq_rd_data),
    .iq_rd_en(iq_rd_en),
    .rstn(rstn),
    .bw20_data_tdata(bw20_data_tdata),
    .bw20_data_tvalid(bw20_data_tvalid),
    .bw02_data_tdata(bw02_data_tdata),
    .bw02_data_tvalid(bw02_data_tvalid)
    );

endmodule
