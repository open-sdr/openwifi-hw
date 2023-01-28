// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

`include "tx_intf_pre_def.v"

`ifdef TX_INTF_ENABLE_DBG
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`else
`define DEBUG_PREFIX
`endif

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

    input wire tx_arbitrary_iq_mode,
    input wire tx_arbitrary_iq_tx_trigger,
    input wire [(2*IQ_DATA_WIDTH-1):0] tx_arbitrary_iq_in,
    input wire slv_reg_wren,
    input wire [4:0] axi_awaddr_core,

    // to lbt
    output wire tx_iq_fifo_empty,

    // to tx core
    output wire tx_hold
	);
  
    reg signed [(10+IQ_DATA_WIDTH-1) : 0] rf_i_tmp;
    reg signed [(10+IQ_DATA_WIDTH-1) : 0] rf_q_tmp;
    reg tx_iq_fifo_wren_reg;

    reg  tx_arbitrary_iq_tx_trigger_reg;
    reg  tx_arbitrary_iq_on;
    wire tx_arbitrary_iq_wren;

    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out_zero_padding;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_out;
    wire [(2*IQ_DATA_WIDTH-1):0] tx_iq_fifo_in;
    wire tx_iq_fifo_rden;
    wire tx_iq_fifo_wren;
    wire tx_iq_fifo_full;
    wire [9:0] data_count;
    wire [9:0] wr_data_count;

    reg  wifi_iq_ready_reg;

    assign bw02_iq_pack = 0;
    assign bw02_iq_valid = 1'b1;

    //arbitrary iq from arm
    assign tx_arbitrary_iq_wren = ( (slv_reg_wren==1) && (axi_awaddr_core==1) ); // slv_reg1
    
    //generate tx_hold signal to hold tx_core if we have enough I/Q in FIFO
    assign tx_hold = (data_count>tx_hold_threshold?1:0);

    //output mux
    assign tx_iq_fifo_out_zero_padding = ( tx_arbitrary_iq_mode==1? (tx_arbitrary_iq_on==1?tx_iq_fifo_out:0) : (tx_iq_fifo_empty==1?0:tx_iq_fifo_out) );
    assign wifi_iq_valid = 1;

    //fifo rd mux
    assign tx_iq_fifo_rden = (tx_arbitrary_iq_mode==1?(tx_arbitrary_iq_on==1?wifi_iq_ready:0):wifi_iq_ready);

    //fifo in mux
    assign tx_iq_fifo_in =   (tx_arbitrary_iq_mode==1?tx_arbitrary_iq_in:{rf_q_tmp[(7+IQ_DATA_WIDTH-1):7], rf_i_tmp[(7+IQ_DATA_WIDTH-1):7]});
    assign tx_iq_fifo_wren = (tx_arbitrary_iq_mode==1?tx_arbitrary_iq_wren:tx_iq_fifo_wren_reg);

    //arbitrary iq tx control
    always @(posedge clk)                                              
    begin
      if (!rstn) begin          
        tx_arbitrary_iq_tx_trigger_reg <= 0;
        tx_arbitrary_iq_on <= 0;
      end else begin  
        tx_arbitrary_iq_tx_trigger_reg <= tx_arbitrary_iq_tx_trigger;
        tx_arbitrary_iq_on <= ( tx_iq_fifo_empty? 0 : ( ((tx_arbitrary_iq_tx_trigger==1) && (tx_arbitrary_iq_tx_trigger_reg==0))?1:tx_arbitrary_iq_on ) );
      end
    end

    // gain module
    always @(posedge clk)                                              
    begin
      if (!rstn) begin                                                                    
          rf_i_tmp<=0;
          rf_q_tmp<=0;
          tx_iq_fifo_wren_reg<=0;
      end else begin  
          rf_i_tmp<=rf_i*bb_gain;
          rf_q_tmp<=rf_q*bb_gain;
          tx_iq_fifo_wren_reg <= (~tx_hold&rf_iq_valid);
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
      .wr_data_count(wr_data_count),
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
