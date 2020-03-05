module bits_to_bytes
(
    input clock,
    input enable,
    input reset,

    input bit_in,
    input input_strobe,

    output reg [7:0] byte_out,
    output reg output_strobe
);

reg [7:0] bit_buf;
reg [2:0] addr;

always @(posedge clock) begin
    if (reset) begin
        addr <= 0;
        bit_buf <= 0;
        byte_out <= 0;
        output_strobe <= 0;
    end else if (enable & input_strobe) begin
        bit_buf[7] <= bit_in;
        bit_buf[6:0] <= bit_buf[7:1];
        addr <= addr + 1;
        if (addr == 7) begin
            byte_out <= {bit_in, bit_buf[7:1]};
            output_strobe <= 1;
        end else begin
            output_strobe <= 0;
        end
    end else begin
        output_strobe <= 0;
    end
end
endmodule
