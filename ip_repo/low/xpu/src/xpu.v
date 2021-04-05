// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

// `define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`define DEBUG_PREFIX

`timescale 1 ns / 1 ps

	module xpu #
	(
        parameter integer GPIO_STATUS_WIDTH = 8,
        parameter integer DELAY_CTL_WIDTH = 7,
        parameter integer RSSI_HALF_DB_WIDTH = 11,
        parameter integer IQ_RSSI_HALF_DB_WIDTH = 9,
	    parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
		parameter integer IQ_DATA_WIDTH	= 16,
        parameter integer WIFI_TX_BRAM_DATA_WIDTH = 64,
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 8,
        parameter integer TSF_TIMER_WIDTH = 64, // according to 802.11 standard
        parameter integer WIFI_TX_BRAM_ADDR_WIDTH = 10
	)
	(
        input  wire [31:0] git_rev,
	    // ad9361 status and ctrl
	    input  wire [(GPIO_STATUS_WIDTH-1):0] gpio_status,

	    // Ports to rx_intf
	    input  wire signed [(IQ_DATA_WIDTH-1):0] ddc_i,
        input  wire signed [(IQ_DATA_WIDTH-1):0] ddc_q,
        input  wire ddc_iq_valid,
        output wire mute_adc_out_to_bb, // when tx, mute self rx
        output wire block_rx_dma_to_ps, // should valid from filter on to fcs valid
        output wire block_rx_dma_to_ps_valid, // should valid from filter on to fcs valid
        output wire signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_lock_by_sig_valid,
        output wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_lock_by_sig_valid,
        output wire [(TSF_TIMER_WIDTH-1):0]  tsf_runtime_val,
        output wire tsf_pulse_1M,
        
		// Ports to openofdm rx
        output wire signed [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db,
        input  wire demod_is_ongoing,
        //input  wire pkt_begin,
		//input  wire pkt_ht,
        input  wire pkt_header_valid,
        input  wire pkt_header_valid_strobe,
        input  wire ht_unsupport,
        input  wire [7:0] pkt_rate,
		input  wire [15:0] pkt_len,
		//input  wire [15:0] pkt_len_total, // for interface to byte_to_word.v in rx_intf.v
		input  wire byte_in_strobe,
		input  wire [7:0] byte_in,
		//input  wire [15:0] byte_count_total, // for interface to byte_to_word.v in rx_intf.v
		input  wire [15:0] byte_count,
        input  wire fcs_in_strobe,
		input  wire fcs_ok,

        // Ports to phy_tx
        input  wire phy_tx_started,
        input  wire phy_tx_done,

	    // Ports to tx_intf
        output wire [4:0] tx_status,
        output wire [47:0] mac_addr,
        output wire retrans_in_progress,
        `DEBUG_PREFIX output wire start_retrans,
        `DEBUG_PREFIX output wire start_tx_ack,
        output wire tx_try_complete,
	    input  wire tx_iq_fifo_empty,
        output wire high_tx_allowed0,
        output wire high_tx_allowed1,
        output wire high_tx_allowed2,
        output wire high_tx_allowed3,
        output wire tx_bb_is_ongoing,
        output wire tx_rf_is_ongoing,
        output wire ack_tx_flag,
        output wire wea,
        output wire [9:0] addra,
        output wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina,
        input  wire tx_pkt_need_ack,
        input  wire [3:0] tx_pkt_retrans_limit,
        input  wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] douta,//from dpram of tx_intf, for tx_control changing some bits to indicate it is the 1st pkt or retransmitted pkt
        input  wire cts_toself_bb_is_ongoing,//this should rise before the phy tx end valid of phy tx IP core to avoid tx_control waiting ack for this tx
        input  wire cts_toself_rf_is_ongoing,//just need to cover the SIFS gap between cts tx and following packet tx
        input wire  [(WIFI_TX_BRAM_ADDR_WIDTH-1):0] bram_addr,
        output wire [3:0] band,
        output wire [7:0] channel,
	    input wire quit_retrans,
	    output wire tx_control_state_idle,
        output wire [9:0] num_slot_random,
        output wire [3:0] cw,
        input wire high_trigger,
        input wire [1:0] tx_queue_idx,
        // to side channel
        output wire [31:0] FC_DI,
    	output wire FC_DI_valid,
		output wire [47:0] addr1,
		output wire addr1_valid,
		output wire [47:0] addr2,
		output wire addr2_valid,
		output wire [47:0] addr3,
		output wire addr3_valid,

		// Ports of Axi Slave Bus Interface S00_AXI
		input  wire s00_axi_aclk,
		input  wire s00_axi_aresetn,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input  wire [2 : 0] s00_axi_awprot,
		input  wire s00_axi_awvalid,
		output wire s00_axi_awready,
		input  wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input  wire s00_axi_wvalid,
		output wire s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire s00_axi_bvalid,
		input  wire s00_axi_bready,
		input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input  wire [2 : 0] s00_axi_arprot,
		input  wire s00_axi_arvalid,
		output wire s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire s00_axi_rvalid,
		input  wire s00_axi_rready
	);

    wire slv_reg_wren_signal;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg0; // rst
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg1; // some source selection
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg2; // tsf load value low
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg3; // tsf load value high (the rising edge of msb will trigger loading)
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg4; // 19:16 band; 15:0 channel
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg5; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg6; // some static config: duration after fcs_strobe to force ch idle
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg7; // rssi report offset, and gpio delay ctrl for rssi calculation, and reset the fifo delay
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg8; // lbt rssi threshold [11:0] 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg9; // xIFS and slot time override for debug
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg10; // tx bb RF delay in number of clock
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg11; // max number of tx re-transmission
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg12; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg13; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg14; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg15; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg16; // receive ack time count top -- 2.4GHz
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg17; // receive ack time count top -- 5GHz
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg18; // before actual ack sending, wait until counter reach this value -- related to SIFS in different band. low 16bit 2.4GHz, high 16bit 5GHz
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg19;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg20; // slice count_total in bit [19:0]; slice selection in bit [21:20]
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg21; // slice count_start in bit [19:0]; slice selection in bit [21:20]
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg22; // slice count_end   in bit [19:0]; slice selection in bit [21:20]
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg23; //
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg24; //
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg25; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg26; // extra duration in CTS frame (response to RTS)
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg27; // filter flags
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg28; // self bssid and filter enable
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg29; // self bssid and filter enable
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg30; // mac addr and filter enable
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg31; // mac addr and filter enable

	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg32;//
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg33;//
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg34;//FC_DI
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg35;//addr1
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg36;//addr1
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg37;//addr2
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg38;//addr2
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg39;//addr3
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg40;//addr3
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg41;//SC
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg42;//addr4
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg43;//addr4
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg44;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg45;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg46;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg47;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg48;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg49;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg50;// trx status
	// wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg51;// tx status, not goes to tx_intf
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg52;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg53;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg54;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg55;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg56;
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg57;
	wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg58;//tsf timer low
	wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg59;//tsf timer high
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg60;//RSSI. step size half dB
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg61;//IQ RSSI. step size half dB
	//wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg62;
	wire [C_S00_AXI_DATA_WIDTH-1:0]	slv_reg63;//FPGA version info
	
	wire block_rx_dma_to_ps_internal;
	wire high_tx_allowed_internal0;
	wire high_tx_allowed_internal1;
	wire high_tx_allowed_internal2;
	wire high_tx_allowed_internal3;

    
    wire ch_idle;
    wire retrans_trigger;

    // wire [31:0] FC_DI;
    // wire FC_DI_valid;
    
    wire [1:0] FC_version;
    wire [1:0] FC_type;
    wire [3:0] FC_subtype;
    wire       FC_to_ds;
    wire       FC_from_ds;
    wire       FC_more_frag;
    wire       FC_retry;
    wire       FC_power_manage;
    wire       FC_more_data;
    wire       FC_protected_frame;
    wire       FC_order;
    wire [15:0] duration;
        
    // wire [47:0] addr1;
    // wire addr1_valid;
    // wire [47:0] addr2;
    // wire addr2_valid;
    // wire [47:0] addr3;
    // wire addr3_valid;
    
    wire [15:0] SC;
    wire SC_valid;
    wire [3:0] SC_fragment_number;
    wire [11:0] SC_sequence_number;
    
    wire [47:0] addr4;
    wire addr4_valid;
    
    wire pulse_tx_bb_end;

    wire signed [(IQ_RSSI_HALF_DB_WIDTH-1):0] iq_rssi_half_db;
    wire iq_rssi_half_db_valid;
    wire rssi_half_db_valid;

    // wire [4:0] tx_status;

    wire slice_en0;
    wire slice_en1;
    wire slice_en2;
    wire slice_en3;

    wire fcs_valid;
    wire sig_valid;

    wire ack_cts_is_ongoing;

    wire [14:0] send_ack_wait_top;
    wire [14:0] recv_ack_timeout_top_adj;
    wire [14:0] recv_ack_sig_valid_timeout_top;
    wire recv_ack_fcs_valid_disable;

    wire       erp_short_slot;
    wire [6:0] preamble_sig_time;
    wire [4:0] ofdm_symbol_time;
    wire [4:0] slot_time;
    wire [6:0] sifs_time;
    wire [6:0] phy_rx_start_delay_time;

    wire [3:0] cw_exp_used;
    wire [3:0] cw_exp_dynamic;
    wire tx_try_complete_int;
    wire backoff_done;
    wire increase_cw;
    wire cw_used ;
    assign tx_try_complete = tx_try_complete_int;
    assign cw_exp_used = ((~slv_reg6[28])?cw_exp_dynamic:slv_reg19[3:0]);
    assign cw = (cw_used?cw_exp_used:0); 
    assign slv_reg63 = git_rev; // from git_rev_rom which is initialized from board_name/openwifi_rev.coe

    assign erp_short_slot = slv_reg4[24];
    assign band = slv_reg4[19:16];
    assign channel = slv_reg4[15:0];

    assign preamble_sig_time =       (slv_reg9[31]?slv_reg9[30:24]:20);
    assign ofdm_symbol_time =        (slv_reg9[31]?slv_reg9[23:19]:4);
    assign slot_time =               (slv_reg9[31]?slv_reg9[18:14]:(band==1?(erp_short_slot?9:20):9));
    assign sifs_time =               (slv_reg9[31]?slv_reg9[13:7] :(band==1?10:16));
    assign phy_rx_start_delay_time = (slv_reg9[31]?slv_reg9[6:0]  :(band==1?24:25));//802.11-2012. Table 19-8—ERP characteristics

    assign send_ack_wait_top = (band==1?slv_reg18[14:0]:slv_reg18[30:16]); //band==1: 2.4GHz

    assign recv_ack_timeout_top_adj = (band==1?slv_reg16[14:0]:slv_reg17[14:0]);
    assign recv_ack_sig_valid_timeout_top = (band==1?slv_reg16[30:16]:slv_reg17[30:16]);
    assign recv_ack_fcs_valid_disable = (band==1?(~slv_reg16[31]):(~slv_reg17[31]));

    assign fcs_valid = (fcs_in_strobe&fcs_ok);
    assign sig_valid = (pkt_header_valid_strobe&pkt_header_valid);

	assign mute_adc_out_to_bb = (slv_reg1[0]?slv_reg1[31]:(tx_rf_is_ongoing|cts_toself_rf_is_ongoing|ack_cts_is_ongoing));
	assign block_rx_dma_to_ps = (block_rx_dma_to_ps_internal&(~slv_reg1[2]));	
	assign high_tx_allowed0 = (  slv_reg1[4]==0?high_tx_allowed_internal0:slv_reg1[1] );
	assign high_tx_allowed1 = ( slv_reg1[12]==0?high_tx_allowed_internal1:slv_reg1[8] );
	assign high_tx_allowed2 = ( slv_reg1[20]==0?high_tx_allowed_internal2:slv_reg1[16] );
	assign high_tx_allowed3 = ( slv_reg1[28]==0?high_tx_allowed_internal3:slv_reg1[24] );
	assign mac_addr = {slv_reg31[15:0], slv_reg30};
	
	// assign slv_reg50 = {high_tx_allowed_internal1, high_tx_allowed_internal0, 4'h0,ack_tx_flag,demod_is_ongoing,tx_rf_is_ongoing,tx_bb_is_ongoing}; // we should use ack_tx_flag to disable tx interrupt to linux!
	// assign slv_reg51[4:0] = tx_status;

	// assign slv_reg34 =  FC_DI;
	assign FC_version = FC_DI[1:0];
	assign FC_type =    FC_DI[3:2];
    assign FC_subtype = FC_DI[7:4];
    assign FC_to_ds =   FC_DI[8];
    assign FC_from_ds = FC_DI[9];
    assign FC_more_frag =       FC_DI[10];
    assign FC_retry =           FC_DI[11];
    assign FC_power_manage =    FC_DI[12];
    assign FC_more_data =       FC_DI[13];
    assign FC_protected_frame = FC_DI[14];
    assign FC_order =           FC_DI[15];
    assign duration  =          FC_DI[31:16];
    
    // assign slv_reg35 = addr1[31:0];
    // assign slv_reg36 = addr1[47:32];
        
    // assign slv_reg37 = addr2[31:0];
    // assign slv_reg38 = addr2[47:32];

    // assign slv_reg39 = addr3[31:0];
    // assign slv_reg40 = addr3[47:32];
    
    // assign slv_reg41 = SC;
    assign SC_fragment_number = SC[3:0];
    assign SC_sequence_number = SC[15:4];
    
    // assign slv_reg42 = addr4[31:0];
    // assign slv_reg43 = addr4[47:32];

    assign slv_reg58 = tsf_runtime_val[(C_S00_AXI_DATA_WIDTH-1):0];
    assign slv_reg59 = tsf_runtime_val[(TSF_TIMER_WIDTH-1):C_S00_AXI_DATA_WIDTH];

    // assign slv_reg60 = rssi_half_db;
    // assign slv_reg61 = iq_rssi_half_db;

    tx_on_detection # (
    ) tx_on_detection_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[0])),

        .bb_rf_delay_count_top(slv_reg10[7:0]),
        .rf_end_ext_count_top(slv_reg10[11:8]),
        .phy_tx_started(phy_tx_started),
        .phy_tx_done(phy_tx_done),
	    .tx_iq_fifo_empty(tx_iq_fifo_empty),

        // .tsf_pulse_1M(tsf_pulse_1M),
        
        .tx_bb_is_ongoing(tx_bb_is_ongoing),
        .tx_rf_is_ongoing(tx_rf_is_ongoing),
        .pulse_tx_bb_end(pulse_tx_bb_end)
    );

    cca # (
        .RSSI_HALF_DB_WIDTH(RSSI_HALF_DB_WIDTH)
    ) cca_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[6])),

        .rssi_half_db(rssi_half_db),
        .rssi_half_db_th(slv_reg8[(RSSI_HALF_DB_WIDTH-1):0]),

        .demod_is_ongoing(demod_is_ongoing),
        .tx_rf_is_ongoing(tx_rf_is_ongoing),
        .cts_toself_rf_is_ongoing(cts_toself_rf_is_ongoing),
        .ack_cts_is_ongoing(ack_cts_is_ongoing),
        .fcs_in_strobe(fcs_in_strobe),
        .wait_after_decode_top(slv_reg6[7:0]),

        .ch_idle(ch_idle)
    );

    csma_ca # (
        .RSSI_HALF_DB_WIDTH(RSSI_HALF_DB_WIDTH)
    ) csma_ca_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[6])),
        
        .tsf_pulse_1M(tsf_pulse_1M),

        .pkt_header_valid(pkt_header_valid),
        .pkt_header_valid_strobe(pkt_header_valid_strobe),
        .signal_rate(pkt_rate),
        .signal_len(pkt_len),
        .fcs_in_strobe(fcs_in_strobe),
        .fcs_valid(fcs_valid),

        .nav_enable(~slv_reg6[31]),
        .difs_enable(~slv_reg6[30]),
        .eifs_enable(~slv_reg6[29]),
        .cw_min(cw_exp_used),
        .preamble_sig_time(preamble_sig_time),
        .ofdm_symbol_time(ofdm_symbol_time),
        .slot_time(slot_time),
        .sifs_time(sifs_time),
        .phy_rx_start_delay_time(phy_rx_start_delay_time),
        .difs_advance(slv_reg5[7:0]),
        .backoff_advance(slv_reg5[15:8]),

        .addr1_valid(addr1_valid),
        .addr1(addr1),
        .self_mac_addr(mac_addr),

        .FC_DI_valid(FC_DI_valid),
        .FC_type(FC_type),
        .FC_subtype(FC_subtype),
        .duration(duration),

        .random_seed({ddc_q[2],ddc_i[0]}),
        .ch_idle(ch_idle),

        .slice_en0(slice_en0),
        .slice_en1(slice_en1),
        .slice_en2(slice_en2),
        .slice_en3(slice_en3),
        .retrans_trigger(retrans_trigger),
        .quit_retrans(quit_retrans),
        .high_trigger(high_trigger),
        .tx_bb_is_ongoing(tx_bb_is_ongoing),
        .ack_tx_flag(ack_tx_flag),

        .high_tx_allowed0(high_tx_allowed_internal0),
        .high_tx_allowed1(high_tx_allowed_internal1),
        .high_tx_allowed2(high_tx_allowed_internal2),
        .high_tx_allowed3(high_tx_allowed_internal3),
        .num_slot_random_log_dl(num_slot_random),
        .increase_cw(increase_cw),
        .cw_used_dl(cw_used),
        .backoff_done(backoff_done)
    );

    cw_exp # (
    ) cw_exp_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[5])),
        .tx_try_complete(tx_try_complete_int),
        .cw_combined(slv_reg19),
        .tx_queue_idx(tx_queue_idx),
        .start_retrans(increase_cw),
        .cw_exp(cw_exp_dynamic)
    );

    tx_control # (
        .RSSI_HALF_DB_WIDTH(RSSI_HALF_DB_WIDTH),
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .WIFI_TX_BRAM_ADDR_WIDTH(WIFI_TX_BRAM_ADDR_WIDTH)
    ) tx_control_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[5])),

        .ack_disable(slv_reg11[4]),
        .preamble_sig_time(preamble_sig_time),
        .ofdm_symbol_time(ofdm_symbol_time),
        .sifs_time(sifs_time),
        .max_num_retrans(slv_reg11[3:0]),
        .tx_pkt_need_ack(tx_pkt_need_ack),
        .tx_pkt_retrans_limit(tx_pkt_retrans_limit),
        .send_ack_wait_top(send_ack_wait_top),
        .recv_ack_timeout_top_adj(recv_ack_timeout_top_adj),
        .recv_ack_sig_valid_timeout_top(recv_ack_sig_valid_timeout_top),
        .recv_ack_fcs_valid_disable(recv_ack_fcs_valid_disable),
        .pulse_tx_bb_end(pulse_tx_bb_end),
        .phy_tx_done(phy_tx_done),
        .sig_valid(sig_valid),
        .signal_rate(pkt_rate),
        .signal_len(pkt_len),
        .fcs_valid(fcs_valid),
        .fcs_in_strobe(fcs_in_strobe),
        .FC_type(FC_type),
        .FC_subtype(FC_subtype),
        .FC_more_frag(FC_more_frag),
        .cts_torts_disable(slv_reg26[31]),
        .cts_torts_rate(slv_reg26[20:16]),
        .duration_extra(slv_reg26[15:0]),
        .duration(duration),
        .addr2(addr2),
        .self_mac_addr(mac_addr),
        .addr1(addr1),
        .cts_toself_bb_is_ongoing(cts_toself_bb_is_ongoing),
        .backoff_done(backoff_done),
        .bram_addr(bram_addr),
        
        .tx_control_state_idle(tx_control_state_idle),
        .ack_cts_is_ongoing(ack_cts_is_ongoing),
        .retrans_in_progress(retrans_in_progress),
        .start_retrans(start_retrans),
        .quit_retrans(quit_retrans),
        .start_tx_ack(start_tx_ack),
        .tx_try_complete(tx_try_complete_int),
        .retrans_trigger(retrans_trigger),
        .tx_status(tx_status),
        .ack_tx_flag(ack_tx_flag),
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta)
    );

    pkt_filter_ctl #(
    ) pkt_filter_ctl_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[2])),

        .filter_cfg(slv_reg27[13:0]),
        .high_priority_discard_mask(slv_reg27[24:16]),
    
        .block_rx_dma_to_ps(block_rx_dma_to_ps_internal),
        .block_rx_dma_to_ps_valid(block_rx_dma_to_ps_valid),
        .self_mac_addr(mac_addr),
        .self_bssid({slv_reg29[15:0], slv_reg28}),
        
        .ht_unsupport(ht_unsupport),
        
        .FC_type(FC_type),
        .FC_subtype(FC_subtype),
        .FC_tofrom_ds({FC_to_ds,FC_from_ds}),
        .FC_DI_valid(FC_DI_valid),
        .signal_len(pkt_len),
        .sig_valid(sig_valid),

        .addr1(addr1),
        .addr1_valid(addr1_valid),
        
        .addr2(addr2),
        .addr2_valid(addr2_valid),
        
        .addr3(addr3),
        .addr3_valid(addr3_valid)
    );
    
    phy_rx_parse # (
    ) phy_rx_parse_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[3])&(~pkt_header_valid_strobe)),

        .ofdm_byte_index(byte_count),
        .ofdm_byte(byte_in),
        .ofdm_byte_valid(byte_in_strobe),

        .FC_DI(FC_DI),
        .FC_DI_valid(FC_DI_valid),
        
        .rx_addr(addr1),
        .rx_addr_valid(addr1_valid),
        
        .dst_addr(addr2),
        .dst_addr_valid(addr2_valid),
        
        .tx_addr(addr3),
        .tx_addr_valid(addr3_valid),
        
        .SC(SC),
        .SC_valid(SC_valid),
        
        .src_addr(addr4),
        .src_addr_valid(addr4_valid)
    );

    rssi # (
        .GPIO_STATUS_WIDTH(GPIO_STATUS_WIDTH),
        .DELAY_CTL_WIDTH(DELAY_CTL_WIDTH),
        .RSSI_HALF_DB_WIDTH(RSSI_HALF_DB_WIDTH),
        .IQ_RSSI_HALF_DB_WIDTH(IQ_RSSI_HALF_DB_WIDTH),
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH)
    ) rssi_i (
	    .gpio_status(gpio_status),

        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[4])),
        .fifo_delay_rstn(s00_axi_aresetn&(~slv_reg7[31])),

        .pkt_header_valid_strobe(pkt_header_valid_strobe),
	    
        .delay_ctl(slv_reg7[(DELAY_CTL_WIDTH-1):0]),
        .rssi_half_db_offset(slv_reg7[(15+RSSI_HALF_DB_WIDTH):16]),
        
        .ddc_i(ddc_i),
        .ddc_q(ddc_q),
        .ddc_iq_valid(ddc_iq_valid),

        .iq_rssi_half_db(iq_rssi_half_db),
        .iq_rssi_half_db_valid(iq_rssi_half_db_valid),
        .rssi_half_db_lock_by_sig_valid(rssi_half_db_lock_by_sig_valid),
        .gpio_status_lock_by_sig_valid(gpio_status_lock_by_sig_valid),
        .rssi_half_db(rssi_half_db),
        .rssi_half_db_valid(rssi_half_db_valid)
    );

	time_slice_gen #(
	) time_slice_gen_i (
        .clk(s00_axi_aclk),
        .rstn(s00_axi_aresetn&(~slv_reg0[7])),
        .tsf_pulse_1M(tsf_pulse_1M),

        .slv_reg_wren_signal(slv_reg_wren_signal),
        .count_total_slice_idx(slv_reg20[21:20]),
        .count_total          (slv_reg20[19:0]),
        .count_start_slice_idx(slv_reg21[21:20]),
        .count_start          (slv_reg21[19:0]),
        .count_end_slice_idx  (slv_reg22[21:20]),
        .count_end            (slv_reg22[19:0]),

        .slice_en0(slice_en0),
        .slice_en1(slice_en1),
        .slice_en2(slice_en2),
        .slice_en3(slice_en3)
	);

	tsf_timer # (
	   .TIMER_WIDTH(TSF_TIMER_WIDTH)
	) tsf_timer_i (
	   .clk(s00_axi_aclk),
       .rstn(s00_axi_aresetn),
       .tsf_load_control(slv_reg3[C_S00_AXI_DATA_WIDTH-1]),
       .tsf_load_val({slv_reg3[(TSF_TIMER_WIDTH-C_S00_AXI_DATA_WIDTH-1):0],slv_reg2}),
       .tsf_runtime_val(tsf_runtime_val),
       .tsf_pulse_1M(tsf_pulse_1M)
	);

// Instantiation of Axi Bus Interface S00_AXI
	xpu_s_axi # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) xpu_s_axi_i (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),

        .slv_reg_wren_signal(slv_reg_wren_signal),
		.SLV_REG0(slv_reg0),
		.SLV_REG1(slv_reg1),
		.SLV_REG2(slv_reg2),
		.SLV_REG3(slv_reg3),
		.SLV_REG4(slv_reg4),
        .SLV_REG5(slv_reg5),
        .SLV_REG6(slv_reg6),
        .SLV_REG7(slv_reg7),
		.SLV_REG8(slv_reg8),
        .SLV_REG9(slv_reg9),
        .SLV_REG10(slv_reg10),
        .SLV_REG11(slv_reg11),/*
        .SLV_REG12(slv_reg12),
        .SLV_REG13(slv_reg13),
        .SLV_REG14(slv_reg14),
        .SLV_REG15(slv_reg15),*/
		.SLV_REG16(slv_reg16),
        .SLV_REG17(slv_reg17),
        .SLV_REG18(slv_reg18),
        .SLV_REG19(slv_reg19),
        .SLV_REG20(slv_reg20),
        .SLV_REG21(slv_reg21),
        .SLV_REG22(slv_reg22),
//        .SLV_REG23(slv_reg23),
//		.SLV_REG24(slv_reg24),
//        .SLV_REG25(slv_reg25),
        .SLV_REG26(slv_reg26),
        .SLV_REG27(slv_reg27),
        .SLV_REG28(slv_reg28),
        .SLV_REG29(slv_reg29),
        .SLV_REG30(slv_reg30),
        .SLV_REG31(slv_reg31),
        
        //.SLV_REG32(slv_reg32),
        //.SLV_REG33(slv_reg33),
        //.SLV_REG34(slv_reg34),
        //.SLV_REG35(slv_reg35),
        //.SLV_REG36(slv_reg36),
        //.SLV_REG37(slv_reg37),
        //.SLV_REG38(slv_reg38),
        //.SLV_REG39(slv_reg39),
        //.SLV_REG40(slv_reg40),
        //.SLV_REG41(slv_reg41),
        //.SLV_REG42(slv_reg42),
        //.SLV_REG43(slv_reg43),
        /*
        .SLV_REG44(slv_reg44),
        .SLV_REG45(slv_reg45),
        .SLV_REG46(slv_reg46),
        .SLV_REG47(slv_reg47),
        .SLV_REG48(slv_reg48),
        .SLV_REG49(slv_reg49),
        .SLV_REG50(slv_reg50),
        .SLV_REG51(slv_reg51),
        .SLV_REG52(slv_reg52),
        .SLV_REG53(slv_reg53),
        .SLV_REG54(slv_reg54),
        .SLV_REG55(slv_reg55),
        .SLV_REG56(slv_reg56),
        .SLV_REG57(slv_reg57),*/
        .SLV_REG58(slv_reg58),
        .SLV_REG59(slv_reg59),
        //.SLV_REG60(slv_reg60),
        //.SLV_REG61(slv_reg61),
        //.SLV_REG62(slv_reg62)//,
        .SLV_REG63(slv_reg63)
	);

	endmodule
