
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`include "side_ch_pre_def.v"

`ifdef SIDE_CH_ENABLE_DBG
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`else
`define DEBUG_PREFIX
`endif

`timescale 1 ns / 1 ps

	module side_ch_counter_event_cfg #
	(
		// parameter integer TSF_TIMER_WIDTH = 64, // according to 802.11 standard

		parameter integer GPIO_STATUS_WIDTH = 8,
		parameter integer RSSI_HALF_DB_WIDTH = 11,
		parameter integer C_S_AXI_DATA_WIDTH = 32
		// parameter integer IQ_DATA_WIDTH = 16,
	    // parameter integer C_S_AXIS_TDATA_WIDTH	= 64,
        // parameter integer MAX_NUM_DMA_SYMBOL = 8192,
        // parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14
		// parameter integer COUNTER_WIDTH = 16
	)
	(
        input wire clk,
        input wire rstn,

		// original event source
		input wire [(GPIO_STATUS_WIDTH-2):0] gain_th,
		input wire signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_th,
	    input wire [(GPIO_STATUS_WIDTH-1):0] gpio_status,
        input wire signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db,

		input wire short_preamble_detected,
		input wire long_preamble_detected,

		input wire pkt_header_valid_strobe,
		input wire pkt_header_valid,

		input wire [C_S_AXI_DATA_WIDTH-1 : 0] addr2_target,
		input wire [47:0] addr2,
		input wire pkt_for_me,
		input wire is_data,

		input wire fcs_in_strobe,
		input wire fcs_ok,

		input wire phy_tx_start,
		input wire phy_tx_done,
		input wire tx_pkt_need_ack,

		// from arm. event source select
	 	input wire event0_sel,
	 	input wire event1_sel,
	 	input wire event2_sel,
	 	input wire event3_sel,
	 	input wire event4_sel,
	 	input wire event5_sel,

		// counter++ event output
		output reg event0,
		output reg event1,
		output reg event2,
		output reg event3,
		output reg event4,
		output reg event5
	);

	reg [(GPIO_STATUS_WIDTH-2):0] gpio_status_reg;
	wire agc_lock;
	wire gain_change;
	wire rssi_above_th;
	wire addr2_match;

	assign agc_lock = gpio_status[GPIO_STATUS_WIDTH-1];
	assign gain_change = (gpio_status[(GPIO_STATUS_WIDTH-2):0] != gpio_status_reg);
	assign rssi_above_th = (rssi_half_db> rssi_half_db_th);
	assign addr2_match = ({addr2[23:16],addr2[31:24],addr2[39:32],addr2[47:40]} == addr2_target);

    always @(posedge clk) begin
		if (!rstn) begin
			gpio_status_reg <= 0;
		end else begin
			gpio_status_reg <= gpio_status[(GPIO_STATUS_WIDTH-2):0];
		end
    end

	always @( event0_sel, short_preamble_detected, phy_tx_start )
	begin
      case (event0_sel)
        0: begin  event0 <= short_preamble_detected;  end
		1: begin  event0 <= phy_tx_start;  end
      endcase
 	end

	always @( event1_sel, long_preamble_detected, phy_tx_done )
	begin
      case (event1_sel)
        0: begin  event1 <= long_preamble_detected;  end
		1: begin  event1 <= phy_tx_done;  end
      endcase
 	end

	always @( event2_sel, pkt_header_valid_strobe, rssi_above_th)
	begin
      case (event2_sel)
        0: begin  event2 <= pkt_header_valid_strobe;  end
		1: begin  event2 <= rssi_above_th;  end
      endcase
 	end

	always @( event3_sel, pkt_header_valid_strobe, pkt_header_valid, gain_change)
	begin
      case (event3_sel)
        0: begin  event3 <= (pkt_header_valid_strobe&pkt_header_valid);  end
		1: begin  event3 <= gain_change;  end
      endcase
 	end

	always @( event4_sel, fcs_in_strobe, addr2_match, pkt_for_me, is_data, agc_lock)
	begin
      case (event4_sel)
        0: begin  event4 <= (((fcs_in_strobe&addr2_match)&pkt_for_me)&is_data);  end
		1: begin  event4 <= agc_lock;  end
      endcase
 	end

	always @( event5_sel, fcs_in_strobe, fcs_ok, addr2_match, pkt_for_me, is_data, tx_pkt_need_ack)
	begin
      case (event5_sel)
        0: begin  event5 <= ((((fcs_in_strobe&fcs_ok)&addr2_match)&pkt_for_me)&is_data);  end
		1: begin  event5 <= tx_pkt_need_ack;  end
      endcase
 	end

	endmodule
