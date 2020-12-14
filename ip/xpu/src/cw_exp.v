
`timescale 1 ns / 1 ps

module cw_exp #
(
    parameter integer CW_EXP_MAX = 8
)
(
    input wire  clk,
	input wire  rstn,
    input wire tx_try_complete,
    input wire [3:0] cw_exp_min,
    input wire start_retrans,
    output reg [3:0] cw_exp
);

always @( posedge clk )
begin
    if ( rstn == 0 )
    begin
        cw_exp <= cw_exp_min;
    end else begin
        if(tx_try_complete) begin
            cw_exp <= cw_exp_min ;
        end else begin
            if (start_retrans && cw_exp < CW_EXP_MAX) begin
                cw_exp <= cw_exp + 1'b1; 
            end else begin
                cw_exp <= cw_exp ;
            end
        end
    end
end


endmodule