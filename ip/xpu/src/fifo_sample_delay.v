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

  localparam [0:0]    WAIT_FILL =  1'b0,
                      NORMAL_RW =  1'b1;

  reg [1:0] rw_state;
  reg rden_internal;
  reg wren_internal;
  wire [LOG2_FIFO_DEPTH:0] rd_data_count;
  wire [LOG2_FIFO_DEPTH:0] wr_data_count;
  wire full;
  wire empty;

  assign data_out_valid = rden_internal;

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
    .rd_en(rden_internal),
    .rst(rst),
    .sleep(),
    .wr_clk(clk),
    .wr_en(wren_internal)
  );

	always @(posedge clk)                                             
    begin
      if (rst)
        begin
          rw_state<=WAIT_FILL;
          rden_internal<=0;
          wren_internal<=0;
        end                                                                   
      else                                                                    
        case (rw_state)
          WAIT_FILL: begin
            if (rd_data_count == delay_ctl) begin
              rw_state<=NORMAL_RW;
              end
            else begin
              rw_state<=rw_state;
              end
            rden_internal<=rden_internal;
            wren_internal<=data_in_valid;
          end
          
          NORMAL_RW: begin
            rw_state<=rw_state;
            rden_internal<=data_in_valid;
            wren_internal<=data_in_valid;
          end

        endcase                                                               
    end

	endmodule
