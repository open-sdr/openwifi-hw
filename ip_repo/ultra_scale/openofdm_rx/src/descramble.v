module descramble
(
    input clock,
    input enable,
    input reset,

    input in_bit,
    input input_strobe,

    output reg out_bit,
    output reg output_strobe
);

reg [6:0] state;
reg [4:0] bit_count;

reg inited;

wire feedback = state[6] ^ state[3];

always @(posedge clock) begin
    if (reset) begin
        bit_count <= 0;
        state <= 0;
        inited <= 0;
        out_bit <= 0;
        output_strobe <= 0;
    end else if (enable & input_strobe) begin
        if (!inited) begin
            state[6-bit_count] <= in_bit;
            if (bit_count == 6) begin
                bit_count <= 0;
                inited <= 1;
            end else begin
                bit_count <= bit_count + 1;
            end
        end else begin
            out_bit <= feedback ^ in_bit;
            output_strobe <= 1;
            state <= {state[5:0], feedback};
        end
    end else begin
        output_strobe <= 0;
    end
end

endmodule
