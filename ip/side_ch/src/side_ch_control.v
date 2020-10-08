
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module side_ch_control #
	(
		parameter integer TSF_TIMER_WIDTH = 64, // according to 802.11 standard

		parameter integer C_S_AXI_DATA_WIDTH = 32,
		parameter integer IQ_DATA_WIDTH = 16,
	    parameter integer C_S_AXIS_TDATA_WIDTH	= 64,
        parameter integer MAX_NUM_DMA_SYMBOL = 4096,
        parameter integer MAX_BIT_NUM_DMA_SYMBOL = 13
	)
	(
        input wire clk,
        input wire rstn,

		// from pl
		input wire [(TSF_TIMER_WIDTH-1):0]  tsf_runtime_val,
		input wire demod_is_ongoing,
		input wire ofdm_symbol_eq_out_pulse,
        input wire ht_unsupport,
        input wire [7:0] pkt_rate,
		input wire [15:0] pkt_len,
		input wire [(2*IQ_DATA_WIDTH-1):0] csi,
		input wire csi_valid,
		input wire signed [31:0] phase_offset_taken,
		input wire [(2*IQ_DATA_WIDTH-1):0] equalizer,
		input wire equalizer_valid,

		input wire pkt_header_valid,
        input wire pkt_header_valid_strobe,
		input wire [31:0] FC_DI,
    	input wire FC_DI_valid,
		input wire [47:0] addr1,
		input wire addr1_valid,
		input wire [47:0] addr2,
		input wire addr2_valid,
		input wire [47:0] addr3,
		input wire addr3_valid,

		input wire fcs_in_strobe,
		input wire fcs_ok,
		input wire block_rx_dma_to_ps,
        input wire block_rx_dma_to_ps_valid,

		// from arm
	 	input wire slv_reg_wren_signal, // to capture m axis num dma symbol write, so that auto trigger start
	 	input wire [4:0] axi_awaddr_core,
		input wire [15 : 0] FC_target,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] addr1_target,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] addr2_target,
		input wire [3:0] match_cfg,
		input wire [3:0] num_eq,
		input wire [1:0] m_axis_start_mode,
		input wire m_axis_start_ext_trigger,
		// (* mark_debug = "true" *) input wire data_transfer_control,

		// s_axis
        input wire  [C_S_AXIS_TDATA_WIDTH-1 : 0] data_to_pl,
        output wire pl_ask_data,
        input wire  [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] s_axis_data_count,
        input wire  emptyn_to_pl,

		input wire  S_AXIS_TVALID,
		input wire  S_AXIS_TLAST,

		// m_axis
	 	output wire m_axis_start_1trans,

        output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] data_to_ps,
        output wire data_to_ps_valid,
        input wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] m_axis_data_count,
        input wire fulln_to_pl,
        
	 input wire  M_AXIS_TVALID,
	 input wire  M_AXIS_TLAST
	);

	// mask[0] is DC, mask[1:26] -> 1,..., 26
	// mask[38:63] -> -26,..., -1
	localparam SUBCARRIER_MASK =
		64'b1111111111111111111111111100000000000111111111111111111111111110;
	localparam HT_SUBCARRIER_MASK =
		64'b1111111111111111111111111111000000011111111111111111111111111110;
	// -7, -21, 21, 7
	localparam PILOT_MASK =
		64'b0000001000000000000010000000000000000000001000000000000010000000;
	localparam DATA_SUBCARRIER_MASK =
		SUBCARRIER_MASK ^ PILOT_MASK;
	localparam HT_DATA_SUBCARRIER_MASK = 
		HT_SUBCARRIER_MASK ^ PILOT_MASK;

	localparam integer CSI_LEN = 56; // length of single CSI
	localparam integer EQUALIZER_LEN = (56-4); // for non HT, four {32767,32767} will be padded to achieve 52 (non HT should have 48)
	localparam integer HEADER_LEN = 2; //timestamp and freq offset

	localparam [1:0]   OFDM_RX_INIT         =      2'b00,
					   OFDM_RX_COUNT        =      2'b01,
					   OFDM_RX_END          =      2'b10;

	// localparam [1:0]   CAPTURE_INIT         =      2'b00,
	// 				   CAPTURE_CSI          =      2'b01,
	// 				   CAPTURE_EQ           =      2'b10,
	// 				   CAPTURE_DONE         =      2'b11;

	localparam [3:0]   WAIT_FOR_CONDITION   =      4'b0000,
					   WAIT_FOR_CONDITION1  =      4'b0001,
					   WAIT_FOR_CONDITION2  =      4'b0010,
					   WAIT_FOR_CAPTURE_DONE=      4'b0011,
					   PREPARE_TO_M_AXIS    =      4'b0100,
					   HEADER_TO_M_AXIS     =      4'b0101,
					   HEADER1_TO_M_AXIS    =      4'b0110,
                       CSI_INFO_TO_M_AXIS   =      4'b0111,
					   EQ_INFO_TO_M_AXIS    =      4'b1000;

	wire ht_flag;
	reg  ht_flag_capture;
	wire [3:0] rate_mcs;
	reg  [8:0] N_DBPS;
	reg  ht_rst;
	reg  last_ofdm_symbol_flag;
	reg  [19:0] num_bit_decoded;
	wire [19:0] num_bit_target;
	//(* mark_debug = "true", DONT_TOUCH = "TRUE" *) 
	reg  [1:0] ofdm_rx_state;

	reg csi_valid_reg;
	reg  capture_src_flag;

	reg [8:0] side_info_count;
	reg [3:0] num_eq_count;
	reg [3:0] side_ch_state;
	reg [3:0] side_ch_state_old;
	wire [MAX_BIT_NUM_DMA_SYMBOL-1 : 0] num_dma_symbol_per_trans;

	wire num_dma_symbol_reg_wr_is_onging;
	reg num_dma_symbol_reg_wr_is_onging_reg;
	reg num_dma_symbol_reg_wr_is_onging_reg1;
	wire m_axis_start_auto_trigger;

	reg [(TSF_TIMER_WIDTH-1):0] tsf_val_lock_by_sig;
	reg demod_is_ongoing_reg;
	reg FC_DI_valid_reg;
	reg addr1_valid_reg;
	reg addr2_valid_reg;
	reg m_axis_start_1trans_reg;
	reg pl_ask_data_reg;
	reg [C_S_AXIS_TDATA_WIDTH-1 : 0] data_to_ps_reg;
	reg data_to_ps_valid_reg;

	wire pkt_begin_rst;
	wire [(2*IQ_DATA_WIDTH-1):0] side_info_fifo_dout;
	wire [(2*IQ_DATA_WIDTH-1):0] side_info_fifo_din;
	wire side_info_fifo_empty;
	wire side_info_fifo_full;
	reg  side_info_fifo_rd_en;
	wire side_info_fifo_wr_en;
	wire [9:0] side_info_fifo_rd_data_count;
	wire [9:0] side_info_fifo_wr_data_count;

 reg [C_S_AXIS_TDATA_WIDTH-1 : 0] side_info;
 reg  side_info_valid;

	reg [63:0] subcarrier_mask;

	assign ht_flag = pkt_rate[7];
	assign rate_mcs = pkt_rate[3:0];
	assign num_bit_target = 22 + {pkt_len,3'd0};

	assign pkt_begin_rst = ( demod_is_ongoing==1 && demod_is_ongoing_reg==0 );

	assign side_info_fifo_wr_en = (capture_src_flag==0?csi_valid:(last_ofdm_symbol_flag?1:equalizer_valid));
	assign side_info_fifo_din   = (capture_src_flag==0?csi:(last_ofdm_symbol_flag?0:equalizer));

	assign num_dma_symbol_per_trans = HEADER_LEN + CSI_LEN + num_eq*EQUALIZER_LEN;
	assign num_dma_symbol_reg_wr_is_onging = (slv_reg_wren_signal==1 && axi_awaddr_core==2);//slv_reg2 wr
	assign m_axis_start_auto_trigger = (num_dma_symbol_reg_wr_is_onging_reg==1 && num_dma_symbol_reg_wr_is_onging_reg1==0);

	assign m_axis_start_1trans = m_axis_start_1trans_reg;
	assign pl_ask_data = pl_ask_data_reg;
	assign data_to_ps = data_to_ps_reg;
	assign data_to_ps_valid = data_to_ps_valid_reg;

	always @( ht_flag, rate_mcs )
	begin
      case ({ht_flag,rate_mcs})
        5'b01011: begin  N_DBPS <= 24;  end  //  6 Mbps
		5'b01111: begin  N_DBPS <= 36;  end  //  9 Mbps
		5'b01010: begin  N_DBPS <= 48;  end  // 12 Mbps
		5'b01110: begin  N_DBPS <= 72;  end  // 18 Mbps
		5'b01001: begin  N_DBPS <= 96;  end  // 24 Mbps
		5'b01101: begin  N_DBPS <= 144; end  // 36 Mbps
		5'b01000: begin  N_DBPS <= 192; end  // 48 Mbps
		5'b01100: begin  N_DBPS <= 216; end  // 54 Mbps
        5'b10000: begin  N_DBPS <= 26;  end  //  6.5 Mbps
        5'b10001: begin  N_DBPS <= 52;  end  // 13.0 Mbps
        5'b10010: begin  N_DBPS <= 78;  end  // 19.5 Mbps
        5'b10011: begin  N_DBPS <= 104; end  // 26.0 Mbps
        5'b10100: begin  N_DBPS <= 156; end  // 39.0 Mbps
        5'b10101: begin  N_DBPS <= 208; end  // 52.0 Mbps
        5'b10110: begin  N_DBPS <= 234; end  // 58.5 Mbps
        5'b10111: begin  N_DBPS <= 260; end  // 65.0 Mbps
        default:  begin  N_DBPS <= 24;  end
      endcase
 	end

	// state machine tracking the rx procedure and give the last ofdm symbol indicator
	// 1. decode end; 2 header invalid; 3 ht unsupport
	always @(posedge clk) begin
		if (pkt_begin_rst) begin
			ht_rst <= 0;
			num_bit_decoded <= 0;
			ofdm_rx_state <= OFDM_RX_INIT;
			last_ofdm_symbol_flag <= 0;
		end else begin
			case (ofdm_rx_state)
				OFDM_RX_INIT: begin
					ht_rst <= 0;
					num_bit_decoded <= (ht_flag?N_DBPS:0);
					ofdm_rx_state <= (ofdm_symbol_eq_out_pulse?OFDM_RX_COUNT:ofdm_rx_state);
					last_ofdm_symbol_flag <= last_ofdm_symbol_flag;
				end

				OFDM_RX_COUNT: begin
					last_ofdm_symbol_flag <= last_ofdm_symbol_flag;
					if ( pkt_header_valid_strobe && (pkt_header_valid==0 || ht_unsupport==1) ) begin
						ht_rst <= ht_rst;
						num_bit_decoded <= num_bit_decoded;
						ofdm_rx_state <= OFDM_RX_END;
					end else if (pkt_header_valid_strobe && ht_flag) begin
						ht_rst <= 1;
						num_bit_decoded <= num_bit_decoded;
						ofdm_rx_state <= OFDM_RX_INIT;
					end else begin
						ht_rst <= ht_rst;
						num_bit_decoded <= ( ofdm_symbol_eq_out_pulse?(num_bit_decoded+N_DBPS):num_bit_decoded );
						ofdm_rx_state <= (num_bit_decoded>=num_bit_target?OFDM_RX_END:ofdm_rx_state);
					end
				end

     			OFDM_RX_END: begin
					ht_rst <= ht_rst;
					ofdm_rx_state <= ofdm_rx_state;
					last_ofdm_symbol_flag <= 1;
					num_bit_decoded <= num_bit_decoded;
				end
			endcase
		end
    end

	// generate multiplexing control signal to write csi/equalizer to fifo
    always @(posedge clk) begin
		if (pkt_begin_rst|ht_rst) begin
			capture_src_flag <= 0;
			csi_valid_reg <= 0;
		end else begin
			csi_valid_reg <= csi_valid;
			if (csi_valid == 0 && csi_valid_reg==1)
				capture_src_flag <= 1;
		end
    end

	// fifo to capture side info (csi, equalizer, etc)
	wire ALMOSTEMPTY;
	wire ALMOSTFULL;
	wire RDERR;
	wire WRERR;
	wire [8:0] WRCOUNT;
	xpm_fifo_sync #(
		.DOUT_RESET_VALUE("0"),    // String
		.ECC_MODE("no_ecc"),       // String
		.FIFO_MEMORY_TYPE("auto"), // String
		.FIFO_READ_LATENCY(0),     // DECIMAL
		.FIFO_WRITE_DEPTH(512),   // DECIMAL
		.FULL_RESET_VALUE(0),      // DECIMAL
		.PROG_EMPTY_THRESH(10),    // DECIMAL
		.PROG_FULL_THRESH(10),     // DECIMAL
		.RD_DATA_COUNT_WIDTH(10),   // DECIMAL
		.READ_DATA_WIDTH(32),      // DECIMAL
		.READ_MODE("fwft"),         // String
		.USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
		.WAKEUP_TIME(0),           // DECIMAL
		.WRITE_DATA_WIDTH(32),     // DECIMAL
		.WR_DATA_COUNT_WIDTH(10)    // DECIMAL
	)
	xpm_fifo_sync_inst (
		.almost_empty(),
		.almost_full(),
		.data_valid(),
		.dbiterr(),
		.dout(side_info_fifo_dout),
		.empty(side_info_fifo_empty),
		.full(side_info_fifo_full),
		.overflow(),
		.prog_empty(),
		.prog_full(),
		.rd_data_count(side_info_fifo_rd_data_count),
		.rd_rst_busy(),
		.sbiterr(),
		.underflow(),
		.wr_ack(),
		.wr_data_count(side_info_fifo_wr_data_count),
		.wr_rst_busy(),
		.din(side_info_fifo_din),
		.injectdbiterr(),
		.injectsbiterr(),
		.rd_en(side_info_fifo_rd_en),
		.rst(pkt_begin_rst|ht_rst),
		.sleep(),
		.wr_clk(clk),
		.wr_en(side_info_fifo_wr_en)
	);

	// state machine to put captured side info to the fifo of m_axis
    always @(posedge clk) begin
		if (!rstn) begin
			num_dma_symbol_reg_wr_is_onging_reg <= 0;
			num_dma_symbol_reg_wr_is_onging_reg1 <= 0;
			tsf_val_lock_by_sig <= 0;
			demod_is_ongoing_reg <= 0;
		 	FC_DI_valid_reg <= 0;
			addr1_valid_reg <= 0;
			addr2_valid_reg <= 0;

			ht_flag_capture <= 0;
			side_info_count <= 0;
			num_eq_count <= 0;

			side_info_fifo_rd_en <= 0;
			side_info <= 0;
			side_info_valid <= 0;
			subcarrier_mask <= HT_SUBCARRIER_MASK; // for pilot no matter it is HT or non HT there are 64 in the fifo
			side_ch_state <= WAIT_FOR_CONDITION;
			side_ch_state_old <= WAIT_FOR_CONDITION;
		end else begin
			num_dma_symbol_reg_wr_is_onging_reg <= num_dma_symbol_reg_wr_is_onging;
			num_dma_symbol_reg_wr_is_onging_reg1 <= num_dma_symbol_reg_wr_is_onging_reg;

			if (pkt_header_valid_strobe)
          		tsf_val_lock_by_sig<=tsf_runtime_val;

			demod_is_ongoing_reg <= demod_is_ongoing;
			FC_DI_valid_reg <= FC_DI_valid;
			addr1_valid_reg <= addr1_valid;
			addr2_valid_reg <= addr2_valid;

			side_ch_state_old <= side_ch_state;
			case (side_ch_state)
				WAIT_FOR_CONDITION: begin
					subcarrier_mask <= HT_SUBCARRIER_MASK;
					ht_flag_capture <= 0;
					side_info_count <= 0;
					num_eq_count <= 0;

					side_info_fifo_rd_en <= 0;
					side_info <= 0;
					side_info_valid <= 0;
					if ( (FC_DI_valid == 1 && FC_DI_valid_reg==0) && (FC_DI[15 : 0] == FC_target || match_cfg[0]==0) ) begin
						if (pkt_len >= 14) begin
							ht_flag_capture <= ht_flag;
							side_ch_state <= WAIT_FOR_CONDITION1;
						end
					end
				end

				WAIT_FOR_CONDITION1: begin
					if ( (addr1_valid == 1 && addr1_valid_reg==0) && ({addr1[23:16],addr1[31:24],addr1[39:32],addr1[47:40]} == addr1_target || match_cfg[1]==0) ) begin
						if (pkt_len >= 20) begin
							side_ch_state <= WAIT_FOR_CONDITION2;
						end else begin
							side_ch_state <= WAIT_FOR_CAPTURE_DONE;
						end
					end
				end

				WAIT_FOR_CONDITION2: begin
					if ( (addr2_valid == 1 && addr2_valid_reg==0) && ({addr2[23:16],addr2[31:24],addr2[39:32],addr2[47:40]} == addr2_target || match_cfg[2]==0) ) begin
						side_ch_state <= WAIT_FOR_CAPTURE_DONE;
					end
				end

				WAIT_FOR_CAPTURE_DONE: begin
					side_ch_state <= (last_ofdm_symbol_flag?PREPARE_TO_M_AXIS:side_ch_state);
				end

				PREPARE_TO_M_AXIS: begin
					side_ch_state <= ((MAX_NUM_DMA_SYMBOL-m_axis_data_count)>=num_dma_symbol_per_trans?HEADER_TO_M_AXIS:WAIT_FOR_CONDITION);
				end

				HEADER_TO_M_AXIS: begin
					side_info <= tsf_val_lock_by_sig;
					side_info_valid <= 1;

					side_ch_state <= HEADER1_TO_M_AXIS;
				end

				HEADER1_TO_M_AXIS: begin
					side_info <= phase_offset_taken;

					side_info_fifo_rd_en <= 1;
					side_ch_state <= CSI_INFO_TO_M_AXIS;
				end

				CSI_INFO_TO_M_AXIS: begin //transfer CSI to fifo of m_axis
					side_info_count <= (side_info_count==64?0:(side_info_count + 1));
					side_info <= {32'd0, side_info_fifo_dout};

					subcarrier_mask <= {subcarrier_mask[0], subcarrier_mask[63:1]};
					if (subcarrier_mask[0])
						side_info_valid <= 1;
					else
						side_info_valid <= 0;

					side_ch_state <= (side_info_count==64?(num_eq==0?WAIT_FOR_CONDITION:EQ_INFO_TO_M_AXIS):side_ch_state);
					side_info_fifo_rd_en <= (side_info_count==63?0:1);
				end

				EQ_INFO_TO_M_AXIS: begin //transfer equalizer result to fifo of m_axis
					side_info_valid <= 1;

					side_info_count <= (side_info_count==(EQUALIZER_LEN-1)?0:(side_info_count + 1));
					num_eq_count <= (side_info_count==(EQUALIZER_LEN-1)?(num_eq_count + 1):num_eq_count);

					if (ht_flag_capture==0) begin
						if (side_info_count>=47 && side_info_count<51) begin
							side_info_fifo_rd_en <= 0;
						end else begin
							side_info_fifo_rd_en <= 1;
						end
						if (side_info_count>47 && side_info_count<=51) begin
							side_info <= {32'd0, 16'd32767, 16'd32767};
						end else begin
							side_info <= {32'd0, side_info_fifo_dout};
						end
					end else begin
						side_info <= {32'd0, side_info_fifo_dout};
						side_info_fifo_rd_en <= 1;
					end

					side_ch_state <= ((num_eq_count==(num_eq-1) && side_info_count==(EQUALIZER_LEN-1))?WAIT_FOR_CONDITION:side_ch_state);
				end
			endcase
		end
    end

	// select data source and mode to m_axis
    always @( m_axis_start_mode,m_axis_start_ext_trigger,S_AXIS_TLAST,emptyn_to_pl,data_to_pl,side_info,side_info_valid,m_axis_start_auto_trigger)//,data_transfer_control)
    begin
       case (m_axis_start_mode)
          2'b00 : begin // loop back from s_axis
                    m_axis_start_1trans_reg = S_AXIS_TLAST;
					data_to_ps_reg = data_to_pl;
					data_to_ps_valid_reg = emptyn_to_pl;
					pl_ask_data_reg = 1;
                  end
          2'b01 : begin
                    m_axis_start_1trans_reg = m_axis_start_auto_trigger;
					data_to_ps_reg = side_info;
					data_to_ps_valid_reg = side_info_valid;
					pl_ask_data_reg = 0;
                  end
          2'b10 : begin
                    m_axis_start_1trans_reg = m_axis_start_ext_trigger;
					data_to_ps_reg = side_info;
					data_to_ps_valid_reg = side_info_valid;
					pl_ask_data_reg = 0;
                  end
          2'b11 : begin
                    // m_axis_start_1trans_reg = m_axis_start_ext_trigger;
					// data_to_ps_reg = data_to_pl;
					// data_to_ps_valid_reg = (pl_ask_data&emptyn_to_pl);
					// pl_ask_data_reg = data_transfer_control;
					m_axis_start_1trans_reg = 0;
					data_to_ps_reg = 0;
					data_to_ps_valid_reg = 0;
					pl_ask_data_reg = 0;
                  end
       endcase
    end

	endmodule
