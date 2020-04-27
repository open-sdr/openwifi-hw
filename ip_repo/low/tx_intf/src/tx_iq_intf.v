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
        
      input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] data_from_s_axis,
      input wire emptyn_from_s_axis,
      output wire ask_data_from_s_axis,

      input wire [10:0] tx_hold_threshold,
      input wire signed [9:0] bb_gain,

	  input wire signed [(IQ_DATA_WIDTH-1) : 0] rf_i,
      input wire signed [(IQ_DATA_WIDTH-1) : 0] rf_q,
      input wire rf_iq_valid,

      // input wire ch_sel, //not used
      input wire src_sel, //0-acc; 1-s_axis
      input wire loopback_sel,
      
      // to m_axis for loop back test
      output wire [(C_S00_AXIS_TDATA_WIDTH-1):0] data_loopback,
      output wire data_loopback_valid,
      
      // to lbt
      output wire tx_iq_fifo_empty,

      // to tx core
      output wire tx_hold
	);
    wire src_sel_rst;
    reg src_sel_rst_reg0;
    reg src_sel_rst_reg1;
    
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
    
    assign ask_data_from_s_axis = (src_sel==0?1'b0:wifi_iq_ready);

    assign data_loopback = (loopback_sel==0?data_from_s_axis:{16'd0, 16'd0, rf_q, rf_i});
    assign data_loopback_valid = (loopback_sel==0?emptyn_from_s_axis:rf_iq_valid);
    
    //generate tx_hold signal to hold tx_core if we have enough I/Q in FIFO
    assign tx_hold = (data_count>tx_hold_threshold?1:0);

    //output mux
    assign tx_iq_fifo_out_merge[(2*IQ_DATA_WIDTH-1):0] = (tx_iq_fifo_empty==1?0:tx_iq_fifo_out);
    assign tx_iq_fifo_out_merge_ch_sel = tx_iq_fifo_out_merge;
    assign wifi_iq_pack = (src_sel==0?tx_iq_fifo_out_merge_ch_sel:data_from_s_axis[(2*IQ_DATA_WIDTH-1):0]);
    assign wifi_iq_valid = (src_sel==0?1:emptyn_from_s_axis);

    assign src_sel_rst    = (src_sel_rst_reg0^src_sel_rst_reg1);

    //fifo rd mux
    assign tx_iq_fifo_rden = (src_sel==0?wifi_iq_ready:1'b0);

    //fifo in mux
    assign tx_iq_fifo_in = {rf_q_tmp[(7+IQ_DATA_WIDTH-1):7], rf_i_tmp[(7+IQ_DATA_WIDTH-1):7]};
    //assign tx_iq_fifo_wren = (src_sel==0?rf_iq_valid:1'b0);
    //assign rf_i_tmp = rf_i*bb_gain;
    //assign rf_q_tmp = rf_q*bb_gain;
    always @(posedge clk)                                              
    begin
      if (!rstn) begin                                                                    
          src_sel_rst_reg0 <= 1'b0;
          src_sel_rst_reg1 <= 1'b0;

          rf_i_tmp<=0;
          rf_q_tmp<=0;
          tx_iq_fifo_wren<=0;
      end else begin  
          src_sel_rst_reg0 <= src_sel;
          src_sel_rst_reg1 <= src_sel_rst_reg0;

          rf_i_tmp<=rf_i*bb_gain;
          rf_q_tmp<=rf_q*bb_gain;
          tx_iq_fifo_wren<=(src_sel==0?(~tx_hold&rf_iq_valid):1'b0);
      end
    end   
          
    fifo32_1clk_dep512 fifo32_1clk_dep512_i (
        .CLK(clk),
        .DATAO(tx_iq_fifo_out),
        .DI(tx_iq_fifo_in),
        .EMPTY(tx_iq_fifo_empty),
        .FULL(tx_iq_fifo_full),
        .RDEN(tx_iq_fifo_rden),
        .RST((~rstn)|src_sel_rst),
        .WREN(tx_iq_fifo_wren),
        .data_count(data_count)
    );

	endmodule
