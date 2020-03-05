/*
* DELAY: 36 cycles
*/
module divider (
    input clock,
    input reset,
    input enable,

    input signed [31:0] dividend,
    input signed [23:0] divisor,
    input input_strobe,

    output signed [31:0] quotient,
    output output_strobe
);

div_gen_v3_0 div_inst (
    .clk(clock),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient)
);

delayT #(.DATA_WIDTH(1), .DELAY(36)) out_inst (
    .clock(clock),
    .reset(reset),
    .data_in(input_strobe),
    .data_out(output_strobe)
);

endmodule
