
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module rx_iq_intf #
	(
	    parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
        parameter integer IQ_DATA_WIDTH	=     16
	)
	(
	    input wire rstn,
	    input wire clk,
	    
	    input wire [(IQ_DATA_WIDTH-1):0] bw20_i0,
      input wire [(IQ_DATA_WIDTH-1):0] bw20_q0,
      input wire [(IQ_DATA_WIDTH-1):0] bw20_i1,
      input wire [(IQ_DATA_WIDTH-1):0] bw20_q1,
	    input wire bw20_iq_valid,

      input wire [(IQ_DATA_WIDTH-1):0] bw02_i0,
      input wire [(IQ_DATA_WIDTH-1):0] bw02_q0,
      input wire [(IQ_DATA_WIDTH-1):0] bw02_i1,
      input wire [(IQ_DATA_WIDTH-1):0] bw02_q1,
      input wire bw02_iq_valid,
        
      input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] data_from_s_axis,
      input wire  emptyn_from_s_axis,
      output wire ask_data_from_s_axis,
      output wire ask_data_from_adc,

      input wire ask_data_from_s_axis_en,
      input wire fifo_in_en,
      input wire fifo_out_en,
      input wire bb_20M_en,
      input wire fifo_out_sel,
      input wire [2:0] fifo_in_sel,
        
        // to wifi receiver
	    output wire [(IQ_DATA_WIDTH-1) : 0] rf_i,
      output wire [(IQ_DATA_WIDTH-1) : 0] rf_q,
      output wire rf_iq_valid,
      input  wire rf_iq_valid_delay_sel,
        
        // to m_axis for loop back test
      output wire [(C_S00_AXIS_TDATA_WIDTH-1):0] rf_iq,
        
      output wire wifi_rx_iq_fifo_emptyn
	);
    
    (* mark_debug = "true" *) wire empty;
    (* mark_debug = "true" *) wire full;
    wire rden;
    wire wren;
    reg wren_selected;
    wire bb_en;
    wire [5:0] data_count;
    reg [(C_S00_AXIS_TDATA_WIDTH-1):0] data_selected;
    reg [3:0] counter;
    reg [3:0] counter_top;
    reg rf_iq_valid_reg;
    
    assign rf_i = (fifo_out_sel==1'b0)?rf_iq[(IQ_DATA_WIDTH-1) : 0]:rf_iq[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)];
    assign rf_q = (fifo_out_sel==1'b0)?rf_iq[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH]:rf_iq[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)];
    assign bb_en = ( (counter==0)|bb_20M_en );
    assign rden = ( (bb_en&(~empty))?1'b1:1'b0 )&fifo_out_en;
    assign wren = wren_selected&fifo_in_en;
    assign rf_iq_valid = ( (rf_iq_valid_delay_sel==1'b0)? rf_iq_valid_reg : rden);
    assign ask_data_from_s_axis = ( ( (bb_en && (~full) && emptyn_from_s_axis ) )&ask_data_from_s_axis_en );
    assign ask_data_from_adc = (~full);
    assign wifi_rx_iq_fifo_emptyn = (~empty);
    
    // rate control
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            counter_top <= 4'd9;
        end 
      else
        begin
            if (data_count<6'd12 && counter<4'd7)
              begin
                counter_top <= 4'd9;
              end
            else if (data_count>6'd20 && counter<4'd7)
              begin
                counter_top <=4'd8;
              end
            else
              begin
                counter_top <= counter_top;
              end
        end
    end
    
    // 20MHz en from 200MHz clock
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            counter <= 4'd0;
        end 
      else
        begin
            if (counter == counter_top)
              begin
                counter <= 4'd0;
              end
            else
              begin
                counter <= counter + 1'b1;
              end
        end
    end

    // data selection
    always @( fifo_in_sel,bw20_iq_valid,bw02_iq_valid,ask_data_from_s_axis,data_from_s_axis,bw20_i0,bw20_q0,bw20_i1,bw20_q1, bw02_i0,bw02_q0, bw02_i1,bw02_q1)//, bw02_i2,bw02_q2, bw02_i3,bw02_q3, bw02_i4,bw02_q4, bw02_i5,bw02_q5, bw02_i6,bw02_q6, bw02_i7,bw02_q7)
    begin
       case (fifo_in_sel)
          3'b000 : begin
                        data_selected[(IQ_DATA_WIDTH-1) : 0] = bw20_i0;
                        data_selected[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = bw20_q0;
                        data_selected[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = bw20_i1;
                        data_selected[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] =  bw20_q1;
                        wren_selected = bw20_iq_valid;
                   end
          3'b001 : begin
                        data_selected[(IQ_DATA_WIDTH-1) : 0] = bw02_i0;
                        data_selected[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = bw02_q0;
                        data_selected[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = bw02_i1;
                        data_selected[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] =  bw02_q1;
                        wren_selected = bw02_iq_valid;
                   end
          3'b010 : begin
                        data_selected[(IQ_DATA_WIDTH-1) : 0] = bw02_i0;
                        data_selected[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = bw02_q0;
                        data_selected[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = bw02_i1;
                        data_selected[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] =  bw02_q1;
                        wren_selected = bw02_iq_valid;
                   end
          3'b011 : begin
                        data_selected[(IQ_DATA_WIDTH-1) : 0] = bw02_i0;
                        data_selected[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = bw02_q0;
                        data_selected[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = bw02_i1;
                        data_selected[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] =  bw02_q1;
                        wren_selected = bw02_iq_valid;
                   end
          3'b100 : begin
                        data_selected[(IQ_DATA_WIDTH-1) : 0] = bw02_i0;
                        data_selected[((2*IQ_DATA_WIDTH)-1) : IQ_DATA_WIDTH] = bw02_q0;
                        data_selected[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = bw02_i1;
                        data_selected[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] =  bw02_q1;
                        wren_selected = bw02_iq_valid;
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
    
    fifo64_1clk_dep32 fifo64_1clk_dep32_i (
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
    
    //control output to wifi receiver
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            rf_iq_valid_reg <= 1'd0;
        end 
      else
        begin
            rf_iq_valid_reg <= rden;
        end
    end    

	endmodule
