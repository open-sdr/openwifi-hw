// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_iq_intf #
	(
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
    parameter integer IQ_DATA_WIDTH = 16
	)
	(
	  input wire rstn,
	  input wire clk,
	    
	  output wire [(2*IQ_DATA_WIDTH-1):0] wifi_iq_pack,
      input  wire wifi_iq_ready,
      output wire wifi_iq_valid,
      
      input wire [10:0] tx_hold_threshold,
      input wire signed [9:0] bb_gain,

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

    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out_merge;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out_merge_ch_sel;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_in;
    wire tx_iq_fifo_rden;
    wire tx_iq_fifo_full;
    wire [10:0] data_count;
    
    assign bw02_iq_pack = 0;
    assign bw02_iq_valid = 1'b1;
    
    //generate tx_hold signal to hold tx_core if we have enough I/Q in FIFO
    assign tx_hold = (data_count>tx_hold_threshold?1:0);

    //output mux
    assign tx_iq_fifo_out_merge[(2*IQ_DATA_WIDTH-1):0] = (tx_iq_fifo_empty==1?0:tx_iq_fifo_out);
    assign tx_iq_fifo_out_merge_ch_sel = tx_iq_fifo_out_merge;
    assign wifi_iq_pack = tx_iq_fifo_out_merge_ch_sel;
    assign wifi_iq_valid = 1;

    //fifo rd mux
    assign tx_iq_fifo_rden = wifi_iq_ready;

    //fifo in mux
    assign tx_iq_fifo_in = {rf_q_tmp[(7+IQ_DATA_WIDTH-1):7], rf_i_tmp[(7+IQ_DATA_WIDTH-1):7]};

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
          
    fifo32_1clk_dep512 fifo32_1clk_dep512_i (
        .CLK(clk),
        .DATAO(tx_iq_fifo_out),
        .DI(tx_iq_fifo_in),
        .EMPTY(tx_iq_fifo_empty),
        .FULL(tx_iq_fifo_full),
        .RDEN(tx_iq_fifo_rden),
        .RST(~rstn),
        .WREN(tx_iq_fifo_wren),
        .data_count(data_count)
    );

	endmodule
