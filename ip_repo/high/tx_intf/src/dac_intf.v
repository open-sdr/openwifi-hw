// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module dac_intf #
	(
    parameter integer IQ_DATA_WIDTH = 16,
		parameter integer DAC_PACK_DATA_WIDTH = 64
	)
	(
	  input wire dac_rst,
    input wire dac_clk,
    
    //connect util_ad9361_dac_upack
    output wire [DAC_PACK_DATA_WIDTH-1 : 0] dac_data,
    output wire dac_valid,
    input  wire dac_ready,
    
    //connect axi_ad9361_dac_dma
    input  wire [DAC_PACK_DATA_WIDTH-1 : 0] dma_data,
    input  wire dma_valid,
    output wire dma_ready,
      
    input wire src_sel,

    input wire ant_flag,
  
    input wire acc_clk,
	  input wire acc_rstn,
    input wire [(2*IQ_DATA_WIDTH-1) : 0] data_from_acc,
    input wire data_valid_from_acc,
    output wire fulln_to_acc
	);

    wire ALMOSTEMPTY;
    wire ALMOSTFULL;
    wire EMPTY_internal;
    wire FULL_internal;
    wire RDERR;
    wire WRERR;
    wire RST_internal;

    // reg src_sel_reg0;
    // reg src_sel_reg1;
    // reg src_sel_reg2;
    // reg src_sel_reg3;
    // reg src_sel_reg4;
    // reg src_sel_reg5;
    // reg src_sel_wider;
    // reg src_sel_in_rf_domain;

    // reg ant_flag_reg0;
    // reg ant_flag_reg1;
    // reg ant_flag_reg2;
    // reg ant_flag_reg3;
    // reg ant_flag_reg4;
    // reg ant_flag_reg5;
    // reg ant_flag_wider;
    // reg ant_flag_in_rf_domain;

    wire src_sel_in_rf_domain;
    wire ant_flag_in_rf_domain;

    wire [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal;
    wire [(DAC_PACK_DATA_WIDTH-1) : 0] dac_data_internal_after_sel;

    wire rden_internal;
    wire wren_internal;
        
    assign dac_data_internal_after_sel = (ant_flag_in_rf_domain?{dac_data_internal,32'd0}:{32'd0,dac_data_internal});
    assign dac_data  = ((src_sel_in_rf_domain==1'b0)?dma_data:dac_data_internal_after_sel);
    assign dac_valid = ((src_sel_in_rf_domain==1'b0)?dma_valid:(!EMPTY_internal));
    assign dma_ready = ((src_sel_in_rf_domain==1'b0)?dac_ready:1'b0);
    
    assign RST_internal = (!acc_rstn);
    assign fulln_to_acc = (!FULL_internal);

    assign rden_internal = ((src_sel_in_rf_domain==1'b0)?1'b0:dac_ready);
    assign wren_internal = ((src_sel_in_rf_domain==1'b0)?1'b0:data_valid_from_acc);

    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_src_sel (
      .src_clk  (acc_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (src_sel),
      .dest_clk (dac_clk),
      .dest_out (src_sel_in_rf_domain)
    );

    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_ant_flag (
      .src_clk  (acc_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (ant_flag),
      .dest_clk (dac_clk),
      .dest_out (ant_flag_in_rf_domain)
    );

    // always @( posedge acc_clk )
    // begin
    //   if ( acc_rstn == 1'b0 ) begin
    //         src_sel_reg0 <= 1'b0;
    //         src_sel_reg1 <= 1'b0;
    //         src_sel_reg2 <= 1'b0;
    //         src_sel_reg3 <= 1'b0;
    //         src_sel_reg4 <= 1'b0;
    //         src_sel_reg5 <= 1'b0;
    //         src_sel_wider <= 1'b0;
    //         ant_flag_reg0 <= 1'b0;
    //         ant_flag_reg1 <= 1'b0;
    //         ant_flag_reg2 <= 1'b0;
    //         ant_flag_reg3 <= 1'b0;
    //         ant_flag_reg4 <= 1'b0;
    //         ant_flag_reg5 <= 1'b0;
    //         ant_flag_wider <= 1'b0;
    //   end 
    //   else begin
    //         src_sel_reg0 <= src_sel;
    //         src_sel_reg1 <= src_sel_reg0;
    //         src_sel_reg2 <= src_sel_reg1;
    //         src_sel_reg3 <= src_sel_reg2;
    //         src_sel_reg4 <= src_sel_reg3;
    //         src_sel_reg5 <= src_sel_reg4;
    //         src_sel_wider <= (src_sel_reg0 | src_sel_reg1 | src_sel_reg2 | src_sel_reg3 | src_sel_reg4 | src_sel_reg5);

    //         ant_flag_reg0 <= ant_flag;
    //         ant_flag_reg1 <= ant_flag_reg0;
    //         ant_flag_reg2 <= ant_flag_reg1;
    //         ant_flag_reg3 <= ant_flag_reg2;
    //         ant_flag_reg4 <= ant_flag_reg3;
    //         ant_flag_reg5 <= ant_flag_reg4;
    //         ant_flag_wider <= (ant_flag_reg0 | ant_flag_reg1 | ant_flag_reg2 | ant_flag_reg3 | ant_flag_reg4 | ant_flag_reg5);
    //   end
    // end
    
    // always @( posedge dac_clk )
    // begin
    //   if ( dac_rst == 1'b1 ) begin
    //       src_sel_in_rf_domain <= 1'b0;
    //       ant_flag_in_rf_domain <= 1'b0;
    //   end 
    //   else begin  
    //       if (src_sel_wider == 1'b1)
    //           src_sel_in_rf_domain <= 1'b1;
    //       else
    //           src_sel_in_rf_domain <= 1'b0;
          
    //       if (ant_flag_wider == 1'b1)
    //           ant_flag_in_rf_domain <= 1'b1;
    //       else
    //           ant_flag_in_rf_domain <= 1'b0;
    //   end
    // end

    // fifo32_2clk_dep32 fifo32_2clk_dep32_i
    //        (.DATAO(dac_data_internal),
    //         .DI(data_from_acc),
    //         .EMPTY(EMPTY_internal),
    //         .FULL(FULL_internal),
    //         .RDCLK(dac_clk),
    //         .RDEN(rden_internal),
    //         .RD_DATA_COUNT(),
    //         .RST(RST_internal),
    //         .WRCLK(acc_clk),
    //         .WREN(wren_internal),
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
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .USE_ADV_FEATURES("0404"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(5)    // DECIMAL
   ) fifo32_2clk_dep32_i (
      .almost_empty(),
      .almost_full(),     // 1-bit output: Almost Full: When asserted, this signal indicates that
      .data_valid(),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
      .dbiterr(),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
      .dout(dac_data_internal),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
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
      .din(data_from_acc),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
      .injectdbiterr(), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
      .injectsbiterr(), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
      .rd_clk(dac_clk),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
      .rd_en(rden_internal),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
      .rst(RST_internal),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
      .sleep(),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
      .wr_clk(acc_clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
      .wr_en(wren_internal)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
   );

	endmodule
