// based on Xilinx module template
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module rx_intf_s_axis #
	(
        parameter integer MAX_NUM_DMA_SYMBOL = 8192,
        parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14,
		parameter integer C_S_AXIS_TDATA_WIDTH	= 64
	)
	(
		input wire endless_mode,
    output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] DATA_TO_ACC,
    output wire EMPTYN_TO_ACC,
    input  wire ACC_ASK_DATA,
    output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] data_count,
    
    input wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] S_AXIS_NUM_DMA_SYMBOL,

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

	wire  	axis_tready;
	reg mst_exec_state;  
	wire fifo_wren;
	reg [bit_num-1:0] write_pointer;
	reg writes_done;
    wire EMPTY;
    wire FULL;
    
    assign fifo_wren = S_AXIS_TVALID && axis_tready;
    assign EMPTYN_TO_ACC = (!EMPTY);
	assign S_AXIS_TREADY	= axis_tready;
	assign axis_tready = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (endless_mode==1)) ) && (!FULL);

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
	        if (fifo_wren)
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

    fifo64_1clk_dep512 fifo64_1clk_de512_i (
        .CLK(S_AXIS_ACLK),
        .DATAO(DATA_TO_ACC),
        .DI(S_AXIS_TDATA),
        .EMPTY(EMPTY),
        .FULL(FULL),
        .RDEN(ACC_ASK_DATA),
        .RST(!S_AXIS_ARESETN),
        .WREN(fifo_wren),
        .data_count(data_count)
    );

	endmodule
