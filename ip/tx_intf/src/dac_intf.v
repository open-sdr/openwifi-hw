// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "clock_speed.v"
`include "board_def.v"

`timescale 1 ns / 1 ps

`include "tx_intf_pre_def.v"

`ifdef TX_INTF_ENABLE_DBG
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`else
`define DEBUG_PREFIX
`endif

`define COUNT_TOP_20M (`NUM_CLK_PER_SAMPLE-1)

`define TX_BB_CLK_GEN_FROM_RF 1

	module dac_intf #
	(
    parameter integer IQ_DATA_WIDTH = 16,
		parameter integer DAC_PACK_DATA_WIDTH = 64
	)
	(
	  input wire dac_rst,
    input wire dac_clk,
    
    //connect util_ad9361_dac_upack
    output wire [DAC_PACK_DATA_WIDTH-1 : 0] dac_data,
    output wire dac_valid,
    `DEBUG_PREFIX input  wire dac_ready,
    
    input wire ant_flag,
    input wire [1:0] simple_cdd_flag,
  
    input wire acc_clk,
	  input wire acc_rstn,
    input wire [(2*IQ_DATA_WIDTH-1) : 0] data_from_acc,
    `DEBUG_PREFIX input wire data_valid_from_acc,

    `DEBUG_PREFIX output wire read_bb_fifo,
    `DEBUG_PREFIX output reg  read_bb_fifo_delay
	);

    `DEBUG_PREFIX reg [(2*IQ_DATA_WIDTH-1) : 0] data_from_acc_stage1;
    `DEBUG_PREFIX reg [(2*IQ_DATA_WIDTH-1) : 0] data_from_acc_stage2;
    `DEBUG_PREFIX reg dac_phase;

    `DEBUG_PREFIX wire read_bb_fifo_raw;
    `DEBUG_PREFIX reg  read_bb_fifo_raw_reg;

    wire ant_flag_in_rf_domain;
    wire [1:0] simple_cdd_flag_in_rf_domain;

    wire [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal;
    reg  [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal_delay1;
    reg  [(2*IQ_DATA_WIDTH-1) : 0] dac_data_internal_delay2;
    wire [(DAC_PACK_DATA_WIDTH-1) : 0] dac_data_internal_after_sel;

    assign dac_data_internal_after_sel = (ant_flag_in_rf_domain?{dac_data_internal,32'd0}:{32'd0,dac_data_internal});
    assign dac_data = ( simple_cdd_flag_in_rf_domain[1]==0? ( simple_cdd_flag_in_rf_domain[0]?{dac_data_internal_delay2, dac_data_internal}:dac_data_internal_after_sel ) : {dac_data_internal,dac_data_internal} );

    assign dac_valid = 1; //dac always need 40Msps IQ data
    
    assign dac_data_internal = (dac_phase?data_from_acc_stage2:0);

    assign read_bb_fifo = (read_bb_fifo_raw==1 && read_bb_fifo_raw_reg==0);

    // dac 40MHz domain
    always @( posedge dac_clk )
    begin
      if ( dac_rst == 1 ) begin
        data_from_acc_stage1 <= 0;
        data_from_acc_stage2 <= 0;
        dac_phase <= 0;

        dac_data_internal_delay1 <= 0;
        dac_data_internal_delay2 <= 0;
      end else begin
        data_from_acc_stage1 <= data_from_acc;
        data_from_acc_stage2 <= data_from_acc_stage1;
        dac_phase <= (~dac_phase);

        dac_data_internal_delay1 <= dac_data_internal;
        dac_data_internal_delay2 <= dac_data_internal_delay1;
      end
    end

    // acc 100MHz domain
    always @( posedge acc_clk )
    begin
      if ( acc_rstn == 0 ) begin
        read_bb_fifo_delay <= 0;
        read_bb_fifo_raw_reg <= 0;
      end else begin
        read_bb_fifo_delay <= read_bb_fifo;
        read_bb_fifo_raw_reg <= read_bb_fifo_raw;
      end
    end

    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_ant_flag (
      .src_clk  (acc_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (ant_flag),
      .dest_clk (dac_clk),
      .dest_out (ant_flag_in_rf_domain)
    );

    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (2)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_simple_cdd_flag (
      .src_clk  (acc_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (simple_cdd_flag),
      .dest_clk (dac_clk),
      .dest_out (simple_cdd_flag_in_rf_domain)
    );

    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_read_bb_fifo (
      .src_clk  (dac_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (dac_phase),
      .dest_clk (acc_clk),
      .dest_out (read_bb_fifo_raw)
    );
	endmodule
