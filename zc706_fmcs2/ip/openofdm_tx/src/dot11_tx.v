/*
 * dot11_tx - TODO
 *
 * Michael Tetemke Mehari mehari.michael@gmail.com
 */

module dot11_tx
(
  input  wire        clk,
  input  wire        phy_tx_arest,

  input  wire        phy_tx_start,
  output reg         phy_tx_done,
  output reg         phy_tx_started,

  input  wire [6:0]  init_pilot_scram_state,
  input  wire [6:0]  init_data_scram_state,

  input  wire [63:0] bram_din,
  output reg  [9:0]  bram_addr,

  input  wire        result_iq_ready,
  output wire        result_iq_valid,
  output wire [15:0] result_i,
  output wire [15:0] result_q
);

reg  after_sym_reset;        // Reset after transmiting an OFDM symbol
reg  after_pkt_reset;        // Reset after transmiting a whole packet
wire reset1 = phy_tx_arest | after_pkt_reset;
wire reset2 = phy_tx_arest | after_pkt_reset | after_sym_reset;

reg [2:0] state1;
localparam S1_WAIT_FOR_PKT   = 0;
localparam S1_SHORT_PREAMBLE = 1;
localparam S1_LONG_PREAMBLE  = 2;
localparam S1_SIGNAL         = 3;
localparam S1_DATA           = 4;

reg [2:0] state2;
localparam S2_PLCP               = 0;
localparam S2_SCRAM_ENC_CRC      = 1;
localparam S2_PUNC_INTERLV_MODL  = 2;
localparam S2_PILOT_DC_SB        = 3;
localparam S2_IFFT_INPUT         = 4;
localparam S2_IFFT_RESULT        = 5;
localparam S2_CYCL_PREFIX        = 6;

reg state3;
localparam S3_SERVICE = 0;
localparam S3_PSDU    = 1;

localparam [63:0] SHORT_PREAMBLE_0 = 64'b0001000100010001000100010000000000000001000100010001000100010000;
localparam [63:0] SHORT_PREAMBLE_1 = 64'b0000000100010000000100000000000000000000000000000000000100010000;

localparam [63:0] LONG_PREAMBLE_0  = 64'b1111111111111111111111111100000000000111111111111111111111111110;
localparam [63:0] LONG_PREAMBLE_1  = 64'b0000101001100000010100110000000000000000010101100111110101001100;

reg  [2:0]  N_BPSC;
reg  [2:0]  n_bpsc_cnt;
reg  [8:0]  N_CBPS;
reg  [7:0]  N_DBPS;
reg  [7:0]  n_dbps_cnt;
reg  [5:0]  plcp_bit_cnt;
reg  [3:0]  RATE;
reg  [14:0] PSDU_BIT_LEN;
reg  [14:0] psdu_bit_cnt;        // Maximum number of PSDU bits = 4095*8 = 32760
//reg  [10:0] ofdm_cnt;            // Maximum number of OFDM symbols = 1 + ceil((16+4095*8+6)/24) = 1367
reg  [7:0]  iq_cnt;

wire [15:0] sym_i;
wire [15:0] sym_q;
//wire        v2fr_empty;

assign result_i        = state2 == S2_CYCL_PREFIX && iq_cnt != 255 ? sym_i : 0;
assign result_q        = state2 == S2_CYCL_PREFIX && iq_cnt != 255 ? sym_q : 0;
assign result_iq_valid = state2 == S2_CYCL_PREFIX && iq_cnt != 255 ? 1     : 0;


// SIGNAL section debugging
// Scrambling
//assign result_q        = (state1 == S1_SIGNAL && state2 == S2_SCRAM_ENC_CRC) ? {15'd0, bit_scram} : 0;
//assign result_iq_valid = (state1 == S1_SIGNAL && state2 == S2_SCRAM_ENC_CRC) ? 1                 : 0;
// convolutional encoder
//assign result_q        = (state1 == S1_SIGNAL && state2 == S2_SCRAM_ENC_CRC) ? {14'd0, bits_enc_i} : 0;
//assign result_iq_valid = (state1 == S1_SIGNAL && state2 == S2_SCRAM_ENC_CRC) ? 1                  : 0;
// puncturing
//assign result_q        = (state1 == S1_SIGNAL && state2 == S2_SCRAM_ENC_CRC) ? {14'd0, bits_enc_i} : 0;
//assign result_iq_valid = (state1 == S1_SIGNAL && state2 == S2_SCRAM_ENC_CRC) ? bits_sreg_en       : 0;
// Interleaving
//assign result_q        = (state1 == S1_SIGNAL && state2 == S2_PUNC_INTERLV_MODL) ? {15'd0, bit_enc_o} : 0;
//assign result_iq_valid = (state1 == S1_SIGNAL && state2 == S2_PUNC_INTERLV_MODL) ? 1                  : 0;
// IFFT input
//assign result_i        = (state1 == S1_SIGNAL && state2 == S2_IFFT_INPUT && iq_cnt < 63) ? ifft_iq[31:16] : 0;
//assign result_q        = (state1 == S1_SIGNAL && state2 == S2_IFFT_INPUT && iq_cnt < 63) ? ifft_iq[15:0]  : 0;
//assign result_iq_valid = (state1 == S1_SIGNAL && state2 == S2_IFFT_INPUT && iq_cnt < 63) ? 1              : 0;
// IFFT result
//assign result_i        = (state1 == S1_SIGNAL && state2 == S2_IFFT_RESULT) ? ifft_o_result_reg[31:16] : 0;
//assign result_q        = (state1 == S1_SIGNAL && state2 == S2_IFFT_RESULT) ? ifft_o_result_reg[15:0]  : 0;
//assign result_iq_valid = (state1 == S1_SIGNAL && state2 == S2_IFFT_RESULT) ? 1                        : 0;

// DATA section debugging
// Scrambling
//assign result_q        = (state1 == S1_DATA && state2 == S2_SCRAM_ENC_CRC) ? {15'd0, bit_scram} : 0;
//assign result_iq_valid = (state1 == S1_DATA && state2 == S2_SCRAM_ENC_CRC) ? 1                  : 0;
// convolutional encoder
//assign result_q        = (state1 == S1_DATA && state2 == S2_SCRAM_ENC_CRC) ? {14'd0, bits_enc_i} : 0;
//assign result_iq_valid = (state1 == S1_DATA && state2 == S2_SCRAM_ENC_CRC) ? 1                  : 0;
// puncturing
//assign result_q        = (state1 == S1_DATA && state2 == S2_SCRAM_ENC_CRC) ? {14'd0, bits_enc_i} : 0;
//assign result_iq_valid = (state1 == S1_DATA && state2 == S2_SCRAM_ENC_CRC) ? bits_sreg_en       : 0;
// Interleaving
//assign result_q        = (state1 == S1_DATA && state2 == S2_PUNC_INTERLV_MODL) ? {15'd0, bit_enc_o} : 0;
//assign result_iq_valid = (state1 == S1_DATA && state2 == S2_PUNC_INTERLV_MODL) ? 1                  : 0;
// IFFT input
//assign result_i        = (state1 == S1_DATA && state2 == S2_IFFT_INPUT && ofdm_cnt == 2 && (iq_cnt < 63 || (iq_cnt == 63 && ifft_o_sync == 1))) ? ifft_iq[31:16] : 0;
//assign result_q        = (state1 == S1_DATA && state2 == S2_IFFT_INPUT && ofdm_cnt == 2 && (iq_cnt < 63 || (iq_cnt == 63 && ifft_o_sync == 1))) ? ifft_iq[15:0]  : 0;
//assign result_iq_valid = (state1 == S1_DATA && state2 == S2_IFFT_INPUT && ofdm_cnt == 2 && (iq_cnt < 63 || (iq_cnt == 63 && ifft_o_sync == 1))) ? 1              : 0;
// IFFT result
//assign result_i        = (state1 == S1_DATA && state2 == S2_IFFT_RESULT && ofdm_cnt == 2) ? ifft_o_result_reg[31:16] : 0;
//assign result_q        = (state1 == S1_DATA && state2 == S2_IFFT_RESULT && ofdm_cnt == 2) ? ifft_o_result_reg[15:0]  : 0;
//assign result_iq_valid = (state1 == S1_DATA && state2 == S2_IFFT_RESULT && ofdm_cnt == 2) ? 1                        : 0;


//////////////////////////////////////////////////////////////////////////
// Cyclic redundancy check (CRC32) and frame check sequence (FCS) block
//////////////////////////////////////////////////////////////////////////
reg         crc_en;
wire [3:0]  crc_data;
wire [31:0] pkt_fcs;
reg  [4:0]  pkt_fcs_idx;

assign crc_data[0] = state3 == S3_PSDU ? bram_din[(psdu_bit_cnt[5:2] << 2) + 0] : 0;
assign crc_data[1] = state3 == S3_PSDU ? bram_din[(psdu_bit_cnt[5:2] << 2) + 1] : 0;
assign crc_data[2] = state3 == S3_PSDU ? bram_din[(psdu_bit_cnt[5:2] << 2) + 2] : 0;
assign crc_data[3] = state3 == S3_PSDU ? bram_din[(psdu_bit_cnt[5:2] << 2) + 3] : 0;

crc32_tx fcs_inst (
    .clk(clk),
    .rst(reset1),
    .crc_en(crc_en),
    .data_in(crc_data),
    .crc_out(pkt_fcs)
);

//////////////////////////////////////////////////////////////////////////
// bit source selection and scrambling operation
//////////////////////////////////////////////////////////////////////////
reg        bit_scram;
reg        bit_scram_last_val;
reg  [6:0] pilot_scram_state;
reg  [6:0] data_scram_state;
always @*
if(state2 == S2_SCRAM_ENC_CRC) begin
    if(state1 == S1_SIGNAL) begin

        bit_scram = bram_din[plcp_bit_cnt[5:0]];

    // Scrambling only occurs in DATA section along with data bit selection
    end else if(state1 == S1_DATA) begin

        // PLCP service field
        if(state3 == S3_SERVICE) begin
            bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ 0;
        end else begin

            // DATA pad field
            if(psdu_bit_cnt >= PSDU_BIT_LEN + 6)
                bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ 0;
            // DATA tail field
            else if(psdu_bit_cnt >= PSDU_BIT_LEN)
                bit_scram = 0;
            // PSDU CRC field
            else if(psdu_bit_cnt >= (PSDU_BIT_LEN - 32))
                bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ pkt_fcs[pkt_fcs_idx];
            // PSDU
            else
                bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ bram_din[psdu_bit_cnt[5:0]];
        end
    end else begin
        bit_scram = 0;
    end
end else if (state2 == S2_CYCL_PREFIX && iq_cnt == 255) begin
    bit_scram = bit_scram_last_val;
end else begin
    bit_scram = 0;
end

//////////////////////////////////////////////////////////////////////////
// Convolutional encoding and bit puncturing
//////////////////////////////////////////////////////////////////////////
reg  [5:0] convenc_curr_state;
wire [5:0] convenc_next_state;
wire [1:0] bits_enc_i;
convenc convenc (
    .curr_state(convenc_curr_state),
    .bit_in(bit_scram),
    .next_state(convenc_next_state),
    .bits_out(bits_enc_i)
);

// This is a shift register for holding convolutionally encoded bits and to be used for puncturing and interleaving.
// Bit puncturing is implicitly carried out, such that interleaver_lut only provides the address for the bits to be read
// For 802.11ag standard, the maximum number of data bits per sysmbol (N_DBPS) is 216, hence the depth of the SRLNXE.
wire bit_enc_o;
wire [1:0] bits_enc_o;
wire [8:0] interlv_addr;
SRLNXE #(.WIDTH(2), .DEPTH(216)) bits_sreg(
    .clk(clk),
    .addr(interlv_addr[8:1]),
    .wen(state2 == S2_SCRAM_ENC_CRC),
    .data_i(bits_enc_i),
    .data_o(bits_enc_o)
);
assign bit_enc_o = bits_enc_o[interlv_addr[0]];

//////////////////////////////////////////////////////////////////////////
// Bit interleaving and modulation
//////////////////////////////////////////////////////////////////////////
// Interleaver index look up table
reg  [8:0] interlv_cnt;
interleaver_lut interleaver_lut(
    .rate(state1 == S1_DATA ? RATE : 4'b1011),
    .idx_i(interlv_cnt[8:0]),
    .idx_o(interlv_addr)
);

// BPSK, QPSK, 16-QAM and 64-QAM modulation
reg  [4:0]  bits_to_mod;
wire [31:0] mod_IQ;
modulation modulation(
    .N_BPSC(state1 == S1_DATA ? N_BPSC : 3'd1),
    .bits_in({bits_to_mod,bit_enc_o}),
    .IQ(mod_IQ)
);

// Store modulated IQ samples into a shift register
reg         mod_sreg_en;
reg  [5:0]  mod_addr;
wire [31:0] mod_sreg_IQ;
SRLNXE #(.WIDTH(32), .DEPTH(48)) mod_sreg(
    .clk(clk),
    .addr(mod_addr),
    .wen(mod_sreg_en), .data_i(mod_IQ),
    .data_o(mod_sreg_IQ)
);


//////////////////////////////////////////////////////////////////////////
// PILOT, DC (0Hz) and sideband(SB)
//////////////////////////////////////////////////////////////////////////
reg  [31:0] pilot_iq [3:0];
wire        pilot_gain = pilot_scram_state[6] ^ pilot_scram_state[3] ^ 0;
wire [31:0] DC_SB_IQ = {16'h0000, 16'h0000};


//////////////////////////////////////////////////////////////////////////
// Inverse Fast Fourier Transform (IFFT)
//////////////////////////////////////////////////////////////////////////
reg        ifft_ce;
reg [31:0] ifft_iq;
reg [31:0] ifft_iq_reg;

always @* begin
    ifft_iq = 0;
    if(state1 == S1_SHORT_PREAMBLE) begin
        ifft_iq = {SHORT_PREAMBLE_1[iq_cnt[5:0]], SHORT_PREAMBLE_0[iq_cnt[5:0]]} == 2'b01 ? {16'h2F1A, 16'h2F1A} : ( {SHORT_PREAMBLE_1[iq_cnt[5:0]], SHORT_PREAMBLE_0[iq_cnt[5:0]]} == 2'b11 ? {16'hD0E6, 16'hD0E6} : {16'h0000, 16'h0000} );
    end else if(state1 == S1_LONG_PREAMBLE) begin
        ifft_iq = {LONG_PREAMBLE_1[iq_cnt[5:0]], LONG_PREAMBLE_0[iq_cnt[5:0]], 30'd0};
    end else if(state1 == S1_SIGNAL || state1 == S1_DATA) begin
        if(iq_cnt == 0 || (iq_cnt >= 27 && iq_cnt < 38))
            ifft_iq = DC_SB_IQ;
        else if(iq_cnt == 7)
            ifft_iq = pilot_iq[2];
        else if(iq_cnt == 21)
            ifft_iq = pilot_iq[3];
        else if(iq_cnt == 43)
            ifft_iq = pilot_iq[0];
        else if(iq_cnt == 57)
            ifft_iq = pilot_iq[1];
        else if(iq_cnt < 64)
            ifft_iq = mod_sreg_IQ;
    end
end

wire        ifft_o_sync;
wire [31:0] ifft_o_result;
reg [31:0]  ifft_o_result_reg;
ifftmain ifft64(
    .i_clk(clk), .i_reset(reset2),
    .i_ce(ifft_ce),
    .i_sample(ifft_iq),
    .o_result(ifft_o_result),
    .o_sync(ifft_o_sync)
);

always @(posedge clk) begin
    ifft_iq_reg <= ifft_iq;
    if(state1 == S1_SHORT_PREAMBLE)
        ifft_o_result_reg <= (ifft_o_result << 1);
    else
        ifft_o_result_reg <= ifft_o_result;
end

// Store IFFT output into a shift register
reg ifft_sreg_en;
SRLNXE #(.WIDTH(32), .DEPTH(64)) ifft_sreg(
    .clk(clk),
    .addr(iq_cnt[5:0]),
    .wen(ifft_sreg_en), .data_i(ifft_o_result_reg),
    .data_o({sym_i, sym_q})
);


//////////////////////////////////////////////////////////////////////////
// DOT11 TX STATE MACHINE
//////////////////////////////////////////////////////////////////////////
always @(posedge clk)
if (reset1) begin
    phy_tx_started     <= 0;
    phy_tx_done        <= 0;
    iq_cnt             <= 0;
    ifft_ce            <= 0;
    ifft_sreg_en       <= 0;
    bits_to_mod        <= 0;
    bram_addr          <= 0;
//    ofdm_cnt           <= 0;
    plcp_bit_cnt       <= 0;
    psdu_bit_cnt       <= 0;
    N_BPSC             <= 0;
    N_CBPS             <= 0;
    N_DBPS             <= 0;
    RATE               <= 0;
    PSDU_BIT_LEN       <= 0;
    convenc_curr_state <= 0;
    interlv_cnt        <= 0;
    n_dbps_cnt         <= 0;
    mod_addr           <= 0;
    pilot_iq[0]        <= 0;
    pilot_iq[1]        <= 0;
    pilot_iq[2]        <= 0;
    pilot_iq[3]        <= 0;
    pkt_fcs_idx        <= 0;
    pilot_scram_state  <= 0;
    data_scram_state   <= 0;
    after_sym_reset    <= 0;
    after_pkt_reset    <= 0;
    state1             <= S1_WAIT_FOR_PKT;
    state2             <= 0;
    state3             <= 0;

end else begin
  case(state1)
    S1_WAIT_FOR_PKT: begin
      if(phy_tx_start) begin
          ifft_ce <= 1;
          state1  <= S1_SHORT_PREAMBLE;
          state2  <= S2_IFFT_INPUT;
      end
    end

    S1_SHORT_PREAMBLE: begin
      case(state2)
        S2_IFFT_INPUT: begin
            if(iq_cnt < 63) begin
                iq_cnt <= iq_cnt + 1;

            end else if(ifft_o_sync == 1) begin
                iq_cnt       <= 0;
                ifft_sreg_en <= 1;
                state2       <= S2_IFFT_RESULT;
            end

            // Send "OPERATION STARTED" message to upper layer
            if(iq_cnt == 0)
                phy_tx_started <= 1;
            else
                phy_tx_started <= 0;
        end

        S2_IFFT_RESULT: begin
            if(iq_cnt < 63) begin
                iq_cnt          <= iq_cnt + 1;
            end else begin
                iq_cnt          <= 159;
                ifft_ce         <= 0;
                ifft_sreg_en    <= 0;
                after_sym_reset <= 1;
                state2          <= S2_CYCL_PREFIX;
            end
        end

        S2_CYCL_PREFIX: begin
            if(result_iq_ready == 1) begin
                if(iq_cnt != 255) begin
                    iq_cnt <= iq_cnt - 1;

                end else begin
                    iq_cnt          <= 0;
                    ifft_ce         <= 1;
                    state1          <= S1_LONG_PREAMBLE;
                    state2          <= S2_IFFT_INPUT;
                end
            end
            after_sym_reset <= 0;
        end
      endcase
    end

    S1_LONG_PREAMBLE: begin
      case(state2)
        S2_IFFT_INPUT: begin
            if(iq_cnt < 63) begin
                iq_cnt <= iq_cnt + 1;

            end else if(ifft_o_sync == 1) begin
                iq_cnt       <= 0;
                ifft_sreg_en <= 1;
                state2       <= S2_IFFT_RESULT;
            end
        end

        S2_IFFT_RESULT: begin
            if(iq_cnt < 63) begin
                iq_cnt          <= iq_cnt + 1;
            end else begin
                iq_cnt          <= 159;
                ifft_ce         <= 0;
                ifft_sreg_en    <= 0;
                after_sym_reset <= 1;
                state2          <= S2_CYCL_PREFIX;
            end
        end

        S2_CYCL_PREFIX: begin
            if(result_iq_ready == 1) begin
                if(iq_cnt != 255) begin
                    iq_cnt <= iq_cnt - 1;

                end else begin
                    bram_addr       <= 0;            // SIGNAL section starting address
                    state1          <= S1_SIGNAL;
                    state2          <= S2_PLCP;
                end
            end
            after_sym_reset <= 0;
        end
      endcase
    end

    S1_SIGNAL: begin
      case(state2)
        // Decode N_BPSC, N_CBPS, N_DBPS and PSDU_BIT_LEN from SIGNAL "rate" field. Will only be applied to DATA field
        S2_PLCP: begin
            case(bram_din[3:0])
                4'b1011: begin  N_BPSC <= 1;  N_CBPS <= 48;   N_DBPS <= 24;   end  //  6 Mbps
                4'b1111: begin  N_BPSC <= 1;  N_CBPS <= 48;   N_DBPS <= 36;   end  //  9 Mbps
                4'b1010: begin  N_BPSC <= 2;  N_CBPS <= 96;   N_DBPS <= 48;   end  // 12 Mbps
                4'b1110: begin  N_BPSC <= 2;  N_CBPS <= 96;   N_DBPS <= 72;   end  // 18 Mbps
                4'b1001: begin  N_BPSC <= 4;  N_CBPS <= 192;  N_DBPS <= 96;   end  // 24 Mbps
                4'b1101: begin  N_BPSC <= 4;  N_CBPS <= 192;  N_DBPS <= 144;  end  // 36 Mbps
                4'b1000: begin  N_BPSC <= 6;  N_CBPS <= 288;  N_DBPS <= 192;  end  // 48 Mbps
                4'b1100: begin  N_BPSC <= 6;  N_CBPS <= 288;  N_DBPS <= 216;  end  // 54 Mbps
                default: begin  N_BPSC <= 1;  N_CBPS <= 48;   N_DBPS <= 24;   end  //  6 Mbps
            endcase
            RATE         <= bram_din[3:0];
            PSDU_BIT_LEN <= ({3'd0, bram_din[16:5]} << 3);

            plcp_bit_cnt       <= 0;
            convenc_curr_state <= 6'b000000;
            state2             <= S2_SCRAM_ENC_CRC;
        end

        S2_SCRAM_ENC_CRC: begin

            plcp_bit_cnt       <= plcp_bit_cnt + 1;
            convenc_curr_state <= convenc_next_state;

            // SIGNAL field contains 24 bits
            if(plcp_bit_cnt == 23) begin
                convenc_curr_state <= 6'b000000;
                interlv_cnt        <= 0;
                mod_sreg_en        <= 1;
                state2             <= S2_PUNC_INTERLV_MODL;
            end
        end

        S2_PUNC_INTERLV_MODL: begin
            if(interlv_cnt < 47) begin
                interlv_cnt <= interlv_cnt + 1;
            end else begin
                mod_sreg_en <= 0;
                state2      <= S2_PILOT_DC_SB;
            end
        end

        S2_PILOT_DC_SB: begin
            pilot_iq[0] <= {16'h4000, 16'h0000};
            pilot_iq[1] <= {16'h4000, 16'h0000};
            pilot_iq[2] <= {16'h4000, 16'h0000};
            pilot_iq[3] <= {16'hC000, 16'h0000};

            iq_cnt  <= 0;
            ifft_ce <= 1;
            state2  <= S2_IFFT_INPUT;
        end

        S2_IFFT_INPUT: begin
            if(iq_cnt < 63) begin
                if(iq_cnt < 6) begin
                    mod_addr <= 47 - (iq_cnt[5:0] + 24);
                end else if(iq_cnt < 20) begin
                    mod_addr <= 47 - (iq_cnt[5:0] + 23);
                end else if(iq_cnt < 26) begin
                    mod_addr <= 47 - (iq_cnt[5:0] + 22);
                end else if(iq_cnt < 42) begin
                    mod_addr <= 47 - (iq_cnt[5:0] - 37);
                end else if(iq_cnt < 56) begin
                    mod_addr <= 47 - (iq_cnt[5:0] - 38);
                end else if(iq_cnt < 63) begin
                    mod_addr <= 47 - (iq_cnt[5:0] - 39);
                end
                iq_cnt <= iq_cnt + 1;

            end else if(ifft_o_sync == 1) begin
                iq_cnt       <= 0;
                ifft_sreg_en <= 1;
                state2       <= S2_IFFT_RESULT;
            end
        end

        S2_IFFT_RESULT: begin
            if(iq_cnt < 63) begin
                iq_cnt          <= iq_cnt + 1;
            end else begin
                iq_cnt          <= 79;                // CP starting index = 49. Due to shift register, it becomes 64-49 = 15 and it is equivalent to the first 6 bits of 79
                ifft_ce         <= 0;
                ifft_sreg_en    <= 0;
                after_sym_reset <= 1;
                state2          <= S2_CYCL_PREFIX;
            end
        end

        S2_CYCL_PREFIX: begin
            if(result_iq_ready == 1) begin
                if(iq_cnt != 255) begin
                    iq_cnt <= iq_cnt - 1;

                end else begin
                    n_dbps_cnt         <= 0;
                    convenc_curr_state <= 6'b000000;
                    pilot_scram_state  <= init_pilot_scram_state;//7'b1111110;
                    data_scram_state   <= init_data_scram_state;//7'b1111111;

//                    ofdm_cnt           <= ofdm_cnt + 1;
                    state1             <= S1_DATA;
                    state2             <= S2_SCRAM_ENC_CRC;
                    state3             <= S3_SERVICE;
                end
            end
            after_sym_reset <= 0;
        end
      endcase
    end

    S1_DATA: begin
      case(state2)
        S2_SCRAM_ENC_CRC: begin
          case(state3)
            S3_SERVICE: begin

                n_dbps_cnt         <= n_dbps_cnt + 1;
                plcp_bit_cnt       <= plcp_bit_cnt + 1;
                convenc_curr_state <= convenc_next_state;
                data_scram_state   <= {data_scram_state[5:0], (data_scram_state[3] ^ data_scram_state[6])};

                // DATA section starting address
                if(plcp_bit_cnt == 38)
                    bram_addr <= 2;

                if(plcp_bit_cnt == 39) begin
                    crc_en <= 1;
                    state3 <= S3_PSDU;
                end
            end


            S3_PSDU: begin

                // 1 OFDM symbol contains N_DBPS coded bits
                if(n_dbps_cnt == N_DBPS-1) begin
                    interlv_cnt        <= 0;
                    bits_to_mod        <= 5'b00000;
                    bit_scram_last_val <= bit_scram;
                    n_bpsc_cnt         <= (N_BPSC == 1) ? 0 : 1;
                    mod_sreg_en        <= (N_BPSC == 1) ? 1 : 0;
                    state2             <= S2_PUNC_INTERLV_MODL;

                end else begin
                    n_dbps_cnt         <= n_dbps_cnt + 1;
                    psdu_bit_cnt       <= psdu_bit_cnt + 1;
                    convenc_curr_state <= convenc_next_state;
                    if(psdu_bit_cnt < PSDU_BIT_LEN || psdu_bit_cnt >= PSDU_BIT_LEN + 6)
                        data_scram_state <= {data_scram_state[5:0], (data_scram_state[3] ^ data_scram_state[6])};

                    // Update CRC reading index
                    if(psdu_bit_cnt >= (PSDU_BIT_LEN - 32) && psdu_bit_cnt < PSDU_BIT_LEN)
                       pkt_fcs_idx <= pkt_fcs_idx + 1;

                    // After processing 64 bits, update block ram address
                    if(psdu_bit_cnt[5:0] == 6'b111110)
                        bram_addr <= bram_addr + 1;

                    // While scrambling, encoding and puncturing the PSDU, calculate aggregate cyclic redundancy check (CRC)
                    if(psdu_bit_cnt < (PSDU_BIT_LEN - 36) && psdu_bit_cnt[1:0] == 2'b11)
                        crc_en <= 1;
                    else
                        crc_en <= 0;
                    end
               end
          endcase
        end

        S2_PUNC_INTERLV_MODL: begin

            bits_to_mod <= {bits_to_mod[3:0],bit_enc_o};

            if(interlv_cnt < N_CBPS - 1) begin
                interlv_cnt <= interlv_cnt + 1;
                // Count N_CBPS bits and perform IQ modulation
                if(n_bpsc_cnt < N_BPSC - 1) begin
                    mod_sreg_en <= 0;
                    n_bpsc_cnt  <= n_bpsc_cnt + 1;
                end else begin
                    mod_sreg_en <= 1;
                    n_bpsc_cnt  <= 0;
                end
            end else begin
                mod_sreg_en <= 0;
                state2      <= S2_PILOT_DC_SB;
            end
        end

        S2_PILOT_DC_SB: begin
            if(pilot_gain == 0) begin
                pilot_iq[0] <= {16'h4000, 16'h0000};
                pilot_iq[1] <= {16'h4000, 16'h0000};
                pilot_iq[2] <= {16'h4000, 16'h0000};
                pilot_iq[3] <= {16'hC000, 16'h0000};
            end else begin
                pilot_iq[0] <= {16'hC000, 16'h0000};
                pilot_iq[1] <= {16'hC000, 16'h0000};
                pilot_iq[2] <= {16'hC000, 16'h0000};
                pilot_iq[3] <= {16'h4000, 16'h0000};
            end
            pilot_scram_state <= {pilot_scram_state[5:0], (pilot_scram_state[3] ^ pilot_scram_state[6])};

            iq_cnt  <= 0;
            ifft_ce <= 1;
            state2  <= S2_IFFT_INPUT;
        end

        S2_IFFT_INPUT: begin
            if(iq_cnt < 63) begin
                if(iq_cnt < 6) begin
                    mod_addr <= 47 - (iq_cnt[5:0] + 24);
                end else if(iq_cnt < 20) begin
                    mod_addr <= 47 - (iq_cnt[5:0] + 23);
                end else if(iq_cnt < 26) begin
                    mod_addr <= 47 - (iq_cnt[5:0] + 22);
                end else if(iq_cnt < 42) begin
                    mod_addr <= 47 - (iq_cnt[5:0] - 37);
                end else if(iq_cnt < 56) begin
                    mod_addr <= 47 - (iq_cnt[5:0] - 38);
                end else if(iq_cnt < 63) begin
                    mod_addr <= 47 - (iq_cnt[5:0] - 39);
                end
                iq_cnt <= iq_cnt + 1;

            end else if(ifft_o_sync == 1) begin
                iq_cnt       <= 0;
                ifft_sreg_en <= 1;
                state2       <= S2_IFFT_RESULT;
            end
        end

        S2_IFFT_RESULT: begin
            if(iq_cnt < 63) begin
                iq_cnt          <= iq_cnt + 1;
            end else begin
                iq_cnt          <= 79;                // CP starting index = 49. Due to shift register, it becomes 64-49 = 15 and it is equivalent to (6 bits of) 79
                ifft_ce         <= 0;
                ifft_sreg_en    <= 0;
                after_sym_reset <= 1;
                state2          <= S2_CYCL_PREFIX;
            end
        end

        S2_CYCL_PREFIX: begin
            if(result_iq_ready == 1) begin
                if(iq_cnt != 255) begin
                    iq_cnt <= iq_cnt - 1;

                end else begin
                    // This is not the last OFDM symbol processed. Issue a soft "SYMBOL" reset
                    if(psdu_bit_cnt <= PSDU_BIT_LEN) begin

                        n_dbps_cnt         <= 0;
                        psdu_bit_cnt       <= psdu_bit_cnt + 1;
                        convenc_curr_state <= convenc_next_state;
                        if(psdu_bit_cnt < PSDU_BIT_LEN || psdu_bit_cnt >= PSDU_BIT_LEN + 6)
                            data_scram_state <= {data_scram_state[5:0], (data_scram_state[3] ^ data_scram_state[6])};

                        // Update CRC reading index
                        if(psdu_bit_cnt >= (PSDU_BIT_LEN - 32) && psdu_bit_cnt < PSDU_BIT_LEN)
                            pkt_fcs_idx <= pkt_fcs_idx + 1;

                        // While scrambling, encoding and puncturing the PSDU, calculate aggregate cyclic redundancy check (CRC)
                        if(psdu_bit_cnt < (PSDU_BIT_LEN - 36) && psdu_bit_cnt[1:0] == 2'b11)
                            crc_en <= 1;
                        else
                            crc_en <= 0;

//                        ofdm_cnt           <= ofdm_cnt + 1;
                        state1             <= S1_DATA;
                        state2             <= S2_SCRAM_ENC_CRC;

                    // This is the last OFDM symbol processed. Issue a soft "PACKET" reset
                    end else if(psdu_bit_cnt > PSDU_BIT_LEN) begin
                        phy_tx_done     <= 1;
                        after_pkt_reset <= 1;        // after_pkt_reset is triggered, DOT11_TX FSM resets.
                    end
                end
            end
            after_sym_reset <= 0;
        end
      endcase
    end

    default: begin
        after_pkt_reset <= 1;
    end
  endcase
end

endmodule
