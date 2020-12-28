// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps
`include "clock_speed.v"
`include "board_def.v"

//`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`define DEBUG_PREFIX

	module tx_on_detection #
	(
    )
	(
        input wire clk,
        input wire rstn,

        input wire [7:0] bb_rf_delay_count_top,
        input wire [3:0] rf_end_ext_count_top,
        input wire phy_tx_started,
        input wire phy_tx_done,
	    input wire tx_iq_fifo_empty,

        // input wire tsf_pulse_1M, // for debug

        output wire tx_bb_is_ongoing,
        output reg  tx_rf_is_ongoing,
        `DEBUG_PREFIX output wire pulse_tx_bb_end
	);

    reg tx_bb_is_ongoing_internal;
    reg tx_bb_is_ongoing_internal0;
    reg tx_bb_is_ongoing_internal1;
    reg tx_bb_is_ongoing_internal2;
    reg tx_bb_is_ongoing_internal3;
    reg search_indication;
    reg tx_iq_fifo_empty_reg;
    `DEBUG_PREFIX reg [13:0] bb_rf_delay_count;

    `DEBUG_PREFIX wire pulse_tx_bb_start;
    `DEBUG_PREFIX reg tx_iq_running;

    `DEBUG_PREFIX reg [13:0] bb_rf_delay_count_top_scale;
    `DEBUG_PREFIX reg [13:0] bb_rf_delay_count_top_scale_ext;
    `DEBUG_PREFIX reg [13:0] bb_rf_delay_count_top_scale_ext_plus1;

    // make sure tx_control.v state machine can make decision before the end of tx
    assign tx_bb_is_ongoing = (tx_bb_is_ongoing_internal|tx_bb_is_ongoing_internal0|tx_bb_is_ongoing_internal1|tx_bb_is_ongoing_internal2|tx_bb_is_ongoing_internal3);//extended version to make sure pulse_tx_bb_end is inside tx_bb_is_ongoing
    assign pulse_tx_bb_start = (tx_bb_is_ongoing_internal==1 && tx_bb_is_ongoing_internal0==0);
    assign pulse_tx_bb_end =   (tx_bb_is_ongoing_internal==0 && tx_bb_is_ongoing_internal0==1);
    
    // // ----------------- debug ----------------
    // (* mark_debug = "true" *) reg [9:0] tx_bb_timeout_count;
    // always @( posedge clk )
    // if ( rstn == 1'b0 || tx_bb_is_ongoing_internal==1'b0 ) begin
    //     tx_bb_timeout_count<=0;
    // end else begin
    //     tx_bb_timeout_count <= (tsf_pulse_1M?(tx_bb_timeout_count+1):tx_bb_timeout_count);
    // end
    // // -----------end of debug ----------------

    always @( posedge clk )
    if ( rstn == 1'b0 ) begin
        bb_rf_delay_count_top_scale <= 0;
        bb_rf_delay_count_top_scale_ext <= 0;
        bb_rf_delay_count_top_scale_ext_plus1 <= 0;

        tx_bb_is_ongoing_internal <= 0;
        tx_bb_is_ongoing_internal0<=0;
        tx_bb_is_ongoing_internal1<=0;
        tx_bb_is_ongoing_internal2<=0;
        tx_bb_is_ongoing_internal3<=0;
        tx_iq_fifo_empty_reg <= 0;
        search_indication<=0;

        tx_iq_running<=0;
    end else begin
        bb_rf_delay_count_top_scale     <= (bb_rf_delay_count_top*`COUNT_SCALE);
        bb_rf_delay_count_top_scale_ext <= (bb_rf_delay_count_top_scale + (rf_end_ext_count_top*`COUNT_SCALE));
        bb_rf_delay_count_top_scale_ext_plus1 <= bb_rf_delay_count_top_scale_ext + 1;

        tx_bb_is_ongoing_internal0<=tx_bb_is_ongoing_internal;
        tx_bb_is_ongoing_internal1<=tx_bb_is_ongoing_internal0;
        tx_bb_is_ongoing_internal2<=tx_bb_is_ongoing_internal1;
        tx_bb_is_ongoing_internal3<=tx_bb_is_ongoing_internal2;

        tx_iq_fifo_empty_reg <= tx_iq_fifo_empty;
        
        if (phy_tx_started)
            search_indication <= 1; // should search fifo from empty to un-empty
        else if (phy_tx_done) 
            search_indication <= 0; // should search fifo from un-empty to empty
         
        if (search_indication==1)
            tx_bb_is_ongoing_internal <= ( (tx_iq_fifo_empty_reg==1 && tx_iq_fifo_empty==0)?1:tx_bb_is_ongoing_internal );
        else
            tx_bb_is_ongoing_internal <= ( (tx_iq_fifo_empty_reg==0 && tx_iq_fifo_empty==1)?0:tx_bb_is_ongoing_internal );
        
        if (pulse_tx_bb_start)
            tx_iq_running<=1;
        else if (pulse_tx_bb_end) 
            tx_iq_running<=0;
    end

    always @(posedge clk) begin                                                                     
      if ( rstn == 0 ) begin 
        bb_rf_delay_count    <= 0;
        tx_rf_is_ongoing     <= 0;
      end else if ( pulse_tx_bb_start || pulse_tx_bb_end ) begin
        bb_rf_delay_count    <= 0;
        tx_rf_is_ongoing     <= tx_rf_is_ongoing;
      end else begin
        bb_rf_delay_count <= (bb_rf_delay_count!=bb_rf_delay_count_top_scale_ext_plus1?(bb_rf_delay_count+1):bb_rf_delay_count);
        if (tx_iq_running==1 && bb_rf_delay_count==bb_rf_delay_count_top_scale)
            tx_rf_is_ongoing <= 1;
        else if (tx_iq_running==0 && bb_rf_delay_count==bb_rf_delay_count_top_scale_ext)
            tx_rf_is_ongoing <= 0;
      end
    end

	endmodule
