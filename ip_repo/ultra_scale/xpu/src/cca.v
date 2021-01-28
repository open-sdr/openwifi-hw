// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "board_def.v"
`include "clock_speed.v"
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`timescale 1 ns / 1 ps

	module cca #
	(
	  parameter integer RSSI_HALF_DB_WIDTH = 11
	)
	(//need to give answer of ch idle based on: rssi, pkt header (and predicted pkt length), virtual carrier sensing (CTS/RTS)
        input wire clk,
        input wire rstn,
        
        input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db,
        input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_th,

        input wire demod_is_ongoing,
        input wire tx_rf_is_ongoing,
        input wire cts_toself_rf_is_ongoing,
        input wire ack_cts_is_ongoing,
        input wire fcs_in_strobe,
        input wire [7:0] wait_after_decode_top,

        `DEBUG_PREFIX output wire ch_idle
	);

  wire ch_idle_rssi;

  `DEBUG_PREFIX reg [11:0] wait_after_decode_top_scale;
  `DEBUG_PREFIX reg [11:0] wait_after_decode_count ;
  `DEBUG_PREFIX reg is_counting ; 
  always @(posedge clk) begin
    if (!rstn) begin
      wait_after_decode_top_scale<=0;
      wait_after_decode_count<=0;
      is_counting<=0;
    end else begin
      wait_after_decode_top_scale<=wait_after_decode_top*`COUNT_SCALE;
      if(fcs_in_strobe && (wait_after_decode_top_scale > 0)) begin
        is_counting<=1;
        wait_after_decode_count<=0;
      end else begin
        wait_after_decode_count<=(is_counting? (wait_after_decode_count+1):wait_after_decode_count);
        is_counting<=( (wait_after_decode_count>=wait_after_decode_top_scale)?0:is_counting );
      end
    end
  end

  assign ch_idle_rssi = (is_counting?1:( (rssi_half_db<=rssi_half_db_th) && (~demod_is_ongoing) ));
  assign ch_idle = (ch_idle_rssi&&(~tx_rf_is_ongoing)&&(~cts_toself_rf_is_ongoing)&&(~ack_cts_is_ongoing)); // remove tx_control_state_idle condition, need to separate ch_idle and internal state

	endmodule
