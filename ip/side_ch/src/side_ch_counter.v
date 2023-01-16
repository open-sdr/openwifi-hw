
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`include "side_ch_pre_def.v"

`ifdef SIDE_CH_ENABLE_DBG
`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`else
`define DEBUG_PREFIX
`endif

`timescale 1 ns / 1 ps

	module side_ch_counter #
	(
		// parameter integer TSF_TIMER_WIDTH = 64, // according to 802.11 standard

		// parameter integer GPIO_STATUS_WIDTH = 8,
		// parameter integer RSSI_HALF_DB_WIDTH = 11,
		// parameter integer C_S_AXI_DATA_WIDTH = 32,
		// parameter integer IQ_DATA_WIDTH = 16,
	    // parameter integer C_S_AXIS_TDATA_WIDTH	= 64,
        // parameter integer MAX_NUM_DMA_SYMBOL = 8192,
        // parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14
		parameter integer COUNTER_WIDTH = 16
	)
	(
        input wire clk,
        // input wire rstn,

		// from arm. capture reg write to clear the corresponding counter
	 	input wire slv_reg_wren_signal,
	 	input wire [4:0] axi_awaddr_core,

		// counter++ event input
		input wire event0,
		input wire event1,
		input wire event2,
		input wire event3,
		input wire event4,
		input wire event5,

		output reg [COUNTER_WIDTH-1 : 0] counter0,
		output reg [COUNTER_WIDTH-1 : 0] counter1,
		output reg [COUNTER_WIDTH-1 : 0] counter2,
		output reg [COUNTER_WIDTH-1 : 0] counter3,
		output reg [COUNTER_WIDTH-1 : 0] counter4,
		output reg [COUNTER_WIDTH-1 : 0] counter5
	);

	reg event0_reg;
	reg event1_reg;
	reg event2_reg;
	reg event3_reg;
	reg event4_reg;
	reg event5_reg;

	wire counter0_rst;
	wire counter1_rst;
	wire counter2_rst;
	wire counter3_rst;
	wire counter4_rst;
	wire counter5_rst;

	assign counter0_rst = (slv_reg_wren_signal==1 && axi_awaddr_core==26);//slv_reg26 wr
	assign counter1_rst = (slv_reg_wren_signal==1 && axi_awaddr_core==27);//slv_reg27 wr
	assign counter2_rst = (slv_reg_wren_signal==1 && axi_awaddr_core==28);//slv_reg28 wr
	assign counter3_rst = (slv_reg_wren_signal==1 && axi_awaddr_core==29);//slv_reg29 wr
	assign counter4_rst = (slv_reg_wren_signal==1 && axi_awaddr_core==30);//slv_reg30 wr
	assign counter5_rst = (slv_reg_wren_signal==1 && axi_awaddr_core==31);//slv_reg31 wr

    always @(posedge clk) begin
		if (counter0_rst) begin
			counter0 <= 0;
			event0_reg <= 0;
		end else begin
			event0_reg <= event0;
			if (event0==1 && event0_reg==0) begin
				counter0 <= counter0 + 1;
			end
		end
    end
    always @(posedge clk) begin
		if (counter1_rst) begin
			counter1 <= 0;
			event1_reg <= 0;
		end else begin
			event1_reg <= event1;
			if (event1==1 && event1_reg==0) begin
				counter1 <= counter1 + 1;
			end
		end
    end
    always @(posedge clk) begin
		if (counter2_rst) begin
			counter2 <= 0;
			event2_reg <= 0;
		end else begin
			event2_reg <= event2;
			if (event2==1 && event2_reg==0) begin
				counter2 <= counter2 + 1;
			end
		end
    end
    always @(posedge clk) begin
		if (counter3_rst) begin
			counter3 <= 0;
			event3_reg <= 0;
		end else begin
			event3_reg <= event3;
			if (event3==1 && event3_reg==0) begin
				counter3 <= counter3 + 1;
			end
		end
    end
    always @(posedge clk) begin
		if (counter4_rst) begin
			counter4 <= 0;
			event4_reg <= 0;
		end else begin
			event4_reg <= event4;
			if (event4==1 && event4_reg==0) begin
				counter4 <= counter4 + 1;
			end
		end
    end
    always @(posedge clk) begin
		if (counter5_rst) begin
			counter5 <= 0;
			event5_reg <= 0;
		end else begin
			event5_reg <= event5;
			if (event5==1 && event5_reg==0) begin
				counter5 <= counter5 + 1;
			end
		end
    end
	endmodule
