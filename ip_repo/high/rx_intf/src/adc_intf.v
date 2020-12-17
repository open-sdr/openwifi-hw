// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module adc_intf #
	(
		parameter integer IQ_DATA_WIDTH = 16
	)
	(
    input wire adc_rst,
    input wire adc_clk,
    input wire [(4*IQ_DATA_WIDTH-1) : 0] adc_data,
    //input wire adc_sync,
    input wire adc_valid,
    input wire acc_clk,
    input wire acc_rstn,

    input wire [2:0] bb_gain,
    output reg [(4*IQ_DATA_WIDTH-1) : 0] data_to_acc,
    output wire emptyn_to_acc,
    input wire acc_ask_data
	);
    wire FULL_internal;
    wire EMPTY_internal;
   //  wire RST_internal;
    wire [(4*IQ_DATA_WIDTH-1) : 0] data_to_acc_internal;
    
    reg [(4*IQ_DATA_WIDTH-1) : 0] adc_data_delay;
    reg adc_valid_count;
    wire adc_valid_decimate;

// // ---------for debug purpose------------
//     (* mark_debug = "true" *) reg adc_clk_in_bb_domain;
//     (* mark_debug = "true" *) reg adc_valid_in_bb_domain;
//     (* mark_debug = "true" *) reg FULL_internal_in_bb_domain;
//     (* mark_debug = "true" *) reg [3:0] wren_count;
//     (* mark_debug = "true" *) reg [3:0] rden_count;
//     reg adc_valid_decimate_reg;
//     wire valid;
//     reg  valid_reg;
//     assign valid = (!EMPTY_internal);
//     always @( posedge acc_clk )
//     begin
//       if ( acc_rstn == 1'b0 ) begin
//         adc_clk_in_bb_domain <= 0;
//         adc_valid_in_bb_domain <= 0;
//         FULL_internal_in_bb_domain <= 0;
//         wren_count <= 0;
//         rden_count <= 0;
//         adc_valid_decimate_reg <= 0;
//         valid_reg <= 0;
//       end
//       else begin
//         adc_clk_in_bb_domain <= adc_clk;
//         adc_valid_in_bb_domain <= adc_valid;
//         FULL_internal_in_bb_domain <= FULL_internal;
//         adc_valid_decimate_reg <= adc_valid_decimate;
//         valid_reg <= valid;
//         if (adc_valid_decimate==1 && adc_valid_decimate_reg==0)
//           wren_count <= 0;
//         else
//           wren_count <= wren_count + 1;

//         if (valid==1 && valid_reg==0)
//           rden_count <= 0;
//         else
//           rden_count <= rden_count + 1;
//       end
//     end
// // ------------end of debug----------

    assign adc_valid_decimate = (adc_valid_count==1);

   //  assign RST_internal = (!acc_rstn);
    assign emptyn_to_acc = (!EMPTY_internal);

    always @( bb_gain, data_to_acc_internal)
    begin
       case (bb_gain)
          3'b000 : begin
                        data_to_acc[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = data_to_acc_internal[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)];
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = data_to_acc_internal[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)];
                        data_to_acc[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = data_to_acc_internal[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)];
                        data_to_acc[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = data_to_acc_internal[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)];
                   end
          3'b001 : begin
                        data_to_acc[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = {data_to_acc_internal[((1*IQ_DATA_WIDTH)-2) : (0*IQ_DATA_WIDTH)], 1'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-2) : (1*IQ_DATA_WIDTH)], 1'd0};
                        data_to_acc[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = {data_to_acc_internal[((3*IQ_DATA_WIDTH)-2) : (2*IQ_DATA_WIDTH)], 1'd0};
                        data_to_acc[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = {data_to_acc_internal[((4*IQ_DATA_WIDTH)-2) : (3*IQ_DATA_WIDTH)], 1'd0};
                   end
          3'b010 : begin
                        data_to_acc[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = {data_to_acc_internal[((1*IQ_DATA_WIDTH)-3) : (0*IQ_DATA_WIDTH)], 2'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-3) : (1*IQ_DATA_WIDTH)], 2'd0};
                        data_to_acc[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = {data_to_acc_internal[((3*IQ_DATA_WIDTH)-3) : (2*IQ_DATA_WIDTH)], 2'd0};
                        data_to_acc[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = {data_to_acc_internal[((4*IQ_DATA_WIDTH)-3) : (3*IQ_DATA_WIDTH)], 2'd0};
                   end
          3'b011 : begin
                        data_to_acc[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = {data_to_acc_internal[((1*IQ_DATA_WIDTH)-4) : (0*IQ_DATA_WIDTH)], 3'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-4) : (1*IQ_DATA_WIDTH)], 3'd0};
                        data_to_acc[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = {data_to_acc_internal[((3*IQ_DATA_WIDTH)-4) : (2*IQ_DATA_WIDTH)], 3'd0};
                        data_to_acc[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = {data_to_acc_internal[((4*IQ_DATA_WIDTH)-4) : (3*IQ_DATA_WIDTH)], 3'd0};
                   end
          3'b100 : begin
                        data_to_acc[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = {data_to_acc_internal[((1*IQ_DATA_WIDTH)-5) : (0*IQ_DATA_WIDTH)], 4'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-5) : (1*IQ_DATA_WIDTH)], 4'd0};
                        data_to_acc[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = {data_to_acc_internal[((3*IQ_DATA_WIDTH)-5) : (2*IQ_DATA_WIDTH)], 4'd0};
                        data_to_acc[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = {data_to_acc_internal[((4*IQ_DATA_WIDTH)-5) : (3*IQ_DATA_WIDTH)], 4'd0};
                   end
          default: begin
                        data_to_acc[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = data_to_acc_internal[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)];
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = data_to_acc_internal[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)];
                        data_to_acc[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = data_to_acc_internal[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)];
                        data_to_acc[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = data_to_acc_internal[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)];
                   end
       endcase
    end

    //decimate input by 2: 40Msps --> 20Msps
    always @( posedge adc_clk )
    begin
      if ( adc_rst == 1 ) begin
        adc_valid_count <= 0;
        adc_data_delay    <= 0;
      end
      else begin
        adc_data_delay <= adc_data;
        if (adc_valid == 1)
          adc_valid_count <= adc_valid_count + 1;
      end
    end

    // fifo32_2clk_dep32 fifo32_2clk_dep32_i
    //        (.DATAO(data_to_acc_internal),
    //         .DI(adc_data_delay),
    //         .EMPTY(EMPTY_internal),
    //         .FULL(FULL_internal),
    //         .RDCLK(acc_clk),
    //         .RDEN(acc_ask_data),
    //         .RD_DATA_COUNT(),
    //         .RST(RST_internal),
    //         .WRCLK(adc_clk),
    //         .WREN(adc_valid_decimate),
    //         .WR_DATA_COUNT());

   xpm_fifo_async #(
      .CDC_SYNC_STAGES(2),       // DECIMAL
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(32),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(5),   // DECIMAL
      .READ_DATA_WIDTH(64),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .USE_ADV_FEATURES("0404"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(64),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(5)    // DECIMAL
   )
   xpm_fifo_async_adc_intf (
      .almost_empty(),
      .almost_full(),     // 1-bit output: Almost Full: When asserted, this signal indicates that
      .data_valid(),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
      .dbiterr(),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
      .dout(data_to_acc_internal),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
      .empty(EMPTY_internal),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
      .full(FULL_internal),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
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
      .din(adc_data_delay),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
      .injectdbiterr(), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
      .injectsbiterr(), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
      .rd_clk(acc_clk),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
      .rd_en(acc_ask_data),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
      .rst(adc_rst),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
      .sleep(),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
      .wr_clk(adc_clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
      .wr_en(adc_valid_decimate)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
   );

	endmodule
