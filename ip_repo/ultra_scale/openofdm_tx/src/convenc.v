/*
 * convenc - convolutional encoder implementation with generator polynomials, g0 = 133 and g1 = 171, of rate R = 1/2
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module convenc
(
  input  wire clk,
  input  wire rst,

  input  wire enc_en,
  input  wire bit_in,
  output wire [1:0] bits_out
);

  reg [5:0] state;
  always @(posedge clk)
  if (rst) begin
      state <= 0;
  end else if(enc_en) begin
      state <= {state[4:0], bit_in};
  end
  assign bits_out[0] =  bit_in ^ state[0] ^ state[1] ^ state[2] ^ state[5];
  assign bits_out[1] =  bit_in ^ state[1] ^ state[2] ^ state[4] ^ state[5];

endmodule
