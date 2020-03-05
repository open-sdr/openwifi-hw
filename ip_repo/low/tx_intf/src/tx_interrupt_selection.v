// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_interrupt_selection
	(
        // selection
        input wire [2:0] src_sel0,
        input wire [2:0] src_sel1,

        // src
        input wire s00_axis_tlast,
        input wire phy_tx_start,
        input wire tx_start_from_acc,
        input wire tx_end_from_acc,
        input wire tx_try_complete,

	    // to ps interrupt
	    output reg tx_itrpt0,
        output reg tx_itrpt1
	);

    always @( src_sel0, s00_axis_tlast,phy_tx_start, tx_start_from_acc, tx_end_from_acc,tx_try_complete)
    begin
       case (src_sel0)
          3'b000 : begin
                        tx_itrpt0 = s00_axis_tlast;
                   end
          3'b001 : begin
                        tx_itrpt0 = phy_tx_start;
                   end
          3'b010 : begin
                        tx_itrpt0 = tx_start_from_acc;
                   end
          3'b011 : begin
                        tx_itrpt0 = tx_end_from_acc;
                   end
          3'b100 : begin
                        tx_itrpt0 = tx_try_complete;
                   end
          default: begin
                        tx_itrpt0 = 0;
                   end
       endcase
    end

    always @( src_sel1, s00_axis_tlast,phy_tx_start, tx_start_from_acc, tx_end_from_acc,tx_try_complete)
    begin
       case (src_sel1)
          3'b000 : begin
                        tx_itrpt1 = s00_axis_tlast;
                   end
          3'b001 : begin
                        tx_itrpt1 = phy_tx_start;
                   end
          3'b010 : begin
                        tx_itrpt1 = tx_start_from_acc;
                   end
          3'b011 : begin
                        tx_itrpt1 = tx_end_from_acc;
                   end
          3'b100 : begin
                        tx_itrpt1 = tx_try_complete;
                   end
          default: begin
                        tx_itrpt1 = 0;
                   end
       endcase
    end

	endmodule
