// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

module mv_avg_dual_ch
#(
    parameter DATA_WIDTH0 = 16,
    parameter DATA_WIDTH1 = 16,
    parameter LOG2_AVG_LEN = 5
)
(
    input clk,
    input rstn,

    input signed [DATA_WIDTH0-1:0] data_in0,
    input signed [DATA_WIDTH1-1:0] data_in1,
    input data_in_valid,

    output reg signed [DATA_WIDTH0-1:0] data_out0,
    output reg signed [DATA_WIDTH1-1:0] data_out1,
    output reg data_out_valid
);

localparam FIFO_SIZE = 1<<LOG2_AVG_LEN;
localparam TOTAL_WIDTH0 = DATA_WIDTH0 + LOG2_AVG_LEN;
localparam TOTAL_WIDTH1 = DATA_WIDTH1 + LOG2_AVG_LEN;

reg signed [(TOTAL_WIDTH0-1):0] running_total0;
reg signed [(TOTAL_WIDTH1-1):0] running_total1;

wire signed [DATA_WIDTH0-1:0] data_in_old0;
wire signed [DATA_WIDTH1-1:0] data_in_old1;

wire signed [TOTAL_WIDTH0-1:0] ext_data_in_old0 = {{LOG2_AVG_LEN{data_in_old0[DATA_WIDTH0-1]}}, data_in_old0};
wire signed [TOTAL_WIDTH0-1:0] ext_data_in0     = {{LOG2_AVG_LEN{data_in0[DATA_WIDTH0-1]}},     data_in0    };
wire signed [TOTAL_WIDTH1-1:0] ext_data_in_old1 = {{LOG2_AVG_LEN{data_in_old1[DATA_WIDTH1-1]}}, data_in_old1};
wire signed [TOTAL_WIDTH1-1:0] ext_data_in1     = {{LOG2_AVG_LEN{data_in1[DATA_WIDTH1-1]}},     data_in1    };

reg data_in_valid_reg;
reg rd_en, rd_en_start;
wire [LOG2_AVG_LEN:0] wr_data_count;

xpm_fifo_sync #(
    .DOUT_RESET_VALUE("0"),    // String
    .ECC_MODE("no_ecc"),       // String
    .FIFO_MEMORY_TYPE("auto"), // String
    .FIFO_READ_LATENCY(0),     // DECIMAL
    .FIFO_WRITE_DEPTH(FIFO_SIZE),   // DECIMAL
    .FULL_RESET_VALUE(0),      // DECIMAL
    .PROG_EMPTY_THRESH(10),    // DECIMAL
    .PROG_FULL_THRESH(10),     // DECIMAL
    .RD_DATA_COUNT_WIDTH(LOG2_AVG_LEN+1),   // DECIMAL
    .READ_DATA_WIDTH(DATA_WIDTH0+DATA_WIDTH1),      // DECIMAL
    .READ_MODE("fwft"),         // String
    .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
    .WAKEUP_TIME(0),           // DECIMAL
    .WRITE_DATA_WIDTH(DATA_WIDTH0+DATA_WIDTH1),     // DECIMAL
    .WR_DATA_COUNT_WIDTH(LOG2_AVG_LEN+1)    // DECIMAL
) fifo_1clk_for_mv_avg_dual_ch_i (
    .almost_empty(),
    .almost_full(),
    .data_valid(),
    .dbiterr(),
    .dout({data_in_old1, data_in_old0}),
    .empty(empty),
    .full(full),
    .overflow(),
    .prog_empty(),
    .prog_full(),
    .rd_data_count(),
    .rd_rst_busy(),
    .sbiterr(),
    .underflow(),
    .wr_ack(),
    .wr_data_count(wr_data_count),
    .wr_rst_busy(),
    .din({data_in1, data_in0}),
    .injectdbiterr(),
    .injectsbiterr(),
    .rd_en(rd_en),
    .rst(~rstn),
    .sleep(),
    .wr_clk(clk),
    .wr_en(data_in_valid)
  );

always @(posedge clk) begin
    if (~rstn) begin
        data_in_valid_reg <= 0;
        running_total0 <= 0;
        running_total1 <= 0;
        data_out0 <= 0;
        data_out1 <= 0;
        data_out_valid <= 0;
        rd_en <= 0;
        rd_en_start <= 0;
    end else begin
        data_in_valid_reg <= data_in_valid;
        data_out_valid <= data_in_valid_reg;
        rd_en_start <= ((wr_data_count == FIFO_SIZE)?1:rd_en_start);
        rd_en <= (rd_en_start?data_in_valid:rd_en);
        data_out0 <= running_total0[TOTAL_WIDTH0-1:LOG2_AVG_LEN];
        data_out1 <= running_total1[TOTAL_WIDTH1-1:LOG2_AVG_LEN];
        if (data_in_valid) begin
            running_total0 <= running_total0 + ext_data_in0 - (rd_en_start?ext_data_in_old0:0);
            running_total1 <= running_total1 + ext_data_in1 - (rd_en_start?ext_data_in_old1:0);
        end
    end
end

endmodule
