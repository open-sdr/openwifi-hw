// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module dac_intf #
	(
		parameter integer DAC_PACK_DATA_WIDTH = 64
	)
	(
	    input wire dac_rst,
      input wire dac_clk,
        
      output wire [DAC_PACK_DATA_WIDTH-1 : 0] dac_data,
      input wire dac_valid,
      output wire dac_dunf,
        
      output wire fifo_rd_en,
      input wire [DAC_PACK_DATA_WIDTH-1 : 0] fifo_rd_dout,
      input wire fifo_rd_underflow,
        
      input wire src_sel,
		
		  input wire acc_clk,
		  input wire acc_rstn,
      input wire [DAC_PACK_DATA_WIDTH-1 : 0] data_from_acc,
      input wire data_valid_from_acc,
      output wire fulln_to_acc
	);

    wire ALMOSTEMPTY;
    wire ALMOSTFULL;
    wire EMPTY_internal;
    wire FULL_internal;
    wire RDERR;
    wire WRERR;
    wire RST_internal;
    
    wire [DAC_PACK_DATA_WIDTH-1 : 0] dac_data_internal;

    wire rden_internal;
    wire wren_internal;

    wire rden;
    wire wren;
    
    reg src_sel_reg0;
    reg src_sel_reg1;
    reg src_sel_reg2;
    reg src_sel_reg3;
    reg src_sel_reg4;
    reg src_sel_reg5;
    reg src_sel_wider;
    reg src_sel_in_dac_domain;
    
    assign dac_data = ((src_sel_in_dac_domain==1'b0)?fifo_rd_dout:dac_data_internal);
    assign fifo_rd_en = ((src_sel_in_dac_domain==1'b0)?dac_valid:1'b0);
    assign dac_dunf = ((src_sel_in_dac_domain==1'b0)?fifo_rd_underflow:EMPTY_internal);
    
    assign RST_internal = (!acc_rstn);
    assign fulln_to_acc = (!FULL_internal);

    assign rden_internal = ((src_sel_in_dac_domain==1'b0)?1'b0:dac_valid);
    assign wren_internal = ((src_sel_in_dac_domain==1'b0)?1'b0:data_valid_from_acc);

    assign rden = dac_valid;
    assign wren = data_valid_from_acc;

    always @( posedge acc_clk )
    begin
      if ( acc_rstn == 1'b0 ) begin
            src_sel_reg0 <= 1'b0;
            src_sel_reg1 <= 1'b0;
            src_sel_reg2 <= 1'b0;
            src_sel_reg3 <= 1'b0;
            src_sel_reg4 <= 1'b0;
            src_sel_reg5 <= 1'b0;
            src_sel_wider <= 1'b0;
      end 
      else begin
            src_sel_reg0 <= src_sel;
            src_sel_reg1 <= src_sel_reg0;
            src_sel_reg2 <= src_sel_reg1;
            src_sel_reg3 <= src_sel_reg2;
            src_sel_reg4 <= src_sel_reg3;
            src_sel_reg5 <= src_sel_reg4;
            src_sel_wider <= (src_sel_reg0 | src_sel_reg1 | src_sel_reg2 | src_sel_reg3 | src_sel_reg4 | src_sel_reg5);
      end
    end
    
    always @( posedge dac_clk )
    begin
      if ( dac_rst == 1'b1 ) begin
          src_sel_in_dac_domain <= 1'b0;
      end 
      else begin  
          if (src_sel_wider == 1'b1)
              src_sel_in_dac_domain <= 1'b1;
          else
              src_sel_in_dac_domain <= 1'b0;
      end
    end

    fifo64_2clk_dep32 fifo64_2clk_dep32_i
           (.DATAO(dac_data_internal),
            .DI(data_from_acc),
            .EMPTY(EMPTY_internal),
            .FULL(FULL_internal),
            .RDCLK(dac_clk),
            .RDEN(rden_internal),
            .RD_DATA_COUNT(),
            .RST(RST_internal),
            .WRCLK(acc_clk),
            .WREN(wren_internal),
            .WR_DATA_COUNT());
	endmodule
