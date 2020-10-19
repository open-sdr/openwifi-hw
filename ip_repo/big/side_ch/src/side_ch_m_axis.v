// based on Xilinx module template
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module side_ch_m_axis #
	(
		// parameter integer START_COUNT_CFG = 0,
		// parameter integer WAIT_COUNT_BITS = 5,
		parameter integer MAX_NUM_DMA_SYMBOL = 8192,
		parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14,

		parameter integer C_M_AXIS_TDATA_WIDTH	= 64
	)
	(
		input wire m_axis_endless_mode,
		input wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] M_AXIS_NUM_DMA_SYMBOL,

		input wire m_axis_start_1trans,

        input wire [C_M_AXIS_TDATA_WIDTH-1 : 0] data_to_ps,
        input wire data_to_ps_valid,
        output wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] m_axis_data_count,
        output wire fulln_to_pl,
        
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);
	
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                                                                          
	                                                                                     
	localparam integer bit_num  = clogb2(MAX_NUM_DMA_SYMBOL);      
                                                                   
	localparam [1:0] IDLE = 2'b00,        // This is the initial/idle state               
	                INIT_COUNTER  = 2'b01, // This state initializes the counter, ones   
	                SEND_STREAM   = 2'b10; // In this state the                          

	reg [1:0] mst_exec_state;                                                            
	reg [bit_num-1:0] read_pointer;                                                      
	// reg [WAIT_COUNT_BITS-1 : 0] 	count;
	wire  	axis_tvalid;
	wire  	axis_tlast;
    reg     axis_tlast_delay;
	wire  	tx_en;
	reg     tx_done;
	wire    EMPTY;
    reg       init_txn_ff;
    wire      init_txn_pulse;
    wire      FULL;
    
    assign fulln_to_pl     = (~FULL);
	assign M_AXIS_TVALID	= axis_tvalid;
	assign M_AXIS_TLAST	    = axis_tlast&&(!axis_tlast_delay);
	assign M_AXIS_TSTRB	    = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

	assign axis_tvalid = ((mst_exec_state == SEND_STREAM) && (read_pointer <= M_AXIS_NUM_DMA_SYMBOL || (m_axis_endless_mode==1) ) && (!EMPTY) );
	assign axis_tlast = ( (read_pointer == M_AXIS_NUM_DMA_SYMBOL) && tx_en ) && (m_axis_endless_mode==0);                                
	assign tx_en = ( M_AXIS_TREADY && axis_tvalid );   

    assign init_txn_pulse    = (!init_txn_ff) && m_axis_start_1trans;
    
    //Generate a pulse to initiate AXI transaction.
    always @(posedge M_AXIS_ACLK)                                              
      begin                                                                        
        // Initiates AXI transaction delay    
        if (!M_AXIS_ARESETN)                                                   
          begin                                                                    
            init_txn_ff <= 1'b0;                                                   
            //init_txn_ff2 <= 1'b0;                                                   
          end                                                                               
        else                                                                       
          begin  
            init_txn_ff <= m_axis_start_1trans;
          end                                                                      
      end     
      
	// Control state machine implementation                             
	always @(posedge M_AXIS_ACLK)                                             
	begin                                                                     
	  if (!M_AXIS_ARESETN)                                                    
	  // Synchronous reset (active low)                                       
	    begin                                                                 
	      mst_exec_state <= IDLE;                                             
	    //   count    <= 0;                                                      
	    end                                                                   
	  else                                                                    
	    case (mst_exec_state)                                                 
	      IDLE:                                                               
            if ( init_txn_pulse )
              begin
                  mst_exec_state  <= INIT_COUNTER;
              end
            else
              begin
                  mst_exec_state  <= IDLE;
              end                           

	      INIT_COUNTER:
		  	mst_exec_state  <= SEND_STREAM;
	        // if ( (count == START_COUNT_CFG) )                               
	        //   begin                                                           
	        //     mst_exec_state  <= SEND_STREAM;
	        //     count    <= 0;                               
	        //   end                                                             
	        // else                                                              
	        //   begin                                                           
	        //     count <= count + 1;                                           
	        //     mst_exec_state  <= INIT_COUNTER;                              
	        //   end                                                             
	                                                                          
	      SEND_STREAM:                                                        
	        if (tx_done)                                                      
	          begin                                                           
	            mst_exec_state <= IDLE;
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state <= SEND_STREAM;                                
	          end                                                             
	    endcase                                                               
	end                                                                       

	// Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
    // to match the latency of M_AXIS_TDATA                                                        
    always @(posedge M_AXIS_ACLK)                                                                  
    begin                                                                                          
      if (!M_AXIS_ARESETN || init_txn_pulse)                                                                         
        begin                                                                                      
          axis_tlast_delay <= 1'b0;                                                     
        end                                                                                        
      else                                                                                         
        begin                                                                                      
          axis_tlast_delay <= axis_tlast;
        end                                                                                        
    end   

	always@(posedge M_AXIS_ACLK)                                               
	begin                                                                            
	  if ( (!M_AXIS_ARESETN) || init_txn_pulse )
	    begin                                                                        
	      read_pointer <= 0;                                                         
	      tx_done <= 1'b0;                                                           
	    end                                                                          
	  else                                                                           
	    if ( read_pointer <= M_AXIS_NUM_DMA_SYMBOL || (m_axis_endless_mode==1) )                                
	      begin                                                                      
	        if (tx_en)                                                               
	          begin                                                                  
	            read_pointer <= read_pointer + 1;                                    
	            tx_done <= 1'b0;                                                     
	          end                                                                    
	      end                                                                        
	    else if ( read_pointer == (M_AXIS_NUM_DMA_SYMBOL + 1) )                             
	      begin                                                                      
	        tx_done <= 1'b1;                                                         
	      end                                                                        
	end                                                                              

    // fifo64_1clk fifo64_1clk_i (
    //     .CLK(M_AXIS_ACLK),
    //     .DATAO(M_AXIS_TDATA),
    //     .DI(data_to_ps),
    //     .EMPTY(EMPTY),
    //     .FULL(FULL),
    //     .RDEN(tx_en),
    //     .RST(!M_AXIS_ARESETN),
    //     .WREN(data_to_ps_valid),
    //     .data_count(m_axis_data_count)
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
		.READ_DATA_WIDTH(C_M_AXIS_TDATA_WIDTH),      // DECIMAL
		.READ_MODE("fwft"),         // String
		.USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
		.WAKEUP_TIME(0),           // DECIMAL
		.WRITE_DATA_WIDTH(C_M_AXIS_TDATA_WIDTH),     // DECIMAL
		.WR_DATA_COUNT_WIDTH(bit_num)    // DECIMAL
	) m_axis_xpm_fifo_sync0 (
		.almost_empty(),
		.almost_full(),
		.data_valid(),
		.dbiterr(),
		.dout(M_AXIS_TDATA),
		.empty(EMPTY),
		.full(FULL),
		.overflow(),
		.prog_empty(),
		.prog_full(),
		.rd_data_count(m_axis_data_count),
		.rd_rst_busy(),
		.sbiterr(),
		.underflow(),
		.wr_ack(),
		.wr_data_count(),
		.wr_rst_busy(),
		.din(data_to_ps),
		.injectdbiterr(),
		.injectsbiterr(),
		.rd_en(tx_en),
		.rst(!M_AXIS_ARESETN),
		.sleep(),
		.wr_clk(M_AXIS_ACLK),
		.wr_en(data_to_ps_valid)
	);

	endmodule
