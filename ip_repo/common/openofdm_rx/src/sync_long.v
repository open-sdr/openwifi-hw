module sync_long (
    input clock,
    input reset,
    input enable,

    input [31:0] sample_in,
    input sample_in_strobe,
    input signed [31:0] phase_offset,
    input short_gi,

    output [`ROTATE_LUT_LEN_SHIFT-1:0] rot_addr,
    input [31:0] rot_data,

    output [31:0] metric,
    output metric_stb,
    output reg long_preamble_detected,

    output reg [31:0] sample_out,
    output reg sample_out_strobe,
    output reg [15:0] num_ofdm_symbol,

    output reg signed [31:0] phase_offset_taken,
    output reg [2:0] state
);
`include "common_params.v"

localparam IN_BUF_LEN_SHIFT = 8;

localparam NUM_STS_TAIL = 32;

reg [15:0] in_offset;
reg [IN_BUF_LEN_SHIFT-1:0] in_waddr;
reg [IN_BUF_LEN_SHIFT-1:0] in_raddr;
wire [IN_BUF_LEN_SHIFT-1:0] gi_skip = short_gi? 9: 17;
reg signed [31:0] num_input_produced;
reg signed [31:0] num_input_consumed;
reg signed [31:0] num_input_avail;

reg [2:0] mult_stage;
reg [1:0] sum_stage;
reg  mult_strobe;

wire signed [31:0] stage_sum_i;
wire signed [31:0] stage_sum_q;

wire stage_sum_stb;

reg signed [31:0] sum_i;
reg signed [31:0] sum_q;
reg sum_stb;

reg signed [31:0] phase_correction;
reg signed [31:0] next_phase_correction;

reg reset_delay ; // add reset signal for fft, somehow all kinds of event flag raises when feeding real rf signal, maybe reset will help
wire fft_resetn ;

/*
// =============save signal to file for matlab bit-true comparison===========
integer file_open_trigger = 0;
integer sum_fd, metric_fd, phase_correction_fd, next_phase_correction_fd, fft_in_fd, fft_out_fd;
wire signed [15:0] fft_out_re_signed, fft_out_im_signed;
// wire signed [31:0] prod_i, prod_q, prod_avg_i, prod_avg_q, phase_in_i_signed, phase_in_q_signed, phase_out_signed;
// assign prod_i = prod[63:32];
assign fft_out_re_signed = fft_out_re[22:7];
assign fft_out_im_signed = fft_out_im[22:7];

always @(posedge clock) begin
    file_open_trigger = file_open_trigger + 1;
    if (file_open_trigger==1) begin
        sum_fd = $fopen("./sum.txt", "w");
        metric_fd = $fopen("./metric.txt", "w");
        phase_correction_fd = $fopen("./phase_correction.txt", "w");
        next_phase_correction_fd = $fopen("./next_phase_correction.txt", "w");
        fft_in_fd = $fopen("./fft_in.txt", "w");
        fft_out_fd = $fopen("./fft_out.txt", "w");
    end

    if (sum_stb && enable && (~reset) ) begin
        $fwrite(sum_fd, "%d %d\n", sum_i, sum_q);
        $fflush(sum_fd);
    end
    if (metric_stb && enable && (~reset) ) begin
        $fwrite(metric_fd, "%d\n", metric);
        $fflush(metric_fd);
    end
    if (raw_stb && enable && (~reset) ) begin
        $fwrite(phase_correction_fd, "%d\n", phase_correction);
        $fflush(phase_correction_fd);
        $fwrite(next_phase_correction_fd, "%d\n", next_phase_correction);
        $fflush(next_phase_correction_fd);
    end
    if (fft_in_stb && enable && (~reset) ) begin
        $fwrite(fft_in_fd, "%d %d\n", fft_in_re, fft_in_im);
        $fflush(fft_in_fd);
    end
    if (fft_valid && enable && (~reset) ) begin
        $fwrite(fft_out_fd, "%d %d\n", fft_out_re_signed, fft_out_im_signed);
        $fflush(fft_out_fd);
    end
end
// ==========end of save signal to file for matlab bit-true comparison===========
*/

always @(posedge clock) begin
    reset_delay = reset ;
end
assign fft_resetn = (~reset) & (~reset_delay); // make sure resetn is at least 2 clock cycles low 

complex_to_mag #(.DATA_WIDTH(32)) sum_mag_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .i(sum_i),
    .q(sum_q),
    .input_strobe(sum_stb),

    .mag(metric),
    .mag_stb(metric_stb)
);

reg [31:0] metric_max1;
reg [(IN_BUF_LEN_SHIFT-1):0] addr1;
reg [31:0] metric_max2;
reg [(IN_BUF_LEN_SHIFT-1):0] addr2;
reg [15:0] gap;

reg [31:0] cross_corr_buf[0:15];

reg [31:0] stage_X0;
reg [31:0] stage_X1;
reg [31:0] stage_X2;
reg [31:0] stage_X3;

reg [31:0] stage_Y0;
reg [31:0] stage_Y1;
reg [31:0] stage_Y2;
reg [31:0] stage_Y3;

stage_mult stage_mult_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .X0(stage_X0[31:16]),
    .X1(stage_X0[15:0]),
    .X2(stage_X1[31:16]),
    .X3(stage_X1[15:0]),
    .X4(stage_X2[31:16]),
    .X5(stage_X2[15:0]),
    .X6(stage_X3[31:16]),
    .X7(stage_X3[15:0]),

    .Y0(stage_Y0[31:16]),
    .Y1(stage_Y0[15:0]),
    .Y2(stage_Y1[31:16]),
    .Y3(stage_Y1[15:0]),
    .Y4(stage_Y2[31:16]),
    .Y5(stage_Y2[15:0]),
    .Y6(stage_Y3[31:16]),
    .Y7(stage_Y3[15:0]),

    .input_strobe(mult_strobe),

    .sum({stage_sum_i, stage_sum_q}),
    .output_strobe(stage_sum_stb)
);

localparam S_SKIPPING = 0;
localparam S_WAIT_FOR_FIRST_PEAK = 1;
localparam S_WAIT_FOR_SECOND_PEAK = 2;
localparam S_IDLE = 3;
localparam S_FFT = 4;

reg fft_start;
//wire fft_start_delayed;

wire fft_in_stb;
reg fft_loading;
wire signed [15:0] fft_in_re;
wire signed [15:0] fft_in_im;
wire [22:0] fft_out_re;
wire [22:0] fft_out_im;
wire fft_ready;
wire fft_done;
wire fft_busy;
wire fft_valid;

wire [31:0] fft_out = {fft_out_re[22:7], fft_out_im[22:7]};

wire signed [15:0] raw_i;
wire signed [15:0] raw_q;
reg raw_stb;
wire idle_line1, idle_line2 ;
reg fft_din_data_tlast ;
wire fft_din_data_tlast_delayed ;
wire event_frame_started;
wire event_tlast_unexpected;
wire event_tlast_missing;
wire event_status_channel_halt;
wire event_data_in_channel_halt;
wire event_data_out_channel_halt;
wire s_axis_config_tready;
wire m_axis_data_tlast;

ram_2port  #(.DWIDTH(32), .AWIDTH(IN_BUF_LEN_SHIFT)) in_buf (
    .clka(clock),
    .ena(1),
    .wea(sample_in_strobe),
    .addra(in_waddr),
    .dia(sample_in),
    .doa(),
    .clkb(clock),
    .enb(fft_start | fft_loading),
    .web(1'b0),
    .addrb(in_raddr),
    .dib(32'hFFFF),
    .dob({raw_i, raw_q})
);

rotate rotate_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .in_i(raw_i),
    .in_q(raw_q),
    .phase(phase_correction),
    .input_strobe(raw_stb),

    .rot_addr(rot_addr),
    .rot_data(rot_data),
    
    .out_i(fft_in_re),
    .out_q(fft_in_im),
    .output_strobe(fft_in_stb)
);

delayT #(.DATA_WIDTH(1), .DELAY(10)) fft_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in(fft_din_data_tlast),
    .data_out(fft_din_data_tlast_delayed)
);

///the fft7_1 isntance is commented out, as it is upgraded to fft9 version
/*xfft_v7_1 dft_inst (
    .clk(clock),
    .fwd_inv(1),
    .start(fft_start_delayed),
    .fwd_inv_we(1),

    .xn_re(fft_in_re),
    .xn_im(fft_in_im),
    .xk_re(fft_out_re),
    .xk_im(fft_out_im),
    .rfd(fft_ready),
    .done(fft_done),
    .busy(fft_busy),
    .dv(fft_valid)
);*/


xfft_v9 dft_inst (
  .aclk(clock),       // input wire aclk
  .aresetn(fft_resetn),                                               
  .s_axis_config_tdata({7'b0, 1'b1}),                          // input wire [7 : 0] s_axis_config_tdata, use LSB to indicate it is forward transform, the rest should be ignored
  .s_axis_config_tvalid(1'b1),                                 // input wire s_axis_config_tvalid
  .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready
  .s_axis_data_tdata({fft_in_im, fft_in_re}),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(fft_in_stb),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(fft_ready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(fft_din_data_tlast_delayed),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata({idle_line1,fft_out_im, idle_line2, fft_out_re}),                      // output wire [47 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(fft_valid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
  .event_frame_started(event_frame_started),                  // output wire event_frame_started
  .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
  .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
  .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
);

reg [15:0] num_sample;

integer i;
integer j;
always @(posedge clock) begin
    if (reset) begin
        for (j = 0; j < 16; j= j+1) begin
            cross_corr_buf[j] <= 0;
        end
        do_clear();
        state <= S_SKIPPING;
        fft_din_data_tlast <= 1'b0;
    end else if (enable) begin
        if (sample_in_strobe && state != S_SKIPPING) begin
            in_waddr <= in_waddr + 1;
            num_input_produced <= num_input_produced + 1;
        end
        num_input_avail <= num_input_produced - num_input_consumed;

        case(state)
            S_SKIPPING: begin
                // skip the tail of  short preamble
                if (num_sample >= NUM_STS_TAIL) begin
                    num_sample <= 0;
                    state <= S_WAIT_FOR_FIRST_PEAK;
                end else if (sample_in_strobe) begin
                    num_sample <= num_sample + 1;
                end
            end

            S_WAIT_FOR_FIRST_PEAK: begin
                do_mult();

                if (metric_stb && (metric > metric_max1)) begin
                    metric_max1 <= metric;
                    addr1 <= in_raddr - 1;
                end

                if (num_sample >= 64) begin
                    num_sample <= 0;
                    addr2 <= 0;
                    state <= S_WAIT_FOR_SECOND_PEAK;
                end else if (metric_stb) begin
                    num_sample <= num_sample + 1;
                end

            end

            S_WAIT_FOR_SECOND_PEAK: begin
                do_mult();

                if (metric_stb && (metric > metric_max2)) begin
                    metric_max2 <= metric;
                    addr2 <= in_raddr - 1;
                end
                gap <= addr2 - addr1;

                if (num_sample >= 64) begin
                    `ifdef DEBUG_PRINT
                        $display("PEAK GAP: %d (%d - %d)", gap, addr2, addr1);
                        $display("PHASE OFFSET: %d", phase_offset);
                    `endif
                    if (gap > 62 && gap < 66) begin
                        long_preamble_detected <= 1;
                        num_sample <= 0;
                        mult_strobe <= 0;
                        sum_stb <= 0;
                        // offset it by the length of cross correlation buffer
                        // size
                        in_raddr <= addr1 - 16;
                        num_input_consumed <= addr1 - 16;
                        in_offset <= 0;
                        num_ofdm_symbol <= 0;
                        phase_correction <= 0;
                        next_phase_correction <= phase_offset;
                        phase_offset_taken <= phase_offset;
                        state <= S_FFT;
                    end else begin
                        state <= S_IDLE;
                    end
                end else if (metric_stb) begin
                    num_sample <= num_sample + 1;
                end
            end

            S_FFT: begin
                if (long_preamble_detected) begin
                    `ifdef DEBUG_PRINT
                        $display("Long preamble detected");
                    `endif
                    long_preamble_detected <= 0;
                end

                if (~fft_loading && num_input_avail > 64) begin
                    fft_start <= 1;
                    in_offset <= 0;
                end

                if (fft_start) begin
                    fft_start <= 0;
                    fft_loading <= 1;
                end

                raw_stb <= fft_start | fft_loading;
                if (raw_stb) begin
                    if (phase_offset > 0) begin
                        if (next_phase_correction > PI) begin
                            phase_correction <= next_phase_correction - DOUBLE_PI;
                            next_phase_correction <= next_phase_correction + phase_offset - DOUBLE_PI;
                        end else begin
                            phase_correction <= next_phase_correction;
                            next_phase_correction <= next_phase_correction + phase_offset;
                        end
                    end else begin
                        if (next_phase_correction < -PI) begin
                            phase_correction <= next_phase_correction + DOUBLE_PI;
                            next_phase_correction <= next_phase_correction + DOUBLE_PI + phase_offset;
                        end else begin
                            phase_correction <= next_phase_correction;
                            next_phase_correction <= next_phase_correction + phase_offset;
                        end
                    end
                end

                if (fft_start | fft_loading) begin
                    in_offset <= in_offset + 1;
                    
                    if( in_offset == 62) begin
                        fft_din_data_tlast <= 1'b1;
                    end

                    if (in_offset == 63) begin
                        fft_din_data_tlast <= 1'b0;
                        fft_loading <= 0;
                        num_ofdm_symbol <= num_ofdm_symbol + 1;
                        if (num_ofdm_symbol > 0) begin
                            // skip the Guard Interval for data symbols
                            in_raddr <= in_raddr + gi_skip;
                            num_input_consumed <= num_input_consumed + gi_skip;
                        end else begin
                            in_raddr <= in_raddr + 1;
                            num_input_consumed <= num_input_consumed + 1;
                        end
                    end else begin
                        in_raddr <= in_raddr + 1;
                        num_input_consumed <= num_input_consumed + 1;
                    end
                end

                sample_out_strobe <= fft_valid;
                sample_out <= fft_out;
            end

            S_IDLE: begin
            end

            default: begin
                state <= S_WAIT_FOR_FIRST_PEAK;
            end
        endcase
    end else begin
        sample_out_strobe <= 0;
    end
end

integer do_mult_i;
task do_mult; begin
    // cross correlation of the first 16 samples of LTS
    if (sample_in_strobe) begin
        cross_corr_buf[15] <= sample_in;
        for (do_mult_i = 0; do_mult_i < 15; do_mult_i = do_mult_i+1) begin
            cross_corr_buf[do_mult_i] <= cross_corr_buf[do_mult_i+1];
        end

        sum_stage <= 0;
        sum_i <= 0;
        sum_q <= 0;
        sum_stb <= 0;

        stage_X0 <= cross_corr_buf[1];
        stage_X1 <= cross_corr_buf[2];
        stage_X2 <= cross_corr_buf[3];
        stage_X3 <= cross_corr_buf[4];

        stage_Y0[31:16] <= 156;
        stage_Y0[15:0] <= 0;
        stage_Y1[31:16] <= -5;
        stage_Y1[15:0] <= 120;
        stage_Y2[31:16] <= 40;
        stage_Y2[15:0] <= 111;
        stage_Y3[31:16] <= 97;
        stage_Y3[15:0] <= -83;

        mult_strobe <= 1;
        mult_stage <= 1;
    end

    if (mult_stage == 1) begin
        stage_X0 <= cross_corr_buf[4];
        stage_X1 <= cross_corr_buf[5];
        stage_X2 <= cross_corr_buf[6];
        stage_X3 <= cross_corr_buf[7];

        stage_Y0[31:16] <= 21;
        stage_Y0[15:0] <= -28;
        stage_Y1[31:16] <= 60;
        stage_Y1[15:0] <= 88;
        stage_Y2[31:16] <= -115;
        stage_Y2[15:0] <= 55;
        stage_Y3[31:16] <= -38;
        stage_Y3[15:0] <= 106;

        mult_stage <= 2;
    end else if (mult_stage == 2) begin
        stage_X0 <= cross_corr_buf[8];
        stage_X1 <= cross_corr_buf[9];
        stage_X2 <= cross_corr_buf[10];
        stage_X3 <= cross_corr_buf[11];

        stage_Y0[31:16] <= 98;
        stage_Y0[15:0] <= 26;
        stage_Y1[31:16] <= 53;
        stage_Y1[15:0] <= -4;
        stage_Y2[31:16] <= 1;
        stage_Y2[15:0] <= 115;
        stage_Y3[31:16] <= -137;
        stage_Y3[15:0] <= 47;

        mult_stage <= 3;
    end else if (mult_stage == 3) begin
        stage_X0 <= cross_corr_buf[12];
        stage_X1 <= cross_corr_buf[13];
        stage_X2 <= cross_corr_buf[14];
        stage_X3 <= cross_corr_buf[15];

        stage_Y0[31:16] <= 24;
        stage_Y0[15:0] <= 59;
        stage_Y1[31:16] <= 59;
        stage_Y1[15:0] <= 15;
        stage_Y2[31:16] <= -22;
        stage_Y2[15:0] <= -161;
        stage_Y3[31:16] <= 119;
        stage_Y3[15:0] <= 4;

        mult_stage <= 4;
    end else if (mult_stage == 4) begin
        mult_stage <= 0;
        mult_strobe <= 0;
        in_raddr <= in_raddr + 1;
        num_input_consumed <= num_input_consumed + 1;
    end

    if (stage_sum_stb) begin
        sum_stage <= sum_stage + 1;
        sum_i <= sum_i + stage_sum_i;
        sum_q <= sum_q + stage_sum_q;
        if (sum_stage == 3) begin
            sum_stb <= 1;
        end
    end else begin
        sum_stb <= 0;
        sum_i <= 0;
        sum_q <= 0;
    end
end
endtask

task do_clear; begin
    gap <= 0;

    in_waddr <= 0;
    in_raddr <= 0;
    in_offset <= 0;
    num_input_produced <= 0;
    num_input_consumed <= 0;
    num_input_avail <= 0;

    phase_correction <= 0;
    next_phase_correction <= 0;

    raw_stb <= 0;

    sum_i <= 0;
    sum_q <= 0;
    sum_stb <= 0;
    sum_stage <= 0;
    mult_strobe <= 0;

    metric_max1 <= 0;
    addr1 <= 0;
    metric_max2 <= 0;
    addr2 <= 0;

    mult_stage <= 0;

    long_preamble_detected <= 0;
    num_sample <= 0;
    num_ofdm_symbol <= 0;

    fft_start <= 0;
    fft_loading <= 0;

    sample_out_strobe <= 0;
    sample_out <= 0;

    stage_X0 <= 0;
    stage_X1 <= 0;
    stage_X2 <= 0;
    stage_X3 <= 0;

    stage_Y0 <= 0;
    stage_Y1 <= 0;
    stage_Y2 <= 0;
    stage_Y3 <= 0;
end
endtask

endmodule
