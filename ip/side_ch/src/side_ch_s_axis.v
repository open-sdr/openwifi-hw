// based on Xilinx module template
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module side_ch_s_axis #
	(
		parameter integer C_S_AXIS_TDATA_WIDTH	= 64,
        parameter integer MAX_NUM_DMA_SYMBOL = 8192,
        parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14
	)
	(
		input wire s_axis_endless_mode,
        input wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] S_AXIS_NUM_DMA_SYMBOL,

		output wire s_axis_state,

        output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] data_to_pl,
        input  wire pl_ask_data,
        output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] s_axis_data_count,
        output wire emptyn_to_pl,

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
	
	wire axis_tready;
	wire fifo_wren;

	reg  [bit_num-1:0] write_pointer;
	reg  writes_done;
    
	wire EMPTY;
    wire FULL;

	assign s_axis_state = mst_exec_state;
    assign fifo_wren = (S_AXIS_TVALID && axis_tready);
	assign S_AXIS_TREADY= axis_tready;
	assign axis_tready = ( (mst_exec_state == WRITE_FIFO) && (write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (s_axis_endless_mode==1)) ) && (!FULL);
    assign emptyn_to_pl = (!EMPTY);

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
	    if ( write_pointer <= S_AXIS_NUM_DMA_SYMBOL || (s_axis_endless_mode==1) )
	      begin
	        if (fifo_wren)
	          begin
	            write_pointer <= write_pointer + 1;
	            writes_done <= 1'b0;
	          end
	          if ( (write_pointer == S_AXIS_NUM_DMA_SYMBOL && (s_axis_endless_mode==0) ) || S_AXIS_TLAST )
	            begin
	              writes_done <= 1'b1;
	            end
	      end  
	end

    fifo64_1clk_dep512 fifo64_1clk_dep512_i (
        .CLK(S_AXIS_ACLK),
        .DATAO(data_to_pl),
        .DI(S_AXIS_TDATA),
        .EMPTY(EMPTY),
        .FULL(FULL),
        .RDEN(pl_ask_data),
        .RST(!S_AXIS_ARESETN),
        .WREN(fifo_wren),
        .data_count(s_axis_data_count)
    );

	endmodule
