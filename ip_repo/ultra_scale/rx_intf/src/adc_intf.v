// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module adc_intf #
	(
		parameter integer IQ_DATA_WIDTH = 16
	)
	(
    input wire adc_rst,
    input wire adc_clk,
    input wire [(2*IQ_DATA_WIDTH-1) : 0] adc_data,
    //input wire adc_sync,
    input wire adc_valid,
    input wire acc_clk,
    input wire acc_rstn,

    input wire [2:0] bb_gain,
    output reg [(2*IQ_DATA_WIDTH-1) : 0] data_to_acc,
    output wire emptyn_to_acc,
    input wire acc_ask_data
	);
    wire FULL_internal;
    wire EMPTY_internal;
    wire RST_internal;
    wire [(2*IQ_DATA_WIDTH-1) : 0] data_to_acc_internal;
    
    reg [(2*IQ_DATA_WIDTH-1) : 0] adc_data_delay;
    reg adc_valid_count;
    wire adc_valid_decimate;

// // ---------for debug purpose------------
//     (* mark_debug = "true" *) reg adc_clk_in_bb_domain;
//     (* mark_debug = "true" *) reg adc_valid_in_bb_domain;
//     (* mark_debug = "true" *) reg FULL_internal_in_bb_domain;
//     (* mark_debug = "true" *) reg [3:0] wren_count;
//     (* mark_debug = "true" *) reg [3:0] rden_count;
//     reg adc_valid_decimate_reg;
//     wire valid;
//     reg  valid_reg;
//     assign valid = (!EMPTY_internal);
//     always @( posedge acc_clk )
//     begin
//       if ( acc_rstn == 1'b0 ) begin
//         adc_clk_in_bb_domain <= 0;
//         adc_valid_in_bb_domain <= 0;
//         FULL_internal_in_bb_domain <= 0;
//         wren_count <= 0;
//         rden_count <= 0;
//         adc_valid_decimate_reg <= 0;
//         valid_reg <= 0;
//       end
//       else begin
//         adc_clk_in_bb_domain <= adc_clk;
//         adc_valid_in_bb_domain <= adc_valid;
//         FULL_internal_in_bb_domain <= FULL_internal;
//         adc_valid_decimate_reg <= adc_valid_decimate;
//         valid_reg <= valid;
//         if (adc_valid_decimate==1 && adc_valid_decimate_reg==0)
//           wren_count <= 0;
//         else
//           wren_count <= wren_count + 1;

//         if (valid==1 && valid_reg==0)
//           rden_count <= 0;
//         else
//           rden_count <= rden_count + 1;
//       end
//     end
// // ------------end of debug----------

    assign adc_valid_decimate = (adc_valid_count==1);

    assign RST_internal = (!acc_rstn);
    assign emptyn_to_acc = (!EMPTY_internal);

    always @( bb_gain, data_to_acc_internal)
    begin
       case (bb_gain)
          3'b000 : begin
                        data_to_acc[(IQ_DATA_WIDTH-1) : 0]                 = data_to_acc_internal[(IQ_DATA_WIDTH-1) : 0];
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = data_to_acc_internal[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH];
                   end
          3'b001 : begin
                        data_to_acc[(IQ_DATA_WIDTH-1) : 0]                 = {data_to_acc_internal[(IQ_DATA_WIDTH-2) : 0],                 1'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-2) : IQ_DATA_WIDTH], 1'd0};
                   end
          3'b010 : begin
                        data_to_acc[(IQ_DATA_WIDTH-1) : 0]                 = {data_to_acc_internal[(IQ_DATA_WIDTH-3) : 0],                 2'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-3) : IQ_DATA_WIDTH], 2'd0};
                   end
          3'b011 : begin
                        data_to_acc[(IQ_DATA_WIDTH-1) : 0]                 = {data_to_acc_internal[(IQ_DATA_WIDTH-4) : 0],                 3'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-4) : IQ_DATA_WIDTH], 3'd0};
                   end
          3'b100 : begin
                        data_to_acc[(IQ_DATA_WIDTH-1) : 0]                 = {data_to_acc_internal[(IQ_DATA_WIDTH-5) : 0],                 4'd0};
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = {data_to_acc_internal[((2*IQ_DATA_WIDTH)-5) : IQ_DATA_WIDTH], 4'd0};
                   end
          default: begin
                        data_to_acc[(IQ_DATA_WIDTH-1) : 0]                 = data_to_acc_internal[(IQ_DATA_WIDTH-1) : 0];
                        data_to_acc[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = data_to_acc_internal[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH];
                   end
       endcase
    end

    //decimate input by 2: 40Msps --> 20Msps
    always @( posedge adc_clk )
    begin
      if ( adc_rst == 1 ) begin
        adc_valid_count <= 0;
        adc_data_delay    <= 0;
      end
      else begin
        adc_data_delay <= adc_data;
        if (adc_valid == 1)
          adc_valid_count <= adc_valid_count + 1;
      end
    end

    fifo32_2clk_dep32 fifo32_2clk_dep32_i
           (.DATAO(data_to_acc_internal),
            .DI(adc_data_delay),
            .EMPTY(EMPTY_internal),
            .FULL(FULL_internal),
            .RDCLK(acc_clk),
            .RDEN(acc_ask_data),
            .RD_DATA_COUNT(),
            .RST(RST_internal),
            .WRCLK(adc_clk),
            .WREN(adc_valid_decimate),
            .WR_DATA_COUNT());
	endmodule
