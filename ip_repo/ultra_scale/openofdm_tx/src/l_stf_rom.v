/*
 * Legacy short_preamble_rom - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module l_stf_rom
(
  input      [3:0]  addr,
  output reg [31:0] dout  
);

  always @ *
    case (addr)
              0:   dout = 32'h05E305E3;
              1:   dout = 32'hEF0C004D;
              2:   dout = 32'hFE47F5F3;
              3:   dout = 32'h1246FE61;
              4:   dout = 32'h0BC70000;
              5:   dout = 32'h1246FE61;
              6:   dout = 32'hFE47F5F3;
              7:   dout = 32'hEF0C004D;
              8:   dout = 32'h05E305E3;
              9:   dout = 32'h004DEF0C;
             10:   dout = 32'hF5F3FE47;
             11:   dout = 32'hFE611246;
             12:   dout = 32'h00000BC7;
             13:   dout = 32'hFE611246;
             14:   dout = 32'hF5F3FE47;
             15:   dout = 32'h004DEF0C;

          default: dout = 32'h00000000;
    endcase

endmodule
