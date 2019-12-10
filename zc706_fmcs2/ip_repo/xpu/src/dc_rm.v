// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module dc_rm #
    (
        parameter DATA_WIDTH = 16
    )
    (
        input  wire clk,
        input  wire rstn,
        input  wire signed [(DATA_WIDTH-1):0] ddc_i,
        input  wire signed [(DATA_WIDTH-1):0] ddc_q,
        input  wire ddc_iq_valid,
        output wire signed [(DATA_WIDTH-1):0] i_dc_rm,
        output wire signed [(DATA_WIDTH-1):0] q_dc_rm,
        output wire iq_dc_rm_valid
    );
    
    wire signed [DATA_WIDTH-1:0] ddc_i_mv_avg;
    wire signed [DATA_WIDTH-1:0] ddc_q_mv_avg;
    wire signed [(2*DATA_WIDTH-1):0] dc_rm_mv_avg_internal;
    
    wire dc_rm_ready_internal;
    
    assign ddc_i_mv_avg = dc_rm_mv_avg_internal[(DATA_WIDTH-1):0];
    assign ddc_q_mv_avg = dc_rm_mv_avg_internal[(2*DATA_WIDTH-1):DATA_WIDTH];

    assign i_dc_rm = ddc_i - ddc_i_mv_avg;
    assign q_dc_rm = ddc_q - ddc_q_mv_avg;

    mv_avg128 # (
    ) mv_avg128_i (
        .M_AXIS_DATA_tdata(dc_rm_mv_avg_internal),
        .M_AXIS_DATA_tvalid(iq_dc_rm_valid),
        .S_AXIS_DATA_tdata({ddc_q,ddc_i}),
        .S_AXIS_DATA_tready(dc_rm_ready_internal),
        .S_AXIS_DATA_tvalid(ddc_iq_valid),
        .aclk(clk),
        .aresetn(rstn)
    );
    
    endmodule