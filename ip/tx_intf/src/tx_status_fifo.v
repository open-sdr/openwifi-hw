// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_status_fifo
	(
	  input wire rstn,
	  input wire clk,
	    
	  input wire slv_reg_rden,
      input wire [4:0] axi_araddr_core,

      input wire tx_try_complete,
      input wire [9:0] num_slot_random,
      input wire [3:0] cw,
      input wire [4:0] tx_status,
      input wire [1:0]  linux_prio,
      input wire [1:0]  tx_queue_idx,
      input wire [9:0]  tx_pkt_sn,
    //   input wire [12:0] s_axis_fifo_data_count0,
    //   input wire [12:0] s_axis_fifo_data_count1,
    //   input wire [12:0] s_axis_fifo_data_count2,
    //   input wire [12:0] s_axis_fifo_data_count3,
      
      output wire [31:0] tx_status_out
	);
    reg  empty_reg;
    wire empty;
    wire full;
    wire rden;
    wire [31:0] datao;
    wire [6:0] data_count;
    // wire [12:0] queue_data_count;

    reg tx_try_complete_reg;
    `DEBUG_PREFIX reg [3:0] cw_delay; 
    `DEBUG_PREFIX reg [3:0] cw_delay1;

    assign rden = ((axi_araddr_core==5'h16)?slv_reg_rden:0);
    assign tx_status_out = (empty_reg?32'hFFFFFFFF:datao);
    // assign queue_data_count = (tx_queue_idx[1]?(tx_queue_idx[0]?s_axis_fifo_data_count3:s_axis_fifo_data_count2):(tx_queue_idx[0]?s_axis_fifo_data_count1:s_axis_fifo_data_count0));

    always @(posedge clk)
    if (!rstn) begin                                                                    
        tx_try_complete_reg <= 1'b0;
        empty_reg <= 0;
        cw_delay <= 0;
        cw_delay1 <= 0;
    end else begin  
        tx_try_complete_reg <= tx_try_complete;
        empty_reg <= empty;
        cw_delay <= cw ;
        cw_delay1 <= cw_delay + num_slot_random[9];
    end 

    fifo32_1clk_dep64 fifo32_1clk_dep64_i (
        .CLK(clk),
        .DATAO(datao),
        .DI({cw_delay1,num_slot_random[8:0],linux_prio,tx_queue_idx,tx_pkt_sn,tx_status}), // highest MSB logs cw exponent + MSB of num_slot_random
        .EMPTY(empty),
        .FULL(full),
        .RDEN(rden),
        .RST(~rstn),
        .WREN(tx_try_complete_reg),
        .data_count(data_count)
    );

	endmodule
