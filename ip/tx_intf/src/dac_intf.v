// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "clock_speed.v"
`include "board_def.v"

`timescale 1 ns / 1 ps

`include "tx_intf_pre_def.v"

`ifdef TX_INTF_ENABLE_DBG
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`else
`define DEBUG_PREFIX
`endif

`define COUNT_TOP_20M (`NUM_CLK_PER_SAMPLE-1)

`define TX_BB_CLK_GEN_FROM_RF 1

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
    `DEBUG_PREFIX input  wire dac_ready,
    
    input wire ant_flag,
    input wire [1:0] simple_cdd_flag,
  
    input wire acc_clk,
	  input wire acc_rstn,
    input wire [(2*IQ_DATA_WIDTH-1) : 0] data_from_acc,
    `DEBUG_PREFIX input wire data_valid_from_acc,

`ifndef TX_BB_CLK_GEN_FROM_RF
    `DEBUG_PREFIX output wire fulln_to_acc
`else
    output reg read_bb_fifo,
    output reg read_bb_fifo_delay
`endif

	);

    wire ALMOSTEMPTY;
    wire ALMOSTFULL;
    wire EMPTY_internal;
    wire FULL_internal;
    wire RDERR;
    wire WRERR;
    wire RST_internal;
    wire [5:0] rd_data_count;
    wire [5:0] wr_data_count;

    wire ant_flag_in_rf_domain;
    wire [1:0] simple_cdd_flag_in_rf_domain;

    wire [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal;
    reg  [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal_delay1;
    reg  [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal_delay2;
    wire [(DAC_PACK_DATA_WIDTH-1) : 0] dac_data_internal_after_sel;

    wire rden_internal;
    wire wren_internal;
    
    assign dac_data_internal_after_sel = (ant_flag_in_rf_domain?{dac_data_internal,32'd0}:{32'd0,dac_data_internal});
    assign dac_data = ( simple_cdd_flag_in_rf_domain[1]==0? ( simple_cdd_flag_in_rf_domain[0]?{dac_data_internal_delay2, dac_data_internal}:dac_data_internal_after_sel ) : {dac_data_internal,dac_data_internal} );

`ifndef TX_BB_CLK_GEN_FROM_RF
    assign dac_valid = (!EMPTY_internal);
`else
    assign dac_valid = 1; //dac always need 40Msps IQ data
`endif
    
    assign RST_internal = (!acc_rstn);
    assign fulln_to_acc = (!FULL_internal);

    assign rden_internal = dac_ready;

// generate 1 baseband (20Msps) sample delay in dac clk (40MHz) domain
    always @( posedge dac_clk )
    begin
      if ( dac_rst == 1 ) begin
        dac_data_internal_delay1 <= 0;
        dac_data_internal_delay2 <= 0;
      end else begin
        dac_data_internal_delay1 <= dac_data_internal;
        dac_data_internal_delay2 <= dac_data_internal_delay1;
      end
    end

`ifndef TX_BB_CLK_GEN_FROM_RF
    assign wren_internal = data_valid_from_acc;
`else // keep reading bb fifo via read_bb_fifo at 20M, keep writing fifo here at 40M (2x interpolation with 0)

    assign wren_internal = wren_internal_reg;

    reg [(2*IQ_DATA_WIDTH-1) : 0] dac_intf_fifo_in;
    reg wren_internal_reg;
    reg [4:0] counter;

    // 20MHz
    always @( posedge acc_clk )
    begin
      if ( acc_rstn == 0 ) begin
        counter <= 0;
        wren_internal_reg <= 0;
        read_bb_fifo <= 0;
        read_bb_fifo_delay <= 0;
        dac_intf_fifo_in <= 0;
      end else begin
        counter <= ( counter==`COUNT_TOP_20M?0:(counter+1'b1) );
        wren_internal_reg <= (counter==0 || counter==1); // 0 for IQ from bb fifo, 1 for zero insertion
        read_bb_fifo <= (counter==0);
        read_bb_fifo_delay <= read_bb_fifo;
        dac_intf_fifo_in <= (counter==0?data_from_acc:0);
      end
    end

`endif

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

    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (2)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_simple_cdd_flag (
      .src_clk  (acc_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (simple_cdd_flag),
      .dest_clk (dac_clk),
      .dest_out (simple_cdd_flag_in_rf_domain)
    );

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
      .RD_DATA_COUNT_WIDTH(6),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .USE_ADV_FEATURES("0404"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(6)    // DECIMAL
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
      .rd_data_count(rd_data_count), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
      .rd_rst_busy(),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
      .sbiterr(),             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
      .underflow(),         // 1-bit output: Underflow: Indicates that the read request (rd_en) during
      .wr_ack(),               // 1-bit output: Write Acknowledge: This signal indicates that a write
      .wr_data_count(wr_data_count), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
      .wr_rst_busy(),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
`ifndef TX_BB_CLK_GEN_FROM_RF
      .din(data_from_acc),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
`else
      .din(dac_intf_fifo_in),
`endif
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
