// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module cca #
	(
	  parameter integer RSSI_HALF_DB_WIDTH = 11
	)
	(//need to give answer of ch idle based on: rssi, pkt header (and predicted pkt length), virtual carrier sensing (CTS/RTS)
        // input wire clk,
        // input wire rstn,
        
        input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db,
        input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_th,

        input wire demod_is_ongoing,
        input wire tx_rf_is_ongoing,
        input wire cts_toself_rf_is_ongoing,
        input wire ack_cts_is_ongoing,
        input wire tx_control_state_idle,

        output wire ch_idle
	);

  wire ch_idle_rssi;

  assign ch_idle_rssi = ( rssi_half_db<=rssi_half_db_th );
  assign ch_idle = (ch_idle_rssi&&(~demod_is_ongoing)&&(~tx_rf_is_ongoing)&&(~cts_toself_rf_is_ongoing)&&(~ack_cts_is_ongoing)&&tx_control_state_idle);

	endmodule
