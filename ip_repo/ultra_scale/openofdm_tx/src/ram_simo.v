/*
 * ram_simo - single input multiple output (simo) ram
 *
 * Michael Tetemke Mehari mehari.michael@gmail.com
 */


module ram_simo #(DEPTH=64)
(
	input  wire clk,

	input  wire [$clog2(DEPTH*8)-1:0] waddr,
	input  wire [$clog2(DEPTH)-1:0]   raddr,
	input  wire wen,
    input  wire data_i,

	output wire [5:0] data_o
);

reg  [DEPTH*8-1:0] mem;
 
// Empty memory initialization (only for simulation purpose)
initial	mem = {DEPTH*8{1'b0}};

// Data is latched on the positive edge of the clock
always @(posedge clk)
if (wen)
	mem[waddr] <= data_i;

assign data_o[0] = mem[{raddr,3'd0}];
assign data_o[1] = mem[{raddr,3'd1}];
assign data_o[2] = mem[{raddr,3'd2}];
assign data_o[3] = mem[{raddr,3'd3}];
assign data_o[4] = mem[{raddr,3'd4}];
assign data_o[5] = mem[{raddr,3'd5}];

endmodule
