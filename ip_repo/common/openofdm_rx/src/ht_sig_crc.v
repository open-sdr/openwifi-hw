module ht_sig_crc
(
    input clock,
    input enable,
    input reset,

    input bit,
    input input_strobe,

    output [7:0] crc
);

reg [7:0] C;
genvar i;

generate
for (i = 0; i < 8; i=i+1) begin: reverse
    assign crc[i] = ~C[7-i];
end
endgenerate


always @(posedge clock) begin
    if (reset) begin
        C <= 8'hff;
    end else if (enable) begin
        if (input_strobe) begin
            C[0] <= bit ^ C[7];
            C[1] <= bit ^ C[7] ^ C[0];
            C[2] <= bit ^ C[7] ^ C[1];
            C[7:3] <= C[6:2];
        end
    end
end

endmodule
