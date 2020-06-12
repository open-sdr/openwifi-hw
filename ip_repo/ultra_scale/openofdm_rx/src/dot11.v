`include "common_defs.v"

module dot11 (
    input clock,
    input enable,
    input reset,

    // setting registers
    //input set_stb,
    //input [7:0] set_addr,
    //input [31:0] set_data,
    
    // add ports for register based inputs
    input [10:0] power_thres,
    input [31:0] min_plateau,

    // INPUT: RSSI
    input [10:0] rssi_half_db,
    // INPUT: I/Q sample
    input [31:0] sample_in,
    input sample_in_strobe,
    input soft_decoding,

    // OUTPUT: bytes and FCS status
    output reg demod_is_ongoing,
    output reg pkt_begin,
    output reg pkt_ht,
    output reg pkt_header_valid,
    output reg pkt_header_valid_strobe,
    output reg ht_unsupport,
    output reg [7:0] pkt_rate,
    output reg [15:0] pkt_len,
    output reg [15:0] pkt_len_total,
    output byte_out_strobe,
    output [7:0] byte_out,
    output reg [15:0] byte_count_total,
    output reg [15:0] byte_count,
    output reg fcs_out_strobe,
    output reg fcs_ok,

    /////////////////////////////////////////////////////////
    // DEBUG PORTS
    /////////////////////////////////////////////////////////
    
    // decode status
    output reg [3:0] state,
    output reg [3:0] status_code,
    output state_changed,

    // power trigger
    output power_trigger,

    // sync short
    output short_preamble_detected,
    output [31:0] phase_offset,

    // sync long
    output [31:0] sync_long_metric,
    output sync_long_metric_stb,
    output long_preamble_detected,
    output [31:0] sync_long_out,
    output sync_long_out_strobe,
    output [2:0] sync_long_state,

    // equalizer
    output [31:0] equalizer_out,
    output equalizer_out_strobe,
    output [2:0] equalizer_state,

    // legacy signal info
    output reg legacy_sig_stb,
    output [3:0] legacy_rate,
    output legacy_sig_rsvd,
    output [11:0] legacy_len,
    output legacy_sig_parity,
    output legacy_sig_parity_ok,
    output [5:0] legacy_sig_tail,

    // ht signal info
    output reg ht_sig_stb,
    output [6:0] ht_mcs,
    output ht_cbw,
    output [15:0] ht_len,
    output ht_smoothing,
    output ht_not_sounding,
    output ht_aggregation,
    output [1:0] ht_stbc,
    output ht_fec_coding,
    output ht_sgi,
    output [1:0] ht_num_ext,
    output reg ht_sig_crc_ok,

    // decoding pipeline
    output [5:0] demod_out,
    output demod_out_strobe,

    output [7:0] deinterleave_erase_out,
    output deinterleave_erase_out_strobe,

    output conv_decoder_out,
    output conv_decoder_out_stb,

    output descramble_out,
    output descramble_out_strobe
);

`include "common_params.v"


////////////////////////////////////////////////////////////////////////////////
// Shared rotation LUT for sync_long and equalizer
////////////////////////////////////////////////////////////////////////////////
wire [`ROTATE_LUT_LEN_SHIFT-1:0] sync_long_rot_addr;
wire [31:0] sync_long_rot_data;

wire [`ROTATE_LUT_LEN_SHIFT-1:0] eq_rot_addr;
wire [31:0] eq_rot_data;

rot_lut rot_lut_inst (
    .clka(clock),
    .addra(sync_long_rot_addr),
    .douta(sync_long_rot_data),

    .clkb(clock),
    .addrb(eq_rot_addr),
    .doutb(eq_rot_data)
);
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
// Shared phase module for sync_short and equalizer
////////////////////////////////////////////////////////////////////////////////
wire [31:0] sync_short_phase_in_i;
wire [31:0] sync_short_phase_in_q;
wire sync_short_phase_in_stb;
wire [31:0] sync_short_phase_out;
wire sync_short_phase_out_stb;

wire [31:0] eq_phase_in_i;
wire [31:0] eq_phase_in_q;
wire eq_phase_in_stb;
wire [31:0] eq_phase_out;
wire eq_phase_out_stb;

wire[31:0] phase_in_i = state == S_SYNC_SHORT?
    sync_short_phase_in_i: eq_phase_in_i;
wire[31:0] phase_in_q = state == S_SYNC_SHORT?
    sync_short_phase_in_q: eq_phase_in_q;
wire phase_in_stb = state == S_SYNC_SHORT?
    sync_short_phase_in_stb: eq_phase_in_stb;

wire [31:0] phase_out;
wire phase_out_stb;

assign sync_short_phase_out = phase_out;
assign sync_short_phase_out_stb = phase_out_stb;
assign eq_phase_out = phase_out;
assign eq_phase_out_stb = phase_out_stb;

phase phase_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .in_i(phase_in_i),
    .in_q(phase_in_q),
    .input_strobe(phase_in_stb),

    .phase(phase_out),
    .output_strobe(phase_out_stb)
);
////////////////////////////////////////////////////////////////////////////////


reg sync_short_reset;
reg sync_long_reset;
wire sync_short_enable = state == S_SYNC_SHORT;
reg sync_long_enable;

reg equalizer_reset;
reg equalizer_enable;

reg ht_next;

wire eq_out_stb_delayed;
wire [15:0] eq_out_i = equalizer_out[31:16];
wire [15:0] eq_out_q = equalizer_out[15:0];
wire [15:0] eq_out_i_delayed;
wire [15:0] eq_out_q_delayed;
reg [15:0] abs_eq_i;
reg [15:0] abs_eq_q;
reg [3:0] rot_eq_count;
reg [3:0] normal_eq_count;

// OFDM control
reg ofdm_reset;
reg ofdm_enable;
reg ofdm_in_stb;
reg [15:0] ofdm_in_i;
reg [15:0] ofdm_in_q;

reg do_descramble;
reg [31:0] num_bits_to_decode;
reg short_gi;

reg [3:0] old_state;

assign power_trigger = (rssi_half_db>=power_thres? 1: 0);
assign state_changed = state != old_state;

// SIGNAL information
reg [23:0] signal_bits;

assign legacy_rate = signal_bits[3:0];
assign legacy_sig_rsvd = signal_bits[4];
assign legacy_len = signal_bits[16:5];
assign legacy_sig_parity = signal_bits[17];
assign legacy_sig_tail = signal_bits[23:18];
assign legacy_sig_parity_ok = ~^signal_bits[17:0];


// HT-SIG information
reg [23:0] ht_sig1;
reg [23:0] ht_sig2;

assign ht_mcs = ht_sig1[6:0];
assign ht_cbw = ht_sig1[7];
assign ht_len = ht_sig1[23:8];

assign ht_smoothing = ht_sig2[0];
assign ht_not_sounding = ht_sig2[1];
assign ht_aggregation = ht_sig2[3];
assign ht_stbc = ht_sig2[5:4];
assign ht_fec_coding = ht_sig2[6];
assign ht_sgi = ht_sig2[7];
assign ht_num_ext = ht_sig2[9:8];


wire ht_rsvd = ht_sig2[2];
wire [7:0] crc = ht_sig2[17:10];
wire [5:0] ht_sig_tail = ht_sig2[23:18];


reg crc_in_stb;
reg crc_in;
reg [7:0] crc_count;
reg crc_reset;
wire [7:0] crc_out;

reg [31:0] sample_count;

wire fcs_enable = state == S_DECODE_DATA && byte_out_strobe;
wire fcs_reset = state_changed && state == S_DECODE_DATA;
wire [7:0] byte_reversed;
wire [31:0] pkt_fcs;

assign byte_reversed[0] = byte_out[7];
assign byte_reversed[1] = byte_out[6];
assign byte_reversed[2] = byte_out[5];
assign byte_reversed[3] = byte_out[4];
assign byte_reversed[4] = byte_out[3];
assign byte_reversed[5] = byte_out[2];
assign byte_reversed[6] = byte_out[1];
assign byte_reversed[7] = byte_out[0];

reg [15:0] sync_long_out_count;

/*
power_trigger power_trigger_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .sample_in(sample_in),
    .sample_in_strobe(sample_in_strobe),

    .power_thres(power_thres),
    .window_size(window_size),
    .num_sample_to_skip(num_sample_to_skip),
    .num_sample_changed(num_sample_changed),

    .pw_state_spy(pw_state_spy),
    .trigger(power_trigger)
);
*/

sync_short sync_short_inst (
    .clock(clock),
    .reset(reset | sync_short_reset),
    .enable(enable & sync_short_enable),

    .min_plateau(min_plateau),
    .sample_in(sample_in),
    .sample_in_strobe(sample_in_strobe),

    .phase_in_i(sync_short_phase_in_i),
    .phase_in_q(sync_short_phase_in_q),
    .phase_in_stb(sync_short_phase_in_stb),

    .phase_out(sync_short_phase_out),
    .phase_out_stb(sync_short_phase_out_stb),

    .short_preamble_detected(short_preamble_detected),
    .phase_offset(phase_offset)
);

sync_long sync_long_inst (
    .clock(clock),
    .reset(reset | sync_long_reset),
    .enable(enable & sync_long_enable),

    .sample_in(sample_in),
    .sample_in_strobe(sample_in_strobe),
    .phase_offset(phase_offset),
    .short_gi(short_gi),

    .rot_addr(sync_long_rot_addr),
    .rot_data(sync_long_rot_data),

    .metric(sync_long_metric),
    .metric_stb(sync_long_metric_stb),
    .long_preamble_detected(long_preamble_detected),
    .state(sync_long_state),

    .sample_out(sync_long_out),
    .sample_out_strobe(sync_long_out_strobe)
);

equalizer equalizer_inst (
    .clock(clock),
    .reset(reset | equalizer_reset),
    .enable(enable & equalizer_enable),

    .sample_in(sync_long_out),
    .sample_in_strobe(sync_long_out_strobe),
    .ht_next(ht_next),

    .phase_in_i(eq_phase_in_i),
    .phase_in_q(eq_phase_in_q),
    .phase_in_stb(eq_phase_in_stb),

    .phase_out(eq_phase_out),
    .phase_out_stb(eq_phase_out_stb),

    .rot_addr(eq_rot_addr),
    .rot_data(eq_rot_data),

    .sample_out(equalizer_out),
    .sample_out_strobe(equalizer_out_strobe),

    .state(equalizer_state)
);


delayT #(.DATA_WIDTH(33), .DELAY(6)) eq_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in({equalizer_out_strobe, equalizer_out}),
    .data_out({eq_out_stb_delayed, eq_out_i_delayed, eq_out_q_delayed})
);


ofdm_decoder ofdm_decoder_inst (
    .clock(clock),
    .reset(reset|ofdm_reset),
    .enable(enable & ofdm_enable),

    .sample_in({ofdm_in_i, ofdm_in_q}),
    .sample_in_strobe(ofdm_in_stb),
    .soft_decoding(soft_decoding),

    .do_descramble(do_descramble),
    .num_bits_to_decode(num_bits_to_decode),
    .rate(pkt_rate),

    .byte_out(byte_out),
    .byte_out_strobe(byte_out_strobe),

    .demod_out(demod_out),
    .demod_out_strobe(demod_out_strobe),

    .deinterleave_erase_out(deinterleave_erase_out),
    .deinterleave_erase_out_strobe(deinterleave_erase_out_strobe),

    .conv_decoder_out(conv_decoder_out),
    .conv_decoder_out_stb(conv_decoder_out_stb),

    .descramble_out(descramble_out),
    .descramble_out_strobe(descramble_out_strobe)
);

ht_sig_crc crc_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset | crc_reset),

    .bit(crc_in),
    .input_strobe(crc_in_stb),
    .crc(crc_out)
);

crc32 fcs_inst (
    .clk(clock),
    .crc_en(enable & fcs_enable),
    .rst(reset | fcs_reset),
    .data_in(byte_reversed),
    .crc_out(pkt_fcs)
);


always @(posedge clock) begin
    if (reset) begin
        status_code <= E_OK;
        state <= S_WAIT_POWER_TRIGGER;
        old_state <= 0;

        sync_short_reset <= 0;

        sync_long_reset <= 0;
        sync_long_enable <= 0;

        byte_count <= 0;
        byte_count_total <= 0;

        demod_is_ongoing <= 0;
        pkt_begin <= 0;
        pkt_ht <= 0;
        pkt_header_valid <= 0;
        pkt_header_valid_strobe <= 0;
        ht_unsupport <= 0;

        rot_eq_count <= 0;
        normal_eq_count <= 0;
        abs_eq_i <= 0;
        abs_eq_q <= 0;

        do_descramble <= 0;
        num_bits_to_decode <= 0;
        short_gi <= 0;
        pkt_rate <= 0;

        equalizer_reset <= 0;
        equalizer_enable <= 0;
        ht_next <= 0;

        pkt_len <= 0;
        pkt_len_total <= 0;

        ofdm_reset <= 0;
        ofdm_enable <= 0;
        ofdm_in_stb <= 0;
        ofdm_in_i <= 0;
        ofdm_in_q <= 0;

        sample_count <= 0;

        sync_long_out_count <= 0;

        signal_bits <= 0;
        legacy_sig_stb <= 0;

        ht_sig1 <= 0;
        ht_sig2 <= 0;
        crc_in_stb <= 0;
        crc_in <= 0;
        crc_count <= 0;
        crc_reset <= 0;
        ht_sig_crc_ok <= 0;
        ht_sig_stb <= 0;

        fcs_out_strobe <= 0;
        fcs_ok <= 0;
    end else if (enable) begin
        old_state <= state;

        case(state)
            S_WAIT_POWER_TRIGGER: begin
                crc_reset <= 0;
                short_gi <= 0;
                demod_is_ongoing <= 0;
                sync_long_enable <= 0;
                equalizer_enable <= 0;
                ofdm_enable <= 0;
                ofdm_reset <= 0;
                pkt_len_total <= 16'hffff;

                if (power_trigger) begin
                    `ifdef DEBUG_PRINT
                        $display("Power triggered.");
                    `endif
                    sync_short_reset <= 1;
                    state <= S_SYNC_SHORT;
                end
            end

            S_SYNC_SHORT: begin
                if (sync_short_reset) begin
                    sync_short_reset <= 0;
                end

                if (~power_trigger) begin
                    // power level drops before finding STS
                    state <= S_WAIT_POWER_TRIGGER;
                end

                if (short_preamble_detected) begin
                    `ifdef DEBUG_PRINT
                        $display("Short preamble detected");
                    `endif
                    sync_long_reset <= 1;
                    sync_long_enable <= 1;
                    sample_count <= 0;
                    state <= S_SYNC_LONG;
                end
                
            end

            S_SYNC_LONG: begin
                if (sync_long_reset) begin
                    sync_long_reset <= 0;
                end

                if (sample_in_strobe) begin
                    sample_count <= sample_count + 1;
                end
                if (sample_count > 320) begin
                    state <= S_WAIT_POWER_TRIGGER;
                end

                if (~power_trigger) begin
                    state <= S_WAIT_POWER_TRIGGER;
                end

                if (long_preamble_detected) begin
                    demod_is_ongoing <= 1;
                    pkt_rate <= {1'b0, 3'b0, 4'b1011};
                    do_descramble <= 0;
                    num_bits_to_decode <= 48;

                    ofdm_reset <= 1;
                    ofdm_enable <= 1;

                    equalizer_enable <= 1;
                    equalizer_reset <= 1;

                    byte_count <= 0;
                    byte_count_total <= 0;
                    state <= S_DECODE_SIGNAL;
                end
            end

            S_DECODE_SIGNAL: begin
                ofdm_reset <= 0;

                if (equalizer_reset) begin
                    equalizer_reset <= 0;
                end

                ofdm_in_stb <= equalizer_out_strobe;
                ofdm_in_i <= eq_out_i;
                ofdm_in_q <= eq_out_q;

                if (byte_out_strobe) begin
                    signal_bits <= {byte_out, signal_bits[23:8]};
                    byte_count <= byte_count + 1;
                    byte_count_total <= byte_count_total + 1;
                end

                if (byte_count == 3) begin
                    byte_count <= 0;
                    `ifdef DEBUG_PRINT
                        $display("[SIGNAL] rate = %04b, ", legacy_rate,
                            "length = %012b (%d), ", legacy_len, legacy_len,
                            "parity = %b, ", legacy_sig_parity,
                            "tail = %6b", legacy_sig_tail);
                    `endif

                    num_bits_to_decode <= (22+(legacy_len<<3))<<1;
                    pkt_rate <= {1'b0, 3'b0, legacy_rate};
                    pkt_len <= legacy_len;
                    pkt_len_total <= legacy_len+3;
                    
                    ofdm_reset <= 1;
                    state <= S_CHECK_SIGNAL;
                end
            end

            S_CHECK_SIGNAL: begin
                if (~legacy_sig_parity_ok) begin
                    pkt_header_valid_strobe <= 1;
                    status_code <= E_PARITY_FAIL;
                    state <= S_SIGNAL_ERROR;
                end else if (legacy_sig_rsvd) begin
                    pkt_header_valid_strobe <= 1;
                    status_code <= E_WRONG_RSVD;
                    state <= S_SIGNAL_ERROR;
                end else if (|legacy_sig_tail) begin
                    pkt_header_valid_strobe <= 1;
                    status_code <= E_WRONG_TAIL;
                    state <= S_SIGNAL_ERROR;
                end else if (legacy_rate[3]==0) begin
                    pkt_header_valid_strobe <= 1;
                    status_code <= E_UNSUPPORTED_RATE;
                    state <= S_SIGNAL_ERROR;
                end else begin
                    legacy_sig_stb <= 1;
                    status_code <= E_OK;
                    if (legacy_rate == 4'b1011) begin
                        abs_eq_i <= 0;
                        abs_eq_q <= 0;
                        rot_eq_count <= 0;
                        normal_eq_count <= 0;
                        state <= S_DETECT_HT;
                    end else begin
                        //num_bits_to_decode <= (legacy_len+3)<<4;
                        do_descramble <= 1;
                        ofdm_reset <= 1;
                        pkt_header_valid <= 1;
                        pkt_header_valid_strobe <= 1;
                        pkt_begin <= 1;
                        pkt_ht <= 0;
                        state <= S_DECODE_DATA;
                    end
                end
            end

            S_SIGNAL_ERROR: begin
                pkt_header_valid_strobe <= 0;
                byte_count <= 0;
                byte_count_total <= 0;
                state <= S_WAIT_POWER_TRIGGER;
            end

            S_DETECT_HT: begin
                legacy_sig_stb <= 0;
                ofdm_reset <= 1;

                if (equalizer_out_strobe) begin
                    abs_eq_i <= eq_out_i[15]? ~eq_out_i+1: eq_out_i;
                    abs_eq_q <= eq_out_q[15]? ~eq_out_q+1: eq_out_q;
                    if (abs_eq_q > abs_eq_i) begin
                        rot_eq_count <= rot_eq_count + 1;
                    end else begin
                        normal_eq_count <= normal_eq_count + 1;
                    end
                end

                if (rot_eq_count >= 4) begin
                    // HT-SIG detected
                    num_bits_to_decode <= 96;
                    do_descramble <= 0;
                    state <= S_HT_SIGNAL;
                end else if (normal_eq_count > 4) begin
                    //num_bits_to_decode <= (legacy_len+3)<<4;
                    do_descramble <= 1;
                    pkt_header_valid <= 1;
                    pkt_header_valid_strobe <= 1;
                    pkt_begin <= 1;
                    pkt_ht <= 0;
                    state <= S_DECODE_DATA;
                end
            end

            S_HT_SIGNAL: begin
                ofdm_reset <= 0;

                ofdm_in_stb <= eq_out_stb_delayed;
                // rotate clockwise by 90 degree
                ofdm_in_i <= eq_out_q_delayed;
                ofdm_in_q <= ~eq_out_i_delayed+1;

                if (byte_out_strobe) begin
                    if (byte_count < 3) begin
                        ht_sig1 <= {byte_out, ht_sig1[23:8]};
                    end else begin
                        ht_sig2 <= {byte_out, ht_sig2[23:8]};
                    end
                    byte_count <= byte_count + 1;
                    byte_count_total <= byte_count_total + 1;
                end

                if (byte_count == 6) begin
                    byte_count <= 0;
                    `ifdef DEBUG_PRINT
                        $display("[HT SIGNAL] mcs = %07b (%d), ", ht_mcs, ht_mcs,
                            "CBW: %d, ", ht_cbw? 40: 20,
                            "length = %012b (%d), ", ht_len, ht_len,
                            "rsvd = %d, ", ht_rsvd,
                            "aggr = %d, ", ht_aggregation,
                            "stbd = %02b, ", ht_stbc,
                            "fec = %d, ", ht_fec_coding,
                            "sgi = %d, ", ht_sgi,
                            "num_ext = %d, ", ht_num_ext,
                            "crc = %08b, ", crc,
                            "tail = %06b", ht_sig_tail);
                    `endif

                    num_bits_to_decode <= (22+(ht_len<<3))<<1;
                    pkt_rate <= {1'b1, ht_mcs};
                    pkt_len <= ht_len;
                    pkt_len_total <= ht_len+3+6; //(6 bytes for 3 byte HT-SIG1 and 3 byte HT-SIG2)

                    crc_count <= 0;
                    crc_reset <= 1;
                    crc_in_stb <= 0;
                    ht_sig_crc_ok <= 0;
                    state <= S_CHECK_HT_SIG_CRC;
                end
            end

            S_CHECK_HT_SIG_CRC: begin
                ofdm_reset <= 1;
                crc_reset <= 0;
                crc_count <= crc_count + 1;

                if (crc_count < 24) begin
                    crc_in_stb <= 1;
                    crc_in <= ht_sig1[crc_count];
                end else if (crc_count < 34) begin
                    crc_in_stb <= 1;
                    crc_in <= ht_sig2[crc_count-24];
                end else if (crc_count == 34) begin
                    crc_in_stb <= 0;
                end else if (crc_count == 35) begin
                    ht_sig_stb <= 1;
                    pkt_ht <= 1;
                    if (crc_out ^ crc) begin
                        pkt_header_valid_strobe <= 1;
                        status_code <= E_WRONG_CRC;
                        state <= S_HT_SIG_ERROR;
                    end else begin
                        `ifdef DEBUG_PRINT
                            $display("[HT SIGNAL] CRC OK");
                        `endif
                        ht_sig_crc_ok <= 1;
                        state <= S_CHECK_HT_SIG;
                    end
                end
            end

            S_CHECK_HT_SIG: begin
                ofdm_reset <= 1;
                ht_sig_stb <= 0;

                pkt_header_valid <= 1;
                pkt_header_valid_strobe <= 1;
                if (ht_mcs > 7) begin
                    ht_unsupport <= 1;
                    status_code <= E_UNSUPPORTED_MCS;
                    state <= S_HT_SIG_ERROR;
                end else if (ht_cbw) begin
                    ht_unsupport <= 1;
                    status_code <= E_UNSUPPORTED_CBW;
                    state <= S_HT_SIG_ERROR;
                end else if (ht_rsvd == 0) begin
                    ht_unsupport <= 1;
                    status_code <= E_HT_WRONG_RSVD;
                    state <= S_HT_SIG_ERROR;
                end else if (ht_stbc != 0) begin
                    ht_unsupport <= 1;
                    status_code <= E_UNSUPPORTED_STBC;
                    state <= S_HT_SIG_ERROR;
                end else if (ht_fec_coding) begin
                    ht_unsupport <= 1;
                    status_code <= E_UNSUPPORTED_FEC;
                    state <= S_HT_SIG_ERROR;
                // end else if (ht_sgi) begin // seems like it supports ht short_gi, we should proceed
                //     ht_unsupport <= 1;
                //     status_code <= E_UNSUPPORTED_SGI;
                //     state <= S_HT_SIG_ERROR;
                end else if (ht_num_ext != 0) begin
                    ht_unsupport <= 1;
                    status_code <= E_UNSUPPORTED_SPATIAL;
                    state <= S_HT_SIG_ERROR;
                end else if (ht_sig_tail != 0) begin
                    ht_unsupport <= 1;
                    status_code <= E_HT_WRONG_TAIL;
                    state <= S_HT_SIG_ERROR;
                end else begin
                    sync_long_out_count <= 0;
                    state <= S_HT_STS;
                end
            end

            S_HT_SIG_ERROR: begin
                ht_unsupport <= 0;
                pkt_header_valid <= 0;
                pkt_header_valid_strobe <= 0;
                byte_count <= 0;
                byte_count_total <= 0;
                ht_sig_stb <= 0;
                state <= S_WAIT_POWER_TRIGGER;
            end

            S_HT_STS: begin
                pkt_header_valid <= 0;
                pkt_header_valid_strobe <= 0;
                if (sync_long_out_strobe) begin
                    sync_long_out_count <= sync_long_out_count + 1;
                end
                if (sync_long_out_count == 64) begin
                    sync_long_out_count <= 0;
                    ht_next <= 1;
                    state <= S_HT_LTS;
                end
            end

            S_HT_LTS: begin
                short_gi <= ht_sgi;
                if (sync_long_out_strobe) begin
                    sync_long_out_count <= sync_long_out_count + 1;
                end
                if (sync_long_out_count == 64) begin
                    ht_next <= 0;
                    //num_bits_to_decode <= (ht_len+3)<<4;
                    do_descramble <= 1;
                    ofdm_reset <= 1;
                    pkt_begin <= 1;
                    state <= S_DECODE_DATA;
                end
            end

            S_DECODE_DATA: begin
                pkt_begin <= 0;
                legacy_sig_stb <= 0;

                pkt_header_valid <= 0;
                pkt_header_valid_strobe <= 0;

                ofdm_reset <= 0;

                ofdm_in_stb <= eq_out_stb_delayed;
                ofdm_in_i <= eq_out_i_delayed;
                ofdm_in_q <= eq_out_q_delayed;

                if (byte_out_strobe) begin
                    `ifdef DEBUG_PRINT
                        $display("[BYTE] [%4d / %-4d] %02x", byte_count+1, pkt_len,
                            byte_out);
                    `endif
                    byte_count <= byte_count + 1;
                    byte_count_total <= byte_count_total + 1;
                end

                if (byte_count >= pkt_len) begin
                    fcs_out_strobe <= 1;
                    byte_count <= 0;
                    byte_count_total <= 0;
                    if (pkt_fcs == EXPECTED_FCS) begin
                        fcs_ok <= 1;
                        status_code <= E_OK;
                    end else begin
                        fcs_ok <= 0;
                        status_code <= E_WRONG_FCS;
                    end
                    state <= S_DECODE_DONE;
                end
            end

            S_DECODE_DONE: begin
                `ifdef DEBUG_PRINT
                    $display("===== PACKET DECODE DONE =====");
                    if (status_code == E_OK) begin
                        $display("FCS CORRECT");
                    end else begin
                        $display("FCS WRONG");
                    end
                `endif
                fcs_out_strobe <= 0;
                fcs_ok <= 0;
                state <= S_WAIT_POWER_TRIGGER;
            end

            default: begin
                byte_count <= 0;
                byte_count_total <= 0;
                state <= S_WAIT_POWER_TRIGGER;
            end
        endcase
    end
end

endmodule
