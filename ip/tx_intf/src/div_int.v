// Project F: Division (Integer)
// (C)2021 Will Green, Open source hardware released under the MIT License
//
// Update to verilog implementation
// Michael Tetemke Mehari (michael.mehari@ugent.be)

`timescale 1ns / 1ps

module div_int #(parameter WIDTH=4) (
	input wire clk,
	input wire reset,
	input wire start,          // start signal
	output reg busy,           // calculation in progress
	output reg valid,          // quotient and remainder are valid
	output reg dbz,            // divide by zero flag
	input wire [WIDTH-1:0] x,  // dividend
	input wire [WIDTH-1:0] y,  // divisor
	output reg [WIDTH-1:0] q,  // quotient
	output reg [WIDTH-1:0] r   // remainder
	);

	reg [WIDTH-1:0] y1;            // copy of divisor
	reg [WIDTH-1:0] q1, q1_next;   // intermediate quotient
	reg [WIDTH:0] ac, ac_next;     // accumulator (1 bit wider)
	reg [$clog2(WIDTH)-1:0] i;     // iteration counter

	always @* begin
		if (ac >= {1'b0,y1}) begin
			ac_next = ac - y1;
			{ac_next, q1_next} = {ac_next[WIDTH-1:0], q1, 1'b1};
		end else begin
			{ac_next, q1_next} = {ac, q1} << 1;
		end
	end

	always @(posedge clk) begin
		if(reset) begin
			busy <= 0;
			valid <= 0;
			dbz <= 0;
			i <= 0;
			y1 <= 0;
			ac <= 0;
			q1 <= 0;

		end else begin
			if (start) begin
				valid <= 0;
				i <= 0;
				if (y == 0) begin  // catch divide by zero
					busy <= 0;
					dbz <= 1;
				end else begin  // initialize values
					busy <= 1;
					dbz <= 0;
					y1 <= y;
					{ac, q1} <= {{WIDTH{1'b0}}, x, 1'b0};
				end

			end else if (busy) begin
				if (i == WIDTH-1) begin  // we're done
					busy <= 0;
					valid <= 1;
					q <= q1_next;
					r <= ac_next[WIDTH:1];  // undo final shift
				end else begin  // next iteration
					i <= i + 1;
					ac <= ac_next;
					q1 <= q1_next;
				end
			end else begin
				valid <= 0;
			end
		end
	end
endmodule

