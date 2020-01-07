/*
 * modulation - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module modulation
(
  input  wire [2:0]  N_BPSC,
  input  wire [5:0]  bits_in,
  output reg  [31:0] IQ
);

// combinatorial logic
always @* begin
	IQ = {16'h0000, 16'h0000};
    // BPSK
    if(N_BPSC == 1) begin
      case(bits_in[0])
        1'b0:	IQ = {16'hC000, 16'h0000};

        1'b1:	IQ = {16'h4000, 16'h0000};
      endcase

    // QPSK
    end else if(N_BPSC == 2) begin
      case(bits_in[1:0])
        2'b00:	IQ = {16'hD2BF, 16'hD2BF};
        2'b10:	IQ = {16'hD2BF, 16'h2D41};

        2'b01:	IQ = {16'h2D41, 16'hD2BF};
        2'b11:	IQ = {16'h2D41, 16'h2D41};
      endcase

    // 16 QAM
    end else if(N_BPSC == 4) begin
      case(bits_in[3:0])
        4'b0000:	IQ = {16'hC349, 16'hC349};
        4'b1000:	IQ = {16'hC349, 16'hEBC3};
        4'b1100:	IQ = {16'hC349, 16'h143D};
        4'b0100:	IQ = {16'hC349, 16'h3CB7};

        4'b0010:	IQ = {16'hEBC3, 16'hC349};
        4'b1010:	IQ = {16'hEBC3, 16'hEBC3};
        4'b1110:	IQ = {16'hEBC3, 16'h143D};
        4'b0110:	IQ = {16'hEBC3, 16'h3CB7};

        4'b0011:	IQ = {16'h143D, 16'hC349};
        4'b1011:	IQ = {16'h143D, 16'hEBC3};
        4'b1111:	IQ = {16'h143D, 16'h143D};
        4'b0111:	IQ = {16'h143D, 16'h3CB7};

        4'b0001:	IQ = {16'h3CB7, 16'hC349};
        4'b1001:	IQ = {16'h3CB7, 16'hEBC3};
        4'b1101:	IQ = {16'h3CB7, 16'h143D};
        4'b0101:	IQ = {16'h3CB7, 16'h3CB7};
      endcase

    // 64 QAM
    end else if(N_BPSC == 6) begin
      case(bits_in[5:0])
        6'b000000:	IQ = {16'hBAE0, 16'hBAE0};
        6'b100000:	IQ = {16'hBAE0, 16'hCEA0};
        6'b110000:	IQ = {16'hBAE0, 16'hE260};
        6'b010000:	IQ = {16'hBAE0, 16'hF620};
        6'b011000:	IQ = {16'hBAE0, 16'h09E0};
        6'b111000:	IQ = {16'hBAE0, 16'h1DA0};
        6'b101000:	IQ = {16'hBAE0, 16'h3160};
        6'b001000:	IQ = {16'hBAE0, 16'h4520};

        6'b000100:	IQ = {16'hCEA0, 16'hBAE0};
        6'b100100:	IQ = {16'hCEA0, 16'hCEA0};
        6'b110100:	IQ = {16'hCEA0, 16'hE260};
        6'b010100:	IQ = {16'hCEA0, 16'hF620};
        6'b011100:	IQ = {16'hCEA0, 16'h09E0};
        6'b111100:	IQ = {16'hCEA0, 16'h1DA0};
        6'b101100:	IQ = {16'hCEA0, 16'h3160};
        6'b001100:	IQ = {16'hCEA0, 16'h4520};

        6'b000110:	IQ = {16'hE260, 16'hBAE0};
        6'b100110:	IQ = {16'hE260, 16'hCEA0};
        6'b110110:	IQ = {16'hE260, 16'hE260};
        6'b010110:	IQ = {16'hE260, 16'hF620};
        6'b011110:	IQ = {16'hE260, 16'h09E0};
        6'b111110:	IQ = {16'hE260, 16'h1DA0};
        6'b101110:	IQ = {16'hE260, 16'h3160};
        6'b001110:	IQ = {16'hE260, 16'h4520};

        6'b000010:	IQ = {16'hF620, 16'hBAE0};
        6'b100010:	IQ = {16'hF620, 16'hCEA0};
        6'b110010:	IQ = {16'hF620, 16'hE260};
        6'b010010:	IQ = {16'hF620, 16'hF620};
        6'b011010:	IQ = {16'hF620, 16'h09E0};
        6'b111010:	IQ = {16'hF620, 16'h1DA0};
        6'b101010:	IQ = {16'hF620, 16'h3160};
        6'b001010:	IQ = {16'hF620, 16'h4520};

        6'b000011:	IQ = {16'h09E0, 16'hBAE0};
        6'b100011:	IQ = {16'h09E0, 16'hCEA0};
        6'b110011:	IQ = {16'h09E0, 16'hE260};
        6'b010011:	IQ = {16'h09E0, 16'hF620};
        6'b011011:	IQ = {16'h09E0, 16'h09E0};
        6'b111011:	IQ = {16'h09E0, 16'h1DA0};
        6'b101011:	IQ = {16'h09E0, 16'h3160};
        6'b001011:	IQ = {16'h09E0, 16'h4520};

        6'b000111:	IQ = {16'h1DA0, 16'hBAE0};
        6'b100111:	IQ = {16'h1DA0, 16'hCEA0};
        6'b110111:	IQ = {16'h1DA0, 16'hE260};
        6'b010111:	IQ = {16'h1DA0, 16'hF620};
        6'b011111:	IQ = {16'h1DA0, 16'h09E0};
        6'b111111:	IQ = {16'h1DA0, 16'h1DA0};
        6'b101111:	IQ = {16'h1DA0, 16'h3160};
        6'b001111:	IQ = {16'h1DA0, 16'h4520};

        6'b000101:	IQ = {16'h3160, 16'hBAE0};
        6'b100101:	IQ = {16'h3160, 16'hCEA0};
        6'b110101:	IQ = {16'h3160, 16'hE260};
        6'b010101:	IQ = {16'h3160, 16'hF620};
        6'b011101:	IQ = {16'h3160, 16'h09E0};
        6'b111101:	IQ = {16'h3160, 16'h1DA0};
        6'b101101:	IQ = {16'h3160, 16'h3160};
        6'b001101:	IQ = {16'h3160, 16'h4520};

        6'b000001:	IQ = {16'h4520, 16'hBAE0};
        6'b100001:	IQ = {16'h4520, 16'hCEA0};
        6'b110001:	IQ = {16'h4520, 16'hE260};
        6'b010001:	IQ = {16'h4520, 16'hF620};
        6'b011001:	IQ = {16'h4520, 16'h09E0};
        6'b111001:	IQ = {16'h4520, 16'h1DA0};
        6'b101001:	IQ = {16'h4520, 16'h3160};
        6'b001001:	IQ = {16'h4520, 16'h4520};
      endcase
    end
end
endmodule
