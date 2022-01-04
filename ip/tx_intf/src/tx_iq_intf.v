// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_iq_intf #
	(
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
    parameter integer CSI_FUZZER_WIDTH = 6,
    parameter integer IQ_DATA_WIDTH = 16
	)
	(
	  input wire rstn,
	  input wire clk,
	    
	  output wire [(2*IQ_DATA_WIDTH-1):0] wifi_iq_pack,
    input  wire wifi_iq_ready,
    output wire wifi_iq_valid,
      
    input wire [9:0] tx_hold_threshold,
    input wire signed [9:0] bb_gain,
    input wire signed [(CSI_FUZZER_WIDTH-1):0] bb_gain1,
    input wire              bb_gain1_rot90_flag,
    input wire signed [(CSI_FUZZER_WIDTH-1):0] bb_gain2,
    input wire              bb_gain2_rot90_flag,

	  input wire signed [(IQ_DATA_WIDTH-1) : 0] rf_i,
    input wire signed [(IQ_DATA_WIDTH-1) : 0] rf_q,
    input wire rf_iq_valid,

    // to lbt
    output wire tx_iq_fifo_empty,

    // to tx core
    output wire tx_hold
	);
  
    reg signed [(10+IQ_DATA_WIDTH-1) : 0] rf_i_tmp;
    reg signed [(10+IQ_DATA_WIDTH-1) : 0] rf_q_tmp;
    reg tx_iq_fifo_wren;

    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out_zero_padding;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_in;
    wire tx_iq_fifo_rden;
    wire tx_iq_fifo_full;
    wire [9:0] data_count;
    
    assign bw02_iq_pack = 0;
    assign bw02_iq_valid = 1'b1;
    
    //generate tx_hold signal to hold tx_core if we have enough I/Q in FIFO
    assign tx_hold = (data_count>tx_hold_threshold?1:0);

    //output mux
    assign tx_iq_fifo_out_zero_padding = (tx_iq_fifo_empty==1?0:tx_iq_fifo_out);
    assign wifi_iq_valid = 1;

    //fifo rd mux
    assign tx_iq_fifo_rden = wifi_iq_ready;

    //fifo in mux
    assign tx_iq_fifo_in = {rf_q_tmp[(7+IQ_DATA_WIDTH-1):7], rf_i_tmp[(7+IQ_DATA_WIDTH-1):7]};

    // gain module
    always @(posedge clk)                                              
    begin
      if (!rstn) begin                                                                    
          rf_i_tmp<=0;
          rf_q_tmp<=0;
          tx_iq_fifo_wren<=0;
      end else begin  
          rf_i_tmp<=rf_i*bb_gain;
          rf_q_tmp<=rf_q*bb_gain;
          tx_iq_fifo_wren <= (~tx_hold&rf_iq_valid);
      end
    end

    //csi fuzzer at fifo out
    csi_fuzzer # (
        .CSI_FUZZER_WIDTH(CSI_FUZZER_WIDTH),
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH)
    ) csi_fuzzer_i (
        .rstn(rstn),
        .clk(clk),

        // input data
        .iq(tx_iq_fifo_out_zero_padding),
        .iq_valid(wifi_iq_ready),

        // FIR coef of the fuzzer
        .bb_gain1(bb_gain1),
        .bb_gain1_rot90_flag(bb_gain1_rot90_flag),
        .bb_gain2(bb_gain2),
        .bb_gain2_rot90_flag(bb_gain2_rot90_flag),

        // output data
        .iq_out(wifi_iq_pack)
    );
          
    // fifo32_1clk_dep512 fifo32_1clk_dep512_i (
    //     .CLK(clk),
    //     .DATAO(tx_iq_fifo_out),
    //     .DI(tx_iq_fifo_in),
    //     .EMPTY(tx_iq_fifo_empty),
    //     .FULL(tx_iq_fifo_full),
    //     .RDEN(tx_iq_fifo_rden),
    //     .RST(~rstn),
    //     .WREN(tx_iq_fifo_wren),
    //     .data_count(data_count)
    // );
    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(512),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(10),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(10)    // DECIMAL
    ) fifo32_1clk_dep512_i (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(tx_iq_fifo_out),
      .empty(tx_iq_fifo_empty),
      .full(tx_iq_fifo_full),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(data_count),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(tx_iq_fifo_in),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_iq_fifo_rden),
      .rst(~rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_iq_fifo_wren)
    );

	endmodule
