// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "clock_speed.v"

`timescale 1 ns / 1 ps

	module tx_intf #
	(
		parameter integer DAC_PACK_DATA_WIDTH	= 64,
		parameter integer IQ_DATA_WIDTH	=     16,
		parameter integer WIFI_TX_BRAM_DATA_WIDTH = 64,
		parameter integer WIFI_TX_BRAM_ADDR_WIDTH = 10,
		parameter integer WIFI_TX_BRAM_WEN_WIDTH = 8,
		
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7,

		parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 64,
		
        parameter integer WAIT_COUNT_BITS = 5,
`ifdef SMALL_FPGA
		parameter integer MAX_NUM_DMA_SYMBOL = 4096
`else
        parameter integer MAX_NUM_DMA_SYMBOL = 8192
`endif
	)
	(
	    input wire dac_rst,
        input wire dac_clk,

	    // connect axi_ad9361_dac_dma
        input  wire dma_valid,
        input  wire [(DAC_PACK_DATA_WIDTH-1) : 0] dma_data,
        output wire dma_ready,
        
        // connect util_ad9361_dac_upack
        output wire dac_valid,
        output wire [(DAC_PACK_DATA_WIDTH-1) : 0] dac_data,
        input  wire dac_ready,

	    // Ports to ACC: PHY_TX
	    output wire phy_tx_start,
        output wire tx_hold,
        input wire  [(WIFI_TX_BRAM_ADDR_WIDTH-1):0] bram_addr,
        input wire signed [(IQ_DATA_WIDTH-1) : 0] rf_i_from_acc,
	    input wire signed [(IQ_DATA_WIDTH-1) : 0] rf_q_from_acc,
	    input wire rf_iq_valid_from_acc,
	    output wire [(WIFI_TX_BRAM_DATA_WIDTH-1) : 0] data_to_acc,
        output wire  [(WIFI_TX_BRAM_ADDR_WIDTH-1):0] bram_addr_to_xpu,
        input wire tx_start_from_acc,
        input wire tx_end_from_acc,
    
	    // interrupt to PS
        output wire tx_itrpt,

        // for xpu
        input wire [4:0] tx_status,
        input wire [47:0] mac_addr,
        output wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] douta,//for changing some bits to indicate it is the 1st pkt or retransmitted pkt
        // output wire [(IQ_DATA_WIDTH-1):0] i0,
        // output wire [(IQ_DATA_WIDTH-1):0] q0,
        // output wire [(IQ_DATA_WIDTH-1):0] i1,
        // output wire [(IQ_DATA_WIDTH-1):0] q1,
        // output wire iq_valid,
        //output wire [31:0] mixer_cfg,
        output wire tx_iq_fifo_empty,
        //output wire [13:0] tx_iq_fifo_data_count,
        input wire high_tx_allowed0, // when this is valid, driver takes over tx, other wise xpu takes over tx
        input wire high_tx_allowed1, // for another queue
        input wire high_tx_allowed2,
        input wire high_tx_allowed3,
        input wire tx_bb_is_ongoing,
        input wire ack_tx_flag,
        input wire wea_from_xpu,
        input wire [9:0] addra_from_xpu,
        input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_from_xpu,
        output wire tx_pkt_need_ack,
        output wire [3:0] tx_pkt_retrans_limit,
        input wire tx_try_complete,
        input wire retrans_in_progress,
        input wire start_retrans,
        input wire start_tx_ack,
        output wire cts_toself_bb_is_ongoing,
        output wire cts_toself_rf_is_ongoing,
        input wire tsf_pulse_1M,
        input wire [3:0] band,
        input wire [7:0] channel,
        output wire quit_retrans,

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

		// Ports of Axi Slave Bus Interface S00_AXIS to PS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);

	function integer clogb2 (input integer bit_depth);                                   
      begin                                                                              
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
          bit_depth = bit_depth >> 1;                                                    
      end                                                                                
    endfunction   
    
    localparam integer MAX_BIT_NUM_DMA_SYMBOL  = clogb2(MAX_NUM_DMA_SYMBOL);

    wire slv_reg_rden;
    wire [4:0] axi_araddr_core;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg0; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg1; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg2; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg3; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg4; // CTS duration for CTS-TO-SELF CTS-PROTECT TX
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg5; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg6; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg7; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg8; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg9; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg10; 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg11; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg12; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg13; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg14; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg15; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg16; 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg17; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg18; 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg19;
    // wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg20; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg21; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg22; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg23; // 
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg24; 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg25; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg26; 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg27; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg28; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg29; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg30; // 
    //wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg31; // MSB 8 bits are used for version read out
    
    wire [(2*IQ_DATA_WIDTH-1) : 0] ant_data;
    wire ant_data_valid;
    
    wire fulln_from_dac_to_duc;

    wire [(2*IQ_DATA_WIDTH-1) : 0] wifi_iq_pack;
    wire wifi_iq_valid;
    wire wifi_iq_ready;
    
    wire [(C_S00_AXIS_TDATA_WIDTH-1):0] s_axis_data_to_acc;
    wire tx_bit_intf_acc_ask_data_from_s_axis;
    wire acc_ask_data_from_s_axis;
    wire s_axis_emptyn_to_acc;
    wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] s_axis_fifo_data_count0;
    wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] s_axis_fifo_data_count1;
    wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] s_axis_fifo_data_count2;
    wire [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] s_axis_fifo_data_count3;
    //(* mark_debug = "true" *) wire [1:0] tx_queue_idx;
    wire [1:0] tx_queue_idx;
    wire [1:0] linux_prio;
    wire [9:0] tx_pkt_sn;
    // wire [15:0] tx_pkt_num_dma_byte;

    wire [6:0] num_dma_symbol_fifo_data_count0;
    wire [6:0] num_dma_symbol_fifo_data_count1;
    wire [6:0] num_dma_symbol_fifo_data_count2;
    wire [6:0] num_dma_symbol_fifo_data_count3;

    wire [5:0] dac_intf_rd_data_count;
    wire [5:0] dac_intf_wr_data_count;
    wire [27:0] dac_intf_counter_1s;
    wire [26:0] dac_intf_counter_rden_store;
    wire [27:0] dac_intf_counter_dac;
    wire [26:0] dac_intf_counter_wren_store;
    
    wire phy_tx_auto_start_mode;
    wire [9:0] phy_tx_auto_start_num_dma_symbol_th;
    
    wire s_axis_recv_data_from_high;
    
    wire tx_itrpt_internal;

    wire [13:0] send_cts_toself_wait_sifs_top;

    assign bram_addr_to_xpu = bram_addr;
    assign send_cts_toself_wait_sifs_top = (band==1?slv_reg6[13:0]:slv_reg6[29:16]);

	assign phy_tx_auto_start_mode = slv_reg2[3];
	assign phy_tx_auto_start_num_dma_symbol_th = slv_reg2[13:4];

    assign slv_reg21[0] = (s_axis_fifo_data_count0>slv_reg11[(MAX_BIT_NUM_DMA_SYMBOL-1):0]?1:0);
    assign slv_reg21[1] = (s_axis_fifo_data_count1>slv_reg11[(MAX_BIT_NUM_DMA_SYMBOL-1):0]?1:0);
    assign slv_reg21[2] = (s_axis_fifo_data_count2>slv_reg11[(MAX_BIT_NUM_DMA_SYMBOL-1):0]?1:0);
    assign slv_reg21[3] = (s_axis_fifo_data_count3>slv_reg11[(MAX_BIT_NUM_DMA_SYMBOL-1):0]?1:0);

    assign acc_ask_data_from_s_axis = tx_bit_intf_acc_ask_data_from_s_axis;

    assign tx_itrpt = (slv_reg14[17]==0?(slv_reg14[8]?tx_itrpt_internal: (tx_itrpt_internal&(~ack_tx_flag)) ):0);

    // assign slv_reg22[29:0] = {linux_prio,tx_queue_idx,tx_pkt_sn,tx_pkt_num_dma_byte};

    // assign slv_reg24[1:0] = tx_queue_idx;
    // assign slv_reg24[13:2] = tx_pkt_sn;
    assign slv_reg24[6:0] = num_dma_symbol_fifo_data_count0;
    assign slv_reg24[14:8] = num_dma_symbol_fifo_data_count1;
    assign slv_reg24[22:16] = num_dma_symbol_fifo_data_count2;
    assign slv_reg24[30:24] = num_dma_symbol_fifo_data_count3;
    
    dac_intf # (
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH),
        .DAC_PACK_DATA_WIDTH(DAC_PACK_DATA_WIDTH)
    ) dac_intf_i (
        .dac_rst(dac_rst|slv_reg0[0]),
        .dac_clk(dac_clk),

        //connect util_ad9361_dac_upack
        .dac_data(dac_data),
        .dac_valid(dac_valid),
        .dac_ready(dac_ready),
        
        //connect axi_ad9361_dac_dma
        .dma_data(dma_data),
        .dma_valid(dma_valid),
        .dma_ready(dma_ready),
        
        //select between original dma and our own wifi tx and duc
        .src_sel(slv_reg7[1]),
        
        .ant_flag(slv_reg16[1]), //slv_reg16: 1: first antenna; 2: second antenna

        .acc_clk(s00_axi_aclk),
        .acc_rstn(s00_axi_aresetn&(~slv_reg0[5])),

        //from duc&ant_selection
        .data_from_acc(ant_data),
        .data_valid_from_acc(ant_data_valid&(~slv_reg10[1])),
        .fulln_to_acc(fulln_from_dac_to_duc)
    );
        
    duc_bank_core # (
    ) duc_bank_core_i (
        .clk(s00_axis_aclk),
        .rstn(s00_axis_aresetn&(~slv_reg0[1])),
        .ant_data_full_n(fulln_from_dac_to_duc),
        .ant_data_wr_data(ant_data),
        .ant_data_wr_en(ant_data_valid),
        .cfg0(slv_reg1),
        .bw20_data_tdata(wifi_iq_pack),
        .bw20_data_tready(wifi_iq_ready),
        .bw20_data_tvalid(wifi_iq_valid)
    );
    
// Instantiation of Axi Bus Interface S00_AXI
	tx_intf_s_axi # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) tx_intf_s_axi_i (
        .slv_reg_rden(slv_reg_rden),
		.axi_araddr_core(axi_araddr_core),

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
        .SLV_REG14(slv_reg14),
        //.SLV_REG15(slv_reg15),
		.SLV_REG16(slv_reg16),
        //.SLV_REG17(slv_reg17),
        //.SLV_REG18(slv_reg18),
        //.SLV_REG19(slv_reg19),
        // .SLV_REG20(slv_reg20),
        .SLV_REG21(slv_reg21),
        .SLV_REG22(slv_reg22),
        //.SLV_REG23(slv_reg23),
		.SLV_REG24(slv_reg24)/*,
        .SLV_REG25(slv_reg25),
        .SLV_REG26(slv_reg26),
        .SLV_REG27(slv_reg27),
        .SLV_REG28(slv_reg28),
        .SLV_REG29(slv_reg29),
        .SLV_REG30(slv_reg30),
        .SLV_REG31(slv_reg31)*/
	);

    tx_status_fifo tx_status_fifo_i ( // hooked to slv_reg22!
        .rstn(s00_axis_aresetn&(~slv_reg0[7])),
        .clk(s00_axis_aclk),
            
        .slv_reg_rden(slv_reg_rden),
        .axi_araddr_core(axi_araddr_core),

        .tx_try_complete(tx_try_complete),
        .tx_status(tx_status),
        .linux_prio(linux_prio),
        .tx_queue_idx(tx_queue_idx),
        .tx_pkt_sn(tx_pkt_sn),
        // .s_axis_fifo_data_count0(s_axis_fifo_data_count0),
        // .s_axis_fifo_data_count1(s_axis_fifo_data_count1),
        // .s_axis_fifo_data_count2(s_axis_fifo_data_count2),
        // .s_axis_fifo_data_count3(s_axis_fifo_data_count3),
        
        .tx_status_out(slv_reg22[18:0])
    );

// Instantiation of Axi Bus Interface S00_AXIS
	tx_intf_s_axis # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
		.MAX_NUM_DMA_SYMBOL(MAX_NUM_DMA_SYMBOL),
        .MAX_BIT_NUM_DMA_SYMBOL(MAX_BIT_NUM_DMA_SYMBOL)
	) tx_intf_s_axis_i (
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn&(~slv_reg0[2])),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid),
		.S_AXIS_NUM_DMA_SYMBOL_raw(slv_reg8[12:0]),
		
		.s_axis_recv_data_from_high(s_axis_recv_data_from_high),
		
		.tx_queue_idx_indication_from_ps(slv_reg8[19:18]),
		.tx_queue_idx(tx_queue_idx),
		.endless_mode(slv_reg5[8]),
		.data_count0(s_axis_fifo_data_count0),
		.data_count1(s_axis_fifo_data_count1),
		.data_count2(s_axis_fifo_data_count2),
		.data_count3(s_axis_fifo_data_count3),
        .DATA_TO_ACC(s_axis_data_to_acc),
        .EMPTYN_TO_ACC(s_axis_emptyn_to_acc),
        .ACC_ASK_DATA(acc_ask_data_from_s_axis&(~slv_reg10[0]))
	);

    tx_interrupt_selection tx_interrupt_selection_i (
        // selection
        .src_sel(slv_reg14[2:0]),
        // src
        .s00_axis_tlast(s00_axis_tlast),
        .phy_tx_start(phy_tx_start),
        .tx_start_from_acc(tx_start_from_acc),
        .tx_end_from_acc(tx_end_from_acc),
        .tx_try_complete(tx_try_complete),

	    // to ps interrupt
	    .tx_itrpt(tx_itrpt_internal)
	);

    tx_bit_intf # (
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .WIFI_TX_BRAM_ADDR_WIDTH(WIFI_TX_BRAM_ADDR_WIDTH),
        .WIFI_TX_BRAM_DATA_WIDTH(WIFI_TX_BRAM_DATA_WIDTH),
        .WIFI_TX_BRAM_WEN_WIDTH(WIFI_TX_BRAM_WEN_WIDTH)
    ) tx_bit_intf_i (
        .rstn(s00_axis_aresetn&(~slv_reg0[6])),
        .clk(s00_axis_aclk),
        
        // recv bits from s_axis
        .tx_queue_idx(tx_queue_idx),
        .linux_prio(linux_prio),
        .data_from_s_axis(s_axis_data_to_acc),
        .ask_data_from_s_axis(tx_bit_intf_acc_ask_data_from_s_axis),
        .emptyn_from_s_axis(s_axis_emptyn_to_acc),
        
        // src indication
        .auto_start_mode(phy_tx_auto_start_mode),
        .num_dma_symbol_th(phy_tx_auto_start_num_dma_symbol_th),
        .num_dma_symbol_total(slv_reg8[31:0]), // high two bits to indicate whether tx should be disable after certain type of tx (for waiting ack)
        .tx_queue_idx_indication_from_ps(slv_reg8[19:18]),
        .s_axis_recv_data_from_high(s_axis_recv_data_from_high),
        .start(phy_tx_start),

        .num_dma_symbol_fifo_data_count0(num_dma_symbol_fifo_data_count0), 
        .num_dma_symbol_fifo_data_count1(num_dma_symbol_fifo_data_count1),
        .num_dma_symbol_fifo_data_count2(num_dma_symbol_fifo_data_count2), 
        .num_dma_symbol_fifo_data_count3(num_dma_symbol_fifo_data_count3),

        .tx_iq_fifo_empty(tx_iq_fifo_empty),
        .cts_toself_config(slv_reg4),
        .send_cts_toself_wait_sifs_top(send_cts_toself_wait_sifs_top),
        .mac_addr(mac_addr),
        .tx_try_complete(tx_try_complete),
        .retrans_in_progress(retrans_in_progress),
        .start_retrans(start_retrans),
        .start_tx_ack(start_tx_ack),
        .high_tx_allowed0(high_tx_allowed0),
        .high_tx_allowed1(high_tx_allowed1),
        .high_tx_allowed2(high_tx_allowed2),
        .high_tx_allowed3(high_tx_allowed3),
        .tx_bb_is_ongoing(tx_bb_is_ongoing),
        .ack_tx_flag(ack_tx_flag),
        .wea_from_xpu(wea_from_xpu),
        .addra_from_xpu(addra_from_xpu),
        .dina_from_xpu(dina_from_xpu),
        .tx_pkt_need_ack(tx_pkt_need_ack),
        .tx_pkt_retrans_limit(tx_pkt_retrans_limit),
        .quit_retrans(quit_retrans),
        .tx_pkt_sn(tx_pkt_sn),
        // .tx_pkt_num_dma_byte(tx_pkt_num_dma_byte),
        .douta(douta),
        .cts_toself_bb_is_ongoing(cts_toself_bb_is_ongoing),
        .cts_toself_rf_is_ongoing(cts_toself_rf_is_ongoing),
         
         // to send out to wifi tx module
        .tx_end_from_acc(tx_end_from_acc),
        .bram_data_to_acc(data_to_acc),
        .bram_addr(bram_addr),

        .tsf_pulse_1M(tsf_pulse_1M)
    );

    tx_iq_intf # (
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
        .IQ_DATA_WIDTH(IQ_DATA_WIDTH)
    ) tx_iq_intf_i (
        .rstn(s00_axis_aresetn&(~slv_reg0[3])),
        .clk(s00_axis_aclk),
        // to duc
        .wifi_iq_pack(wifi_iq_pack),
        .wifi_iq_ready(wifi_iq_ready),
        .wifi_iq_valid(wifi_iq_valid),

        .tx_hold_threshold(slv_reg12[10:0]),
        .bb_gain(slv_reg13[9:0]),
        // iq generated by outside wifi tx module
        .rf_i(rf_i_from_acc),
        .rf_q(rf_q_from_acc),
        .rf_iq_valid(rf_iq_valid_from_acc),

        .tx_iq_fifo_empty(tx_iq_fifo_empty),
        .tx_hold(tx_hold)
    );
    
	endmodule
