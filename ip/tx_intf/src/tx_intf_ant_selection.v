// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_intf_ant_selection #
	(
	    parameter integer IQ_DATA_WIDTH = 16,
		parameter integer DAC_PACK_DATA_WIDTH = 64
	)
	(
        input wire [DAC_PACK_DATA_WIDTH-1 : 0] data_in,
        input wire [1:0] ant_flag,
        output reg [DAC_PACK_DATA_WIDTH-1 : 0] data_out
	);

    localparam integer MSB_IDX  = (DAC_PACK_DATA_WIDTH-1);
    localparam integer MSB_HALF_IDX  = ((DAC_PACK_DATA_WIDTH/2)-1);
    localparam integer WIDTH_HALF  = (DAC_PACK_DATA_WIDTH/2);
    
    wire signed [(IQ_DATA_WIDTH-1):0] i0;
    wire signed [(IQ_DATA_WIDTH-1):0] q0;
    wire signed [(IQ_DATA_WIDTH-1):0] i1;
    wire signed [(IQ_DATA_WIDTH-1):0] q1;
    wire signed [(IQ_DATA_WIDTH-1):0] i_merged;
    wire signed [(IQ_DATA_WIDTH-1):0] q_merged;
    
    assign i0 = data_in[(1*IQ_DATA_WIDTH-1):(0*IQ_DATA_WIDTH)];
    assign q0 = data_in[(2*IQ_DATA_WIDTH-1):(1*IQ_DATA_WIDTH)];
    assign i1 = data_in[(3*IQ_DATA_WIDTH-1):(2*IQ_DATA_WIDTH)];
    assign q1 = data_in[(4*IQ_DATA_WIDTH-1):(3*IQ_DATA_WIDTH)];
    assign i_merged = i0+i1;
    assign q_merged = q0+q1;
    always @( ant_flag,q_merged,i_merged, data_in)
    begin
       case (ant_flag)
          2'b00 : begin
                        data_out[MSB_HALF_IDX:0]     = {q_merged,i_merged};
                        data_out[MSB_IDX:WIDTH_HALF] = {q_merged,i_merged};
                   end
          2'b01 : begin
                        data_out[MSB_HALF_IDX:0]     = data_in[MSB_HALF_IDX:0];
                        data_out[MSB_IDX:WIDTH_HALF] = data_in[MSB_IDX:WIDTH_HALF];
                   end
          2'b10 : begin
                        data_out[MSB_HALF_IDX:0]     = data_in[MSB_IDX:WIDTH_HALF];
                        data_out[MSB_IDX:WIDTH_HALF] = data_in[MSB_HALF_IDX:0];
                   end
          2'b11 : begin
                        data_out[MSB_HALF_IDX:0]     = data_in[MSB_HALF_IDX:0];
                        data_out[MSB_IDX:WIDTH_HALF] = data_in[MSB_IDX:WIDTH_HALF];
                   end
          default: begin
                        data_out[MSB_HALF_IDX:0]     = data_in[MSB_HALF_IDX:0];
                        data_out[MSB_IDX:WIDTH_HALF] = data_in[MSB_IDX:WIDTH_HALF];
                   end
       endcase
    end

	endmodule
