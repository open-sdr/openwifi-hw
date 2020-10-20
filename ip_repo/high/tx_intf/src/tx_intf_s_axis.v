// based on Xilinx module template
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_intf_s_axis #
	(
        parameter integer MAX_NUM_DMA_SYMBOL = 8192,
        parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14,
		parameter integer C_S_AXIS_TDATA_WIDTH	= 64
	)
	(
	    input wire [1:0] tx_queue_idx_indication_from_ps,
	    input wire [1:0] tx_queue_idx,
		input wire endless_mode,
        output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC,
        output wire EMPTYN_TO_ACC,
        input  wire ACC_ASK_DATA,
        output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] data_count0,
        output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] data_count1,
        output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] data_count2,
        output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] data_count3,

        input wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] S_AXIS_NUM_DMA_SYMBOL_raw,
        output wire s_axis_recv_data_from_high,

		input wire  S_AXIS_ACLK,
		input wire  S_AXIS_ARESETN,
		output wire  S_AXIS_TREADY,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		input wire  S_AXIS_TLAST,
		input wire  S_AXIS_TVALID
	);
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

	localparam integer bit_num  = clogb2(MAX_NUM_DMA_SYMBOL);

	localparam [1:0] IDLE = 1'b0,        // This is the initial/idle state 
	                WRITE_FIFO  = 1'b1; // In this state FIFO is written with the

	reg  mst_exec_state;  
	reg [bit_num-1 : 0] S_AXIS_NUM_DMA_SYMBOL;
	
	wire axis_tready0;
	wire axis_tready1;
	wire axis_tready2;
	wire axis_tready3;

	wire fifo_wren0;
	wire fifo_wren1;
	wire fifo_wren2;
	wire fifo_wren3;

	reg  [bit_num-1:0] write_pointer;
	reg  writes_done;
    
	wire EMPTY0;
    wire EMPTY1;
	wire EMPTY2;
    wire EMPTY3;

    wire FULL0;
    wire FULL1;
    wire FULL2;
    wire FULL3;

    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC0;
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC1;
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC2;
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC3;
    wire ACC_ASK_DATA0;
    wire ACC_ASK_DATA1;
    wire ACC_ASK_DATA2;
    wire ACC_ASK_DATA3;

    assign fifo_wren0 = (tx_queue_idx_indication_from_ps==0?(S_AXIS_TVALID && axis_tready0):0);
    assign fifo_wren1 = (tx_queue_idx_indication_from_ps==1?(S_AXIS_TVALID && axis_tready1):0);
    assign fifo_wren2 = (tx_queue_idx_indication_from_ps==2?(S_AXIS_TVALID && axis_tready2):0);
	assign fifo_wren3 = (tx_queue_idx_indication_from_ps==3?(S_AXIS_TVALID && axis_tready3):0);
	assign S_AXIS_TREADY= ( tx_queue_idx_indication_from_ps[1]?(tx_queue_idx_indication_from_ps[0]?axis_tready3:axis_tready2):(tx_queue_idx_indication_from_ps[0]?axis_tready1:axis_tready0) );
	assign axis_tready0 = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL0);
	assign axis_tready1 = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL1);
	assign axis_tready2 = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL2);
	assign axis_tready3 = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL3);

	assign s_axis_recv_data_from_high = mst_exec_state;
	
	assign DATA_TO_ACC =   (tx_queue_idx[1]?(tx_queue_idx[0]?DATA_TO_ACC3:DATA_TO_ACC2):(tx_queue_idx[0]?DATA_TO_ACC1:DATA_TO_ACC0));
    assign EMPTYN_TO_ACC = (tx_queue_idx[1]?(tx_queue_idx[0]?(!EMPTY3):(!EMPTY2)):(tx_queue_idx[0]?(!EMPTY1):(!EMPTY0)));
    assign ACC_ASK_DATA0 = (tx_queue_idx==0?ACC_ASK_DATA:0);
    assign ACC_ASK_DATA1 = (tx_queue_idx==1?ACC_ASK_DATA:0);
    assign ACC_ASK_DATA2 = (tx_queue_idx==2?ACC_ASK_DATA:0);
    assign ACC_ASK_DATA3 = (tx_queue_idx==3?ACC_ASK_DATA:0);

	always @(posedge S_AXIS_ACLK) 
	begin  
		if (!S_AXIS_ARESETN) begin
			mst_exec_state <= IDLE;
			S_AXIS_NUM_DMA_SYMBOL <= 0;
		end else begin
			S_AXIS_NUM_DMA_SYMBOL <= S_AXIS_NUM_DMA_SYMBOL_raw - 1;
			case (mst_exec_state)
			IDLE: 
				if (S_AXIS_TVALID) begin
					mst_exec_state <= WRITE_FIFO;
				end else begin
					mst_exec_state <= IDLE;
				end
			WRITE_FIFO: 
				if (writes_done) begin
					mst_exec_state <= IDLE;
				end else begin
					mst_exec_state <= WRITE_FIFO;
				end
			endcase
		end
	end

	always@(posedge S_AXIS_ACLK)
	begin
	  if ((!S_AXIS_ARESETN) || (writes_done == 1'b1) )
	    begin
	      write_pointer <= 0;
	      writes_done <= 1'b0;
	    end  
	  else
	    if ( write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1) )
	      begin
	        if (fifo_wren0||fifo_wren1)
	          begin
	            write_pointer <= write_pointer + 1;
	            writes_done <= 1'b0;
	          end
	          if ( (write_pointer == S_AXIS_NUM_DMA_SYMBOL && (endless_mode==0) ) || S_AXIS_TLAST )
	            begin
	              writes_done <= 1'b1;
	            end
	      end  
	end

    // fifo64_1clk_dep4k fifo64_1clk_dep4k_i0 ( //queue0
    //     .CLK(S_AXIS_ACLK),
    //     .DATAO(DATA_TO_ACC0),
    //     .DI(S_AXIS_TDATA),
    //     .EMPTY(EMPTY0),
    //     .FULL(FULL0),
    //     .RDEN(ACC_ASK_DATA0),
    //     .RST(!S_AXIS_ARESETN),
    //     .WREN(fifo_wren0),
    //     .data_count(data_count0)
    // );
	xpm_fifo_sync #(
		.DOUT_RESET_VALUE("0"),    // String
		.ECC_MODE("no_ecc"),       // String
		.FIFO_MEMORY_TYPE("auto"), // String
		.FIFO_READ_LATENCY(0),     // DECIMAL
		.FIFO_WRITE_DEPTH(MAX_NUM_DMA_SYMBOL),   // DECIMAL
		.FULL_RESET_VALUE(0),      // DECIMAL
		.PROG_EMPTY_THRESH(10),    // DECIMAL
		.PROG_FULL_THRESH(10),     // DECIMAL
		.RD_DATA_COUNT_WIDTH(bit_num),   // DECIMAL
		.READ_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),      // DECIMAL
		.READ_MODE("fwft"),         // String
		.USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
		.WAKEUP_TIME(0),           // DECIMAL
		.WRITE_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),     // DECIMAL
		.WR_DATA_COUNT_WIDTH(bit_num)    // DECIMAL
	) fifo64_i0 (
		.almost_empty(),
		.almost_full(),
		.data_valid(),
		.dbiterr(),
		.dout(DATA_TO_ACC0),
		.empty(EMPTY0),
		.full(FULL0),
		.overflow(),
		.prog_empty(),
		.prog_full(),
		.rd_data_count(data_count0),
		.rd_rst_busy(),
		.sbiterr(),
		.underflow(),
		.wr_ack(),
		.wr_data_count(),
		.wr_rst_busy(),
		.din(S_AXIS_TDATA),
		.injectdbiterr(),
		.injectsbiterr(),
		.rd_en(ACC_ASK_DATA0),
		.rst(!S_AXIS_ARESETN),
		.sleep(),
		.wr_clk(S_AXIS_ACLK),
		.wr_en(fifo_wren0)
	);

    // fifo64_1clk_dep4k fifo64_1clk_dep4k_i1 ( //queue1
    //     .CLK(S_AXIS_ACLK),
    //     .DATAO(DATA_TO_ACC1),
    //     .DI(S_AXIS_TDATA),
    //     .EMPTY(EMPTY1),
    //     .FULL(FULL1),
    //     .RDEN(ACC_ASK_DATA1),
    //     .RST(!S_AXIS_ARESETN),
    //     .WREN(fifo_wren1),
    //     .data_count(data_count1)
    // );
	xpm_fifo_sync #(
		.DOUT_RESET_VALUE("0"),    // String
		.ECC_MODE("no_ecc"),       // String
		.FIFO_MEMORY_TYPE("auto"), // String
		.FIFO_READ_LATENCY(0),     // DECIMAL
		.FIFO_WRITE_DEPTH(MAX_NUM_DMA_SYMBOL),   // DECIMAL
		.FULL_RESET_VALUE(0),      // DECIMAL
		.PROG_EMPTY_THRESH(10),    // DECIMAL
		.PROG_FULL_THRESH(10),     // DECIMAL
		.RD_DATA_COUNT_WIDTH(bit_num),   // DECIMAL
		.READ_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),      // DECIMAL
		.READ_MODE("fwft"),         // String
		.USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
		.WAKEUP_TIME(0),           // DECIMAL
		.WRITE_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),     // DECIMAL
		.WR_DATA_COUNT_WIDTH(bit_num)    // DECIMAL
	) fifo64_i1 (
		.almost_empty(),
		.almost_full(),
		.data_valid(),
		.dbiterr(),
		.dout(DATA_TO_ACC1),
		.empty(EMPTY1),
		.full(FULL1),
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
		.din(S_AXIS_TDATA),
		.injectdbiterr(),
		.injectsbiterr(),
		.rd_en(ACC_ASK_DATA1),
		.rst(!S_AXIS_ARESETN),
		.sleep(),
		.wr_clk(S_AXIS_ACLK),
		.wr_en(fifo_wren1)
	);

    // fifo64_1clk fifo64_1clk_dep4k_i2 ( //queue2
    //     .CLK(S_AXIS_ACLK),
    //     .DATAO(DATA_TO_ACC2),
    //     .DI(S_AXIS_TDATA),
    //     .EMPTY(EMPTY2),
    //     .FULL(FULL2),
    //     .RDEN(ACC_ASK_DATA2),
    //     .RST(!S_AXIS_ARESETN),
    //     .WREN(fifo_wren2),
    //     .data_count(data_count2)
    // );
	xpm_fifo_sync #(
		.DOUT_RESET_VALUE("0"),    // String
		.ECC_MODE("no_ecc"),       // String
		.FIFO_MEMORY_TYPE("auto"), // String
		.FIFO_READ_LATENCY(0),     // DECIMAL
		.FIFO_WRITE_DEPTH(MAX_NUM_DMA_SYMBOL),   // DECIMAL
		.FULL_RESET_VALUE(0),      // DECIMAL
		.PROG_EMPTY_THRESH(10),    // DECIMAL
		.PROG_FULL_THRESH(10),     // DECIMAL
		.RD_DATA_COUNT_WIDTH(bit_num),   // DECIMAL
		.READ_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),      // DECIMAL
		.READ_MODE("fwft"),         // String
		.USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
		.WAKEUP_TIME(0),           // DECIMAL
		.WRITE_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),     // DECIMAL
		.WR_DATA_COUNT_WIDTH(bit_num)    // DECIMAL
	) fifo64_i2 (
		.almost_empty(),
		.almost_full(),
		.data_valid(),
		.dbiterr(),
		.dout(DATA_TO_ACC2),
		.empty(EMPTY2),
		.full(FULL2),
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
		.din(S_AXIS_TDATA),
		.injectdbiterr(),
		.injectsbiterr(),
		.rd_en(ACC_ASK_DATA2),
		.rst(!S_AXIS_ARESETN),
		.sleep(),
		.wr_clk(S_AXIS_ACLK),
		.wr_en(fifo_wren2)
	);

    // fifo64_1clk fifo64_1clk_dep4k_i3 ( //queue3
    //     .CLK(S_AXIS_ACLK),
    //     .DATAO(DATA_TO_ACC3),
    //     .DI(S_AXIS_TDATA),
    //     .EMPTY(EMPTY3),
    //     .FULL(FULL3),
    //     .RDEN(ACC_ASK_DATA3),
    //     .RST(!S_AXIS_ARESETN),
    //     .WREN(fifo_wren3),
    //     .data_count(data_count3)
    // );
	xpm_fifo_sync #(
		.DOUT_RESET_VALUE("0"),    // String
		.ECC_MODE("no_ecc"),       // String
		.FIFO_MEMORY_TYPE("auto"), // String
		.FIFO_READ_LATENCY(0),     // DECIMAL
		.FIFO_WRITE_DEPTH(MAX_NUM_DMA_SYMBOL),   // DECIMAL
		.FULL_RESET_VALUE(0),      // DECIMAL
		.PROG_EMPTY_THRESH(10),    // DECIMAL
		.PROG_FULL_THRESH(10),     // DECIMAL
		.RD_DATA_COUNT_WIDTH(bit_num),   // DECIMAL
		.READ_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),      // DECIMAL
		.READ_MODE("fwft"),         // String
		.USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
		.WAKEUP_TIME(0),           // DECIMAL
		.WRITE_DATA_WIDTH(C_S_AXIS_TDATA_WIDTH),     // DECIMAL
		.WR_DATA_COUNT_WIDTH(bit_num)    // DECIMAL
	) fifo64_i3 (
		.almost_empty(),
		.almost_full(),
		.data_valid(),
		.dbiterr(),
		.dout(DATA_TO_ACC3),
		.empty(EMPTY3),
		.full(FULL3),
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
		.din(S_AXIS_TDATA),
		.injectdbiterr(),
		.injectsbiterr(),
		.rd_en(ACC_ASK_DATA3),
		.rst(!S_AXIS_ARESETN),
		.sleep(),
		.wr_clk(S_AXIS_ACLK),
		.wr_en(fifo_wren3)
	);

	endmodule
