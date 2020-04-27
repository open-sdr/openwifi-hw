module moving_avg
#(
    parameter DATA_WIDTH = 32,
    parameter WINDOW_SHIFT = 4,
    parameter SIGNED = 0
)
(
    input clock,
    input enable,
    input reset,

    input signed [DATA_WIDTH-1:0] data_in,
    input input_strobe,

    output reg signed [DATA_WIDTH-1:0] data_out,
    output reg output_strobe
);

localparam WINDOW_SIZE = 1<<WINDOW_SHIFT;
localparam SUM_WIDTH = DATA_WIDTH + WINDOW_SHIFT;

reg signed [(SUM_WIDTH-1):0] running_sum;

wire signed [DATA_WIDTH-1:0] old_data;
wire signed [DATA_WIDTH-1:0] new_data = data_in;

wire signed [SUM_WIDTH-1:0] ext_old_data = {{WINDOW_SHIFT{old_data[DATA_WIDTH-1]}}, old_data};
wire signed [SUM_WIDTH-1:0] ext_new_data = {{WINDOW_SHIFT{new_data[DATA_WIDTH-1]}}, new_data};


reg [WINDOW_SHIFT-1:0] addr;
reg full;

ram_2port  #(.DWIDTH(DATA_WIDTH), .AWIDTH(WINDOW_SHIFT)) delay_line (
    .clka(clock),
    .ena(1),
    .wea(input_strobe),
    .addra(addr),
    .dia(data_in),
    .doa(),
    .clkb(clock),
    .enb(input_strobe),
    .web(0),
    .addrb(addr),
    .dib(32'hFFFF),
    .dob(old_data)
);

integer i;
always @(posedge clock) begin
    if (reset) begin
        addr <= 0;
        running_sum <= 0;
        full <= 0;
        data_out <= 0;
    end else if (enable) begin
        if (input_strobe) begin
            addr <= addr + 1;
            data_out <= running_sum[SUM_WIDTH-1:WINDOW_SHIFT];

            if (addr == WINDOW_SIZE-1) begin
                full <= 1;
            end

            if (full) begin
                running_sum <= running_sum + ext_new_data- ext_old_data;
            end else begin
                running_sum <= running_sum + ext_new_data;
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
