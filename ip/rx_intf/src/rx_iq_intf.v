
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "clock_speed.v"
`include "board_def.v"

`timescale 1 ns / 1 ps

`define COUNT_TOP_20M  ((`NUM_CLK_PER_SAMPLE)-1)

	module rx_iq_intf #
	(
	    parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
      parameter integer IQ_DATA_WIDTH	=     16
	)
	(
    // -------------debug purpose----------------
    // output reg trigger_out,
    // -------------debug purpose----------------

    input wire rstn,
    input wire clk,
    
    input wire [(IQ_DATA_WIDTH-1):0] bw20_i0,
    input wire [(IQ_DATA_WIDTH-1):0] bw20_q0,
    input wire bw20_iq_valid,

    input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] data_from_s_axis,
    input wire  emptyn_from_s_axis,
    output wire ask_data_from_s_axis,
//      output wire ask_data_from_adc,

    input wire ask_data_from_s_axis_en,
    input wire fifo_in_en,
    input wire fifo_out_en,
    input wire bb_20M_en,
//      input wire fifo_out_sel,
    input wire [2:0] fifo_in_sel,
      
    // to wifi receiver
    output wire [(IQ_DATA_WIDTH-1) : 0] rf_i,
    output wire [(IQ_DATA_WIDTH-1) : 0] rf_q,
    output wire rf_iq_valid,
    input  wire rf_iq_valid_delay_sel,
    
    // to m_axis for loop back test
    output wire [((2*IQ_DATA_WIDTH)-1):0] rf_iq,
      
    output wire wifi_rx_iq_fifo_emptyn
	);
    
    wire empty;
    wire full;
    wire rden;
    wire wren;
    reg wren_selected;
    wire bb_en;
    wire [5:0] data_count;
    reg [((2*IQ_DATA_WIDTH)-1):0] data_selected;
    reg [4:0] counter;
    reg [4:0] counter_top;
    reg rf_iq_valid_reg;
    wire fractional_flag;
    reg counter_top_flag;

// // ---------for debug purpose------------
//     // (* mark_debug = "true" *) wire [8:0] num_clk_per_sample;
//     // (* mark_debug = "true" *) wire [8:0] sampling_rate_mhz;
//     // (* mark_debug = "true" *) wire [8:0] num_clk_per_us;
//     // (* mark_debug = "true" *) wire [8:0] num_clk_per_us_new;
//     // (* mark_debug = "true" *) wire fractional_flag_shadow;
//     // (* mark_debug = "true" *) wire fractional_flag_shadow1;
//     // assign num_clk_per_sample = `NUM_CLK_PER_SAMPLE;
//     // assign sampling_rate_mhz = `SAMPLING_RATE_MHZ;
//     // assign num_clk_per_us = `NUM_CLK_PER_US;
//     // assign num_clk_per_us_new = (num_clk_per_sample*sampling_rate_mhz);
//     // assign fractional_flag_shadow = ((`NUM_CLK_PER_SAMPLE*`SAMPLING_RATE_MHZ) != `NUM_CLK_PER_US);
//     // assign fractional_flag_shadow1 = ((num_clk_per_sample*sampling_rate_mhz) != num_clk_per_us);

//     reg [4:0] rden_count;
//     reg [4:0] wren_count;
//     reg rden_reg;
//     reg wren_reg;
//     reg [4:0] counter_top_old;
//     always @( posedge clk )
//     begin
//       if ( rstn == 1'b0 ) begin
//         rden_count <= 0;
//         wren_count <= 0;
//         rden_reg <= 0;
//         wren_reg <= 0;
//         counter_top_old <= 0;
//         trigger_out <= 0;
//       end else begin
//         rden_reg <= rden;
//         wren_reg <= wren;
//         if (rden==1 && rden_reg==0)
//           rden_count <= 0;
//         else
//           rden_count <= rden_count + 1;

//         if (wren==1 && wren_reg==0)
//           wren_count <= 0;
//         else
//           wren_count <= wren_count + 1;
        
//         if (counter == 0) begin // do the check and action when an I/Q is read
//           counter_top_old <= counter_top;
//           trigger_out <= (counter_top_old!=counter_top);
//         end
//       end
//     end
// // ------------end of debug----------

    assign rf_i = rf_iq[    (IQ_DATA_WIDTH-1) : 0];
    assign rf_q = rf_iq[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH];
    assign bb_en = ( (counter==0)|bb_20M_en );
    assign rden = ( (bb_en&(~empty))?1'b1:1'b0 )&fifo_out_en;
    assign wren = wren_selected&fifo_in_en;
    assign rf_iq_valid = ( (rf_iq_valid_delay_sel==1'b0)? rf_iq_valid_reg : rden);
    assign ask_data_from_s_axis = ( ( (bb_en && (~full) && emptyn_from_s_axis ) )&ask_data_from_s_axis_en );
//    assign ask_data_from_adc = (~full);
    assign wifi_rx_iq_fifo_emptyn = (~empty);

    // assign fractional_flag = (num_clk_per_us_new != num_clk_per_us);
    assign fractional_flag = ((`NUM_CLK_PER_SAMPLE*`SAMPLING_RATE_MHZ) != `NUM_CLK_PER_US);
    
    // rate control to make sure ofdm rx get I/Q as uniform as possible
    always @( posedge clk )
    begin
      if ( rstn == 0 ) begin
        counter_top <= `COUNT_TOP_20M; // COUNT_TOP_20M is the expected value when there is no drift between front-end and baseband clock
        counter_top_flag <= 0;
      end else begin
        if (counter == 0) begin // do the check and action when an I/Q is read
          counter_top_flag <= (~counter_top_flag);
          if (fractional_flag) begin
            if (data_count<11) // if less amount of data in fifo, read slower by making counter period longer
              counter_top <= (`COUNT_TOP_20M+1);
            else if (data_count<22) // if normal amount of data in fifo, read at normal speed: baseband 20Msps
              counter_top <= (counter_top_flag?(`COUNT_TOP_20M):(`COUNT_TOP_20M+1));
            else // if more amount of data in fifo, read faster by making counter period shorter
              counter_top <= (`COUNT_TOP_20M);
          end else begin
            if (data_count<11) // if less amount of data in fifo, read slower by making counter period longer
              counter_top <= (`COUNT_TOP_20M+1);
            else if (data_count<22) // if normal amount of data in fifo, read at normal speed: baseband 20Msps
              counter_top <= `COUNT_TOP_20M;
            else // if more amount of data in fifo, read faster by making counter period shorter
              counter_top <= (`COUNT_TOP_20M-1);
          end
        end
      end
    end
    
    // 20MHz en
    always @( posedge clk )
    begin
      if ( rstn == 0 )
        counter <= 0;
      else
        if (counter == counter_top)
          counter <= 4'd0;
        else
          counter <= counter + 1'b1;
    end

    //delay I/Q valid to wifi receiver for loop back mode
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        rf_iq_valid_reg <= 1'd0;
      else
        rf_iq_valid_reg <= rden;
    end

    // I/Q source selection
    always @( fifo_in_sel,bw20_iq_valid,ask_data_from_s_axis,data_from_s_axis,bw20_i0,bw20_q0)
    begin
       case (fifo_in_sel)
          3'b000 : begin
                    data_selected[(IQ_DATA_WIDTH-1) : 0] = bw20_i0;
                    data_selected[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = bw20_q0;
                    wren_selected = bw20_iq_valid;
                   end
          3'b101 : begin
                    data_selected = data_from_s_axis;
                    wren_selected = ask_data_from_s_axis;
                   end
          3'b110 : begin
                    data_selected = data_from_s_axis;
                    wren_selected = ask_data_from_s_axis;
                   end
          3'b111 : begin
                    data_selected = data_from_s_axis;
                    wren_selected = ask_data_from_s_axis;
                   end
          default: begin
                    data_selected = data_from_s_axis;
                    wren_selected = ask_data_from_s_axis;
                   end
       endcase
    end
    
    fifo32_1clk_dep32 fifo32_1clk_dep32_i (
        .CLK(clk),
        .DATAO(rf_iq),
        .DI(data_selected),
        .EMPTY(empty),
        .FULL(full),
        .RDEN(rden),
        .RST(~rstn),
        .WREN(wren),
        .data_count(data_count)
    );
    
	endmodule
