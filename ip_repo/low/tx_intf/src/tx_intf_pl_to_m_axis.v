// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_intf_pl_to_m_axis #
	(
		parameter integer C_M00_AXIS_TDATA_WIDTH = 64
	)
	(
	    // to m_axis and PS
	    output wire start_1trans_to_m_axis,
	    output wire [(C_M00_AXIS_TDATA_WIDTH-1) : 0] data_to_m_axis,
	    output wire data_ready_to_m_axis,
//	    input wire fulln_from_m_axis,
	    
	    // start m_axis trans mode
	    input wire [1:0] start_1trans_mode,
	    input wire start_1trans_ext_trigger,
	    input wire src_sel,
	    
	    // from wifi rx
        input wire tx_start_from_acc,
        input wire tx_end_from_acc,
        
        input wire [(C_M00_AXIS_TDATA_WIDTH-1) : 0] data_loopback,
        input wire data_loopback_valid
	);

    assign start_1trans_to_m_axis = start_1trans_to_m_axis_reg;
    reg start_1trans_to_m_axis_reg;

    always @( start_1trans_mode,tx_start_from_acc,tx_end_from_acc,start_1trans_ext_trigger)
    begin
       case (start_1trans_mode)
          2'b00 : begin
                        start_1trans_to_m_axis_reg = tx_end_from_acc;
                   end
          2'b01 : begin
                        start_1trans_to_m_axis_reg = tx_start_from_acc;
                   end
          2'b10 : begin
                        start_1trans_to_m_axis_reg = start_1trans_ext_trigger;
                   end
          2'b11 : begin
                        start_1trans_to_m_axis_reg = start_1trans_ext_trigger;
                   end
          default: begin
                        start_1trans_to_m_axis_reg = start_1trans_ext_trigger;
                   end
       endcase
    end

	assign data_to_m_axis = (src_sel==1'b0)?data_loopback:data_loopback;
    assign data_ready_to_m_axis = (src_sel==1'b0)?data_loopback_valid:data_loopback_valid;

	endmodule
