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
    
        input wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] S_AXIS_NUM_DMA_SYMBOL,
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
	wire axis_tready0;
	wire axis_tready1;
	wire fifo_wren0;
	wire fifo_wren1;
	reg  [bit_num-1:0] write_pointer;
	reg  writes_done;
    wire EMPTY0;
    wire FULL0;
    wire EMPTY1;
    wire FULL1;
    
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC0;
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC1;
    wire ACC_ASK_DATA0;
    wire ACC_ASK_DATA1;
    
    assign fifo_wren0 = (tx_queue_idx_indication_from_ps[0]==0?(S_AXIS_TVALID && axis_tready0):0);
    assign fifo_wren1 = (tx_queue_idx_indication_from_ps[0]==1?(S_AXIS_TVALID && axis_tready1):0);
	assign S_AXIS_TREADY	= (tx_queue_idx_indication_from_ps[0]==0?axis_tready0:axis_tready1);
	assign axis_tready0 = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL0);
	assign axis_tready1 = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL1);

	assign s_axis_recv_data_from_high = mst_exec_state;
	
	assign DATA_TO_ACC =   (tx_queue_idx[0]==0?DATA_TO_ACC0:DATA_TO_ACC1);
    assign EMPTYN_TO_ACC = (tx_queue_idx[0]==0?(!EMPTY0):(!EMPTY1));
    assign ACC_ASK_DATA0 = (tx_queue_idx[0]==0?ACC_ASK_DATA:0);
    assign ACC_ASK_DATA1 = (tx_queue_idx[0]==1?ACC_ASK_DATA:0);

	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	          if (S_AXIS_TVALID)
	            begin
	              mst_exec_state <= WRITE_FIFO;
	            end
	          else
	            begin
	              mst_exec_state <= IDLE;
	            end
	      WRITE_FIFO: 
	        if (writes_done)
	          begin
	            mst_exec_state <= IDLE;
	          end
	        else
	          begin
	            mst_exec_state <= WRITE_FIFO;
	          end
	    endcase
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

    fifo64_1clk fifo64_1clk_i0 ( //queue0
        .CLK(S_AXIS_ACLK),
        .DATAO(DATA_TO_ACC0),
        .DI(S_AXIS_TDATA),
        .EMPTY(EMPTY0),
        .FULL(FULL0),
        .RDEN(ACC_ASK_DATA0),
        .RST(!S_AXIS_ARESETN),
        .WREN(fifo_wren0),
        .data_count(data_count0)
    );

    fifo64_1clk fifo64_1clk_i1 ( //queue1
        .CLK(S_AXIS_ACLK),
        .DATAO(DATA_TO_ACC1),
        .DI(S_AXIS_TDATA),
        .EMPTY(EMPTY1),
        .FULL(FULL1),
        .RDEN(ACC_ASK_DATA1),
        .RST(!S_AXIS_ARESETN),
        .WREN(fifo_wren1),
        .data_count(data_count1)
    );

	endmodule
