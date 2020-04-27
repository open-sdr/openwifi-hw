/*
* OFDM deinterleaver
*/
module deinterleave
(
    input clock,
    input reset,
    input enable,

    input [7:0] rate,
    input [5:0] in_bits,
    input [5:0] soft_in_bits,
    input [3:0] soft_in_bits_pos,
    input input_strobe,
    input soft_decoding,

    output reg [5:0] out_bits,
    output [1:0] erase,
    output output_strobe
);

wire ht = rate[7];

wire [5:0] num_data_carrier = ht? 52: 48;
wire [5:0] half_data_carrier = ht? 26: 24;

reg [5:0] addra;
reg [5:0] addrb;

reg [11:0] lut_key;
wire [21:0] lut_out;
wire [21:0] lut_out_delayed;

reg lut_valid;
wire lut_valid_delayed;

assign erase[0] = lut_out_delayed[21];
assign erase[1] = lut_out_delayed[20];

wire [2:0] lut_bita = lut_out_delayed[7:5];
wire [2:0] lut_bitb = lut_out_delayed[4:2];

wire [5:0] bit_outa;
wire [5:0] bit_outb;
wire [5:0] soft_bit_outa;
wire [5:0] soft_bit_outb;
wire [3:0] soft_bit_outa_pos;
wire [3:0] soft_bit_outb_pos;

// Soft and hard decoding
wire [4:0] MOD_TYPE = {rate[7], rate[3:0]};
wire BPSK   = MOD_TYPE == 5'b01011 || MOD_TYPE == 5'b01111 || MOD_TYPE == 5'b10000;
wire QPSK   = MOD_TYPE == 5'b01010 || MOD_TYPE == 5'b01110 || MOD_TYPE == 5'b10001 || MOD_TYPE == 5'b10010;
wire QAM_16 = MOD_TYPE == 5'b01001 || MOD_TYPE == 5'b01101 || MOD_TYPE == 5'b10011 || MOD_TYPE == 5'b10100;
wire QAM_64 = MOD_TYPE == 5'b01000 || MOD_TYPE == 5'b01100 || MOD_TYPE == 5'b10101 || MOD_TYPE == 5'b10110 || MOD_TYPE == 5'b10111;

wire [2:0] N_BPSC_DIV_2 = BPSK ? 3'b000 : (QPSK ? 3'b001 : (QAM_16 ? 3'b010: (QAM_64 ? 3'b011 : 3'b111)));

always @* begin
    if(lut_valid_delayed == 1'b1) begin

        // Soft decoding
        if(soft_decoding && (BPSK || QPSK || QAM_16 || QAM_64)) begin
            if(BPSK || lut_bita < N_BPSC_DIV_2) begin
                if(lut_bita[1:0] == soft_bit_outa_pos[1:0]) begin
                    out_bits[2:0] = soft_bit_outa[2:0];
                end else begin
                    if(bit_outa[lut_bita] == 1'b1)
                        out_bits[2:0] = 3'b111;
                    else
                        out_bits[2:0] = 3'b011;
                end
            end else begin
                if(lut_bita == ({1'b0,soft_bit_outa_pos[3:2]} + N_BPSC_DIV_2)) begin
                    out_bits[2:0] = soft_bit_outa[5:3];
                end else begin
                    if(bit_outa[lut_bita] == 1'b1)
                        out_bits[2:0] = 3'b111;
                    else
                        out_bits[2:0] = 3'b011;
                end
            end

            if(BPSK || lut_bitb < N_BPSC_DIV_2) begin
                if(lut_bitb[1:0] == soft_bit_outb_pos[1:0]) begin
                    out_bits[5:3] = soft_bit_outb[2:0];
                end else begin
                    if(bit_outb[lut_bitb] == 1'b1)
                        out_bits[5:3] = 3'b111;
                    else
                        out_bits[5:3] = 3'b011;
                end
            end else begin
                if(lut_bitb == ({1'b0,soft_bit_outb_pos[3:2]} + N_BPSC_DIV_2)) begin
                    out_bits[5:3] = soft_bit_outb[5:3];
                end else begin
                    if(bit_outb[lut_bitb] == 1'b1)
                        out_bits[5:3] = 3'b111;
                    else
                        out_bits[5:3] = 3'b011;
                end
            end

        // Hard decoding
        end else begin
            if(bit_outa[lut_bita] == 1'b1)
                out_bits[2:0] = 3'b111;
            else
                out_bits[2:0] = 3'b011;

            if(bit_outb[lut_bitb] == 1'b1)
                out_bits[5:3] = 3'b111;
            else
                out_bits[5:3] = 3'b011;
        end
    end else begin
        out_bits[2:0] = 0;
        out_bits[5:3] = 0;
    end
end

//assign out_bits[0] = lut_valid_delayed? bit_outa[lut_bita]: 0;
//assign out_bits[1] = lut_valid_delayed? bit_outb[lut_bitb]: 0;
assign output_strobe = enable & lut_valid_delayed & lut_out_delayed[1];

wire [5:0] lut_addra = lut_out[19:14];
wire [5:0] lut_addrb = lut_out[13:8];
wire lut_done = lut_out[0];

reg ram_delay;
reg ht_delayed;

ram_2port #(.DWIDTH(16), .AWIDTH(6)) ram_inst (
    .clka(clock),
    .ena(1),
    .wea(input_strobe),
    .addra(addra),
    .dia({in_bits, soft_in_bits, soft_in_bits_pos}),
    .doa({bit_outa,soft_bit_outa,soft_bit_outa_pos}),
    .clkb(clock),
    .enb(1),
    .web(0),
    .addrb(addrb),
    .dib(32'hFFFF),
    .dob({bit_outb,soft_bit_outb,soft_bit_outb_pos})
);

deinter_lut lut_inst (
    .clka(clock),
    .addra(lut_key),
    .douta(lut_out)
);

delayT #(.DATA_WIDTH(23), .DELAY(2)) delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in({lut_valid, lut_out}),
    .data_out({lut_valid_delayed, lut_out_delayed})
);


localparam S_INPUT = 0;
localparam S_GET_BASE = 1;
localparam S_OUTPUT = 2;

(* mark_debug = "true" *) reg [1:0] state;

always @(posedge clock) begin
    if (reset) begin
        addra <= num_data_carrier>>1;
        addrb <= 0;

        lut_key <= 0;
        lut_valid <= 0;
        ht_delayed <= 0;

        ram_delay <= 0;
        state <= S_INPUT;
    end else if (enable) begin
        ht_delayed <= ht;
        if (ht != ht_delayed) begin
            addra <= num_data_carrier>>1;
        end

        case(state)
            S_INPUT: begin
                if (input_strobe) begin
                    if (addra == half_data_carrier-1) begin
                        lut_key <= {7'b0, ht, rate[3:0]};
                        ram_delay <= 0;
                        lut_valid <= 0;
                        state <= S_GET_BASE;
                    end else begin
                        if (addra == num_data_carrier-1) begin
                            addra <= 0;
                        end else begin
                            addra <= addra + 1;
                        end
                    end
                end
            end

            S_GET_BASE: begin
                if (ram_delay) begin
                    lut_key <= lut_out;
                    ram_delay <= 0;
                    state <= S_OUTPUT;
                end else begin
                    ram_delay <= 1;
                end
            end

            S_OUTPUT: begin
                if (ram_delay) begin
                    addra <= lut_addra;
                    addrb <= lut_addrb;
                    if (lut_done) begin
                        lut_key <= 0;
                        lut_valid <= 0;
                        state <= S_INPUT;
                    end else begin
                        lut_valid <= 1;
                        lut_key <= lut_key + 1;
                    end
                end else begin
                    ram_delay <= 1;
                    lut_valid <= 1;
                    lut_key <= lut_key + 1;
                end
            end
            default: begin
            end
        endcase
    end
end

endmodule
