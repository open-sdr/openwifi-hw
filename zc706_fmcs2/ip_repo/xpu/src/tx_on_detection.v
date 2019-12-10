// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_on_detection #
	(
    )
	(
        input wire clk,
        input wire rstn,

        input wire [11:0] bb_rf_delay_count_top,
        input wire phy_tx_started,
        input wire phy_tx_done,
	    input wire tx_iq_fifo_empty,

        output wire tx_bb_is_ongoing,
        output reg  tx_rf_is_ongoing,
        output wire pulse_tx_bb_end_almost
	);

    reg tx_bb_is_ongoing_internal;
    reg tx_bb_is_ongoing_internal0;
    reg tx_bb_is_ongoing_internal1;
    reg tx_bb_is_ongoing_internal2;
    reg tx_bb_is_ongoing_internal3;
    reg search_indication;
    reg tx_iq_fifo_empty_reg;
    reg [11:0] bb_rf_delay_count;

    // make sure tx_control.v state machine can make decision before the end of tx
    assign tx_bb_is_ongoing = (tx_bb_is_ongoing_internal|tx_bb_is_ongoing_internal0|tx_bb_is_ongoing_internal1|tx_bb_is_ongoing_internal2|tx_bb_is_ongoing_internal3);//extended version to make sure pulse_tx_bb_end_almost is inside tx_bb_is_ongoing
    assign pulse_tx_bb_end_almost = (tx_bb_is_ongoing_internal==0 && tx_bb_is_ongoing_internal0==1);
    
    always @( posedge clk )
    if ( rstn == 1'b0 )
        begin
        tx_bb_is_ongoing_internal <= 0;
        tx_bb_is_ongoing_internal0<=0;
        tx_bb_is_ongoing_internal1<=0;
        tx_bb_is_ongoing_internal2<=0;
        tx_bb_is_ongoing_internal3<=0;
        tx_iq_fifo_empty_reg <= 0;
        search_indication<=0;
        bb_rf_delay_count<=0;
        tx_rf_is_ongoing<=0;
        end
    else
        begin
        
        tx_bb_is_ongoing_internal0<=tx_bb_is_ongoing_internal;
        tx_bb_is_ongoing_internal1<=tx_bb_is_ongoing_internal0;
        tx_bb_is_ongoing_internal2<=tx_bb_is_ongoing_internal1;
        tx_bb_is_ongoing_internal3<=tx_bb_is_ongoing_internal2;

        tx_iq_fifo_empty_reg <= tx_iq_fifo_empty;
        
        if (phy_tx_started)
            begin
            search_indication <= 1; // should search fifo from empty to un-empty
            end
        else if (phy_tx_done) 
            begin
            search_indication <= 0; // should search fifo from un-empty to empty
            end
        
        if (search_indication==1)
            begin
            tx_bb_is_ongoing_internal <= ( (tx_iq_fifo_empty_reg==1 && tx_iq_fifo_empty==0)?1:tx_bb_is_ongoing_internal );
            end
        else
            begin
            tx_bb_is_ongoing_internal <= ( (tx_iq_fifo_empty_reg==0 && tx_iq_fifo_empty==1)?0:tx_bb_is_ongoing_internal );
            end
        
        if (tx_bb_is_ongoing_internal==1 && tx_bb_is_ongoing_internal0==0)
            begin
            bb_rf_delay_count<=0;
            end
        else if (tx_bb_is_ongoing_internal==0 && tx_bb_is_ongoing_internal0==1)
            begin
            bb_rf_delay_count<=(bb_rf_delay_count_top|1);
            end
        else
            begin
            bb_rf_delay_count<=( tx_bb_is_ongoing_internal?( bb_rf_delay_count+(bb_rf_delay_count!=(bb_rf_delay_count_top|1)) ) : ( bb_rf_delay_count- (bb_rf_delay_count!=0) ) );
            end

        if (bb_rf_delay_count==0)
            begin
            tx_rf_is_ongoing<=0;
            end
        else if (bb_rf_delay_count==(bb_rf_delay_count_top|1))
            begin
            tx_rf_is_ongoing<=1;
            end

        end

	endmodule
