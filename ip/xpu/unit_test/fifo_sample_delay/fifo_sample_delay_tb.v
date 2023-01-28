// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1ns/1ps

module fifo_sample_delay_tb #(
    parameter integer IQ_DATA_WIDTH	= 16
) (
);

reg clock;
reg reset;
reg [(IQ_DATA_WIDTH-1):0] data_in;
reg data_in_valid;
wire [(IQ_DATA_WIDTH-1):0] data_out;
wire data_out_valid;
reg [15:0] clk_count;

integer sample_count;

`define SPEED_100M // comment out this to use 200M

`define NUM_SAMPLE 1000

initial begin
    $dumpfile("fifo_sample_delay_tb.vcd");
    $dumpvars;

    data_in <= 0;
    data_in_valid <= 0;
    clk_count <= 0;
    sample_count = 0;
    clock = 0;

    reset = 1;
    #100 reset = 0;
    // 5clk reset (100MHz) at a specific time
    #1003 reset = 1;
    #57 reset = 0;
    // 5clk reset (100MHz) at a specific time
    #2005 reset = 1;
    #87 reset = 0;
    // 5clk reset (100MHz) at a specific time
    #3008 reset = 1;
    #50 reset = 0;
end

always begin // clk gen
`ifdef SPEED_100M
    #5 clock = !clock;  //100MHz
`else
    #2.5 clock = !clock;//200MHz
`endif
end

`ifdef SPEED_100M
`define CLK_COUNT_TOP_FOR_VALID 4  // for 100M; 100/20 = 5
`else
`define CLK_COUNT_TOP_FOR_VALID 9  // for 200M; 200/20 = 10
`endif
always @(posedge clock) begin
    if (clk_count == `CLK_COUNT_TOP_FOR_VALID) begin
        data_in_valid <= 1;
        data_in <= data_in + 1;
        clk_count <= 0;
        sample_count = sample_count + 1;
        if (sample_count == `NUM_SAMPLE)
            $finish;
    end else begin
        data_in_valid <= 0;
        clk_count <= clk_count + 1;
        data_in <= -data_in;//to emulate value change between valid
    end
end

fifo_sample_delay #(.DATA_WIDTH(IQ_DATA_WIDTH), .LOG2_FIFO_DEPTH(7)) fifo_sample_delay_inst (
    .clk(clock),
    .rst(reset),

    .delay_ctl(4),
    .data_in(data_in),
    .data_in_valid(data_in_valid),
    .data_out(data_out),
    .data_out_valid(data_out_valid)
);

endmodule
