// Michael Tetemke Mehari (michael.mehari@ugent.be)

module ht_sig_crc_calc(
	input wire clk,
	input wire reset,
	input wire [33:0] d,
	input wire start,
	output reg busy,
	output reg valid,
	output reg [7:0] crc
	);

	reg [5:0] i;
	reg [33:0] data;
	reg [7:0] c;

	wire temp;
	assign temp = c[7] ^ data[i];

	always @(posedge clk) begin
		if(reset) begin
			valid <= 0;
			i <= 0;
			data <= 0;
			c <= 0;
			busy <= 0;
			crc <= 0;

		end else begin
			if (start) begin
				valid <= 0;
				i <= 0;
				data <= d;
				c <= 8'b11111111;
				busy <= 1;
				crc <= 0;

			end else if (busy) begin

				c[7] <= c[6];
				c[6] <= c[5];
				c[5] <= c[4];
				c[4] <= c[3];
				c[3] <= c[2];
				c[2] <= c[1] ^ temp;
				c[1] <= c[0] ^ temp;
				c[0] <= temp;

				if (i == 34) begin
					busy <= 0;
					valid <= 1;
					crc <= ~({c[0],c[1],c[2],c[3],c[4],c[5],c[6],c[7]});
				end else begin
					i <= i + 1;
				end
			end else begin
				valid <= 0;
			end
		end
	end

endmodule
