// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

module n_sym_len14_pkt #
(
)
(
    input wire ht_flag,
    input wire [3:0] rate_mcs,
    output wire [2:0] n_sym
);

  reg [2:0] num_data_ofdm_symbol;

  assign n_sym = num_data_ofdm_symbol;
  // lookup table for how many data OFDM symbol will be used for ACK/CTS (length 14)
  // to decide recv_ack_timeout_top and others
  //always @( signal_rate[7],signal_rate[3:0] )
  always @( ht_flag, rate_mcs )
  begin
      case ({ht_flag,rate_mcs})
        5'b01011 : begin //6Mbps
              num_data_ofdm_symbol = 6;
              end
        5'b01111 : begin //non-ht 9Mbps
              num_data_ofdm_symbol = 4;
              end
        5'b01010 : begin //non-ht 12Mbps
              num_data_ofdm_symbol = 3;
              end
        5'b01110 : begin //non-ht 18Mbps
              num_data_ofdm_symbol = 2;
              end
        5'b01001 :  begin //non-ht 24Mbps
              num_data_ofdm_symbol = 2;
              end
        5'b01101 : begin //non-ht 36Mbps
              num_data_ofdm_symbol = 1;
              end
        5'b01000  : begin //non-ht 48Mbps
              num_data_ofdm_symbol = 1;
              end
        5'b01100 : begin //non-ht 54Mbps
              num_data_ofdm_symbol = 1;
              end
        5'b10000 : begin //ht mcs 0
              num_data_ofdm_symbol = 6;
              end
        5'b10001 : begin //ht mcs 1
              num_data_ofdm_symbol = 3;
              end
        5'b10010 : begin //ht mcs 2
              num_data_ofdm_symbol = 2;
              end
        5'b10011 : begin //ht mcs 3
              num_data_ofdm_symbol = 2;
              end
        5'b10100 :  begin //ht mcs 4
              num_data_ofdm_symbol = 1;
              end
        5'b10101 : begin //ht mcs 5
              num_data_ofdm_symbol = 1;
              end
        5'b10110  : begin //ht mcs 6
              num_data_ofdm_symbol = 1;
              end
        5'b10111 : begin //ht mcs 7
              num_data_ofdm_symbol = 1;
              end
        default: begin
              num_data_ofdm_symbol = 6;
              end
      endcase
  end

endmodule
