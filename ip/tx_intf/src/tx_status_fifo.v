// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

`include "tx_intf_pre_def.v"

`ifdef TX_INTF_ENABLE_DBG
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`else
`define DEBUG_PREFIX
`endif

	module tx_status_fifo
	(
	  input wire rstn,
	  input wire clk,
	    
	  input wire slv_reg_rden,
    input wire [4:0] axi_araddr_core,

      input wire tx_try_complete,
      input wire [9:0] num_slot_random,
      input wire [3:0] cw,
      input wire [79:0] tx_status,
      input wire [1:0]  linux_prio,
      input wire [5:0]  pkt_cnt,
      input wire [1:0]  tx_queue_idx,
      input wire [5:0]  bd_wr_idx,
      
      output wire [31:0] tx_status_out1,
      output wire [31:0] tx_status_out2,
      output wire [31:0] tx_status_out3,
      output wire [31:0] tx_status_out4
	);
    reg  empty_reg1;
    reg  empty_reg2;
    reg  empty_reg3;
    reg  empty_reg4;
    wire empty1;
    wire empty2;
    wire empty3;
    wire empty4;
    wire full1;
    wire full2;
    wire full3;
    wire full4;
    wire [31:0] datao1;
    wire [31:0] datao2;
    wire [31:0] datao3;
    wire [31:0] datao4;
    wire [6:0] data_count1;
    wire [6:0] data_count2;
    wire [6:0] data_count3;
    wire [6:0] data_count4;

    reg tx_try_complete_reg;
    `DEBUG_PREFIX reg [3:0] cw_delay; 
    `DEBUG_PREFIX reg [3:0] cw_delay1;

    assign tx_status_out1 = (empty_reg1?32'hFFFFFFFF:datao1);
    assign tx_status_out2 = (empty_reg2?32'h00000000:datao2);
    assign tx_status_out3 = (empty_reg3?32'h00000000:datao3);
    assign tx_status_out4 = (empty_reg4?32'h00000000:datao4);


    wire [3:0] num_retrans;
    wire [11:0] blk_ack_resp_ssn;
    wire [31:0] blk_ack_bitmap_low;
    wire [31:0] blk_ack_bitmap_high;
    assign num_retrans = tx_status[3:0];
    assign blk_ack_resp_ssn = tx_status[15:4];
    assign blk_ack_bitmap_low = tx_status[47:16];
    assign blk_ack_bitmap_high = tx_status[79:48];

    always @(posedge clk)
    if (!rstn) begin                                                                    
        tx_try_complete_reg <= 1'b0;
        empty_reg1 <= 0;
        empty_reg2 <= 0;
        empty_reg3 <= 0;
        empty_reg4 <= 0;
        cw_delay <= 0;
        cw_delay1 <= 0;
    end else begin  
        tx_try_complete_reg <= tx_try_complete;
        empty_reg1 <= empty1;
        empty_reg2 <= empty2;
        empty_reg3 <= empty3;
        empty_reg4 <= empty4;
        cw_delay <= cw ;
        cw_delay1 <= cw_delay + num_slot_random[9];
    end 

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i1 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(datao1),
      .empty(empty1),
      .full(full1),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(data_count1),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din({cw_delay1,num_slot_random[8:0],linux_prio,tx_queue_idx,4'd0,bd_wr_idx,1'd0,num_retrans}),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(slv_reg_rden && (axi_araddr_core == 5'h16)),
      .rst(~rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_try_complete_reg)
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i2 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(datao2),
      .empty(empty2),
      .full(full2),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(data_count2),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din({14'd0,blk_ack_resp_ssn,pkt_cnt}),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(slv_reg_rden && (axi_araddr_core == 5'h17)),
      .rst(~rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_try_complete_reg)
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i3 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(datao3),
      .empty(empty3),
      .full(full3),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(data_count3),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(blk_ack_bitmap_low),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(slv_reg_rden && (axi_araddr_core == 5'h18)),
      .rst(~rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_try_complete_reg)
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i4 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(datao4),
      .empty(empty4),
      .full(full4),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(data_count4),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(blk_ack_bitmap_high),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(slv_reg_rden && (axi_araddr_core == 5'h19)),
      .rst(~rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_try_complete_reg)
    );

	endmodule
