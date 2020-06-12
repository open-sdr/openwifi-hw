module ofdm_decoder
(
    input clock,
    input enable,
    input reset,

    input [31:0] sample_in,
    input sample_in_strobe,
    input soft_decoding,

    // decode instructions
    input [7:0] rate,
    input do_descramble,
    input [31:0] num_bits_to_decode,

    output [5:0] demod_out,
    output demod_out_strobe,

    output [7:0] deinterleave_erase_out,
    output deinterleave_erase_out_strobe,

    output conv_decoder_out,
    output conv_decoder_out_stb,

    output descramble_out,
    output descramble_out_strobe,

    output [7:0] byte_out,
    output byte_out_strobe
);

wire [5:0] demod_soft_bits;
wire [3:0] demod_soft_bits_pos;

reg conv_in_stb, conv_in_stb_dly, do_descramble_dly;
reg [2:0] conv_in0, conv_in0_dly;
reg [2:0] conv_in1, conv_in1_dly;
reg [1:0] conv_erase, conv_erase_dly;

wire [15:0] input_i = sample_in[31:16];
wire [15:0] input_q = sample_in[15:0];

wire vit_ce = reset | (enable & conv_in_stb) | conv_in_stb_dly;
//wire vit_ce = 1'b1 ;
wire vit_clr = reset;
reg vit_clr_dly;
wire vit_rdy;

wire [5:0] deinterleave_out;
wire deinterleave_out_strobe;
wire [1:0] erase;

// assign conv_decoder_out_stb = vit_ce & vit_rdy;
assign conv_decoder_out_stb = m_axis_data_tvalid; // vit_rdy was used as data valid in the old version of the core, which is no longer the case 
reg [3:0] skip_bit;
reg bit_in;
reg bit_in_stb;

reg [31:0] deinter_out_count;
//reg flush;

assign deinterleave_erase_out = {erase,deinterleave_out};
assign deinterleave_erase_out_strobe = deinterleave_out_strobe;
demodulate demod_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .rate(rate),
    .cons_i(input_i),
    .cons_q(input_q),
    .input_strobe(sample_in_strobe),
    .bits(demod_out),
    .soft_bits(demod_soft_bits),
    .soft_bits_pos(demod_soft_bits_pos),
    .output_strobe(demod_out_strobe)
);

deinterleave deinterleave_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),

    .rate(rate),
    .in_bits(demod_out),
    .soft_in_bits(demod_soft_bits),
    .soft_in_bits_pos(demod_soft_bits_pos),
    .input_strobe(demod_out_strobe),
    .soft_decoding(soft_decoding),

    .out_bits(deinterleave_out),
    .output_strobe(deinterleave_out_strobe),
    .erase(erase)
);
/*
viterbi_v7_0 viterbi_inst (
    .clk(clock),
    .ce(vit_ce),
    .sclr(vit_clr),
    .data_in0(conv_in0),
    .data_in1(conv_in1),
    .erase(conv_erase),
    .rdy(vit_rdy),
    .data_out(conv_decoder_out)
);
*/
wire m_axis_data_tvalid ;
//reg [4:0] idle_wire_5bit ;
//wire [6:0] idle_wire_7bit ; 
viterbi_v7_0 viterbi_inst (
  .aclk(clock),                              // input wire aclk
  .aresetn(~vit_clr),                        // input wire aresetn
  .aclken(vit_ce),                          // input wire aclken
  .s_axis_data_tdata({5'b0,conv_in1_dly,5'b0,conv_in0_dly}),    // input wire [15 : 0] s_axis_data_tdata
  .s_axis_data_tuser({6'b0,conv_erase_dly}),    // input wire [7 : 0] s_axis_data_tuser
  .s_axis_data_tvalid(conv_in_stb_dly),  // input wire s_axis_data_tvalid
  .s_axis_data_tready(vit_rdy),  // output wire s_axis_data_tready
  .m_axis_data_tdata({idle_wire_7bit, conv_decoder_out}),    // output wire [7 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(m_axis_data_tvalid)  // output wire m_axis_data_tvalid
);

descramble decramble_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    
    .in_bit(conv_decoder_out),
    .input_strobe(conv_decoder_out_stb),

    .out_bit(descramble_out),
    .output_strobe(descramble_out_strobe)
);


bits_to_bytes byte_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),

    .bit_in(bit_in),
    .input_strobe(bit_in_stb),

    .byte_out(byte_out),
    .output_strobe(byte_out_strobe)
);

always @(posedge clock) begin
    if (reset) begin
        conv_in_stb <= 0;
        conv_in0 <= 0;
        conv_in1 <= 0;
        conv_erase <= 0;

        bit_in <= 0;
        // skip the first 9 bits of descramble out (service bits)
        skip_bit <= 9;
        bit_in_stb <= 0;

        //flush <= 0;
        deinter_out_count <= 0;
    end else if (enable) begin
        if (deinterleave_out_strobe) begin
            deinter_out_count <= deinter_out_count + 2;
        end //else begin
            // wait for finishing deinterleaving current symbol
            // only do flush for non-DATA bits, such as SIG and HT-SIG, which
            // are not scrambled
            //if (~do_descramble && deinter_out_count >= num_bits_to_decode) begin
            //if (deinter_out_count >= num_bits_to_decode) begin // careful! deinter_out_count is only correct from 6M ~ 48M! under 54M, it should be 2*216, but actual value is 288!
                //flush <= 1;
            //end
        //end
        //if (!flush) begin
        if (!(deinter_out_count >= num_bits_to_decode)) begin
            conv_in_stb <= deinterleave_out_strobe;
            conv_in0 <= deinterleave_out[2:0];
            conv_in1 <= deinterleave_out[5:3];
            conv_erase <= erase;
        end else begin
            conv_in_stb <= 1;
            conv_in0 <= 3'b011;
            conv_in1 <= 3'b011;
            conv_erase <= 0;
        end

        if (deinter_out_count > 0) begin
            if (~do_descramble_dly) begin
                bit_in <= conv_decoder_out;
                bit_in_stb <= conv_decoder_out_stb;
            end else begin
                bit_in <= descramble_out;
                if (descramble_out_strobe) begin
                    if (skip_bit > 0 ) begin
                        skip_bit <= skip_bit - 1;
                        bit_in_stb <= 0;
                    end else begin
                        bit_in_stb <= 1;
                    end
                end else begin
                    bit_in_stb <= 0;
                end
            end
        end
    end
end

// process used to delay things
// TODO: this is only a temp solution, as tready only rise one clock after ce goes high, delay statically by one clock, in future should take into account tready
always @(posedge clock) begin
    conv_in1_dly <= conv_in1;
    conv_in0_dly <= conv_in0;
    conv_erase_dly <= conv_erase;
    conv_in_stb_dly <= conv_in_stb ;
    do_descramble_dly <= do_descramble;
end

endmodule
