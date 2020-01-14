/*
 * convenc - convolutional encoder implementation with generator polynomials, g0 = 133 and g1 = 171, of rate R = 1/2
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module convenc
(
  input  wire [5:0] curr_state,
  input  wire       bit_in,
  output wire [5:0] next_state,
  output wire [1:0] bits_out
);

  assign next_state  = {curr_state[4:0], bit_in};
  assign bits_out[0] =  bit_in ^ curr_state[0] ^ curr_state[1] ^ curr_state[2] ^ curr_state[5];
  assign bits_out[1] =  bit_in ^ curr_state[1] ^ curr_state[2] ^ curr_state[4] ^ curr_state[5];

endmodule
