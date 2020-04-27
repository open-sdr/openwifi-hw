module calc_mean
(
    input clock,
    input enable,
    input reset,

    input signed [15:0] a,
    input signed [15:0] b,
    input sign,
    input input_strobe,

    output reg signed [15:0] c,
    output reg output_strobe
);

reg signed [15:0] aa;
reg signed [15:0] bb;
reg signed [15:0] cc;

reg [1:0] delay;
reg [1:0] sign_stage;

always @(posedge clock) begin
    if (reset) begin
        aa <= 0;
        bb <= 0;
        cc <= 0;
        c <= 0;
        output_strobe <= 0;
        delay <= 0;
    end else if (enable) begin
        delay[0] <= input_strobe;
        delay[1] <= delay[0];
        output_strobe <= delay[1];
        sign_stage[1] <= sign_stage[0];
        sign_stage[0] <= sign;

        aa <= a>>>1;
        bb <= b>>>1;
        cc <= aa + bb;
        c <= sign_stage[1]? ~cc+1: cc;
    end
end

endmodule

