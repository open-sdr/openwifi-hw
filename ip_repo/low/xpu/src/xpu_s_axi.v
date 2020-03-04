// based on Xilinx module template
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module xpu_s_axi #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG0,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG1,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG2,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG3,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG4,/*
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG5,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG6,*/
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG7,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG8,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG9,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG10,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG11,/*
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG12,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG13,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG14,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG15,*/
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG16,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG17,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG18,
        output wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG19,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG20,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG21,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG22,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG23,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG24,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG25,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG26,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG27,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG28,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG29,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG30,
        output  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG31,
        //input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG32,
        //input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG33,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG34,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG35,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG36,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG37,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG38,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG39,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG40,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG41,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG42,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG43,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG44,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG45,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG46,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG47,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG48,
        // input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG49,
        //input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG50,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG51,/*
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG52,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG53,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG54,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG55,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG56,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG57,*/
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG58,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG59,
        //input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG60,
        //input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG61,
        //input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG62,
        input  wire [C_S_AXI_DATA_WIDTH-1:0] SLV_REG63,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 5;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 64
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg16;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg17;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg18;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg19;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg20;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg21;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg22;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg23;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg24;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg25;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg26;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg27;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg28;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg29;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg30;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg31;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg32;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg33;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg34;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg35;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg36;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg37;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg38;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg39;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg40;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg41;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg42;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg43;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg44;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg45;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg46;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg47;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg48;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg49;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg50;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg51;/*
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg52;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg53;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg54;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg55;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg56;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg57;*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg58;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg59;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg60;
	// reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg61;
	//reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg62;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg63;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	
    assign SLV_REG0 = slv_reg0;
    assign SLV_REG1 = slv_reg1;
    assign SLV_REG2 = slv_reg2;
    assign SLV_REG3 = slv_reg3;
    assign SLV_REG4 = slv_reg4;
    //assign SLV_REG5 = slv_reg5;
    //assign SLV_REG6 = slv_reg6;
    assign SLV_REG7 = slv_reg7;
    assign SLV_REG8 = slv_reg8;
    assign SLV_REG9 = slv_reg9;
    assign SLV_REG10 = slv_reg10;
    assign SLV_REG11 = slv_reg11;
    //assign SLV_REG12 = slv_reg12;
    //assign SLV_REG13 = slv_reg13;
    //assign SLV_REG14 = slv_reg14;
    //assign SLV_REG15 = slv_reg15;
    assign SLV_REG16 = slv_reg16;
    assign SLV_REG17 = slv_reg17;
    assign SLV_REG18 = slv_reg18;
    assign SLV_REG19 = slv_reg19;
    assign SLV_REG20 = slv_reg20;
    assign SLV_REG21 = slv_reg21;
    assign SLV_REG22 = slv_reg22;
    assign SLV_REG23 = slv_reg23;
    assign SLV_REG24 = slv_reg24;
    assign SLV_REG25 = slv_reg25;
    assign SLV_REG26 = slv_reg26;
    assign SLV_REG27 = slv_reg27;
    assign SLV_REG28 = slv_reg28;
    assign SLV_REG29 = slv_reg29;
    assign SLV_REG30 = slv_reg30;
    assign SLV_REG31 = slv_reg31;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 32'h0;
	      slv_reg1 <= 32'h0;
	      slv_reg2 <= 32'h0;
	      slv_reg3 <= 32'h0;
	      slv_reg4 <= 32'h0;
	      //slv_reg5 <= 32'h0;
	      //slv_reg6 <= 32'h0;
	      slv_reg7 <= 32'h0;
	      slv_reg8 <= 32'h0;
	      slv_reg9 <= 32'h0;
	      slv_reg10 <= 32'h0;
	      slv_reg11 <= 32'h0;
	      //slv_reg12 <= 32'h0;
	      //slv_reg13 <= 32'h0;
	      //slv_reg14 <= 32'h0;
	      //slv_reg15 <= 32'h0;
	      slv_reg16 <= 32'h0;
	      slv_reg17 <= 32'h0;
	      slv_reg18 <= 32'h0;
	      slv_reg19 <= 32'h0;
	      slv_reg20 <= 32'h0;
	      slv_reg21 <= 32'h0;
	      slv_reg22 <= 32'h0;
	      slv_reg23 <= 32'h0;
	      slv_reg24 <= 32'h0;
	      slv_reg25 <= 32'h0;
	      slv_reg26 <= 32'h0;
	      slv_reg27 <= 32'h0;
	      slv_reg28 <= 32'h0;
	      slv_reg29 <= 32'h0;
	      slv_reg30 <= 32'h0;
	      slv_reg31 <= 32'h0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          6'h00:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h01:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h02:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h03:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          6'h04:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  /*
	          6'h05:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 5
	                slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h06:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 6
	                slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  */
	          6'h07:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 7
	                slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h08:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 8
	                slv_reg8[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h09:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 9
	                slv_reg9[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h0A:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 10
	                slv_reg10[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h0B:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 11
	                slv_reg11[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  /*
	          6'h0C:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 12
	                slv_reg12[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h0D:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 13
	                slv_reg13[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h0E:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 14
	                slv_reg14[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h0F:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 15
	                slv_reg15[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  */
	          6'h10:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 16
	                slv_reg16[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h11:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 17
	                slv_reg17[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          6'h12:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 18
	                slv_reg18[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          6'h13:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 19
	                slv_reg19[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h14:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 10
	                slv_reg20[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h15:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 11
	                slv_reg21[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h16:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 12
	                slv_reg22[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h17:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 13
	                slv_reg23[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h18:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 14
	                slv_reg24[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h19:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 15
	                slv_reg25[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          6'h1A:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 16
	                slv_reg26[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          6'h1B:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 17
	                slv_reg27[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h1C:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 18
	                slv_reg28[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h1D:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 19
	                slv_reg29[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h1E:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 19
	                slv_reg30[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          6'h1F:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 19
	                slv_reg31[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                      slv_reg4 <= slv_reg4;
	                      //slv_reg5 <= slv_reg5;
	                      //slv_reg6 <= slv_reg6;
	                      slv_reg7 <= slv_reg7;
	                      slv_reg8 <= slv_reg8;
	                      slv_reg9 <= slv_reg9;
	                      slv_reg10 <= slv_reg10;
	                      slv_reg11 <= slv_reg11;
	                      //slv_reg12 <= slv_reg12;
	                      //slv_reg13 <= slv_reg13;
	                      //slv_reg14 <= slv_reg14;
	                      //slv_reg15 <= slv_reg15;
	                      slv_reg16 <= slv_reg16;
	                      slv_reg17 <= slv_reg17;
	                      slv_reg18 <= slv_reg18;
	                      slv_reg19 <= slv_reg19;
	                      slv_reg20 <= slv_reg20;
	                      slv_reg21 <= slv_reg21;
	                      slv_reg22 <= slv_reg22;
	                      slv_reg23 <= slv_reg23;
	                      slv_reg24 <= slv_reg24;
	                      slv_reg25 <= slv_reg25;
	                      slv_reg26 <= slv_reg26;
	                      slv_reg27 <= slv_reg27;
	                      slv_reg28 <= slv_reg28;
	                      slv_reg29 <= slv_reg29;
	                      slv_reg30 <= slv_reg30;
	                      slv_reg31 <= slv_reg31;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        6'h00   : reg_data_out <= slv_reg0;
	        6'h01   : reg_data_out <= slv_reg1;
	        6'h02   : reg_data_out <= slv_reg2;
	        6'h03   : reg_data_out <= slv_reg3;
	        6'h04   : reg_data_out <= slv_reg4;/*
	        6'h05   : reg_data_out <= slv_reg5;
	        6'h06   : reg_data_out <= slv_reg6;*/
	        6'h07   : reg_data_out <= slv_reg7;
	        6'h08   : reg_data_out <= slv_reg8;
	        6'h09   : reg_data_out <= slv_reg9;
	        6'h0A   : reg_data_out <= slv_reg10;
	        6'h0B   : reg_data_out <= slv_reg11;/*
	        6'h0C   : reg_data_out <= slv_reg12;
	        6'h0D   : reg_data_out <= slv_reg13;
	        6'h0E   : reg_data_out <= slv_reg14;
	        6'h0F   : reg_data_out <= slv_reg15;*/
	        6'h10   : reg_data_out <= slv_reg16;
	        6'h11   : reg_data_out <= slv_reg17;
	        6'h12   : reg_data_out <= slv_reg18;
	        6'h13   : reg_data_out <= slv_reg19;
	        6'h14   : reg_data_out <= slv_reg20;
	        6'h15   : reg_data_out <= slv_reg21;
	        6'h16   : reg_data_out <= slv_reg22;
	        6'h17   : reg_data_out <= slv_reg23;
	        6'h18   : reg_data_out <= slv_reg24;
	        6'h19   : reg_data_out <= slv_reg25;
	        6'h1A   : reg_data_out <= slv_reg26;
	        6'h1B   : reg_data_out <= slv_reg27;
	        6'h1C   : reg_data_out <= slv_reg28;
	        6'h1D   : reg_data_out <= slv_reg29;
	        6'h1E   : reg_data_out <= slv_reg30;
	        6'h1F   : reg_data_out <= slv_reg31;
	        //6'h20   : reg_data_out <= slv_reg32;
	        //6'h21   : reg_data_out <= slv_reg33;
	        // 6'h22   : reg_data_out <= slv_reg34;
	        // 6'h23   : reg_data_out <= slv_reg35;
	        // 6'h24   : reg_data_out <= slv_reg36;
	        // 6'h25   : reg_data_out <= slv_reg37;
	        // 6'h26   : reg_data_out <= slv_reg38;
	        // 6'h27   : reg_data_out <= slv_reg39;
	        // 6'h28   : reg_data_out <= slv_reg40;
	        // 6'h29   : reg_data_out <= slv_reg41;
	        // 6'h2A   : reg_data_out <= slv_reg42;
	        // 6'h2B   : reg_data_out <= slv_reg43;
	        // 6'h2C   : reg_data_out <= slv_reg44;
	        // 6'h2D   : reg_data_out <= slv_reg45;
	        // 6'h2E   : reg_data_out <= slv_reg46;
	        // 6'h2F   : reg_data_out <= slv_reg47;
	        // 6'h30   : reg_data_out <= slv_reg48;
	        // 6'h31   : reg_data_out <= slv_reg49;
	        //6'h32   : reg_data_out <= slv_reg50;
	        6'h33   : reg_data_out <= slv_reg51;/*
	        6'h34   : reg_data_out <= slv_reg52;
	        6'h35   : reg_data_out <= slv_reg53;
	        6'h36   : reg_data_out <= slv_reg54;
	        6'h37   : reg_data_out <= slv_reg55;
	        6'h38   : reg_data_out <= slv_reg56;
	        6'h39   : reg_data_out <= slv_reg57;*/
	        6'h3A   : reg_data_out <= slv_reg58;
	        6'h3B   : reg_data_out <= slv_reg59;
	        //6'h3C   : reg_data_out <= slv_reg60;
	        //6'h3D   : reg_data_out <= slv_reg61;
	        //6'h3E   : reg_data_out <= slv_reg62;
	        6'h3F   : reg_data_out <= slv_reg63;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          // slv_reg20 <= 32'h0;
          // slv_reg21 <= 32'h0;
          // slv_reg22 <= 32'h0;
          // slv_reg23 <= 32'h0;
          // slv_reg24 <= 32'h0;
          // slv_reg25 <= 32'h0;
          // slv_reg26 <= 32'h0;
          // slv_reg27 <= 32'h0;
          // slv_reg28 <= 32'h0;
          // slv_reg29 <= 32'h0;
          // slv_reg30 <= 32'h0;
          // slv_reg31 <= 32'h0;

          //slv_reg32 <= 32'h0;
          //slv_reg33 <= 32'h0;
        //   slv_reg34 <= 32'h0;
        //   slv_reg35 <= 32'h0;
        //   slv_reg36 <= 32'h0;
        //   slv_reg37 <= 32'h0;
        //   slv_reg38 <= 32'h0;
        //   slv_reg39 <= 32'h0;
        //   slv_reg40 <= 32'h0;
        //   slv_reg41 <= 32'h0;
        //   slv_reg42 <= 32'h0;
        //   slv_reg43 <= 32'h0;
        //   slv_reg44 <= 32'h0;
        //   slv_reg45 <= 32'h0;
        //   slv_reg46 <= 32'h0;
        //   slv_reg47 <= 32'h0;
        //   slv_reg48 <= 32'h0;
        //   slv_reg49 <= 32'h0;
          //slv_reg50 <= 32'h0;
          slv_reg51 <= 32'h0;/*
          slv_reg52 <= 32'h0;
          slv_reg53 <= 32'h0;
          slv_reg54 <= 32'h0;
          slv_reg55 <= 32'h0;
          slv_reg56 <= 32'h0;
          slv_reg57 <= 32'h0;*/
          slv_reg58 <= 32'h0;
          slv_reg59 <= 32'h0;
          //slv_reg60 <= 32'h0;
          //slv_reg61 <= 32'h0;
          //slv_reg62 <= 32'h0;
          slv_reg63 <= 32'h0;
        end 
      else
        begin    
          // slv_reg20 <= SLV_REG20;
          // slv_reg21 <= SLV_REG21;
          // slv_reg22 <= SLV_REG22;
          // slv_reg23 <= SLV_REG23;
          // slv_reg24 <= SLV_REG24;
          // slv_reg25 <= SLV_REG25;
          // slv_reg26 <= SLV_REG26;
          // slv_reg27 <= SLV_REG27;
          // slv_reg28 <= SLV_REG28;
          // slv_reg29 <= SLV_REG29;
          // slv_reg30 <= SLV_REG30;
          // slv_reg31 <= SLV_REG31;

          //slv_reg32 <= SLV_REG32;
          //slv_reg33 <= SLV_REG33;
        //   slv_reg34 <= SLV_REG34;
        //   slv_reg35 <= SLV_REG35;
        //   slv_reg36 <= SLV_REG36;
        //   slv_reg37 <= SLV_REG37;
        //   slv_reg38 <= SLV_REG38;
        //   slv_reg39 <= SLV_REG39;
        //   slv_reg40 <= SLV_REG40;
        //   slv_reg41 <= SLV_REG41;
        //   slv_reg42 <= SLV_REG42;
        //   slv_reg43 <= SLV_REG43;
        //   slv_reg44 <= SLV_REG44;
        //   slv_reg45 <= SLV_REG45;
        //   slv_reg46 <= SLV_REG46;
        //   slv_reg47 <= SLV_REG47;
        //   slv_reg48 <= SLV_REG48;
        //   slv_reg49 <= SLV_REG49;
          //slv_reg50 <= SLV_REG50;
          slv_reg51 <= SLV_REG51;/*
          slv_reg52 <= SLV_REG52;
          slv_reg53 <= SLV_REG53;
          slv_reg54 <= SLV_REG54;
          slv_reg55 <= SLV_REG55;
          slv_reg56 <= SLV_REG56;
          slv_reg57 <= SLV_REG57;*/
          slv_reg58 <= SLV_REG58;
          slv_reg59 <= SLV_REG59;
          //slv_reg60 <= SLV_REG60;
          //slv_reg61 <= SLV_REG61;
          //slv_reg62 <= SLV_REG62;
          slv_reg63 <= SLV_REG63;

        end 
    end       
    
	// User logic ends

	endmodule
