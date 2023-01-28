// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1ns/1ps

module mv_avg_tb #(
    parameter integer IQ_DATA_WIDTH	= 32
) (

);

reg clock;
reg reset, sim_reset;

integer run_out_of_iq_sample, iq_count_tmp;
integer file_data_in;
reg  signed [(IQ_DATA_WIDTH-1):0] data_in;
reg  signed [(IQ_DATA_WIDTH-1):0] data_in0;
reg  signed [(IQ_DATA_WIDTH-1):0] data_in1;
reg  data_in_valid;

//wire signed [(IQ_DATA_WIDTH-1):0] data_out;
//wire data_out_valid, ready_signal;

wire signed [(IQ_DATA_WIDTH-1):0] data_out_new;
wire data_out_new_valid;

wire signed [(IQ_DATA_WIDTH-1):0] data_out0;
wire signed [(IQ_DATA_WIDTH-1):0] data_out1;
wire data_out_dual_ch_valid;

//wire signed [(IQ_DATA_WIDTH-1):0] data_out128;
//wire data_out128_valid, ready_signal128;

wire signed [(IQ_DATA_WIDTH-1):0] data_out128_new;
wire data_out128_new_valid;

reg [15:0] clk_count;

integer sample_count; // to terminal the simulation after NUM_SAMPLE

integer data_in_fd, data_out_fd, data_out_new_fd, data_out_dual_ch_fd, data_out128_fd, data_out128_new_fd;

`define SPEED_100M // comment out this to use 200M

//`define INPUT_FILE  "../../../../../test_vec/data_in_sync_short_prod.txt"
`define INPUT_FILE  "../../../../../test_vec/data_in.txt"
//`define OUTPUT_FILE "../../../../../test_vec/data_out.txt"
`define OUTPUT_NEW_FILE "../../../../../test_vec/data_out_new.txt"
//`define OUTPUT128_FILE "../../../../../test_vec/data_out128.txt"
//`define OUTPUT128_NEW_FILE "../../../../../test_vec/data_out128_new.txt"

`define OUTPUT_DUAL_CH_FILE "../../../../../test_vec/data_out_dual_ch.txt"

`define NUM_SAMPLE 1999

initial begin
    $dumpfile("mv_avg_tb.vcd");
    $dumpvars;

    run_out_of_iq_sample = 0;
    
    clock = 0;
    reset = 1;
    
    sim_reset = 1;
    
    #10 sim_reset = 0;

    #100 reset = 0;
    
    // 5clk reset (100MHz) at a specific time
    #25003 reset = 1;
    #57 reset = 0;
    // 5clk reset (100MHz) at a specific time
    #24995 reset = 1;
    #87 reset = 0;
    // 5clk reset (100MHz) at a specific time
    #25008 reset = 1;
    #50 reset = 0;
end

always begin // clk gen
`ifdef SPEED_100M
        #5 clock = !clock;  //100MHz
`else
        #2.5 clock = !clock;//200MHz
`endif
end

integer file_open_trigger = 0;
always @(posedge clock) begin
    if (sim_reset) begin
        file_open_trigger = 0;
    end else begin    
        if (file_open_trigger==0) begin
            data_in_fd  = $fopen(`INPUT_FILE, "r");
//            data_out_fd = $fopen(`OUTPUT_FILE, "w");
            data_out_new_fd = $fopen(`OUTPUT_NEW_FILE, "w");
//            data_out128_fd = $fopen(`OUTPUT128_FILE, "w");
//            data_out128_new_fd = $fopen(`OUTPUT128_NEW_FILE, "w");
            data_out_dual_ch_fd = $fopen(`OUTPUT_DUAL_CH_FILE, "w");
        end
        file_open_trigger = file_open_trigger + 1;
    end
end

`ifdef SPEED_100M
`define CLK_COUNT_TOP_FOR_VALID 4  // for 100M; 100/20 = 5
`else
`define CLK_COUNT_TOP_FOR_VALID 9  // for 200M; 200/20 = 10
`endif
always @(posedge clock) begin
    if (sim_reset) begin
        data_in <= 0;
        data_in0 <= 0;
        data_in1 <= 0;
        data_in_valid <= 0;
        clk_count <= 0;
    end else begin
    	if (clk_count == `CLK_COUNT_TOP_FOR_VALID) begin
            data_in_valid <= 1;
            iq_count_tmp = $fscanf(data_in_fd, "%d", file_data_in);
            data_in <= file_data_in;
            data_in0 <= file_data_in;
            data_in1 <= -file_data_in;
            clk_count <= 0;
            if (iq_count_tmp != 1)
                run_out_of_iq_sample = 1;
        end else begin
            data_in_valid <= 0;
            clk_count <= clk_count + 1;
            data_in <= -data_in;//to emulate value change between valid
            data_in0 <= data_in0-100;//to emulate value change between valid
            data_in1 <= -(data_in1<<2);//to emulate value change between valid
        end

        if (data_in_valid) begin
            if ((sample_count % 100) == 0) begin
                $display("%d", sample_count);
            end

            if (run_out_of_iq_sample) begin
                $fclose(data_in_fd);
//                $fclose(data_out_fd);
                $fclose(data_out_new_fd);
//                $fclose(data_out128_fd);
//                $fclose(data_out128_new_fd);
                $fclose(data_out_dual_ch_fd);
                $finish;
            end
        end

//        if (data_out_valid) begin
//            $fwrite(data_out_fd, "%d\n", data_out);
//            $fflush(data_out_fd);
//        end

        if (data_out_new_valid) begin
            $fwrite(data_out_new_fd, "%d\n", data_out_new);
            $fflush(data_out_new_fd);
        end

//        if (data_out128_valid) begin
//            $fwrite(data_out128_fd, "%d\n", data_out128);
//            $fflush(data_out128_fd);
//        end

//        if (data_out128_new_valid) begin
//            $fwrite(data_out128_new_fd, "%d\n", data_out128_new);
//            $fflush(data_out128_new_fd);
//        end
        if (data_out_dual_ch_valid) begin
            $fwrite(data_out_dual_ch_fd, "%d %d\n", data_out0, data_out1);
            $fflush(data_out_dual_ch_fd);
        end
    end
end

//mv_avg32 # (
//) mv_avg32_i (
//   .M_AXIS_DATA_tdata(data_out),
//   .M_AXIS_DATA_tvalid(data_out_valid),
//   .S_AXIS_DATA_tdata(data_in),
//   .S_AXIS_DATA_tready(ready_signal),
//   .S_AXIS_DATA_tvalid(data_in_valid),
//   .aclk(clock),
//   .aresetn(~reset)
//);

mv_avg #(.DATA_WIDTH(IQ_DATA_WIDTH), .LOG2_AVG_LEN(5)) mv_avg_inst (
    .clk(clock),
    .rstn(~reset),

    .data_in(data_in),
    .data_in_valid(data_in_valid),
    .data_out(data_out_new),
    .data_out_valid(data_out_new_valid)
);

mv_avg_dual_ch #(.DATA_WIDTH0(IQ_DATA_WIDTH), .DATA_WIDTH1(IQ_DATA_WIDTH), .LOG2_AVG_LEN(4)) mv_avg_dual_ch_inst (
    .clk(clock),
    .rstn(~reset),

    .data_in0(data_in0),
    .data_in1(data_in1),
    .data_in_valid(data_in_valid),
    .data_out0(data_out0),
    .data_out1(data_out1),
    .data_out_valid(data_out_dual_ch_valid)
);

//mv_avg128 # (
//) mv_avg128_i (
//   .M_AXIS_DATA_tdata(data_out128),
//   .M_AXIS_DATA_tvalid(data_out128_valid),
//   .S_AXIS_DATA_tdata(data_in),
//   .S_AXIS_DATA_tready(ready_signal128),
//   .S_AXIS_DATA_tvalid(data_in_valid),
//   .aclk(clock),
//   .aresetn(~reset)
//);

//mv_avg #(.DATA_WIDTH(16), .LOG2_AVG_LEN(7)) mv_avg_new_inst (
//    .clk(clock),
//    .rstn(~reset),

//    .data_in(data_in),
//    .data_in_valid(data_in_valid),
//    .data_out(data_out128_new),
//    .data_out_valid(data_out128_new_valid)
//);

endmodule
