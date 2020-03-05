/*
* Delay using RAM
* Only support 2^n delay
*/
module delay_sample
#(
    parameter DATA_WIDTH = 16,
    parameter DELAY_SHIFT = 4
)
(
    input clock, 
    input enable,
    input reset,

    input [(DATA_WIDTH-1):0] data_in,
    input input_strobe,

    output [(DATA_WIDTH-1):0] data_out,
    output reg output_strobe
);

localparam DELAY_SIZE = 1<<DELAY_SHIFT;

reg [DELAY_SHIFT-1:0] 	  addr;
reg full;

ram_2port  #(.DWIDTH(DATA_WIDTH), .AWIDTH(DELAY_SHIFT)) delay_line (
    .clka(clock),
    .ena(1),
    .wea(input_strobe),
    .addra(addr),
    .dia(data_in),
    .doa(),
    .clkb(clock),
    .enb(input_strobe),
    .web(1'b0),
    .addrb(addr),
    .dib(32'hFFFF),
    .dob(data_out)
);

always @(posedge clock) begin
    if (reset) begin
        addr <= 0;
        full <= 0;
    end else if (enable) begin
        if (input_strobe) begin
            addr <= addr + 1;
            if (addr == DELAY_SIZE-1) begin
                full <= 1;
            end
            output_strobe <= full;
        end else begin
            output_strobe <= 0;
        end
    end else begin
        output_strobe <= 0;
    end
end

endmodule
