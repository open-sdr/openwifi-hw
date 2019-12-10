
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module rx_intf_ant_selection #
	(
		parameter integer ADC_PACK_DATA_WIDTH = 64
	)
	(
        input wire [ADC_PACK_DATA_WIDTH-1 : 0] data_in,
        input wire [1:0] ant_flag,
        output wire [ADC_PACK_DATA_WIDTH-1 : 0] data_out
	);

    localparam integer MSB_IDX  = (ADC_PACK_DATA_WIDTH-1);
    localparam integer MSB_HALF_IDX  = ((ADC_PACK_DATA_WIDTH/2)-1);
    localparam integer WIDTH_HALF  = (ADC_PACK_DATA_WIDTH/2);
    assign data_out[MSB_HALF_IDX:0]     = (ant_flag[0]==1'b0)?data_in[MSB_HALF_IDX:0]:data_in[MSB_IDX:WIDTH_HALF];
    assign data_out[MSB_IDX:WIDTH_HALF] = (ant_flag[1]==1'b0)?data_in[MSB_HALF_IDX:0]:data_in[MSB_IDX:WIDTH_HALF];

	endmodule
