/*
 * SRLNXE - N by X-Bit Shift Register
 *
 * Michael Tetemke Mehari mehari.michael@gmail.com
 */


module SRLNXE #(WIDTH=32, DEPTH=128)
(
	input  wire clk,

	input  wire [$clog2(DEPTH)-1:0] addr,
	input  wire wen,
	input  wire [WIDTH-1:0] data_i,

	output wire [WIDTH-1:0] data_o
);

	genvar  i; 
	generate
	for (i=0;i<WIDTH;i=i+1)	begin : gen_srlnxE
		SRLXE #(.DEPTH(DEPTH)) srlxe(
			.clk(clk),
			.addr(addr),
			.wen(wen), .data_i(data_i[i]),
			.data_o(data_o[i])
		);
	end
	endgenerate

endmodule
