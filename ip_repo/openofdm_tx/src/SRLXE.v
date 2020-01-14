/*
 * SRLXE - X-Bit Shift Register
 *
 * Michael Tetemke Mehari mehari.michael@gmail.com
 */


module SRLXE #(DEPTH=128)
(
	input  wire clk,

	input  wire [$clog2(DEPTH)-1:0] addr,
	input  wire wen,
    input  wire data_i,

	output wire data_o
);

reg  [DEPTH-1:0] mem;

// Empty memory initialization (only for simulation purpose)
initial	mem = {DEPTH{1'b0}};

// Data is latched on the positive edge of the clock
always @(posedge clk)
if (wen)
	mem[DEPTH-1:0] <= {mem[DEPTH-2:0], data_i};

assign data_o = mem[addr];

endmodule
