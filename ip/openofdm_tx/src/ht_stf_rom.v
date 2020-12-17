/*
 * HT short_preamble_rom - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module ht_stf_rom
(
  input      [3:0]  addr,
  output reg [31:0] dout  
);

  always @ *
    case (addr)
              0:   dout = 32'h02D402D4;
              1:   dout = 32'hF7DB0025;
              2:   dout = 32'hFF2CFB2C;
              3:   dout = 32'h08C7FF39;
              4:   dout = 32'h05A80000;
              5:   dout = 32'h08C7FF39;
              6:   dout = 32'hFF2CFB2C;
              7:   dout = 32'hF7DB0025;
              8:   dout = 32'h02D402D4;
              9:   dout = 32'h0025F7DB;
             10:   dout = 32'hFB2CFF2C;
             11:   dout = 32'hFF3908C7;
             12:   dout = 32'h000005A8;
             13:   dout = 32'hFF3908C7;
             14:   dout = 32'hFB2CFF2C;
             15:   dout = 32'h0025F7DB;

          default: dout = 32'h00000000;
    endcase

endmodule


