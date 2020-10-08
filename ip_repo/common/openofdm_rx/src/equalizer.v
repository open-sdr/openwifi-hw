`include "common_defs.v"

module equalizer
(
    input clock,
    input enable,
    input reset,

    input [31:0] sample_in,
    input sample_in_strobe,
    input ht_next,
    input pkt_ht,

    output [31:0] phase_in_i,
    output [31:0] phase_in_q,
    output reg phase_in_stb,
    input [31:0] phase_out,
    input phase_out_stb,

    output [`ROTATE_LUT_LEN_SHIFT-1:0] rot_addr,
    input [31:0] rot_data,

    output reg [31:0] sample_out,
    output reg sample_out_strobe,
    
    output reg [2:0] state,

    // for side channel
    output wire [31:0] csi,
    output wire csi_valid
);


// mask[0] is DC, mask[1:26] -> 1,..., 26
// mask[38:63] -> -26,..., -1
localparam SUBCARRIER_MASK =
    64'b1111111111111111111111111100000000000111111111111111111111111110;

localparam HT_SUBCARRIER_MASK =
    64'b1111111111111111111111111111000000011111111111111111111111111110;

// -7, -21, 21, 7
localparam PILOT_MASK =
    64'b0000001000000000000010000000000000000000001000000000000010000000;

localparam DATA_SUBCARRIER_MASK =
    SUBCARRIER_MASK ^ PILOT_MASK;

localparam HT_DATA_SUBCARRIER_MASK = 
    HT_SUBCARRIER_MASK ^ PILOT_MASK;


// -1,..,-26, 26,..,1
localparam LTS_REF =
    64'b0000101001100000010100110000000000000000010101100111110101001100;

localparam HT_LTS_REF =
    64'b0000101001100000010100110000000000011000010101100111110101001100;


localparam POLARITY = 
    127'b1111111000111011000101001011111010101000010110111100111001010110011000001101101011101000110010001000000100100110100111101110000;

// 21, 7, -7, -21
localparam HT_POLARITY = 4'b1000;


localparam IN_BUF_LEN_SHIFT = 6;

reg ht;
reg [5:0] num_data_carrier;
reg [7:0] num_ofdm_sym;

// bit masks
reg [63:0] lts_ref;
reg [63:0] ht_lts_ref;
reg [63:0] subcarrier_mask;
reg [63:0] data_subcarrier_mask;
reg [63:0] pilot_mask;

reg [126:0] polarity;
reg [3:0] ht_polarity;
reg [3:0] current_polarity;
reg [3:0] pilot_count;

reg signed [15:0] input_i;
reg signed [15:0] input_q;

reg current_sign;

wire signed [15:0] new_lts_i;
wire signed [15:0] new_lts_q;
wire new_lts_stb;

reg calc_mean_strobe;

reg [5:0] lts_waddr;
reg [6:0] lts_raddr; // one bit wider to detect overflow
reg [15:0] lts_i_in;
reg [15:0] lts_q_in;
reg lts_in_stb;
wire signed [15:0] lts_i_out;
wire signed [15:0] lts_q_out;
wire signed [15:0] lts_q_out_neg = ~lts_q_out + 1;

reg [5:0] in_waddr;
reg [6:0] in_raddr;
wire [15:0] buf_i_out;
wire [15:0] buf_q_out;

reg pilot_in_stb;
wire signed [31:0] pilot_i;
wire signed [31:0] pilot_q;

reg signed [31:0] pilot_sum_i;
reg signed [31:0] pilot_sum_q;

assign phase_in_i = pilot_sum_i;
assign phase_in_q = pilot_sum_q;

reg signed [31:0] pilot_phase;

reg rot_in_stb;
wire signed [15:0] rot_i;
wire signed [15:0] rot_q;

wire [31:0] mag_sq;
wire [31:0] prod_i;
wire [31:0] prod_q;
wire [31:0] prod_i_scaled = prod_i<<(`CONS_SCALE_SHIFT+1);
wire [31:0] prod_q_scaled = prod_q<<(`CONS_SCALE_SHIFT+1); // +1 to fix the bug threshold for demodulate.v
wire prod_stb;

reg signed [15:0] lts_reg1_i, lts_reg2_i, lts_reg3_i, lts_reg4_i, lts_reg5_i;
reg signed [15:0] lts_reg1_q, lts_reg2_q, lts_reg3_q, lts_reg4_q, lts_reg5_q;
wire signed [18:0] lts_sum_1_3_i = lts_reg1_i + lts_reg2_i + lts_reg3_i;
wire signed [18:0] lts_sum_1_3_q = lts_reg1_q + lts_reg2_q + lts_reg3_q;
wire signed [18:0] lts_sum_1_4_i = lts_reg1_i + lts_reg2_i + lts_reg3_i + lts_reg4_i;
wire signed [18:0] lts_sum_1_4_q = lts_reg1_q + lts_reg2_q + lts_reg3_q + lts_reg4_q;
wire signed [18:0] lts_sum_1_5_i = lts_reg1_i + lts_reg2_i + lts_reg3_i + lts_reg4_i + lts_reg5_i;
wire signed [18:0] lts_sum_1_5_q = lts_reg1_q + lts_reg2_q + lts_reg3_q + lts_reg4_q + lts_reg5_q;
wire signed [18:0] lts_sum_2_5_i =              lts_reg2_i + lts_reg3_i + lts_reg4_i + lts_reg5_i;
wire signed [18:0] lts_sum_2_5_q =              lts_reg2_q + lts_reg3_q + lts_reg4_q + lts_reg5_q;
wire signed [18:0] lts_sum_3_5_i =                           lts_reg3_i + lts_reg4_i + lts_reg5_i;
wire signed [18:0] lts_sum_3_5_q =                           lts_reg3_q + lts_reg4_q + lts_reg5_q;
wire signed [18:0] lts_sum_wo3_i = lts_reg1_i + lts_reg2_i              + lts_reg4_i + lts_reg5_i;
wire signed [18:0] lts_sum_wo3_q = lts_reg1_q + lts_reg2_q              + lts_reg4_q + lts_reg5_q;
reg signed [18:0] lts_sum_i;
reg signed [18:0] lts_sum_q;

reg [2:0] lts_mv_avg_len;
reg lts_div_in_stb;

wire [31:0] dividend_i = (state == S_UPDATE_DC_LTS || state == S_MV_AVG_LTS) ? (lts_sum_i[18] == 0 ? {13'h0,lts_sum_i} : {13'h1FFF,lts_sum_i})  : (state == S_ADJUST_FREQ_OFFSET ? prod_i_scaled : 0);
wire [31:0] dividend_q = (state == S_UPDATE_DC_LTS || state == S_MV_AVG_LTS) ? (lts_sum_q[18] == 0 ? {13'h0,lts_sum_q} : {13'h1FFF,lts_sum_q})	  : (state == S_ADJUST_FREQ_OFFSET ? prod_q_scaled : 0);
wire [23:0] divisor_i = (state == S_UPDATE_DC_LTS || state == S_MV_AVG_LTS) ? {21'b0,lts_mv_avg_len} : (state == S_ADJUST_FREQ_OFFSET ? mag_sq[23:0] : 1);
wire [23:0] divisor_q = (state == S_UPDATE_DC_LTS || state == S_MV_AVG_LTS) ? {21'b0,lts_mv_avg_len} : (state == S_ADJUST_FREQ_OFFSET ? mag_sq[23:0] : 1);
wire div_in_stb = (state == S_UPDATE_DC_LTS || state == S_MV_AVG_LTS) ? lts_div_in_stb : (state == S_ADJUST_FREQ_OFFSET ? prod_out_strobe : 0);


reg [15:0] num_output;
wire [31:0] quotient_i;
wire [31:0] quotient_q;
wire [31:0] norm_i = quotient_i;
wire [31:0] norm_q = quotient_q;
wire [31:0] lts_div_i = quotient_i;
wire [31:0] lts_div_q = quotient_q;

wire div_out_stb;
wire norm_out_stb = div_out_stb;
wire lts_div_out_stb = div_out_stb;

reg prod_in_strobe;
wire prod_out_strobe;

// for side channel
reg sample_in_strobe_dly;
assign csi = {lts_i_out, lts_q_out};
assign csi_valid = ( (num_ofdm_sym == 1 || (pkt_ht==1 && num_ofdm_sym==5)) && state == S_CALC_FREQ_OFFSET && sample_in_strobe_dly == 1 && enable && (~reset) );

/*
// =============save signal to file for matlab bit-true comparison===========
integer file_open_trigger = 0;
integer new_lts_fd, phase_offset_pilot_input_fd, phase_offset_lts_input_fd, phase_offset_pilot_fd, phase_offset_pilot_sum_fd, phase_offset_phase_out_fd, rot_out_fd, equalizer_prod_fd, equalizer_prod_scaled_fd, equalizer_mag_sq_fd, equalizer_out_fd;

wire signed [15:0] norm_i_signed, norm_q_signed;
assign norm_i_signed = sample_out[31:16];
assign norm_q_signed = sample_out[15:0];

wire signed [31:0] prod_i_signed, prod_q_signed, prod_i_scaled_signed, prod_q_scaled_signed, phase_out_signed;
assign prod_i_signed = prod_i;
assign prod_q_signed = prod_q;
assign prod_i_scaled_signed = prod_i_scaled;
assign prod_q_scaled_signed = prod_q_scaled;
assign phase_out_signed = phase_out;

always @(posedge clock) begin
    file_open_trigger = file_open_trigger + 1;
    if (file_open_trigger==1) begin
        new_lts_fd = $fopen("./new_lts.txt", "w");
        phase_offset_pilot_input_fd = $fopen("./phase_offset_pilot_input.txt", "w");
        phase_offset_lts_input_fd = $fopen("./phase_offset_lts_input.txt", "w");
        phase_offset_pilot_fd = $fopen("./phase_offset_pilot.txt", "w");
        phase_offset_pilot_sum_fd = $fopen("./phase_offset_pilot_sum.txt", "w");
        phase_offset_phase_out_fd = $fopen("./phase_offset_phase_out.txt", "w");
        rot_out_fd = $fopen("./rot_out.txt", "w");
        equalizer_prod_fd = $fopen("./equalizer_prod.txt", "w");
        equalizer_prod_scaled_fd = $fopen("./equalizer_prod_scaled.txt", "w");
        equalizer_mag_sq_fd = $fopen("./equalizer_mag_sq.txt", "w");
        equalizer_out_fd = $fopen("./equalizer_out.txt", "w");
    end

    if (num_ofdm_sym == 1 && state == S_CALC_FREQ_OFFSET && sample_in_strobe_dly == 1 && enable && (~reset) ) begin
        $fwrite(new_lts_fd, "%d %d\n", lts_i_out, lts_q_out);
        $fflush(new_lts_fd);
    end

    if (pilot_in_stb && enable && (~reset) ) begin
        $fwrite(phase_offset_pilot_input_fd, "%d %d\n", input_i, input_q);
        $fflush(phase_offset_pilot_input_fd);
        $fwrite(phase_offset_lts_input_fd, "%d %d\n", lts_i_out, lts_q_out);
        $fflush(phase_offset_lts_input_fd);
    end

    if (pilot_out_stb && enable && (~reset) ) begin
        $fwrite(phase_offset_pilot_fd, "%d %d\n", pilot_i, pilot_q);
        $fflush(phase_offset_pilot_fd);
    end

    if (phase_in_stb && enable && (~reset) ) begin
        $fwrite(phase_offset_pilot_sum_fd, "%d %d\n", pilot_sum_i, pilot_sum_q);
        $fflush(phase_offset_pilot_sum_fd);
    end

    if (phase_out_stb && enable && (~reset) ) begin
        $fwrite(phase_offset_phase_out_fd, "%d\n", phase_out_signed);
        $fflush(phase_offset_phase_out_fd);
    end

    if (rot_out_stb && enable && (~reset) ) begin
        $fwrite(rot_out_fd, "%d %d\n", rot_i, rot_q);
        $fflush(rot_out_fd);
    end
    
    if (prod_out_strobe && enable && (~reset) ) begin
        $fwrite(equalizer_prod_fd, "%d %d\n", prod_i_signed, prod_q_signed);
        $fflush(equalizer_prod_fd);
        $fwrite(equalizer_prod_scaled_fd, "%d %d\n", prod_i_scaled_signed, prod_q_scaled_signed);
        $fflush(equalizer_prod_scaled_fd);
        $fwrite(equalizer_mag_sq_fd, "%d\n", mag_sq);
        $fflush(equalizer_mag_sq_fd);
    end

    if (sample_out_strobe && enable && (~reset) ) begin
        $fwrite(equalizer_out_fd, "%d %d\n", norm_i_signed, norm_q_signed);
        $fflush(equalizer_out_fd);
    end
end
// ==========end of save signal to file for matlab bit-true comparison===========
*/

ram_2port #(.DWIDTH(32), .AWIDTH(6)) lts_inst (
    .clka(clock),
    .ena(1),
    .wea(lts_in_stb),
    .addra(lts_waddr),
    .dia({lts_i_in, lts_q_in}),
    .doa(),
    .clkb(clock),
    .enb(1),
    .web(1'b0),
    .addrb(lts_raddr[5:0]),
    .dib(32'hFFFF),
    .dob({lts_i_out, lts_q_out})
);

calc_mean lts_i_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    
    .a(lts_i_out),
    .b(input_i),
    .sign(current_sign),
    .input_strobe(calc_mean_strobe),

    .c(new_lts_i),
    .output_strobe(new_lts_stb)
);

calc_mean lts_q_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    
    .a(lts_q_out),
    .b(input_q),
    .sign(current_sign),
    .input_strobe(calc_mean_strobe),

    .c(new_lts_q)
);

ram_2port  #(.DWIDTH(32), .AWIDTH(6)) in_buf_inst (
    .clka(clock),
    .ena(1),
    .wea(sample_in_strobe),
    .addra(in_waddr),
    .dia(sample_in),
    .doa(),
    .clkb(clock),
    .enb(1),
    .web(1'b0),
    .addrb(in_raddr[5:0]),
    .dib(32'hFFFF),
    .dob({buf_i_out, buf_q_out})
);

complex_mult pilot_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    .a_i(input_i),
    .a_q(input_q),
    .b_i(lts_i_out),
    .b_q(lts_q_out),
    .input_strobe(pilot_in_stb),
    .p_i(pilot_i),
    .p_q(pilot_q),
    .output_strobe(pilot_out_stb)
);

rotate rotate_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .in_i(buf_i_out),
    .in_q(buf_q_out),
    .phase(pilot_phase),
    .input_strobe(rot_in_stb),

    .rot_addr(rot_addr),
    .rot_data(rot_data),
    
    .out_i(rot_i),
    .out_q(rot_q),
    .output_strobe(rot_out_stb)
);

complex_mult input_lts_prod_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    .a_i(rot_i),
    .a_q(rot_q),
    .b_i(lts_i_out),
    .b_q(lts_q_out_neg),
    .input_strobe(rot_out_stb),
    .p_i(prod_i),
    .p_q(prod_q),
    .output_strobe(prod_out_strobe)
);

complex_mult lts_lts_prod_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    .a_i(lts_i_out),
    .a_q(lts_q_out),
    .b_i(lts_i_out),
    .b_q(lts_q_out_neg),
    .input_strobe(rot_out_stb),
    .p_i(mag_sq)
);

divider norm_i_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .dividend(dividend_i),
    .divisor(divisor_i),
    .input_strobe(div_in_stb),

    .quotient(quotient_i),
    .output_strobe(div_out_stb)
);

divider norm_q_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .dividend(dividend_q),
    .divisor(divisor_q),
    .input_strobe(div_in_stb),

    .quotient(quotient_q)
);

localparam S_FIRST_LTS = 0;
localparam S_SECOND_LTS = 1;
localparam S_UPDATE_DC_LTS = 2;
localparam S_MV_AVG_LTS = 3;
localparam S_GET_POLARITY = 4;
localparam S_CALC_FREQ_OFFSET = 5;
localparam S_ADJUST_FREQ_OFFSET = 6;
localparam S_HT_LTS = 7;

always @(posedge clock) begin
    if (reset) begin
        sample_out_strobe <= 0;
        lts_raddr <= 0;
        lts_waddr <= 0;
        sample_out <= 0;

        lts_in_stb <= 0;
        lts_i_in <= 0;
        lts_q_in <= 0;

        ht <= 0;
        num_data_carrier <= 48;
        num_ofdm_sym <= 0;

        subcarrier_mask <= SUBCARRIER_MASK;
        data_subcarrier_mask <= DATA_SUBCARRIER_MASK;
        pilot_mask <= PILOT_MASK;
        lts_ref <= LTS_REF;
        ht_lts_ref <= HT_LTS_REF;
        polarity <= POLARITY;

        ht_polarity <= HT_POLARITY;

        current_polarity <= 0;
        pilot_count <= 0;

        in_waddr <= 0;
        in_raddr <= 0;

        lts_reg1_i <= 0; lts_reg2_i <= 0; lts_reg3_i <= 0; lts_reg4_i <= 0; lts_reg5_i <= 0;
        lts_reg1_q <= 0; lts_reg2_q <= 0; lts_reg3_q <= 0; lts_reg4_q <= 0; lts_reg5_q <= 0;
        lts_sum_i <= 0;
        lts_sum_q <= 0;
        lts_div_in_stb <= 0;

        phase_in_stb <= 0;
        pilot_sum_i <= 0;
        pilot_sum_q <= 0;
        pilot_phase <= 0;
        pilot_in_stb <= 0;

        prod_in_strobe <= 0;

        rot_in_stb <= 0;

        current_sign <= 0;
        input_i <= 0;
        input_q <= 0;
        calc_mean_strobe <= 0;

        num_output <= 0;

        state <= S_FIRST_LTS;
    end else if (enable) begin
        sample_in_strobe_dly <= sample_in_strobe;
        case(state)
            S_FIRST_LTS: begin
                // store first LTS as is
                lts_in_stb <= sample_in_strobe;
                {lts_i_in, lts_q_in} <= sample_in;

                if (lts_in_stb) begin
                    if (lts_waddr == 63) begin
                        lts_waddr <= 0;
                        lts_raddr <= 0;
                        state <= S_SECOND_LTS;
                    end else begin
                        lts_waddr <= lts_waddr + 1;
                    end
                end
            end

            S_SECOND_LTS: begin
                // calculate and store the mean of the two LTS
                if (sample_in_strobe) begin
                    calc_mean_strobe <= sample_in_strobe;
                    {input_i, input_q} <= sample_in;
                    current_sign <= lts_ref[0];
                    lts_ref <= {lts_ref[0], lts_ref[63:1]};
                    lts_raddr <= lts_raddr + 1;
                end else begin
                    calc_mean_strobe <= 0;
                end

                lts_in_stb <= new_lts_stb;
                {lts_i_in, lts_q_in} <= {new_lts_i, new_lts_q};

                if (lts_in_stb) begin
                    if (lts_waddr == 63) begin
                        lts_waddr <= 0;
                        lts_raddr <= 62;
                        lts_in_stb <= 0;
                        lts_div_in_stb <= 0;
                        state <= S_UPDATE_DC_LTS;
                    end else begin
                        lts_waddr <= lts_waddr + 1;
                    end
                end
            end 

            S_UPDATE_DC_LTS: begin
                if(lts_div_in_stb == 1) begin
                    lts_div_in_stb <= 0;
                end else if(lts_raddr == 4) begin
                    lts_sum_i <= lts_sum_wo3_i;
                    lts_sum_q <= lts_sum_wo3_q;
                    lts_mv_avg_len <= 4;
                    lts_div_in_stb <= 1;
                    lts_raddr <= 5;
                end else if(lts_raddr != 5) begin
                    // LTS Shift register
                    lts_reg1_i <= lts_i_out; lts_reg2_i <= lts_reg1_i; lts_reg3_i <= lts_reg2_i; lts_reg4_i <= lts_reg3_i; lts_reg5_i <= lts_reg4_i;
                    lts_reg1_q <= lts_q_out; lts_reg2_q <= lts_reg1_q; lts_reg3_q <= lts_reg2_q; lts_reg4_q <= lts_reg3_q; lts_reg5_q <= lts_reg4_q;
                    lts_raddr[5:0] <= lts_raddr[5:0] + 1;
                end else begin
                    if(lts_in_stb == 1) begin
                        lts_waddr <= 37;
                        lts_raddr <= 38;
                        lts_in_stb <= 0;
                        state <= S_MV_AVG_LTS;
                    end else if(lts_div_out_stb == 1) begin
                        lts_i_in <= lts_div_i[15:0];
                        lts_q_in <= lts_div_q[15:0];
                        lts_in_stb <= 1;
                    end
                end

            end

            S_MV_AVG_LTS: begin
                if(lts_raddr == 42) begin
                    lts_sum_i <= lts_sum_1_3_i;
                    lts_sum_q <= lts_sum_1_3_q;
                    lts_mv_avg_len <= 3;
                    lts_div_in_stb <= 1;
                end else if(lts_raddr == 43) begin
                    lts_sum_i <= lts_sum_1_4_i;
                    lts_sum_q <= lts_sum_1_4_q;
                    lts_mv_avg_len <= 4;
                    lts_div_in_stb <= 1;
                end else if(lts_raddr > 43 || lts_raddr < 29) begin
                    lts_sum_i <= lts_sum_1_5_i;
                    lts_sum_q <= lts_sum_1_5_q;
                    lts_mv_avg_len <= 5;
                    lts_div_in_stb <= 1;
                end else if(lts_raddr == 29) begin
                    lts_sum_i <= lts_sum_2_5_i;
                    lts_sum_q <= lts_sum_2_5_q;
                    lts_mv_avg_len <= 4;
                    lts_div_in_stb <= 1;
                end else if(lts_raddr == 30) begin
                    lts_sum_i <= lts_sum_3_5_i;
                    lts_sum_q <= lts_sum_3_5_q;
                    lts_mv_avg_len <= 3;
                    lts_div_in_stb <= 1;
                end else if(lts_raddr == 31) begin
                    lts_div_in_stb <= 0;
                end

                if(lts_raddr >= 38 || lts_raddr <= 30) begin
                    // LTS Shift register
                    lts_reg1_i <= lts_i_out; lts_reg2_i <= lts_reg1_i; lts_reg3_i <= lts_reg2_i; lts_reg4_i <= lts_reg3_i; lts_reg5_i <= lts_reg4_i;
                    lts_reg1_q <= lts_q_out; lts_reg2_q <= lts_reg1_q; lts_reg3_q <= lts_reg2_q; lts_reg4_q <= lts_reg3_q; lts_reg5_q <= lts_reg4_q;
                    lts_raddr[5:0] <= lts_raddr[5:0] + 1;
                end

                if(lts_div_out_stb == 1) begin
                    lts_i_in <= lts_div_i[15:0];
                    lts_q_in <= lts_div_q[15:0];
                    lts_waddr[5:0] <= lts_waddr[5:0] + 1;
                end
                lts_in_stb <= lts_div_out_stb;

                if(lts_waddr == 26) begin
                    state <= S_GET_POLARITY;
                end
            end

            S_GET_POLARITY: begin
                // obtain the polarity of pilot sub-carriers for next OFDM symbol
                if (ht) begin
                    current_polarity <= {
                        ht_polarity[1]^polarity[0], // -7
                        ht_polarity[0]^polarity[0], // -21
                        ht_polarity[3]^polarity[0], // 21
                        ht_polarity[2]^polarity[0]  // 7
                        };
                    ht_polarity <= {ht_polarity[0], ht_polarity[3:1]};
                end else begin
                    current_polarity <= {
                        polarity[0],    // -7
                        polarity[0],    // -21
                        ~polarity[0],   // 21
                        polarity[0]     // 7
                        };
                end
                polarity <= {polarity[0], polarity[126:1]};

                pilot_sum_i <= 0;
                pilot_sum_q <= 0;
                pilot_count <= 0;
                in_waddr <= 0;
                in_raddr <= 0;
                input_i <= 0;
                input_q <= 0;
                lts_raddr <= 0;
                num_ofdm_sym <= num_ofdm_sym + 1;
                state <= S_CALC_FREQ_OFFSET;
            end

            S_CALC_FREQ_OFFSET: begin
                if (~ht & ht_next) begin
                    ht <= 1;
                    num_data_carrier <= 52;
                    lts_waddr <= 0;
                    lts_ref <= HT_LTS_REF;
                    subcarrier_mask <= HT_SUBCARRIER_MASK;
                    data_subcarrier_mask <= HT_DATA_SUBCARRIER_MASK;
                    pilot_mask <= PILOT_MASK;
                    // reverse this extra shift
                    polarity <= {polarity[125:0], polarity[126]};
                    state <= S_HT_LTS;
                end

                // calculate residue freq offset using pilot sub carriers
                if (sample_in_strobe) begin
                    in_waddr <= in_waddr + 1;
                    lts_raddr <= lts_raddr + 1;

                    pilot_mask <= {pilot_mask[0], pilot_mask[63:1]};
                    if (pilot_mask[0]) begin
                        pilot_count <= pilot_count + 1;
                        current_polarity <= {current_polarity[0],
                            current_polarity[3:1]};
                        // obtain the conjugate of current pilot sub carrier
                        if (current_polarity[0] == 0) begin
                            input_i <= sample_in[31:16];
                            input_q <= ~sample_in[15:0] + 1;
                        end else begin
                            input_i <= ~sample_in[31:16] + 1;
                            input_q <= sample_in[15:0];
                        end
                        pilot_in_stb <= 1;
                    end else begin
                        pilot_in_stb <= 0;
                    end
                end else begin
                    pilot_in_stb <= 0;
                end

                if (pilot_out_stb) begin
                    pilot_sum_i <= pilot_sum_i + pilot_i;
                    pilot_sum_q <= pilot_sum_q + pilot_q;
                    if (pilot_count == 4) begin
                        phase_in_stb <= 1;
                    end else begin
                        phase_in_stb <= 0;
                    end
                end else begin
                    phase_in_stb <= 0;
                end

                if (phase_out_stb) begin
                    `ifdef DEBUG_PRINT
                        $display("[PILOT OFFSET] %d", phase_out);
                    `endif
                    pilot_phase <= phase_out;
                    in_raddr <= 0;
                    // compensate for RAM read delay
                    lts_raddr <= 1;
                    rot_in_stb <= 0;
                    num_output <= 0;
                    state <= S_ADJUST_FREQ_OFFSET;
                end
            end

            S_ADJUST_FREQ_OFFSET: begin
                // first rotate, then normalize by avg LTS
                if (in_raddr < 64) begin
                    in_raddr <= in_raddr + 1;
                    rot_in_stb <= 1;
                end else begin
                    rot_in_stb <= 0;
                end

                if (rot_out_stb) begin
                    lts_raddr <= lts_raddr + 1;
                end

                if (norm_out_stb) begin
                    data_subcarrier_mask <= {data_subcarrier_mask[0],
                        data_subcarrier_mask[63:1]};
                    if (data_subcarrier_mask[0]) begin
                        sample_out_strobe <= 1;
                        sample_out <= {norm_i[31], norm_i[14:0],
                            norm_q[31], norm_q[14:0]};
                        num_output <= num_output + 1;
                    end else begin
                        sample_out_strobe <= 0;
                    end
                end else begin
                    sample_out_strobe <= 0;
                end

                if (num_output == num_data_carrier) begin
                    state <= S_GET_POLARITY;
                end
            end

            S_HT_LTS: begin
                if (sample_in_strobe) begin
                    lts_in_stb <= 1;
                    ht_lts_ref <= {ht_lts_ref[0], ht_lts_ref[63:1]};
                    if (ht_lts_ref[0] == 0) begin
                        {lts_i_in, lts_q_in} <= sample_in;
                    end else begin
                        lts_i_in <= ~sample_in[31:16]+1;
                        lts_q_in <= ~sample_in[15:0]+1;
                    end
                end else begin
                    lts_in_stb <= 0;
                end

                if (lts_in_stb) begin
                    if (lts_waddr == 63) begin
                        lts_waddr <= 0;
                        lts_raddr <= 62;
                        lts_in_stb <= 0;
                        lts_div_in_stb <= 0;
                        state <= S_UPDATE_DC_LTS;
                    end else begin
                        lts_waddr <= lts_waddr + 1;
                    end
                end

            end

            default: begin
                state <= S_FIRST_LTS;
            end
        endcase
    end else begin
        sample_out_strobe <= 0;
    end
end

endmodule
