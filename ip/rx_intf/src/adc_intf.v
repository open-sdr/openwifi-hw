// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module adc_intf #
	(
		parameter integer ADC_PACK_DATA_WIDTH = 64
	)
	(
	  //input wire adc_rst,
      input wire adc_clk,
      input wire [ADC_PACK_DATA_WIDTH-1 : 0] adc_data,
      //input wire adc_sync,
      input wire adc_valid,
	  input wire acc_clk,
	  input wire acc_rstn,
      output wire [ADC_PACK_DATA_WIDTH-1 : 0] data_to_acc,
      output wire emptyn_to_acc,
      input wire acc_ask_data
	);

    wire ALMOSTEMPTY;
    wire ALMOSTFULL;
    wire EMPTY_internal;
    wire RDERR;
    wire WRERR;
    wire RST_internal;
    
    wire rden;
    wire wren;

    assign rden = acc_ask_data;
    assign wren = adc_valid;

    assign RST_internal = (!acc_rstn);
    assign emptyn_to_acc = (!EMPTY_internal);

    fifo64_2clk_dep32 fifo64_2clk_dep32_i
           (.DATAO(data_to_acc),
            .DI(adc_data),
            .EMPTY(EMPTY_internal),
            .FULL(),
            .RDCLK(acc_clk),
            .RDEN(acc_ask_data),
            .RD_DATA_COUNT(),
            .RST(RST_internal),
            .WRCLK(adc_clk),
            .WREN(adc_valid),
            .WR_DATA_COUNT());
	endmodule
