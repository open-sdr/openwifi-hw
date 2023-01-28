// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

module fifo_sample_delay #
(
    parameter integer DATA_WIDTH	= 8,
    parameter integer LOG2_FIFO_DEPTH	= 7
)
(
      input wire clk,
      input wire rst,

      input wire [(LOG2_FIFO_DEPTH-1):0] delay_ctl,

      input wire [(DATA_WIDTH-1):0] data_in,
      input wire data_in_valid,
      output wire [(DATA_WIDTH-1):0] data_out,
      output wire data_out_valid
);

wire [LOG2_FIFO_DEPTH:0] rd_data_count;
wire [LOG2_FIFO_DEPTH:0] wr_data_count;
wire full;
wire empty;

reg rd_en_start;
wire rd_en;

reg  [LOG2_FIFO_DEPTH:0]  wr_data_count_reg;
wire wr_complete_pulse;

assign wr_complete_pulse = (wr_data_count > wr_data_count_reg);
assign rd_en = (rd_en_start&wr_complete_pulse);
assign data_out_valid = (rd_en_start&data_in_valid);

xpm_fifo_sync #(
  .DOUT_RESET_VALUE("0"),    // String
  .ECC_MODE("no_ecc"),       // String
  .FIFO_MEMORY_TYPE("auto"), // String
  .FIFO_READ_LATENCY(0),     // DECIMAL
  .FIFO_WRITE_DEPTH(1<<LOG2_FIFO_DEPTH),   // DECIMAL
  .FULL_RESET_VALUE(0),      // DECIMAL
  .PROG_EMPTY_THRESH(10),    // DECIMAL
  .PROG_FULL_THRESH(10),     // DECIMAL
  .RD_DATA_COUNT_WIDTH(LOG2_FIFO_DEPTH+1),   // DECIMAL
  .READ_DATA_WIDTH(DATA_WIDTH),      // DECIMAL
  .READ_MODE("fwft"),         // String
  .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
  .WAKEUP_TIME(0),           // DECIMAL
  .WRITE_DATA_WIDTH(DATA_WIDTH),     // DECIMAL
  .WR_DATA_COUNT_WIDTH(LOG2_FIFO_DEPTH+1)    // DECIMAL
) fifo_1clk_i (
  .almost_empty(),
  .almost_full(),
  .data_valid(),
  .dbiterr(),
  .dout(data_out),
  .empty(empty),
  .full(full),
  .overflow(),
  .prog_empty(),
  .prog_full(),
  .rd_data_count(rd_data_count),
  .rd_rst_busy(),
  .sbiterr(),
  .underflow(),
  .wr_ack(),
  .wr_data_count(wr_data_count),
  .wr_rst_busy(),
  .din(data_in),
  .injectdbiterr(),
  .injectsbiterr(),
  .rd_en(rd_en),
  .rst(rst),
  .sleep(),
  .wr_clk(clk),
  .wr_en(data_in_valid)
);

always @(posedge clk) begin
  if (rst) begin
    wr_data_count_reg <= 0;
    rd_en_start <= 0;
  end else begin                                                                   
    wr_data_count_reg <= wr_data_count;
    rd_en_start <= ((wr_data_count == delay_ctl)?1:rd_en_start);
  end
end

endmodule
