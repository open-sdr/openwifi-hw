// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

module tx_interrupt_selection
(
     // selection
     input wire [2:0] src_sel,

     // src
     input wire s00_axis_tlast,
     input wire phy_tx_start,
     input wire tx_start_from_acc,
     input wire tx_end_from_acc,
     input wire tx_try_complete,

     // to ps interrupt
     output reg tx_itrpt
);

always @( src_sel, s00_axis_tlast,phy_tx_start, tx_start_from_acc, tx_end_from_acc,tx_try_complete)
begin
     case (src_sel)
     3'b000 : begin
                    tx_itrpt = s00_axis_tlast;
               end
     3'b001 : begin
                    tx_itrpt = phy_tx_start;
               end
     3'b010 : begin
                    tx_itrpt = tx_start_from_acc;
               end
     3'b011 : begin
                    tx_itrpt = tx_end_from_acc;
               end
     3'b100 : begin
                    tx_itrpt = tx_try_complete;
               end
     default: begin
                    tx_itrpt = 0;
               end
     endcase
end

endmodule
