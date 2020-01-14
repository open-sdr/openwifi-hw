// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module iq_abs_avg #
	(
		parameter integer IQ_DATA_WIDTH	= 16
	)
	(
        input wire clk,
        input wire rstn,
	    // Ports to receive IQ from DDC
	    input wire signed [(IQ_DATA_WIDTH-1):0] ddc_i,
        input wire signed [(IQ_DATA_WIDTH-1):0] ddc_q,
        input wire ddc_iq_valid,

        // result outputs
        output wire signed [(IQ_DATA_WIDTH-1):0] iq_rssi,
        output wire iq_rssi_valid
	);
    
    wire signed [(IQ_DATA_WIDTH-1):0] i_dc_rm;
    wire signed [(IQ_DATA_WIDTH-1):0] q_dc_rm;
    wire iq_dc_rm_valid;
    
    wire signed [(IQ_DATA_WIDTH-1):0] i_abs;
    wire signed [(IQ_DATA_WIDTH-1):0] q_abs;

    wire signed [(2*IQ_DATA_WIDTH-1):0] iq_abs_mv_avg;
    
    wire iq_abs_avg_ready_internal;
    
    assign i_abs = (i_dc_rm[IQ_DATA_WIDTH-1]==1'b1)?(-i_dc_rm):i_dc_rm;
    assign q_abs = (q_dc_rm[IQ_DATA_WIDTH-1]==1'b1)?(-q_dc_rm):q_dc_rm;
    
    assign iq_rssi = ((iq_abs_mv_avg[(IQ_DATA_WIDTH-1):0]+iq_abs_mv_avg[(2*IQ_DATA_WIDTH-1):IQ_DATA_WIDTH])>>1);

    dc_rm # (
        .DATA_WIDTH(IQ_DATA_WIDTH)
    ) dc_rm_i (
        .clk(clk),
        .rstn(rstn),
        .ddc_i(ddc_i),
        .ddc_q(ddc_q),
        .ddc_iq_valid(ddc_iq_valid),
        .i_dc_rm(i_dc_rm),
        .q_dc_rm(q_dc_rm),
        .iq_dc_rm_valid(iq_dc_rm_valid)
    );

    mv_avg32 # (
    ) mv_avg32_i (
        .M_AXIS_DATA_tdata(iq_abs_mv_avg),
        .M_AXIS_DATA_tvalid(iq_rssi_valid),
        .S_AXIS_DATA_tdata({q_abs,i_abs}),
        .S_AXIS_DATA_tready(iq_abs_avg_ready_internal),
        .S_AXIS_DATA_tvalid(iq_dc_rm_valid),
        .aclk(clk),
        .aresetn(rstn)
    );
      
	endmodule
