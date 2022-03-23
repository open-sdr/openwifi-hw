// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module gpio_status_rf_to_bb #
	(
		parameter integer GPIO_STATUS_WIDTH = 8
	)
	(
      input  wire rf_rst,
      input  wire rf_clk,
      input  wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_rf,

      input  wire bb_rstn,
      input  wire bb_clk,
      input  wire bb_iq_valid,
      output wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_bb
	);
// -----------for debug-----------------------------
   wire [(GPIO_STATUS_WIDTH-2):0] gpio_status_gain;
   wire gpio_status_lock;

   assign gpio_status_gain = gpio_status_rf[(GPIO_STATUS_WIDTH-2):0];
   assign gpio_status_lock = gpio_status_rf[GPIO_STATUS_WIDTH-1];
// ----------end of for debug-----------------------
   
   wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_tmp;
   wire [(GPIO_STATUS_WIDTH-1):0] agc_gain_mv_avg;
   wire [1:0] agc_lock_mv_avg;

   assign gpio_status_bb = {~agc_lock_mv_avg[0], agc_gain_mv_avg[(GPIO_STATUS_WIDTH-2):0]};

   xpm_fifo_async #(
      .CDC_SYNC_STAGES(2),       // DECIMAL
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(16),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(5),   // DECIMAL
      .READ_DATA_WIDTH(GPIO_STATUS_WIDTH),      // DECIMAL
      .READ_MODE("std"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .USE_ADV_FEATURES("0000"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(GPIO_STATUS_WIDTH),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(5)    // DECIMAL
   )
   xpm_fifo_async_gpio_status_rf_to_bb (
      .almost_empty(),
      .almost_full(),     // 1-bit output: Almost Full: When asserted, this signal indicates that
      .data_valid(),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
      .dbiterr(),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
      .dout(gpio_status_tmp),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
      .empty(),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
      .full(),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
      .overflow(),           // 1-bit output: Overflow: This signal indicates that a write request
      .prog_empty(),       // 1-bit output: Programmable Empty: This signal is asserted when the
      .prog_full(),         // 1-bit output: Programmable Full: This signal is asserted when the
      .rd_data_count(), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
      .rd_rst_busy(),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
      .sbiterr(),             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
      .underflow(),         // 1-bit output: Underflow: Indicates that the read request (rd_en) during
      .wr_ack(),               // 1-bit output: Write Acknowledge: This signal indicates that a write
      .wr_data_count(), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
      .wr_rst_busy(),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
      .din(gpio_status_rf),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
      .injectdbiterr(), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
      .injectsbiterr(), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
      .rd_clk(bb_clk),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
      .rd_en(1),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
      .rst(rf_rst),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
      .sleep(),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
      .wr_clk(rf_clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
      .wr_en(1)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
   );

   mv_avg_dual_ch #(.DATA_WIDTH0(8), .DATA_WIDTH1(2), .LOG2_AVG_LEN(5)) agc_mv_avg_dual_ch_inst (
      .clk(bb_clk),
      .rstn(bb_rstn),

      .data_in0({1'b0, gpio_status_tmp[(GPIO_STATUS_WIDTH-2):0]}),
      .data_in1({1'b0, ~gpio_status_tmp[GPIO_STATUS_WIDTH-1]}),
      .data_in_valid(bb_iq_valid),

      .data_out0(agc_gain_mv_avg),
      .data_out1(agc_lock_mv_avg),
      .data_out_valid()
   );

   // mv_avg #(.DATA_WIDTH(8), .LOG2_AVG_LEN(5)) agc_gain_mv_avg32_inst (
   //    .clk(bb_clk),
   //    .rstn(bb_rstn),

   //    .data_in({1'b0, gpio_status_tmp[(GPIO_STATUS_WIDTH-2):0]}),
   //    .data_in_valid(bb_iq_valid),
   //    .data_out(agc_gain_mv_avg),
   //    .data_out_valid()
   // );
   // mv_avg #(.DATA_WIDTH(2), .LOG2_AVG_LEN(5)) agc_lock_avg32_inst (
   //    .clk(bb_clk),
   //    .rstn(bb_rstn),

   //    .data_in({1'b0, ~gpio_status_tmp[GPIO_STATUS_WIDTH-1]}),
   //    .data_in_valid(bb_iq_valid),
   //    .data_out(agc_lock_mv_avg),
   //    .data_out_valid()
   // );

	endmodule
