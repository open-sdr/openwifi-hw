/*
* xianjun.jiao@imec.be; putaoshu@msn.com
* DELAY: 36 cycles -- this is old parameter
* The new div_gen 5.x allow the valid signal, auto delay or manual delay config
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

div_gen div_inst (
    .clk(clock),
    .dividend(dividend),
    .divisor(divisor),
    .input_strobe(input_strobe),
    .output_strobe(output_strobe),
    .quotient(quotient)
);

// // --------old one---------------
// div_gen_v3_0 div_inst (
//     .clk(clock),
//     .dividend(dividend),
//     .divisor(divisor),
//     .quotient(quotient)
// );

// delayT #(.DATA_WIDTH(1), .DELAY(36)) out_inst (
//     .clock(clock),
//     .reset(reset),
//     .data_in(input_strobe),
//     .data_out(output_strobe)
// );

endmodule
