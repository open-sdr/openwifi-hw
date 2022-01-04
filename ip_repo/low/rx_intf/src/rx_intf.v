
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module rx_intf #
	(
        parameter integer GPIO_STATUS_WIDTH = 8,
        parameter integer RSSI_HALF_DB_WIDTH = 11,

		parameter integer ADC_PACK_DATA_WIDTH	= 64,
		parameter integer IQ_DATA_WIDTH	=     16,
		parameter integer RSSI_DATA_WIDTH	=     10,
		
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7,

		parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 64,
		
        parameter integer WAIT_COUNT_BITS = 5,
		parameter integer MAX_NUM_DMA_SYMBOL = 8192,
        parameter integer TSF_TIMER_WIDTH = 64 // according to 802.11 standard
	)
	(
        // -------------debug purpose----------------
        output wire trigger_out,
        output wire trigger_out1,
        // -------------debug purpose----------------

	    // from ad9361_adc_pack
        input wire adc_clk,
        input wire adc_rst,
        input wire [(ADC_PACK_DATA_WIDTH-1) : 0] adc_data,
        //(* mark_debug = "true" *) input wire adc_sync,
        input wire adc_valid,

        // I/Q ports from tx_intf for loop back
        input wire [(2*IQ_DATA_WIDTH-1) : 0] iq0_from_tx_intf,
        input wire [(2*IQ_DATA_WIDTH-1) : 0] iq1_from_tx_intf,
        input wire iq_valid_from_tx_intf,

	    // Ports to openofdm rx
        output wire [(2*IQ_DATA_WIDTH-1) : 0] sample0,
        output wire [(2*IQ_DATA_WIDTH-1) : 0] sample1,
	    output wire sample_strobe,
        input  wire pkt_header_valid,
        input  wire pkt_header_valid_strobe,
        input  wire ht_unsupport,
        input  wire [7:0] pkt_rate,
		input  wire [15:0] pkt_len,
		input  wire ht_sgi,
		input  wire byte_in_strobe,
		input  wire [7:0] byte_in,
		input  wire [15:0] byte_count,
        input  wire fcs_in_strobe,
		input  wire fcs_ok,

	    // interrupt to PS
        output wire rx_pkt_intr,
        
        // interrupt from xilixn axi dma
        input wire s2mm_intr,
        
        // for xpu
        input  wire mute_adc_out_to_bb, // in acc clock domain
        input  wire block_rx_dma_to_ps, // if addr filter is on in xpu
        input  wire block_rx_dma_to_ps_valid, // if addr filter is on in xpu
 	    input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_lock_by_sig_valid,
        input wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_lock_by_sig_valid,
        input wire [(TSF_TIMER_WIDTH-1):0]  tsf_runtime_val,
        input wire tsf_pulse_1M,

		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Master Bus Interface M00_AXIS to PS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);

	function integer clogb2 (input integer bit_depth);                                   
      begin                                                                              
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
          bit_depth = bit_depth >> 1;                                                    
      end                                                                                
    endfunction   
    
    localparam integer MAX_BIT_NUM_DMA_SYMBOL  = clogb2(MAX_NUM_DMA_SYMBOL);
    
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg0; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg1; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg2; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg3; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg4; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg5; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg6; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg7; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg8; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg9; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg10; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg11; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg12; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg13; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg14; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg15; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg16; 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg17; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg18; 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg19; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg20; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg21; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg22; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg23; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg24; 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg25; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg26; 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg27; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg28; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg29; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg30; // 
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg31; // 

    //for direct loop back
	wire  m00_axis_tvalid_inner;
	wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata_inner;
	wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb_inner;
	wire  m00_axis_tlast_inner;
    wire  m00_axis_tlast_auto_recover;

    wire emptyn_to_bb;
    wire [(ADC_PACK_DATA_WIDTH-1) : 0] ant_data_after_sel;

    wire [(IQ_DATA_WIDTH-1) : 0] rf_i0_to_acc;
	wire [(IQ_DATA_WIDTH-1) : 0] rf_q0_to_acc;
    wire [(IQ_DATA_WIDTH-1) : 0] rf_i1_to_acc;
	wire [(IQ_DATA_WIDTH-1) : 0] rf_q1_to_acc;
 
	wire [(IQ_DATA_WIDTH-1):0] bw20_i0;
    wire [(IQ_DATA_WIDTH-1):0] bw20_q0;
	wire [(IQ_DATA_WIDTH-1):0] bw20_i1;
    wire [(IQ_DATA_WIDTH-1):0] bw20_q1;
    wire bw20_iq_valid;
        
    wire [(4*IQ_DATA_WIDTH-1) : 0] rf_iq_loopback;
    
	wire start_1trans_from_acc_to_m_axis;
    wire [(C_M00_AXIS_TDATA_WIDTH-1):0] data_from_acc_to_m_axis;
    wire data_ready_from_acc_to_m_axis;
    wire fulln_from_m_axis_to_acc;
    wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] m_axis_fifo_data_count;
    wire fcs_valid_internal;
    wire rx_pkt_intr_internal;
    wire intr_internal;
    
    wire wifi_rx_iq_fifo_emptyn;
    
    //wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] monitor_num_dma_symbol_to_pl;
    wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] monitor_num_dma_symbol_to_ps;
    wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] num_dma_symbol_to_ps;

    //wire fcs_invalid_from_acc_delay;
    wire m_axis_auto_rst;
    wire m_axis_rst;
    wire enable_m_axis_auto_rst;
    
    wire ant_flag_in_rf_domain;
    wire mute_adc_out_to_bb_in_rf_domain;
    wire [(ADC_PACK_DATA_WIDTH-1) : 0] adc_data_internal;
    wire [(ADC_PACK_DATA_WIDTH-1) : 0] adc_data_after_sel;

    wire [(C_M00_AXIS_TDATA_WIDTH-1) : 0] data_from_acc;
	wire data_ready_from_acc;

    wire fcs_valid;
    wire fcs_invalid;
    wire sig_valid;
    wire sig_invalid;

    wire rx_pkt_sn_plus_one;

    // -------------debug purpose----------------
    wire trigger_out_internal = 1;
    assign trigger_out1 = slv_reg1[4];
    assign trigger_out = (slv_reg1[0]&trigger_out_internal);
    // -------------debug purpose----------------

    assign sample0 = {rf_i0_to_acc,rf_q0_to_acc};
    assign sample1 = {rf_i1_to_acc,rf_q1_to_acc};
    assign fcs_valid = (fcs_in_strobe&fcs_ok);
    assign fcs_invalid = (fcs_in_strobe&(~fcs_ok));
    assign sig_valid = (pkt_header_valid_strobe&pkt_header_valid);
    assign sig_invalid = (pkt_header_valid_strobe&(~pkt_header_valid));

	assign m00_axis_tvalid = m00_axis_tvalid_inner;
	assign m00_axis_tdata  = m00_axis_tdata_inner;
	assign m00_axis_tstrb  = m00_axis_tstrb_inner;
	assign m00_axis_tlast  = (m00_axis_tlast_inner|m00_axis_tlast_auto_recover);

    //assign slv_reg23[(GPIO_STATUS_WIDTH-1):0] = gpio_status;

    assign fcs_valid_internal = (slv_reg5[3]==0?fcs_valid:fcs_in_strobe);
    assign rx_pkt_intr = (slv_reg2[8]==0?intr_internal:slv_reg2[0]);
    
    assign intr_internal = (slv_reg2[12]==0?rx_pkt_intr_internal:fcs_valid_internal);

    assign num_dma_symbol_to_ps = (slv_reg5[5]==1)?(monitor_num_dma_symbol_to_ps-1):(slv_reg9[(MAX_BIT_NUM_DMA_SYMBOL-1):0]-1);

    assign enable_m_axis_auto_rst = slv_reg5[16];
    assign m_axis_auto_rst = (m_axis_rst&enable_m_axis_auto_rst);
  
    assign adc_data_after_sel = (ant_flag_in_rf_domain?{adc_data[(2*IQ_DATA_WIDTH-1) : 0],adc_data[(ADC_PACK_DATA_WIDTH-1) : (2*IQ_DATA_WIDTH)]}:adc_data);
    assign adc_data_internal  = (mute_adc_out_to_bb_in_rf_domain?{adc_data_after_sel[(ADC_PACK_DATA_WIDTH-1) : (2*IQ_DATA_WIDTH)],32'd0}:adc_data_after_sel);

    assign bw20_i0 = (slv_reg3[8]?iq0_from_tx_intf[  (IQ_DATA_WIDTH-1) :             0]:ant_data_after_sel[  (IQ_DATA_WIDTH-1) : 0]);
    assign bw20_q0 = (slv_reg3[8]?iq0_from_tx_intf[(2*IQ_DATA_WIDTH-1) : IQ_DATA_WIDTH]:ant_data_after_sel[(2*IQ_DATA_WIDTH-1) : IQ_DATA_WIDTH]);
    assign bw20_i1 = (slv_reg3[8]?iq1_from_tx_intf[  (IQ_DATA_WIDTH-1) :             0]:ant_data_after_sel[(3*IQ_DATA_WIDTH-1) : (2*IQ_DATA_WIDTH)]);
    assign bw20_q1 = (slv_reg3[8]?iq1_from_tx_intf[(2*IQ_DATA_WIDTH-1) : IQ_DATA_WIDTH]:ant_data_after_sel[(4*IQ_DATA_WIDTH-1) : (3*IQ_DATA_WIDTH)]);
    assign bw20_iq_valid = (slv_reg3[8]?iq_valid_from_tx_intf:emptyn_to_bb);
    
// ---------------------------fro mute_adc_out_to_bb control from acc domain to adc domain-------------------------------------
    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_mute_adc (
      .src_clk  (s00_axi_aclk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (mute_adc_out_to_bb),
      .dest_clk (adc_clk),
      .dest_out (mute_adc_out_to_bb_in_rf_domain)
    );

// ---------------------------fro antenna selection from acc domain to adc domain-------------------------------------
    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_ant_flag (
      .src_clk  (s00_axi_aclk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (slv_reg16[0]),
      .dest_clk (adc_clk),
      .dest_out (ant_flag_in_rf_domain)
    );

    adc_intf # (
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH)        
    ) adc_intf_i (
        .adc_rst(adc_rst),
        .adc_clk(adc_clk),
        .adc_data(adc_data_internal),
        //.adc_sync(adc_sync),
        .adc_valid(adc_valid),
        .acc_clk(m00_axis_aclk),
        .acc_rstn(m00_axis_aresetn&(~slv_reg0[5])),

        .bb_gain(slv_reg11[2:0]), // number of bit shift to left
        .data_to_bb(ant_data_after_sel),
        .emptyn_to_bb(emptyn_to_bb),
        .bb_ask_data(1'b1&(~slv_reg10[1]))
    );

// Instantiation of Axi Bus Interface S00_AXI
	rx_intf_s_axi # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) rx_intf_s_axi_i (
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
        .SLV_REG11(slv_reg11),
        .SLV_REG12(slv_reg12),
        .SLV_REG13(slv_reg13),
        //.SLV_REG14(slv_reg14),
        //.SLV_REG15(slv_reg15),
		.SLV_REG16(slv_reg16)/*,
        .SLV_REG17(slv_reg17),
        .SLV_REG18(slv_reg18),
        .SLV_REG19(slv_reg19),
        .SLV_REG20(slv_reg20),
        .SLV_REG21(slv_reg21),
        .SLV_REG22(slv_reg22),
        .SLV_REG23(slv_reg23),
		.SLV_REG24(slv_reg24),
        .SLV_REG25(slv_reg25),
        .SLV_REG26(slv_reg26),
        .SLV_REG27(slv_reg27),
        .SLV_REG28(slv_reg28),
        .SLV_REG29(slv_reg29),
        .SLV_REG30(slv_reg30),
        .SLV_REG31(slv_reg31)*/
	);

    rx_iq_intf # (
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH)
    ) rx_iq_intf_i (
        // ----------- debug purpose ---------------
        //.trigger_out(trigger_out_internal),
        // ----------- debug purpose ---------------

        .rstn(m00_axis_aresetn&(~slv_reg0[3])),
        .clk(m00_axis_aclk),
        .bw20_i0(bw20_i0),
        .bw20_q0(bw20_q0),
        .bw20_i1(bw20_i1),
        .bw20_q1(bw20_q1),
        .bw20_iq_valid(bw20_iq_valid),
        .fifo_in_en(~slv_reg4[1]),
        .fifo_out_en(~slv_reg4[2]),
        .bb_20M_en(slv_reg4[3]),
        .rf_i0(rf_i0_to_acc),
        .rf_q0(rf_q0_to_acc),
        .rf_i1(rf_i1_to_acc),
        .rf_q1(rf_q1_to_acc),
        .rf_iq_valid(sample_strobe),
        .rf_iq_valid_delay_sel(slv_reg3[4]),
        .rf_iq(rf_iq_loopback),
        .wifi_rx_iq_fifo_emptyn(wifi_rx_iq_fifo_emptyn)
    );

    byte_to_word_fcs_sn_insert byte_to_word_fcs_sn_insert_inst (
        .clk(m00_axis_aclk),
        .rstn(m00_axis_aresetn&(~slv_reg0[7])&(~pkt_header_valid_strobe)),
        .rstn_sn(m00_axis_aresetn&(~slv_reg0[7])),

        .byte_in(byte_in),
        .byte_in_strobe(byte_in_strobe),
        .byte_count(byte_count),
        .num_byte(pkt_len),
        .fcs_in_strobe(fcs_in_strobe),
        .fcs_ok(fcs_ok),
        .rx_pkt_sn_plus_one(rx_pkt_sn_plus_one),

        .word_out(data_from_acc),
        .word_out_strobe(data_ready_from_acc)
    );

    rx_intf_pl_to_m_axis # ( 
        .GPIO_STATUS_WIDTH(GPIO_STATUS_WIDTH),
        .RSSI_HALF_DB_WIDTH(RSSI_HALF_DB_WIDTH),
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH),
        .TSF_TIMER_WIDTH(TSF_TIMER_WIDTH),
        .C_M00_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
        .MAX_BIT_NUM_DMA_SYMBOL(MAX_BIT_NUM_DMA_SYMBOL)
    ) rx_intf_pl_to_m_axis_i (
        .clk(m00_axis_aclk),
        .rstn(m00_axis_aresetn&(~slv_reg0[8])),

	    // port to xpu
	    .block_rx_dma_to_ps(block_rx_dma_to_ps),
        .block_rx_dma_to_ps_valid(block_rx_dma_to_ps_valid),
	    .rssi_half_db_lock_by_sig_valid(rssi_half_db_lock_by_sig_valid),
	    .gpio_status_lock_by_sig_valid(gpio_status_lock_by_sig_valid),
	    
        // to m_axis and PS
        .start_1trans_to_m_axis(start_1trans_from_acc_to_m_axis),
        .data_to_m_axis_out(data_from_acc_to_m_axis),
        .data_ready_to_m_axis_out(data_ready_from_acc_to_m_axis),
	    .monitor_num_dma_symbol_to_ps(monitor_num_dma_symbol_to_ps),
        .m_axis_rst(m_axis_rst),
        .m_axis_tlast(m00_axis_tlast_inner),
        .m_axis_tlast_auto_recover(m00_axis_tlast_auto_recover),

        // port to xilinx axi dma
        .s2mm_intr(s2mm_intr),
        .rx_pkt_intr(rx_pkt_intr_internal),

        // to byte_to_word_fcs_sn_intert
        .rx_pkt_sn_plus_one(rx_pkt_sn_plus_one),

        .m_axis_tlast_auto_recover_enable(~slv_reg12[31]),
        .m_axis_tlast_auto_recover_timeout_top(slv_reg12[12:0]),
        .start_1trans_mode(slv_reg5[2:0]),
        .start_1trans_ext_trigger(slv_reg6[0]),
        .src_sel(slv_reg7[0]),
        .tsf_runtime_val(tsf_runtime_val),
        .count_top(slv_reg13[14:0]),
//        .pad_test(slv_reg13[31]),
        
        .data_from_acc(data_from_acc),
        .data_ready_from_acc(data_ready_from_acc),
        .pkt_rate(pkt_rate),
	    .pkt_len(pkt_len),
        .sig_valid(sig_valid),
	    .ht_sgi(ht_sgi),
        .ht_unsupport(ht_unsupport),
        .fcs_valid(fcs_valid),
        
        .rf_iq(rf_iq_loopback),
        .rf_iq_valid(sample_strobe),

        .tsf_pulse_1M(tsf_pulse_1M)
    );
    
	rx_intf_m_axis # (
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.WAIT_COUNT_BITS(WAIT_COUNT_BITS),
		.MAX_NUM_DMA_SYMBOL(MAX_NUM_DMA_SYMBOL),
		.MAX_BIT_NUM_DMA_SYMBOL(MAX_BIT_NUM_DMA_SYMBOL)
	) rx_intf_m_axis_i (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN( m00_axis_aresetn&(~slv_reg0[4])&(~m_axis_auto_rst) ),
		.M_AXIS_TVALID(m00_axis_tvalid_inner),
		.M_AXIS_TDATA(m00_axis_tdata_inner),
		.M_AXIS_TSTRB(m00_axis_tstrb_inner),
		.M_AXIS_TLAST(m00_axis_tlast_inner),
		.M_AXIS_TREADY(m00_axis_tready),
		.START_COUNT_CFG(0),
		.M_AXIS_NUM_DMA_SYMBOL(num_dma_symbol_to_ps),
		.start_1trans(start_1trans_from_acc_to_m_axis),
		
        .endless_mode(slv_reg5[9]),
        .DATA_FROM_ACC(data_from_acc_to_m_axis),
        .ACC_DATA_READY(data_ready_from_acc_to_m_axis),
        .data_count(m_axis_fifo_data_count),
        .FULLN_TO_ACC(fulln_from_m_axis_to_acc)
	);

	endmodule
