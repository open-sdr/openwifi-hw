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
        0:	IQ = {16'hC000, 16'h0000};

        1:	IQ = {16'h4000, 16'h0000};
      endcase

    // QPSK
    end else if(N_BPSC == 2) begin
      case(bits_in[1:0])
        0:	IQ = {16'hD2BF, 16'hD2BF};
        1:	IQ = {16'hD2BF, 16'h2D41};

        2:	IQ = {16'h2D41, 16'hD2BF};
        3:	IQ = {16'h2D41, 16'h2D41};
      endcase

    // 16 QAM
    end else if(N_BPSC == 4) begin
      case(bits_in[3:0])
        0:	IQ = {16'hC349, 16'hC349};
        1:	IQ = {16'hC349, 16'hEBC3};
        3:	IQ = {16'hC349, 16'h143D};
        2:	IQ = {16'hC349, 16'h3CB7};

        4:	IQ = {16'hEBC3, 16'hC349};
        5:	IQ = {16'hEBC3, 16'hEBC3};
        7:	IQ = {16'hEBC3, 16'h143D};
        6:	IQ = {16'hEBC3, 16'h3CB7};

        12:	IQ = {16'h143D, 16'hC349};
        13:	IQ = {16'h143D, 16'hEBC3};
        15:	IQ = {16'h143D, 16'h143D};
        14:	IQ = {16'h143D, 16'h3CB7};

        8:	IQ = {16'h3CB7, 16'hC349};
        9:	IQ = {16'h3CB7, 16'hEBC3};
        11:	IQ = {16'h3CB7, 16'h143D};
        10:	IQ = {16'h3CB7, 16'h3CB7};
      endcase

    // 64 QAM
    end else if(N_BPSC == 6) begin
      case(bits_in[5:0])
        0:	IQ = {16'hBAE0, 16'hBAE0};
        1:	IQ = {16'hBAE0, 16'hCEA0};
        3:	IQ = {16'hBAE0, 16'hE260};
        2:	IQ = {16'hBAE0, 16'hF620};
        6:	IQ = {16'hBAE0, 16'h09E0};
        7:	IQ = {16'hBAE0, 16'h1DA0};
        5:	IQ = {16'hBAE0, 16'h3160};
        4:	IQ = {16'hBAE0, 16'h4520};

        8:	IQ = {16'hCEA0, 16'hBAE0};
        9:	IQ = {16'hCEA0, 16'hCEA0};
        11:	IQ = {16'hCEA0, 16'hE260};
        10:	IQ = {16'hCEA0, 16'hF620};
        14:	IQ = {16'hCEA0, 16'h09E0};
        15:	IQ = {16'hCEA0, 16'h1DA0};
        13:	IQ = {16'hCEA0, 16'h3160};
        12:	IQ = {16'hCEA0, 16'h4520};

        24:	IQ = {16'hE260, 16'hBAE0};
        25:	IQ = {16'hE260, 16'hCEA0};
        27:	IQ = {16'hE260, 16'hE260};
        26:	IQ = {16'hE260, 16'hF620};
        30:	IQ = {16'hE260, 16'h09E0};
        31:	IQ = {16'hE260, 16'h1DA0};
        29:	IQ = {16'hE260, 16'h3160};
        28:	IQ = {16'hE260, 16'h4520};

        16:	IQ = {16'hF620, 16'hBAE0};
        17:	IQ = {16'hF620, 16'hCEA0};
        19:	IQ = {16'hF620, 16'hE260};
        18:	IQ = {16'hF620, 16'hF620};
        22:	IQ = {16'hF620, 16'h09E0};
        23:	IQ = {16'hF620, 16'h1DA0};
        21:	IQ = {16'hF620, 16'h3160};
        20:	IQ = {16'hF620, 16'h4520};

        48:	IQ = {16'h09E0, 16'hBAE0};
        49:	IQ = {16'h09E0, 16'hCEA0};
        51:	IQ = {16'h09E0, 16'hE260};
        50:	IQ = {16'h09E0, 16'hF620};
        54:	IQ = {16'h09E0, 16'h09E0};
        55:	IQ = {16'h09E0, 16'h1DA0};
        53:	IQ = {16'h09E0, 16'h3160};
        52:	IQ = {16'h09E0, 16'h4520};

        56:	IQ = {16'h1DA0, 16'hBAE0};
        57:	IQ = {16'h1DA0, 16'hCEA0};
        59:	IQ = {16'h1DA0, 16'hE260};
        58:	IQ = {16'h1DA0, 16'hF620};
        62:	IQ = {16'h1DA0, 16'h09E0};
        63:	IQ = {16'h1DA0, 16'h1DA0};
        61:	IQ = {16'h1DA0, 16'h3160};
        60:	IQ = {16'h1DA0, 16'h4520};

        40:	IQ = {16'h3160, 16'hBAE0};
        41:	IQ = {16'h3160, 16'hCEA0};
        43:	IQ = {16'h3160, 16'hE260};
        42:	IQ = {16'h3160, 16'hF620};
        46:	IQ = {16'h3160, 16'h09E0};
        47:	IQ = {16'h3160, 16'h1DA0};
        45:	IQ = {16'h3160, 16'h3160};
        44:	IQ = {16'h3160, 16'h4520};

        32:	IQ = {16'h4520, 16'hBAE0};
        33:	IQ = {16'h4520, 16'hCEA0};
        35:	IQ = {16'h4520, 16'hE260};
        34:	IQ = {16'h4520, 16'hF620};
        38:	IQ = {16'h4520, 16'h09E0};
        39:	IQ = {16'h4520, 16'h1DA0};
        37:	IQ = {16'h4520, 16'h3160};
        36:	IQ = {16'h4520, 16'h4520};
      endcase
    end
end
endmodule
