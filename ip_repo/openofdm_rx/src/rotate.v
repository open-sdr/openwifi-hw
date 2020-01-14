`include "common_defs.v"

module rotate
(
    input clock,
    input enable,
    input reset,

    input [15:0] in_i,
    input [15:0] in_q,
    // [-PI, PI]
    // scaled up by ATAN_LUT_SCALE_SHIFT
    input signed [31:0] phase,
    input input_strobe,

    output [`ROTATE_LUT_LEN_SHIFT-1:0] rot_addr,
    input [31:0] rot_data,

    output signed [15:0] out_i,
    output signed [15:0] out_q,
    output output_strobe
);
`include "common_params.v"

reg [31:0] phase_delayed;
reg [31:0] phase_abs;

reg [2:0] quadrant;
reg [2:0] quadrant_delayed;
wire [15:0] in_i_delayed;
wire [15:0] in_q_delayed;

reg [31:0] actual_phase;

wire [15:0] raw_rot_i;
wire [15:0] raw_rot_q;
reg [15:0] rot_i;
reg [15:0] rot_q;

wire mult_in_stb;

wire [31:0] p_i;
wire [31:0] p_q;

assign out_i = p_i[`ROTATE_LUT_SCALE_SHIFT+15:`ROTATE_LUT_SCALE_SHIFT];
assign out_q = p_q[`ROTATE_LUT_SCALE_SHIFT+15:`ROTATE_LUT_SCALE_SHIFT];

assign rot_addr = actual_phase[`ROTATE_LUT_LEN_SHIFT-1:0];
assign raw_rot_i = rot_data[31:16];
assign raw_rot_q = rot_data[15:0];


delayT #(.DATA_WIDTH(32), .DELAY(4)) in_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in({in_i, in_q}),
    .data_out({in_i_delayed, in_q_delayed})
);

delayT #(.DATA_WIDTH(1), .DELAY(4)) mult_delay_inst (
    .clock(clock),
    .reset(reset),

    .data_in(input_strobe),
    .data_out(mult_in_stb)
);


complex_mult mult_inst (
    .clock(clock),
    .enable(enable),
    .reset(reset),
    .a_i(in_i_delayed),
    .a_q(in_q_delayed),
    .b_i(rot_i),
    .b_q(rot_q),
    .input_strobe(mult_in_stb),
    .p_i(p_i),
    .p_q(p_q),
    .output_strobe(output_strobe)
);


integer i;
always @(posedge clock) begin
    if (reset) begin
        actual_phase <= 0;

        rot_i <= 0;
        rot_q <= 0;
        phase_abs <= 0;
        phase_delayed <= 0;

    end else if (enable) begin
        `ifdef DEBUG_PRINT
            if (phase > PI || phase < -PI) begin
                $display("[WARN] phase overflow: %d\n", phase);
            end
        `endif

        // cycle 1
        phase_abs <= phase[31]? ~phase+1: phase;
        phase_delayed <= phase;

        // cycle 2
        if (phase_abs <= PI_4) begin
            quadrant <= {phase_delayed[31], 2'b00};
            actual_phase <= phase_abs;
        end else if (phase_abs <= PI_2) begin
            quadrant <= {phase_delayed[31], 2'b01};
            actual_phase <= PI_2 - phase_abs;
        end else if (phase_abs <= PI_3_4) begin
            quadrant <= {phase_delayed[31], 2'b10};
            actual_phase <= phase_abs - PI_2;
        end else begin
            quadrant <= {phase_delayed[31], 2'b11};
            actual_phase <= PI - phase_abs;
        end

        // cycle 3
        // wait for raw_rot_i
        quadrant_delayed <= quadrant;

        // cycle 4
        case(quadrant_delayed)
            3'b000: begin
                rot_i <= raw_rot_i;
                rot_q <= raw_rot_q;
            end
            3'b001: begin
                rot_i <= raw_rot_q;
                rot_q <= raw_rot_i;
            end
            3'b010: begin
                rot_i <= ~raw_rot_q+1;
                rot_q <= raw_rot_i;
            end
            3'b011: begin
                rot_i <= ~raw_rot_i+1;
                rot_q <= raw_rot_q;
            end
            3'b100: begin
                rot_i <= raw_rot_i;
                rot_q <= ~raw_rot_q+1;
            end
            3'b101: begin
                rot_i <= raw_rot_q;
                rot_q <= ~raw_rot_i+1;
            end
            3'b110: begin
                rot_i <= ~raw_rot_q+1;
                rot_q <= ~raw_rot_i+1;
            end
            3'b111: begin
                rot_i <= ~raw_rot_i+1;
                rot_q <= ~raw_rot_q+1;
            end
        endcase
    end
end

endmodule
