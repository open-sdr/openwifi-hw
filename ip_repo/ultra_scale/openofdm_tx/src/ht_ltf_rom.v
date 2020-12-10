/*
 * HT long_preamble_rom - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module ht_ltf_rom
(
  input      [6:0]  addr,
  output reg [31:0] dout  
);

  always @ *
    case (addr)
              0:   dout = 32'h08000400;
              1:   dout = 32'h0F430285;
              2:   dout = 32'hFD1FEC0B;
              3:   dout = 32'h0782FE9C;
              4:   dout = 32'h03220D06;
              5:   dout = 32'hEE7DFF47;
              6:   dout = 32'h00201579;
              7:   dout = 32'h06D4FA1F;
              8:   dout = 32'h0C7C0624;
              9:   dout = 32'hFB180DF6;
             10:   dout = 32'hF1430374;
             11:   dout = 32'h07A81176;
             12:   dout = 32'h02B4F4BC;
             13:   dout = 32'h0C65FD14;
             14:   dout = 32'h05170813;
             15:   dout = 32'hFF5812D1;
             16:   dout = 32'h14000000;
             17:   dout = 32'hFF58ED2F;
             18:   dout = 32'h0517F7ED;
             19:   dout = 32'h0C6502EC;
             20:   dout = 32'h02B40B44;
             21:   dout = 32'h07A8EE8A;
             22:   dout = 32'hF143FC8C;
             23:   dout = 32'hFB18F20A;
             24:   dout = 32'h0C7CF9DC;
             25:   dout = 32'h06D405E1;
             26:   dout = 32'h0020EA87;
             27:   dout = 32'hEE7D00B9;
             28:   dout = 32'h0322F2FA;
             29:   dout = 32'h07820164;
             30:   dout = 32'hFD1F13F5;
             31:   dout = 32'h0F43FD7B;
             32:   dout = 32'h0800FC00;
             33:   dout = 32'h04BA0788;
             34:   dout = 32'hF8AD0A15;
             35:   dout = 32'hEF330443;
             36:   dout = 32'h0A860E4A;
             37:   dout = 32'h08E70134;
             38:   dout = 32'hF848094F;
             39:   dout = 32'hF8C6FF82;
             40:   dout = 32'hFB84E9DC;
             41:   dout = 32'hF0660092;
             42:   dout = 32'hEFB4FB54;
             43:   dout = 32'h099CF7AE;
             44:   dout = 32'hFFA40694;
             45:   dout = 32'hF43D0E74;
             46:   dout = 32'h0BBD0E0D;
             47:   dout = 32'h01930C23;
             48:   dout = 32'hEC000000;
             49:   dout = 32'h0193F3DD;
             50:   dout = 32'h0BBDF1F3;
             51:   dout = 32'hF43DF18C;
             52:   dout = 32'hFFA4F96C;
             53:   dout = 32'h099C0852;
             54:   dout = 32'hEFB404AC;
             55:   dout = 32'hF066FF6E;
             56:   dout = 32'hFB841624;
             57:   dout = 32'hF8C6007E;
             58:   dout = 32'hF848F6B1;
             59:   dout = 32'h08E7FECC;
             60:   dout = 32'h0A86F1B6;
             61:   dout = 32'hEF33FBBD;
             62:   dout = 32'hF8ADF5EB;
             63:   dout = 32'h04BAF878;
             64:   dout = 32'h08000400;
             65:   dout = 32'h0F430285;
             66:   dout = 32'hFD1FEC0B;
             67:   dout = 32'h0782FE9C;
             68:   dout = 32'h03220D06;
             69:   dout = 32'hEE7DFF47;
             70:   dout = 32'h00201579;
             71:   dout = 32'h06D4FA1F;
             72:   dout = 32'h0C7C0624;
             73:   dout = 32'hFB180DF6;
             74:   dout = 32'hF1430374;
             75:   dout = 32'h07A81176;
             76:   dout = 32'h02B4F4BC;
             77:   dout = 32'h0C65FD14;
             78:   dout = 32'h05170813;
             79:   dout = 32'hFF5812D1;

          default: dout = 32'h00000000;
    endcase

endmodule
