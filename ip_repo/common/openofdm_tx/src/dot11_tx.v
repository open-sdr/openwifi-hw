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

reg  FSM3_reset;        // Reset after transmiting a whole packet
wire reset_int = phy_tx_arest | FSM3_reset;

// Data collection states
reg [1:0] state1;
localparam S1_WAIT_PKT = 0;
localparam S1_L_SIG    = 1;
localparam S1_HT_SIG   = 2;
localparam S1_DATA     = 3;
reg [2:0] state11;
localparam S11_SERVICE   = 0;
localparam S11_PSDU_DATA = 1;
localparam S11_PSDU_CRC  = 2;
localparam S11_TAIL      = 3;
localparam S11_PAD       = 4;
localparam S11_RESET     = 5;

// IQ sample generation states
reg [1:0] state2;
localparam S2_PUNC_INTERLV   = 0;
localparam S2_PILOT_DC_SB    = 1;
localparam S2_MOD_IFFT_INPUT = 2;
localparam S2_RESET          = 3;

// IQ sample forwarding states
reg [2:0] state3;
localparam S3_WAIT_PKT = 0;
localparam S3_L_STF    = 1;
localparam S3_L_LTF    = 2;
localparam S3_L_SIG    = 3;
localparam S3_HT_SIG   = 4;
localparam S3_HT_STF   = 5;
localparam S3_HT_LTF   = 6;
localparam S3_DATA     = 7;

reg PKT_TYPE;
localparam LEGACY = 0;
localparam HT     = 1;

localparam NO_OUTPUT_YET  = 0;
localparam OUTPUT_STARTED = 1;

localparam CP_FIFO  = 0;
localparam PKT_FIFO = 1;

reg [5:0]  plcp_bit_cnt;
reg [3:0]  service_bit_cnt;
reg [14:0] psdu_bit_cnt;        // Maximum number of PSDU bits = 4095*8 = 32760
reg [10:0] ofdm_cnt_FSM1;       // Maximum number of OFDM symbols = 1 + ceil((16+4095*8+6)/24) = 1367

//////////////////////////////////////////////////////////////////////////
// LEGACY SHORT + LONG PREAMBLE
//////////////////////////////////////////////////////////////////////////
wire [31:0] l_stf;
wire [31:0] l_ltf;
reg  [7:0] preamble_addr;
l_stf_rom l_stf_rom (
    .addr(preamble_addr[3:0]),
    .dout(l_stf)
);

l_ltf_rom l_ltf_rom (
    .addr(preamble_addr),
    .dout(l_ltf)
);

//////////////////////////////////////////////////////////////////////////
// HT SHORT + LONG PREAMBLE
//////////////////////////////////////////////////////////////////////////
wire [31:0] ht_stf;
wire [31:0] ht_ltf;
ht_stf_rom ht_stf_rom (
    .addr(preamble_addr[3:0]),
    .dout(ht_stf)
);

ht_ltf_rom ht_ltf_rom (
    .addr(preamble_addr[6:0]),
    .dout(ht_ltf)
);

//////////////////////////////////////////////////////////////////////////
// Cyclic redundancy check (CRC32) and frame check sequence (FCS) block
//////////////////////////////////////////////////////////////////////////
wire        crc_en;
wire [3:0]  crc_data;
wire [31:0] pkt_fcs;
reg  [4:0]  pkt_fcs_idx;

assign crc_data[0] = state11 == S11_PSDU_DATA ? bram_din[(psdu_bit_cnt[5:2] << 2) + 0] : 0;
assign crc_data[1] = state11 == S11_PSDU_DATA ? bram_din[(psdu_bit_cnt[5:2] << 2) + 1] : 0;
assign crc_data[2] = state11 == S11_PSDU_DATA ? bram_din[(psdu_bit_cnt[5:2] << 2) + 2] : 0;
assign crc_data[3] = state11 == S11_PSDU_DATA ? bram_din[(psdu_bit_cnt[5:2] << 2) + 3] : 0;
crc32_tx fcs_inst (
    .clk(clk),
    .rst(reset_int),
    .crc_en(crc_en),
    .data_in(crc_data),
    .crc_out(pkt_fcs)
);
assign crc_en = (bits_enc_fifo_iready == 1 && state1 == S1_DATA && state11 == S11_PSDU_DATA && psdu_bit_cnt[1:0] == 2'b11);
//////////////////////////////////////////////////////////////////////////
// bit source selection and scrambling operation
//////////////////////////////////////////////////////////////////////////
reg       bit_scram;
reg [6:0] data_scram_state;
always @* begin
    bit_scram = 0;

    // Legacy PLCP [rate + reserved + length + parity + tail] and HT PLCP [MCS + length + reserved + short/long GI + CRC + tail] fields
    if(state1 == S1_L_SIG || state1 == S1_HT_SIG)
        bit_scram = bram_din[plcp_bit_cnt];

    // DATA [service + PSDU + CRC + tail + pad] fields
    else if(state1 == S1_DATA) begin
        // PLCP service field
        if(state11 == S11_SERVICE) begin
            bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ 0;

        // PSDU DATA feild
        end else if(state11 == S11_PSDU_DATA) begin
            bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ bram_din[psdu_bit_cnt[5:0]];

        // PSDU CRC field
        end else if(state11 == S11_PSDU_CRC) begin
            bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ pkt_fcs[pkt_fcs_idx];

        // DATA tail field
        end else if(state11 == S11_TAIL) begin
            bit_scram = 0;

        // DATA pad field
        end else if(state11 == S11_PAD) begin
            bit_scram = data_scram_state[6] ^ data_scram_state[3] ^ 0;
        end
    end
end

//////////////////////////////////////////////////////////////////////////
// Convolutional encoding
//////////////////////////////////////////////////////////////////////////
wire       enc_reset;
wire       enc_en;
wire [1:0] bits_enc;
convenc convenc (
    .clk(clk),
    .rst(enc_reset),
    .enc_en(enc_en),
    .bit_in(bit_scram),
    .bits_out(bits_enc)
);
assign enc_reset = phy_tx_arest | state1 == S1_WAIT_PKT | plcp_bit_cnt == 23 | plcp_bit_cnt == 47;
assign enc_en = state1 >= S1_L_SIG && state11 != S11_RESET && bits_enc_fifo_iready;

//////////////////////////////////////////////////////////////////////////
// DOT11 TX FINITE STATE MACHINE 1
//////////////////////////////////////////////////////////////////////////
reg [2:0]  N_BPSC;
reg [8:0]  N_DBPS;
reg [4:0]  RATE;
reg [14:0] PSDU_BIT_LEN;
reg        S_GI;
reg [8:0]  dbps_cnt_FSM1;

always @(posedge clk)
if (reset_int) begin
    bram_addr <= 0;
    N_BPSC <= 0;
    N_DBPS <= 0;
    RATE <= 0;
    PSDU_BIT_LEN <= 0;
    S_GI <= 0;
    plcp_bit_cnt <= 0;
    service_bit_cnt <= 0;
    psdu_bit_cnt <= 0;
    pkt_fcs_idx <= 0;
    dbps_cnt_FSM1 <= 0;
    ofdm_cnt_FSM1 <= 0;
    data_scram_state <= 0;
    state1 <= S1_WAIT_PKT;
    state11 <= S11_SERVICE;

end else if(bits_enc_fifo_iready == 1) begin
    case(state1)
    S1_WAIT_PKT: begin
        if(phy_tx_start) begin
            bram_addr <= 0;
            plcp_bit_cnt <= 0;
            state1 <= S1_L_SIG;
        end
    end

    S1_L_SIG: begin
        plcp_bit_cnt <= plcp_bit_cnt + 1;
        if(plcp_bit_cnt == 0) begin
            case(bram_din[3:0])
                4'b1011: begin  N_BPSC <= 1;  N_DBPS <= 24;  RATE <= 5'b01011; end  //  6 Mbps
                4'b1111: begin  N_BPSC <= 1;  N_DBPS <= 36;  RATE <= 5'b01111; end  //  9 Mbps
                4'b1010: begin  N_BPSC <= 2;  N_DBPS <= 48;  RATE <= 5'b01010; end  // 12 Mbps
                4'b1110: begin  N_BPSC <= 2;  N_DBPS <= 72;  RATE <= 5'b01110; end  // 18 Mbps
                4'b1001: begin  N_BPSC <= 4;  N_DBPS <= 96;  RATE <= 5'b01001; end  // 24 Mbps
                4'b1101: begin  N_BPSC <= 4;  N_DBPS <= 144; RATE <= 5'b01101; end  // 36 Mbps
                4'b1000: begin  N_BPSC <= 6;  N_DBPS <= 192; RATE <= 5'b01000; end  // 48 Mbps
                4'b1100: begin  N_BPSC <= 6;  N_DBPS <= 216; RATE <= 5'b01100; end  // 54 Mbps
                default: begin  N_BPSC <= 1;  N_DBPS <= 24;  RATE <= 5'b01011; end  //  6 Mbps
            endcase
            PSDU_BIT_LEN <= ({3'd0, bram_din[16:5]} << 3);
            PKT_TYPE <= bram_din[24];

        end else if(plcp_bit_cnt == 22) begin
            bram_addr <= 1;

        end else if(plcp_bit_cnt == 23) begin
            ofdm_cnt_FSM1 <= ofdm_cnt_FSM1 + 1;
            plcp_bit_cnt <= 0;

            // HT packet
            if(RATE == 5'b01011 && PKT_TYPE == HT) begin
                PKT_TYPE <= HT;
                state1 <= S1_HT_SIG;

            // Legacy packet
            end else begin
                PKT_TYPE <= LEGACY;
                service_bit_cnt <= 0;
                data_scram_state <= init_data_scram_state;
                dbps_cnt_FSM1 <= 0;

                state1 <= S1_DATA;
                state11 <= S11_SERVICE;
            end
        end
    end

    S1_HT_SIG: begin
        plcp_bit_cnt <= plcp_bit_cnt + 1;
        if(plcp_bit_cnt == 0) begin
            case(bram_din[2:0])
                3'b000:  begin  N_BPSC <= 1;  N_DBPS <= 26;  RATE <= 5'b10000; end  //  6.5 Mbps
                3'b001:  begin  N_BPSC <= 2;  N_DBPS <= 52;  RATE <= 5'b10001; end  // 13.0 Mbps
                3'b010:  begin  N_BPSC <= 2;  N_DBPS <= 78;  RATE <= 5'b10010; end  // 19.5 Mbps
                3'b011:  begin  N_BPSC <= 4;  N_DBPS <= 104; RATE <= 5'b10011; end  // 26.0 Mbps
                3'b100:  begin  N_BPSC <= 4;  N_DBPS <= 156; RATE <= 5'b10100; end  // 39.0 Mbps
                3'b101:  begin  N_BPSC <= 6;  N_DBPS <= 208; RATE <= 5'b10101; end  // 52.0 Mbps
                3'b110:  begin  N_BPSC <= 6;  N_DBPS <= 234; RATE <= 5'b10110; end  // 58.5 Mbps
                3'b111:  begin  N_BPSC <= 6;  N_DBPS <= 260; RATE <= 5'b10111; end  // 65.0 Mbps
                default: begin  N_BPSC <= 1;  N_DBPS <= 26;  RATE <= 5'b10000; end  //  6.5 Mbps
            endcase
            PSDU_BIT_LEN <= ({3'd0, bram_din[19:8]} << 3);
            S_GI <= bram_din[31];
        end else if(plcp_bit_cnt == 23) begin
            ofdm_cnt_FSM1 <= ofdm_cnt_FSM1 + 1;

        end else if(plcp_bit_cnt == 47) begin
            ofdm_cnt_FSM1 <= ofdm_cnt_FSM1 + 1;

            service_bit_cnt <= 0;
            data_scram_state <= init_data_scram_state;
            dbps_cnt_FSM1 <= 0;

            state1 <= S1_DATA;
            state11 <= S11_SERVICE;
        end
    end

    S1_DATA: begin
        data_scram_state <= {data_scram_state[5:0], (data_scram_state[3] ^ data_scram_state[6])};
        case(state11)
        S11_SERVICE: begin
            service_bit_cnt <= service_bit_cnt + 1;
            if(service_bit_cnt == 14) begin
                bram_addr <= 2;
            end else if(service_bit_cnt == 15) begin
                psdu_bit_cnt <= 0;
                state11 <= S11_PSDU_DATA;
            end
        end

        S11_PSDU_DATA: begin
            psdu_bit_cnt <= psdu_bit_cnt + 1;
            if(psdu_bit_cnt == (PSDU_BIT_LEN - 33))
                state11 <= S11_PSDU_CRC;
        end

        S11_PSDU_CRC: begin
            psdu_bit_cnt <= psdu_bit_cnt + 1;
            pkt_fcs_idx <= pkt_fcs_idx + 1;
            if(psdu_bit_cnt == PSDU_BIT_LEN - 1)
                state11 <= S11_TAIL;
        end

        S11_TAIL: begin
            data_scram_state <= data_scram_state;
            psdu_bit_cnt <= psdu_bit_cnt + 1;
            if(psdu_bit_cnt == PSDU_BIT_LEN + 5)
                state11 <= S11_PAD;
        end

        S11_PAD: begin
            psdu_bit_cnt <= psdu_bit_cnt + 1;
            if(dbps_cnt_FSM1 == 0) begin
                state11 <= S11_RESET;
            end
        end

        S11_RESET: begin
        end
        endcase

        // Update block ram address
        if(state11 <= S11_PSDU_DATA && psdu_bit_cnt[5:0] == 6'b111110)
            bram_addr <= bram_addr + 1;

        // Update dbps and ofdm symbol counters
        if(state11 <= S11_PAD) begin
            if(dbps_cnt_FSM1 == N_DBPS-1) begin
                dbps_cnt_FSM1 <= 0;
                ofdm_cnt_FSM1 <= ofdm_cnt_FSM1 + 1;
            end else begin
                dbps_cnt_FSM1 <= dbps_cnt_FSM1 + 1;
            end
        end
    end

    default: begin
        state1 <= S1_WAIT_PKT;
    end
    endcase
end

//////////////////////////////////////////////////////////////////////////
// Store scrambed bits into axi stream fifo
//////////////////////////////////////////////////////////////////////////
wire [1:0]  bits_enc_fifo_idata,  bits_enc_fifo_odata;
wire        bits_enc_fifo_ivalid, bits_enc_fifo_ovalid;
wire        bits_enc_fifo_iready, bits_enc_fifo_oready;
wire [15:0] bits_enc_fifo_space;
axi_fifo_bram #(.WIDTH(2), .SIZE(14)) bits_enc_fifo(
    .clk(clk), .reset(reset_int), .clear(reset_int),
    .i_tdata(bits_enc_fifo_idata), .i_tvalid(bits_enc_fifo_ivalid), .i_tready(bits_enc_fifo_iready),
    .o_tdata(bits_enc_fifo_odata), .o_tvalid(bits_enc_fifo_ovalid), .o_tready(bits_enc_fifo_oready),
    .space(bits_enc_fifo_space), .occupied()
);
assign bits_enc_fifo_idata  = bits_enc;
assign bits_enc_fifo_ivalid = state1 != S1_WAIT_PKT && state11 < S11_RESET;
assign bits_enc_fifo_oready = (state2 == S2_PUNC_INTERLV && bits_enc_fifo_ovalid == 1 && (enc_pos == 1 || (|punc_info == 1)));

//////////////////////////////////////////////////////////////////////////
// Bit puncturing and bit interleaving
//////////////////////////////////////////////////////////////////////////
// Puncturing and interleaving index look up table
reg  [10:0] ofdm_cnt_FSM2;
reg  [8:0]  dbps_cnt_FSM2;
wire [1:0]  punc_info;
wire [17:0] interlv_addrs;
punc_interlv_lut punc_interlv_lut(
    .rate(PKT_TYPE == LEGACY ? (ofdm_cnt_FSM2 > 0 ? RATE : 5'b01011) : (ofdm_cnt_FSM2 > 2 ? RATE : 5'b01011)),
    .idx_i(dbps_cnt_FSM2),
    .idx_o(interlv_addrs),
    .punc_o(punc_info)
);

// This is a RAM module for holding convolutionally encoded, punctured and interleaved bits.
// Bit puncturing is implicitly carried out, such that punc_interlv_lut provides write address along with puncturing ON/OFF signal
reg        enc_pos;
wire       bits_ram_en;
wire       punc_bit;
wire [8:0] bits_ram_waddr;
reg  [5:0] mod_addr;
wire [5:0] bits_to_mod;
ram_simo #(.DEPTH(52)) bits_ram(
    .clk(clk),
    .waddr(bits_ram_waddr),
    .raddr(mod_addr),
    .wen(bits_ram_en),
    .data_i(punc_bit),
    .data_o(bits_to_mod)
);
assign bits_ram_waddr = enc_pos == 1 ? interlv_addrs[17:9] : (punc_info[0] == 0 ? interlv_addrs[8:0] : interlv_addrs[17:9]);
assign bits_ram_en = (state2 == S2_PUNC_INTERLV);
assign punc_bit = enc_pos == 1 ? bits_enc_fifo_odata[0] : (punc_info[0] == 0 ? bits_enc_fifo_odata[1] : bits_enc_fifo_odata[0]);

//////////////////////////////////////////////////////////////////////////
// Bits modulation
//////////////////////////////////////////////////////////////////////////
// BPSK, QPSK, 16-QAM and 64-QAM modulation
wire [31:0] mod_IQ;
modulation modulation(
    .N_BPSC(PKT_TYPE == LEGACY ? (ofdm_cnt_FSM2 > 0 ? N_BPSC : 3'd1) : (ofdm_cnt_FSM2 > 2 ? N_BPSC : 3'd1)),
    .bits_in(bits_to_mod),
    .IQ(mod_IQ)
);

//////////////////////////////////////////////////////////////////////////
// PILOT, DC (0Hz) and sideband(SB)
//////////////////////////////////////////////////////////////////////////
reg  [31:0] pilot_iq [3:0];
reg  [6:0]  pilot_scram_state;
reg  [3:0]  ht_polarity;
wire        pilot_gain = pilot_scram_state[6] ^ pilot_scram_state[3] ^ 0;
wire [31:0] DC_SB_IQ = {16'h0000, 16'h0000};

//////////////////////////////////////////////////////////////////////////
// Inverse Fast Fourier Transform (IFFT)
//////////////////////////////////////////////////////////////////////////
reg [31:0] ifft_iq;
reg [7:0]  iq_cnt;
always @* begin
    ifft_iq = 0;
    if(state2 == S2_MOD_IFFT_INPUT) begin
        if(iq_cnt == 0 || ((PKT_TYPE == LEGACY || PKT_TYPE == HT && ofdm_cnt_FSM2 <= 2) && iq_cnt >= 27 && iq_cnt < 38) || (PKT_TYPE == HT && ofdm_cnt_FSM2 > 2 && iq_cnt >= 29 && iq_cnt < 36)) begin
            ifft_iq = DC_SB_IQ;
        end else if(iq_cnt == 7) begin
            ifft_iq = pilot_iq[2];
        end else if(iq_cnt == 21) begin
            ifft_iq = pilot_iq[3];
        end else if(iq_cnt == 43) begin
            ifft_iq = pilot_iq[0];
        end else if(iq_cnt == 57) begin
            ifft_iq = pilot_iq[1];
        end else if(iq_cnt < 64) begin
            if(PKT_TYPE == HT && (ofdm_cnt_FSM2 == 1 || ofdm_cnt_FSM2 == 2))
                ifft_iq = {mod_IQ[15:0], mod_IQ[31:16]};
            else
                ifft_iq = mod_IQ;
        end
    end
end

reg         ifft_ce;
wire        ifft_o_sync;
wire [31:0] ifft_o_result;
ifftmain ifft64(
    .i_clk(clk), .i_reset(reset_int),
    .i_ce(ifft_ce),
    .i_sample(ifft_iq),
    .o_result(ifft_o_result),
    .o_sync(ifft_o_sync)
);

//////////////////////////////////////////////////////////////////////////
// DOT11 TX FINITE STATE MACHINE 2
//////////////////////////////////////////////////////////////////////////
wire [8:0]  dbps_size;

always @(posedge clk)
if (reset_int) begin
    dbps_cnt_FSM2 <= 0;
    enc_pos <= 0;
    ofdm_cnt_FSM2 <= 0;
    iq_cnt <= 0;
    ifft_ce <= 0;
    mod_addr <= 0;
    pilot_scram_state <= init_pilot_scram_state;
    ht_polarity <= 4'b1000;
    state2 <= S2_PUNC_INTERLV;

end else begin
    case(state2)
    S2_PUNC_INTERLV: begin
        if(pkt_fifo_space > 63 && CP_fifo_space > 15 && bits_enc_fifo_ovalid == 1) begin
            // The encoding position is shifted only if encoded bits are not punctured
            if(|punc_info == 0)
                enc_pos <= ~enc_pos;

            // If encoding position is on the second place or if encoded bits are punctured
            if(enc_pos == 1 || |punc_info == 1) begin
                if(dbps_cnt_FSM2 == dbps_size-1) begin
                    dbps_cnt_FSM2 <= 0;
                    state2 <= S2_PILOT_DC_SB;

                end else begin
                    dbps_cnt_FSM2 <= dbps_cnt_FSM2 + 1;
                end
            end
        end
    end

    S2_PILOT_DC_SB: begin
        if(PKT_TYPE == HT && ofdm_cnt_FSM2 > 2) begin
            if(ht_polarity[0] ^ pilot_gain == 0)
                pilot_iq[0] <= {16'h4000, 16'h0000};
            else
                pilot_iq[0] <= {16'hC000, 16'h0000};

            if(ht_polarity[1] ^ pilot_gain == 0)
                pilot_iq[1] <= {16'h4000, 16'h0000};
            else
                pilot_iq[1] <= {16'hC000, 16'h0000};

            if(ht_polarity[2] ^ pilot_gain == 0)
                pilot_iq[2] <= {16'h4000, 16'h0000};
            else
                pilot_iq[2] <= {16'hC000, 16'h0000};

            if(ht_polarity[3] ^ pilot_gain == 0)
                pilot_iq[3] <= {16'h4000, 16'h0000};
            else
                pilot_iq[3] <= {16'hC000, 16'h0000};

            ht_polarity <= {ht_polarity[0], ht_polarity[3:1]};
        end else begin
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
        end
        pilot_scram_state <= {pilot_scram_state[5:0], (pilot_scram_state[3] ^ pilot_scram_state[6])};

        iq_cnt <= 0;
        ifft_ce <= 1;
        state2 <= S2_MOD_IFFT_INPUT;
    end

    S2_MOD_IFFT_INPUT: begin
        if(iq_cnt < 63) begin
            if(PKT_TYPE == HT && ofdm_cnt_FSM2 > 2) begin
                if(iq_cnt < 6)
                    mod_addr <= iq_cnt[5:0] + 26;
                else if(iq_cnt < 20)
                    mod_addr <= iq_cnt[5:0] + 25;
                else if(iq_cnt < 28)
                    mod_addr <= iq_cnt[5:0] + 24;
                else if(iq_cnt < 42)
                    mod_addr <= iq_cnt[5:0] - 35;
                else if(iq_cnt < 56)
                    mod_addr <= iq_cnt[5:0] - 36;
                else if(iq_cnt < 63)
                    mod_addr <= iq_cnt[5:0] - 37;
            end else begin
                if(iq_cnt < 6)
                    mod_addr <= iq_cnt[5:0] + 24;
                else if(iq_cnt < 20)
                    mod_addr <= iq_cnt[5:0] + 23;
                else if(iq_cnt < 28)
                    mod_addr <= iq_cnt[5:0] + 22;
                else if(iq_cnt < 42)
                    mod_addr <= iq_cnt[5:0] - 37;
                else if(iq_cnt < 56)
                    mod_addr <= iq_cnt[5:0] - 38;
                else if(iq_cnt < 63)
                    mod_addr <= iq_cnt[5:0] - 39;
            end

            iq_cnt <= iq_cnt + 1;

        end else begin
            ifft_ce <= 0;
            ofdm_cnt_FSM2 <= ofdm_cnt_FSM2 + 1;
            state2 <= S2_RESET;
        end
    end

    S2_RESET: begin
        // This is not the last OFDM symbol processed
        if(ofdm_cnt_FSM2 < ofdm_cnt_FSM1) begin
		    state2 <= S2_PUNC_INTERLV;
        end else if(state11 == S11_RESET) begin
            if(pkt_fifo_space > 2 && CP_fifo_space > 2)
                ifft_ce <= 1;
            else
                ifft_ce <= 0;
        end
    end

    default: begin
        state2 <= S2_PUNC_INTERLV;
    end
    endcase
end
assign dbps_size = PKT_TYPE == LEGACY ? (ofdm_cnt_FSM2 > 0 ? N_DBPS : 24) : (ofdm_cnt_FSM2 > 2 ? N_DBPS : 24);

//////////////////////////////////////////////////////////////////////////
// Count number of [pkt/CP] IQ samples to send
//////////////////////////////////////////////////////////////////////////
reg        ifft_status;
reg        ifft_ce_reg;
reg [31:0] ifft_o_result_reg;
reg [5:0]  ifft_o_iq_cnt;
reg [10:0] ifft_o_sync_cnt;
reg [15:0] nof_iq2send;
always @(posedge clk)
if (reset_int) begin
    ifft_o_iq_cnt <= 0;
    ifft_o_sync_cnt <= 0;
    ifft_status <= NO_OUTPUT_YET;
    nof_iq2send <= 320;

end else begin
    ifft_o_result_reg <= ifft_o_result;
    ifft_ce_reg <= ifft_ce;

    if(ifft_o_sync == 1) begin
        ifft_o_sync_cnt <= ifft_o_sync_cnt + 1;
        // The moment ifft outputs the first result, we change the status
        if(ifft_status == NO_OUTPUT_YET)
            ifft_status <= OUTPUT_STARTED;
    end

    // IFFT output counter
    if(ifft_status == OUTPUT_STARTED && ifft_ce == 1)
        ifft_o_iq_cnt <= ifft_o_iq_cnt + 1;

    // update number of IQ samples to send
    if(state2 == S2_PILOT_DC_SB) begin
        if(PKT_TYPE == HT) begin
            if(nof_iq2send == 480)
                nof_iq2send <= nof_iq2send + 240;
            else if(nof_iq2send < 480 || S_GI == 0)
                nof_iq2send <= nof_iq2send + 80;
            else
                nof_iq2send <= nof_iq2send + 72;
        end else begin
            nof_iq2send <= nof_iq2send + 80;
        end
    end
end

//////////////////////////////////////////////////////////////////////////
// Cyclic Prefix IFFT output -> Axi stream fifo
//////////////////////////////////////////////////////////////////////////
wire [31:0] CP_fifo_idata,  CP_fifo_odata;
wire        CP_fifo_ivalid, CP_fifo_ovalid;
wire        CP_fifo_iready, CP_fifo_oready;
wire [15:0] CP_fifo_space;
axi_fifo_bram #(.WIDTH(32), .SIZE(10)) CP_fifo(
    .clk(clk), .reset(reset_int), .clear(reset_int),
    .i_tdata(CP_fifo_idata), .i_tvalid(CP_fifo_ivalid), .i_tready(CP_fifo_iready),
    .o_tdata(CP_fifo_odata), .o_tvalid(CP_fifo_ovalid), .o_tready(CP_fifo_oready),
    .space(CP_fifo_space), .occupied()
);
assign CP_fifo_idata  = ifft_o_result_reg;
assign CP_fifo_ivalid = (S_GI == 1 && ifft_o_sync_cnt > 3) ? (ifft_o_iq_cnt[5:3] == 3'b111 ? ifft_ce_reg : 0) : (ifft_o_iq_cnt[5:4] == 2'b11 ? ifft_ce_reg : 0);
assign CP_fifo_oready = (state3 == S3_L_SIG || state3 == S3_HT_SIG || state3 == S3_DATA) && fifo_turn == CP_FIFO ? result_iq_ready : 0;

//////////////////////////////////////////////////////////////////////////
// Packet IFFT output -> Axi stream fifo
//////////////////////////////////////////////////////////////////////////
wire [31:0] pkt_fifo_idata,  pkt_fifo_odata;
wire        pkt_fifo_ivalid, pkt_fifo_ovalid;
wire        pkt_fifo_iready, pkt_fifo_oready;
wire [15:0] pkt_fifo_space;
axi_fifo_bram #(.WIDTH(32), .SIZE(12)) pkt_fifo(
    .clk(clk), .reset(reset_int), .clear(reset_int),
    .i_tdata(pkt_fifo_idata), .i_tvalid(pkt_fifo_ivalid), .i_tready(pkt_fifo_iready),
    .o_tdata(pkt_fifo_odata), .o_tvalid(pkt_fifo_ovalid), .o_tready(pkt_fifo_oready),
    .space(pkt_fifo_space), .occupied()
);
assign pkt_fifo_idata  = ifft_o_result_reg;
assign pkt_fifo_ivalid = ifft_status == OUTPUT_STARTED ? ifft_ce_reg : 0;
assign pkt_fifo_oready = (state3 == S3_L_SIG || state3 == S3_HT_SIG || state3 == S3_DATA) && fifo_turn == PKT_FIFO ? result_iq_ready : 0;

//////////////////////////////////////////////////////////////////////////
// Count number of [pkt/CP] IQ samples sent
//////////////////////////////////////////////////////////////////////////
reg        fifo_turn;
reg [15:0] pkt_iq_sent;
reg [13:0] CP_iq_sent;
always @(posedge clk)
if (reset_int) begin
    fifo_turn   <= PKT_FIFO;
    pkt_iq_sent <= 0;
    CP_iq_sent  <= 0;

end else begin
    if(result_iq_ready == 1 && result_iq_valid == 1) begin
        if(fifo_turn == PKT_FIFO) begin
            if(pkt_iq_sent[5:0] == 6'b111111 && |pkt_iq_sent[15:8] == 1)
                fifo_turn <= CP_FIFO;
            pkt_iq_sent   <= pkt_iq_sent + 1;
        end else if(fifo_turn == CP_FIFO) begin
            if((pkt_iq_sent < 640 && CP_iq_sent[3:0] == 4'b1111) || (S_GI == 0 && CP_iq_sent[3:0] == 4'b1111) || (S_GI == 1 && pkt_iq_sent >= 640 && CP_iq_sent[2:0] == 3'b111))
                fifo_turn <= PKT_FIFO;
            CP_iq_sent    <= CP_iq_sent + 1;
        end
    end
end

//////////////////////////////////////////////////////////////////////////
// DOT11 TX FINITE STATE MACHINE 3
//////////////////////////////////////////////////////////////////////////
always @(posedge clk)
if (reset_int) begin
    preamble_addr <= 0;
    phy_tx_done <= 0;
    FSM3_reset <= 0;

    state3 <= S3_WAIT_PKT;

end else if(result_iq_ready == 1) begin
    case(state3)
    S3_WAIT_PKT: begin
        if(phy_tx_start) begin
            preamble_addr <= 0;
            state3 <= S3_L_STF;
        end
    end

    S3_L_STF: begin
        // Legacy short preamble contains 10*16 = 160 samples
        if(preamble_addr < 159) begin
            preamble_addr <= preamble_addr + 1;
        end else begin
            preamble_addr <= 0;
            state3 <= S3_L_LTF;
        end

        // Send "OPERATION STARTED" message to upper layer
        if(preamble_addr == 0)
            phy_tx_started <= 1;
        else
            phy_tx_started <= 0;
    end

    S3_L_LTF: begin
        // Legacy long preamble contains 160 samples
        if(preamble_addr < 159) begin
            preamble_addr <= preamble_addr + 1;

        end else begin
            state3 <= S3_L_SIG;
        end
    end

    S3_L_SIG: begin
        // Legacy SIGNAL contains 80 samples
        if(pkt_iq_sent == 383 && CP_iq_sent == 16) begin
            if(PKT_TYPE == LEGACY)
                state3 <= S3_DATA;
            else
                state3 <= S3_HT_SIG;
        end
    end

    S3_HT_SIG: begin
        // HT SIGNAL contains 160 samples
        if(pkt_iq_sent == 511 && CP_iq_sent == 48) begin
            preamble_addr <= 0;
            state3 <= S3_HT_STF;
        end
    end

    S3_HT_STF: begin
        // HT short preamble contains 5*16 = 80 samples
        if(preamble_addr < 79) begin
            preamble_addr <= preamble_addr + 1;
        end else begin
            preamble_addr <= 0;
            state3 <= S3_HT_LTF;
        end
    end

    S3_HT_LTF: begin
        // HT long preamble contains 80 samples
        if(preamble_addr < 79) begin
            preamble_addr <= preamble_addr + 1;

        end else begin
            state3 <= S3_DATA;
        end
    end

    S3_DATA: begin
        if((pkt_iq_sent + {2'b00, CP_iq_sent}) == nof_iq2send-2) begin
            phy_tx_done <= 1;
            FSM3_reset <= 1;
        end
    end
    endcase
end

assign result_i        = state3 == S3_L_STF ? l_stf[31:16] : (state3 == S3_L_LTF ? l_ltf[31:16] : (state3 == S3_HT_STF ? ht_stf[31:16] : (state3 == S3_HT_LTF ? ht_ltf[31:16] : (fifo_turn == PKT_FIFO ? pkt_fifo_odata[31:16] : CP_fifo_odata[31:16]))));
assign result_q        = state3 == S3_L_STF ? l_stf[15:0]  : (state3 == S3_L_LTF ? l_ltf[15:0]  : (state3 == S3_HT_STF ? ht_stf[15:0]  : (state3 == S3_HT_LTF ? ht_ltf[15:0]  : (fifo_turn == PKT_FIFO ? pkt_fifo_odata[15:0]  : CP_fifo_odata[15:0]))));
assign result_iq_valid = state3 == S3_L_STF || state3 == S3_L_LTF || state3 == S3_HT_STF || state3 == S3_HT_LTF ? 1 : (fifo_turn == PKT_FIFO ? pkt_fifo_ovalid : CP_fifo_ovalid);

endmodule
