// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps
// `define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`define DEBUG_PREFIX

	module rssi #
	(
        parameter integer GPIO_STATUS_WIDTH = 8,
        parameter integer DELAY_CTL_WIDTH = 7,
        parameter integer RSSI_HALF_DB_WIDTH = 11,
        parameter integer IQ_RSSI_HALF_DB_WIDTH = 9,
		parameter integer IQ_DATA_WIDTH	= 16
	)
	(
	    // ad9361 status and ctrl
	    input wire [7:0] gpio_status,

        input wire clk,
        input wire rstn,
        input wire fifo_delay_rstn,

        input wire pkt_header_valid_strobe,

        input wire [(DELAY_CTL_WIDTH-1):0]    delay_ctl,
        `DEBUG_PREFIX input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_offset,

	    // Ports to receive IQ from DDC
	    input wire signed [(IQ_DATA_WIDTH-1):0] ddc_i,
        input wire signed [(IQ_DATA_WIDTH-1):0] ddc_q,
        input wire ddc_iq_valid,

        // result outputs
        `DEBUG_PREFIX output wire signed [(IQ_RSSI_HALF_DB_WIDTH-1):0] iq_rssi_half_db,
        output wire iq_rssi_half_db_valid,
        output reg signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_lock_by_sig_valid,
        output reg [(GPIO_STATUS_WIDTH-1):0] gpio_status_lock_by_sig_valid,
        `DEBUG_PREFIX output reg signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db,
        output reg rssi_half_db_valid
	);

    wire signed [(IQ_DATA_WIDTH-1):0] iq_rssi;
    wire iq_rssi_valid;
   `DEBUG_PREFIX wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_delay;
    wire gpio_status_delay_valid;

    iq_abs_avg # (
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH)
    ) iq_abs_avg_i (
        .clk(clk),
        .rstn(rstn),
        .ddc_i(ddc_i),
        .ddc_q(ddc_q),
        .ddc_iq_valid(ddc_iq_valid),
        .iq_rssi(iq_rssi),
        .iq_rssi_valid(iq_rssi_valid)
    );

    iq_rssi_to_db # (
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH),
        .IQ_RSSI_HALF_DB_WIDTH(IQ_RSSI_HALF_DB_WIDTH)
    ) iq_rssi_to_db_i (
        .clk(clk),
        .rstn(rstn),
        .iq_rssi(iq_rssi),
        .iq_rssi_valid(iq_rssi_valid),
        .iq_rssi_half_db(iq_rssi_half_db), // step size is 0.5dB not 1dB!
        .iq_rssi_half_db_valid(iq_rssi_half_db_valid)
    );

    fifo8_delay64 # (
        .DATA_WIDTH(GPIO_STATUS_WIDTH),
        .DELAY_CTL_WIDTH(DELAY_CTL_WIDTH)
    ) fifo8_delay64_i (
        .clk(clk),
        .rstn(fifo_delay_rstn),
        .delay_ctl(delay_ctl),
        .data_in(gpio_status),
        .data_in_valid(iq_rssi_half_db_valid),
        .data_out(gpio_status_delay),
        .data_out_valid(gpio_status_delay_valid)
    );

    always @( posedge clk )
    if ( rstn == 1'b0 )
    begin
        rssi_half_db <= 0;
        rssi_half_db_valid <= 0;
    end
    else
    begin
        rssi_half_db_valid <= gpio_status_delay_valid;
        if (gpio_status_delay_valid)
        begin
            rssi_half_db <= (rssi_half_db_offset + iq_rssi_half_db - {3'b0, gpio_status_delay[6:0], 1'b0} ); // temp formula
        end
    end

    always @( posedge clk )
    if ( rstn == 1'b0 )
    begin
        rssi_half_db_lock_by_sig_valid <= 0;
        gpio_status_lock_by_sig_valid <= 0;
    end
    else
    begin
        if (pkt_header_valid_strobe)
        begin
            rssi_half_db_lock_by_sig_valid <= rssi_half_db;
            gpio_status_lock_by_sig_valid <= gpio_status;
        end
    end

	endmodule
