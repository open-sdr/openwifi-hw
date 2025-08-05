// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1ns/1ps

module adc_intf_tb #(
  parameter integer IQ_DATA_WIDTH = 16
) (
);

reg adc_rst;
reg adc_clk;
reg [(4*IQ_DATA_WIDTH-1) : 0] adc_data;

reg acc_clk_raw;
wire acc_clk;
reg acc_rstn;

wire [2:0] bb_gain;
wire [(4*IQ_DATA_WIDTH-1) : 0] data_to_bb;
wire data_to_bb_valid;

initial begin
  // $dumpfile("adc_intf_tb.vcd");
  // $dumpvars;

  adc_clk = 0;
  acc_clk_raw = 0;
  
  adc_rst = 0;
  acc_rstn = 1;

  adc_data = 0;

  #13 adc_rst = 1;
  #16 acc_rstn = 0;

  #73 acc_rstn = 1;
  #97 adc_rst = 0;
end

assign bb_gain = 0;
always begin // clk gen
  #5 acc_clk_raw = !acc_clk_raw;  //100MHz
end
assign #3.3 acc_clk = acc_clk_raw;

always begin // clk gen
  #12.5 adc_clk = !adc_clk;  //40MHz
end

always @(posedge adc_clk) begin
  if (adc_rst) begin
    adc_data <= 0;
  end else begin
    adc_data <= adc_data + 1;
  end
end

adc_intf #(.IQ_DATA_WIDTH(IQ_DATA_WIDTH)) adc_intf_inst (
  .adc_rst(adc_rst),
  .adc_clk(adc_clk),
  .adc_data(adc_data),
  .adc_data_valid(1),

  .acc_clk(acc_clk),
  .acc_rstn(acc_rstn),

  .bb_gain(bb_gain),
  .data_to_bb(data_to_bb),
  .data_to_bb_valid(data_to_bb_valid)
);

endmodule
