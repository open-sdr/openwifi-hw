/*
 * crc32 - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module crc32_tx
(
	input  wire rst,
	input  wire clk,

	input  wire crc_en,
	input  wire [3:0]  data_in,
	output reg  [31:0] crc_out
);

wire [3:0]  idx;
reg [31:0] crc_table;
always @(*) begin
	case(idx)
		4'b0000: begin crc_table = 32'h4DBDF21C; end
		4'b0001: begin crc_table = 32'h500AE278; end
		4'b0010: begin crc_table = 32'h76D3D2D4; end
		4'b0011: begin crc_table = 32'h6B64C2B0; end
		4'b0100: begin crc_table = 32'h3B61B38C; end
		4'b0101: begin crc_table = 32'h26D6A3E8; end
		4'b0110: begin crc_table = 32'h000F9344; end
		4'b0111: begin crc_table = 32'h1DB88320; end
		4'b1000: begin crc_table = 32'hA005713C; end
		4'b1001: begin crc_table = 32'hBDB26158; end
		4'b1010: begin crc_table = 32'h9B6B51F4; end
		4'b1011: begin crc_table = 32'h86DC4190; end
		4'b1100: begin crc_table = 32'hD6D930AC; end
		4'b1101: begin crc_table = 32'hCB6E20C8; end
		4'b1110: begin crc_table = 32'hEDB71064; end
		4'b1111: begin crc_table = 32'hF0000000; end
	endcase
end
assign idx = crc_out[3:0] ^ data_in;


always @(posedge clk)
if (rst)
   	crc_out <= 0;
else if(crc_en)
	crc_out <= {4'b0000, crc_out[31:4]} ^ crc_table;

endmodule
