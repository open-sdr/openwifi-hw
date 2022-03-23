// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

module edge_to_flip
#(
    parameter TEMP0 = 16,
    parameter TEMP1 = 5
)
(
    input clk,
    input rstn,

    input data_in,
    output reg flip_output
);

reg data_in_reg;
always @(posedge clk) begin
    if (~rstn) begin
        data_in_reg <= 0;
        flip_output <= 0;
    end else begin
        data_in_reg <= data_in;
        flip_output <= ((data_in==1 && data_in_reg==0)?(~flip_output):flip_output);
    end
end

endmodule
