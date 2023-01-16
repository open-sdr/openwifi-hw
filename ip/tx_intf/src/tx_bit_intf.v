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

`define WAIT_FOR_TX_IQ_FILL_COUNT_TOP (20*`NUM_CLK_PER_US)

	module tx_bit_intf #
	(
        parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
        parameter integer WIFI_TX_BRAM_ADDR_WIDTH = 10,
        parameter integer WIFI_TX_BRAM_DATA_WIDTH = 64,
        parameter integer WIFI_TX_BRAM_WEN_WIDTH = 8
	)
	(
	    input wire rstn,
	    input wire clk,
	    
      // from openofdm rx
      `DEBUG_PREFIX input  wire fcs_in_strobe,

	    input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] data_from_s_axis,
	    `DEBUG_PREFIX output wire ask_data_from_s_axis,
	    `DEBUG_PREFIX input wire  emptyn_from_s_axis,
	    `DEBUG_PREFIX output wire [2:0] tx_queue_idx,
	    `DEBUG_PREFIX output reg  [2:0] linux_prio,
	    `DEBUG_PREFIX output reg  [5:0] pkt_cnt,
	    
	    //input wire src_indication,//0-s_axis-->phy_tx-->iq-->duc; 1-s_axis-->iq-->duc
	    input wire auto_start_mode,
	    input wire [9:0] num_dma_symbol_th,
	    `DEBUG_PREFIX input wire [31:0] tx_config,
	    `DEBUG_PREFIX input wire [2:0] tx_queue_idx_indication_from_ps,
	    `DEBUG_PREFIX input wire [31:0] phy_hdr_config,
	    input wire [31:0] ampdu_action_config,
	    `DEBUG_PREFIX input wire s_axis_recv_data_from_high,
	    `DEBUG_PREFIX output wire start,

      `DEBUG_PREFIX output wire [6:0] tx_config_fifo_data_count0,
      `DEBUG_PREFIX output wire [6:0] tx_config_fifo_data_count1,
      `DEBUG_PREFIX output wire [6:0] tx_config_fifo_data_count2,
      `DEBUG_PREFIX output wire [6:0] tx_config_fifo_data_count3,

      `DEBUG_PREFIX input wire tx_iq_fifo_empty,
      input wire [31:0] cts_toself_config,
      input wire [13:0] send_cts_toself_wait_sifs_top, //between cts and following frame, there should be a sifs waiting period
      input wire [47:0] mac_addr,
      `DEBUG_PREFIX input wire tx_try_complete,
      `DEBUG_PREFIX input wire retrans_in_progress,
      `DEBUG_PREFIX input wire start_retrans,
      `DEBUG_PREFIX input wire start_tx_ack,
      `DEBUG_PREFIX input wire tx_control_state_idle,
	    `DEBUG_PREFIX input wire [3:0] slice_en,
      `DEBUG_PREFIX input wire backoff_done,
	    `DEBUG_PREFIX input wire tx_bb_is_ongoing,
	    `DEBUG_PREFIX input wire ack_tx_flag,
	    `DEBUG_PREFIX input wire wea_from_xpu,
      input wire [9:0] addra_from_xpu,
      input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_from_xpu,
      `DEBUG_PREFIX output wire tx_pkt_need_ack,
      `DEBUG_PREFIX output wire [3:0] tx_pkt_retrans_limit,
      `DEBUG_PREFIX output wire use_ht_aggr,
      `DEBUG_PREFIX output reg quit_retrans,
      `DEBUG_PREFIX output reg reset_backoff,
      `DEBUG_PREFIX output reg high_trigger,
      `DEBUG_PREFIX output reg [5:0] bd_wr_idx,
      // output reg [15:0] tx_pkt_num_dma_byte,
      output wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] douta,
      output reg cts_toself_bb_is_ongoing,
      output reg cts_toself_rf_is_ongoing,
	    
	    // port to phy_tx
	    `DEBUG_PREFIX input wire tx_end_from_acc,
	    output wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] bram_data_to_acc,
      input wire  [(WIFI_TX_BRAM_ADDR_WIDTH-1):0] bram_addr,

      input wire tsf_pulse_1M
	);
    
    localparam [3:0]   WAIT_TO_TRIG=                    4'b0000,
                       WAIT_CHANCE =                    4'b0001,
                       PREPARE_TX_FETCH=                4'b0010,
                       PREPARE_TX_JUDGE=                4'b0011,
                       DO_CTS_TOSELF=                   4'b0100,
                       WAIT_SIFS =                      4'b0101,
                       CHECK_AGGR =                     4'b0110,
                       PREP_PHY_HDR =                   4'b0111,
                       DO_PHY_HDR1 =                    4'b1000,
                       DO_PHY_HDR2 =                    4'b1001,
                       DO_TX =                          4'b1010,
                       WAIT_TX_COMP =                   4'b1011;
    `DEBUG_PREFIX reg [3:0] high_tx_ctl_state;
    `DEBUG_PREFIX reg [3:0] high_tx_ctl_state_old;
    
    reg  [13:0] send_cts_toself_wait_count;
    `DEBUG_PREFIX reg  [12:0] wr_counter;
    `DEBUG_PREFIX reg read_from_s_axis_en;
    
    `DEBUG_PREFIX wire wea_high;
    `DEBUG_PREFIX wire wea;
    `DEBUG_PREFIX wire [9:0] addra;
    `DEBUG_PREFIX wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina;
    wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] bram_data_to_acc_int;

    `DEBUG_PREFIX reg wea_internal;
    reg [12:0] addra_internal;
    reg [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_internal;

    `DEBUG_PREFIX reg [3:0] floating_pkt_flag;
    
    `DEBUG_PREFIX reg [1:0] tx_queue_idx_reg;
    `DEBUG_PREFIX wire [63:0] tx_config_fifo_rd_data0;
    `DEBUG_PREFIX wire [63:0] tx_config_fifo_rd_data1;
    `DEBUG_PREFIX wire [63:0] tx_config_fifo_rd_data2;
    `DEBUG_PREFIX wire [63:0] tx_config_fifo_rd_data3;
    reg [63:0] tx_config_current, tx_config_current_prev;
    reg [63:0] tx_config_current_next [3:0];

    wire [3:0] rate_signal_value;
    wire [3:0] cts_rate_signal_value;
    wire [15:0] cts_duration;
    wire use_cts_traffice_rate;
    wire use_cts_protect;

    assign tx_pkt_need_ack = tx_config_current[13];
    assign tx_pkt_retrans_limit = tx_config_current[17:14];
    assign rate_signal_value = tx_config_current[35:32];
    assign cts_rate_signal_value = tx_config_current[39:36];
    assign cts_duration = tx_config_current[55:40];
    assign use_cts_traffice_rate = tx_config_current[62];
    assign use_cts_protect = tx_config_current[63];

    `DEBUG_PREFIX wire [31:0] phy_hdr_config_fifo_rd_data0;
    `DEBUG_PREFIX wire [31:0] phy_hdr_config_fifo_rd_data1;
    `DEBUG_PREFIX wire [31:0] phy_hdr_config_fifo_rd_data2;
    `DEBUG_PREFIX wire [31:0] phy_hdr_config_fifo_rd_data3;

    reg [31:0] phy_hdr_config_current, phy_hdr_config_current_prev;
    reg [31:0] phy_hdr_config_current_next [3:0];
    `DEBUG_PREFIX wire [12:0] len_psdu;
    wire use_short_gi;
    wire use_ht_rate;
    `DEBUG_PREFIX wire [3:0] rate_hw_value;
    wire ht_aggr_start;
    assign len_psdu = phy_hdr_config_current[12:0];
    assign use_ht_aggr = phy_hdr_config_current[13];
    assign use_short_gi = phy_hdr_config_current[14];
    assign use_ht_rate = phy_hdr_config_current[15];
    assign rate_hw_value = phy_hdr_config_current[19:16];
    assign ht_aggr_start = phy_hdr_config_current[20];

    reg [3:0] rate_legacy;
    reg [8:0] dbps_ht;
    always @(rate_hw_value)
    case(rate_hw_value)
       0: begin rate_legacy = 4'd11; dbps_ht = 9'd26; end
       1: begin rate_legacy = 4'd11; dbps_ht = 9'd52; end
       2: begin rate_legacy = 4'd11; dbps_ht = 9'd78; end
       3: begin rate_legacy = 4'd11; dbps_ht = 9'd104; end
       4: begin rate_legacy = 4'd11; dbps_ht = 9'd156; end
       5: begin rate_legacy = 4'd15; dbps_ht = 9'd208; end
       6: begin rate_legacy = 4'd10; dbps_ht = 9'd234; end
       7: begin rate_legacy = 4'd14; dbps_ht = 9'd260; end
       8: begin rate_legacy = 4'd9;  dbps_ht = 9'd26; end
       9: begin rate_legacy = 4'd13; dbps_ht = 9'd26; end
      10: begin rate_legacy = 4'd8;  dbps_ht = 9'd26; end
      11: begin rate_legacy = 4'd12; dbps_ht = 9'd26; end
      12: begin rate_legacy = 4'd0;  dbps_ht = 9'd26; end
      13: begin rate_legacy = 4'd0;  dbps_ht = 9'd26; end
      14: begin rate_legacy = 4'd0;  dbps_ht = 9'd26; end
      15: begin rate_legacy = 4'd0;  dbps_ht = 9'd26; end
    endcase

    `DEBUG_PREFIX reg num_data_sym_ready;
    `DEBUG_PREFIX reg len_legacy_ready;
    `DEBUG_PREFIX reg [11:0] len_legacy;
    `DEBUG_PREFIX reg [15:0] len_ht;
    `DEBUG_PREFIX reg [12:0] len_pkt_sym;
    `DEBUG_PREFIX wire [16:0] l_sig_data;
    `DEBUG_PREFIX wire l_sig_parity;
    assign l_sig_data = {len_legacy, 1'b0, (use_ht_rate == 0 ? rate_legacy : 4'd11)};
    assign l_sig_parity = ^l_sig_data;

    `DEBUG_PREFIX reg [3:0] tx_config_fifo_rden;
    `DEBUG_PREFIX reg [3:0] tx_config_fifo_wren;
    `DEBUG_PREFIX wire [3:0] tx_config_fifo_empty;
    `DEBUG_PREFIX wire [3:0] tx_config_fifo_full;

    `DEBUG_PREFIX wire high_prio_pkt_waiting;
    assign high_prio_pkt_waiting = ((((1<<tx_queue_idx_reg)-1)&tx_config_fifo_empty) != ((1<<tx_queue_idx_reg)-1));

    `DEBUG_PREFIX wire s_axis_recv_data_from_high_valid;

    `DEBUG_PREFIX wire [15:0] max_tx_bytes;
    `DEBUG_PREFIX wire [5:0] buf_size;
    `DEBUG_PREFIX wire [2:0] ampdu_density;
    assign max_tx_bytes  = ampdu_action_config[15:0];
    assign buf_size      = ampdu_action_config[21:16];
    assign ampdu_density = ampdu_action_config[24:22];
    
    reg start_delay0;
    reg start_delay1;
    reg start_delay2;
    reg start_delay3;
    reg start_delay4;
    reg start_delay5;

    `DEBUG_PREFIX reg tx_try_complete_dl0;
    `DEBUG_PREFIX reg tx_try_complete_dl1;
    `DEBUG_PREFIX reg tx_try_complete_dl2;
    `DEBUG_PREFIX wire tx_try_complete_dl_pulses;

    `DEBUG_PREFIX reg fcs_in_strobe_dl0;
    `DEBUG_PREFIX reg fcs_in_strobe_dl1;
    `DEBUG_PREFIX wire fcs_in_strobe_dl_pulses;
 
    `DEBUG_PREFIX reg s_axis_recv_data_from_high_delay;

    reg [3:0] cts_toself_rate;
    wire cts_toself_signal_parity;
    wire [11:0] cts_toself_signal_len;

    reg [47:0] mac_addr_reg;

    reg [13:0] send_cts_toself_wait_sifs_top_scale;

    assign fcs_in_strobe_dl_pulses = (fcs_in_strobe || fcs_in_strobe_dl0 || fcs_in_strobe_dl1);
    assign tx_try_complete_dl_pulses = (tx_try_complete || tx_try_complete_dl0 || tx_try_complete_dl1 || tx_try_complete_dl2) ;
    assign ask_data_from_s_axis = read_from_s_axis_en;
    assign start = ( (auto_start_mode==1'b0)?(1'b0): (start_delay0|start_delay1|start_delay2|start_delay3|start_delay4|start_delay5) );

    assign wea_high = (read_from_s_axis_en&emptyn_from_s_axis);
    assign wea = ( (retrans_in_progress)?wea_from_xpu:wea_internal );
    assign addra = ( (retrans_in_progress)?addra_from_xpu:addra_internal );
    assign dina = ( (retrans_in_progress)?dina_from_xpu:dina_internal );
    assign bram_data_to_acc = (ack_tx_flag? dina_from_xpu:bram_data_to_acc_int);
    
    assign s_axis_recv_data_from_high_valid = ( ((s_axis_recv_data_from_high==0) && (s_axis_recv_data_from_high_delay==1))?1:0 );
    
    assign tx_queue_idx = tx_queue_idx_reg;

    assign cts_toself_signal_parity = (~(^cts_toself_rate)); //because the cts and ack pkt length field is always 14: 1110 that always has 3 1s
    assign cts_toself_signal_len = 14;

    reg div_start;     // start signal
    wire div_busy;     // calculation in progress
    wire div_valid;    // quotient and remainder are valid
    wire div_dbz;      // divide by zero flag
    reg [15:0] dividend;
    reg [15:0] divisor;
    wire [15:0] quotient;
    wire [15:0] remainder;
    wire [15:0] num_data_sym;

    // integer division (https://projectf.io/posts/division-in-verilog/)
    div_int  #(.WIDTH(16)) div_int_inst (
        .clk(clk),
        .reset(!rstn),
        .start(div_start),
        .busy(div_busy),
        .valid(div_valid),
        .dbz(div_dbz),
        .x(dividend),
        .y(divisor),
        .q(quotient),
        .r(remainder)
    );
    assign num_data_sym = quotient + (remainder == 0 ? 0 : 1);

    // HT_SIG CRC calculation
    reg ht_sig_crc_ready;
    reg [33:0] ht_sig_data;
    reg ht_sig_crc_start;
    wire ht_sig_crc_busy;
    wire ht_sig_crc_valid;
    wire [7:0] ht_sig_crc;
    reg [7:0] ht_sig_crc_reg;
    ht_sig_crc_calc ht_sig_crc_calc_inst (
        .clk(clk),
        .reset(!rstn),
        .d(ht_sig_data),
        .start(ht_sig_crc_start),
        .busy(ht_sig_crc_busy),
        .valid(ht_sig_crc_valid),
        .crc(ht_sig_crc)
    );
    
    // state machine to do tx for high layer if slice_en and csma allowed
	  always @(posedge clk)                                             
    begin
      if (!rstn)
        begin
          wea_internal<=0;
          addra_internal<=0;
          dina_internal<=0;

          pkt_cnt <= 0;
          len_ht <= 0;

          cts_toself_rate<=0;
          send_cts_toself_wait_sifs_top_scale <= 0;

          num_data_sym_ready <= 0;
          len_legacy_ready <= 0;
          len_legacy <= 0;
          ht_sig_crc_ready <= 0;
          len_pkt_sym <= 0;
          ht_sig_crc_reg <= 0;

          read_from_s_axis_en <= 0;      
          floating_pkt_flag<= 4'b0000;
          tx_config_current <= 0;
          tx_config_fifo_rden<= 4'b0000;
          high_tx_ctl_state <= WAIT_TO_TRIG;
          high_tx_ctl_state_old<=WAIT_TO_TRIG;
          wr_counter <= 13'b0;
          tx_queue_idx_reg<=0;
          send_cts_toself_wait_count<=0;

          cts_toself_bb_is_ongoing<=0;
          cts_toself_rf_is_ongoing<=0;
          quit_retrans<=0;
          reset_backoff<=0;
          high_trigger<=0;
          mac_addr_reg<=0;
        end                                                                   
      else begin
        high_tx_ctl_state_old <= high_tx_ctl_state;
        cts_toself_rate <= (use_cts_traffice_rate ? rate_signal_value : cts_rate_signal_value);
        mac_addr_reg <= mac_addr;

        send_cts_toself_wait_sifs_top_scale <= (send_cts_toself_wait_sifs_top*`COUNT_SCALE);

        case (high_tx_ctl_state)                                                 
          WAIT_TO_TRIG:begin
            wea_internal<=0;
            addra_internal<=0;
            dina_internal<=0;

            reset_backoff<=0;

            cts_toself_bb_is_ongoing<=0;
            cts_toself_rf_is_ongoing<=0;

            read_from_s_axis_en <= 0;
            if ( slice_en[0] && (~tx_config_fifo_empty[0] || floating_pkt_flag[0]) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && tx_control_state_idle && (~tx_try_complete_dl_pulses) && (~fcs_in_strobe_dl_pulses)) begin
              if(retrans_in_progress == 1) begin
                quit_retrans <= 1;
                high_tx_ctl_state<=WAIT_TX_COMP;
                tx_queue_idx_reg<=tx_queue_idx_reg;
                high_trigger<=0;
              end else begin
                quit_retrans<=0;
                tx_queue_idx_reg<=0; 
                high_tx_ctl_state<=WAIT_CHANCE;
                high_trigger<=1;
              end            
            end else if  ( slice_en[1] && (~tx_config_fifo_empty[1] || floating_pkt_flag[1]) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && (~retrans_in_progress) && tx_control_state_idle && (~tx_try_complete_dl_pulses) && (~fcs_in_strobe_dl_pulses)) begin
              high_tx_ctl_state  <= WAIT_CHANCE;
              tx_queue_idx_reg<=1; 
              high_trigger<=1;             
            end else if  ( slice_en[2] && (~tx_config_fifo_empty[2] || floating_pkt_flag[2]) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && (~retrans_in_progress) && tx_control_state_idle && (~tx_try_complete_dl_pulses) && (~fcs_in_strobe_dl_pulses)) begin
              high_tx_ctl_state  <= WAIT_CHANCE;
              tx_queue_idx_reg<=2; 
              high_trigger<=1;     
            end else if  ( slice_en[3] && (~tx_config_fifo_empty[3] || floating_pkt_flag[3]) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && (~retrans_in_progress) && tx_control_state_idle && (~tx_try_complete_dl_pulses) && (~fcs_in_strobe_dl_pulses)) begin
              high_tx_ctl_state  <= WAIT_CHANCE;
              tx_queue_idx_reg<=3; 
              high_trigger<=1;             
            end
            wr_counter <= 13'b0;
            send_cts_toself_wait_count<=0;
          end

          WAIT_CHANCE: begin
            wea_internal<=0;
            addra_internal<=0;
            dina_internal<=0;
            high_trigger<=0;
            cts_toself_bb_is_ongoing<=0;
            cts_toself_rf_is_ongoing<=0;

            read_from_s_axis_en <= 0;
            
            if(tx_queue_idx_reg==0) begin
              if (~slice_en[0]) begin
                high_tx_ctl_state<=WAIT_TO_TRIG;
                reset_backoff<=1;
              end else if(backoff_done) begin
                if(~floating_pkt_flag[0]) begin
                  tx_config_fifo_rden<= 4'b0001;
                end
                high_tx_ctl_state<=PREPARE_TX_FETCH;
              end
            end else if(tx_queue_idx_reg==1) begin
              if(~slice_en[1]) begin
                high_tx_ctl_state<=WAIT_TO_TRIG;
                reset_backoff<=1;
              end else if(backoff_done) begin
                if(~floating_pkt_flag[1]) begin
                  tx_config_fifo_rden<= 4'b0010;
                end
                high_tx_ctl_state<=PREPARE_TX_FETCH;
              end
            end else if(tx_queue_idx_reg==2) begin
              if(~slice_en[2]) begin
                high_tx_ctl_state<=WAIT_TO_TRIG;
                reset_backoff<=1;
              end else if(backoff_done) begin
                if(~floating_pkt_flag[2]) begin
                  tx_config_fifo_rden<= 4'b0100;
                end
                high_tx_ctl_state<=PREPARE_TX_FETCH;
              end
            end else if(tx_queue_idx_reg==3) begin
              if(~slice_en[3]) begin
                high_tx_ctl_state<=WAIT_TO_TRIG;
                reset_backoff<=1;
              end else if(backoff_done) begin
                if(~floating_pkt_flag[3]) begin
                  tx_config_fifo_rden<= 4'b1000;
                end
                high_tx_ctl_state<=PREPARE_TX_FETCH;
              end
            end

            wr_counter <= 13'b0;
            send_cts_toself_wait_count<=0;
          end

          WAIT_TX_COMP: begin
            quit_retrans <= 0;
            high_trigger <= 0;
            if(tx_try_complete_dl2 == 1) begin
              high_tx_ctl_state  <= WAIT_CHANCE;
              tx_queue_idx_reg<=0;
            end
          end

          PREPARE_TX_FETCH: begin
            if(~floating_pkt_flag[tx_queue_idx_reg]) begin
              tx_config_current <= ( tx_queue_idx_reg[1]?(tx_queue_idx_reg[0]?tx_config_fifo_rd_data3:tx_config_fifo_rd_data2):(tx_queue_idx_reg[0]?tx_config_fifo_rd_data1:tx_config_fifo_rd_data0) );
              phy_hdr_config_current <= ( tx_queue_idx_reg[1]?(tx_queue_idx_reg[0]?phy_hdr_config_fifo_rd_data3:phy_hdr_config_fifo_rd_data2):(tx_queue_idx_reg[0]?phy_hdr_config_fifo_rd_data1:phy_hdr_config_fifo_rd_data0) );
            end else begin
              tx_config_current <= tx_config_current_next[tx_queue_idx_reg];
              phy_hdr_config_current <= phy_hdr_config_current_next[tx_queue_idx_reg];
              floating_pkt_flag[tx_queue_idx_reg] <= 0;
            end
            tx_config_fifo_rden<= 4'b0000;

            if(high_tx_ctl_state_old == WAIT_CHANCE) begin
              pkt_cnt <= 0;
              len_ht <= 0;
            end

            high_tx_ctl_state  <= PREPARE_TX_JUDGE;
          end

          PREPARE_TX_JUDGE: begin
            if (use_cts_protect==1) begin // from cts_toself_config[31] in tx queue
              // read_from_s_axis_en <= read_from_s_axis_en;
              high_tx_ctl_state  <= DO_CTS_TOSELF;
            end else begin
              high_tx_ctl_state  <= CHECK_AGGR;
            end
          end

          DO_CTS_TOSELF: begin
            send_cts_toself_wait_count <= ( ( send_cts_toself_wait_count != (`WAIT_FOR_TX_IQ_FILL_COUNT_TOP) )?(send_cts_toself_wait_count + 1): (tx_iq_fifo_empty?0:send_cts_toself_wait_count) );
            wea_internal <= (send_cts_toself_wait_count<4?1:0);
            //addra_internal <= (send_cts_toself_wait_count<4?send_cts_toself_wait_count:0);
            addra_internal <= send_cts_toself_wait_count;
            cts_toself_bb_is_ongoing <= (send_cts_toself_wait_count<4?cts_toself_bb_is_ongoing:(tx_iq_fifo_empty?0:1));
            cts_toself_rf_is_ongoing <= (send_cts_toself_wait_count==(`WAIT_FOR_TX_IQ_FILL_COUNT_TOP)?1:cts_toself_rf_is_ongoing);
            high_tx_ctl_state <= (send_cts_toself_wait_count!=(`WAIT_FOR_TX_IQ_FILL_COUNT_TOP)?high_tx_ctl_state:(tx_iq_fifo_empty?WAIT_SIFS:high_tx_ctl_state));

            if (send_cts_toself_wait_count==0) begin
                //dina_internal<={32'h0, 32'h000001cb};
                dina_internal<={32'h0, 14'd0, cts_toself_signal_parity, cts_toself_signal_len, 1'b0, cts_toself_rate};
            end else if (send_cts_toself_wait_count==2)begin
                dina_internal<={mac_addr_reg[31:0], cts_duration, 8'd0, 4'b1100, 2'b01, 2'd0};//CTS FC_type 2'b01 FC_subtype 4'b1100 duration tx_config_current[55:40] from cts_toself_config[23:8] in tx queue
            end else if (send_cts_toself_wait_count==3) begin
                dina_internal<={48'h0,mac_addr_reg[47:32]};
            end 
          end

          WAIT_SIFS: begin
            send_cts_toself_wait_count <= send_cts_toself_wait_count+1;
            if (send_cts_toself_wait_count == send_cts_toself_wait_sifs_top_scale ) begin
              read_from_s_axis_en <= 1;
              high_tx_ctl_state  <= DO_TX;
            end 
          end

          CHECK_AGGR: begin

			// 802.11ag packets
			if(pkt_cnt == 0 && use_ht_rate == 0) begin

				pkt_cnt <= pkt_cnt + 1;
				len_pkt_sym <= (|len_psdu[2:0] == 0 ? (len_psdu>>3) : (len_psdu>>3)+1);
				high_tx_ctl_state <= PREP_PHY_HDR;

			// 802.11n packets
			end else begin

				// Non aggregation packet
				if(pkt_cnt == 0 && use_ht_aggr == 0) begin

					pkt_cnt <= pkt_cnt + 1;
					len_ht <= len_psdu + 4;	// CRC to be calculated
					len_pkt_sym <= (|len_psdu[2:0] == 0 ? (len_psdu>>3) : (len_psdu>>3)+1);
					high_tx_ctl_state <= PREP_PHY_HDR;

				// Aggregation packet
				end else begin
					// Stop packet aggregation when one the following conditions is met
					// 1. Aggregate packet count exceeded the limit
					// 2. Aggregate packet size exceeded the limit
					// 3. New aggregation session started
					// 4. Non aggregation packet arrived
					// 5. High priority packet is waiting
					// 6. There is no packet in selected FIFO
					if( (pkt_cnt+1 > buf_size) || (len_ht+len_psdu > max_tx_bytes) || (pkt_cnt>0 && ht_aggr_start==1) || (use_ht_rate == 0 || (use_ht_rate == 1 && use_ht_aggr == 0)) ) begin
						len_pkt_sym <= len_ht >> 3;

						// This last packet is floating as it will not be used in current aggregation. Leave this packet for next round and continue the aggregation process
						floating_pkt_flag[tx_queue_idx_reg] <= 1;
						tx_config_current_next[tx_queue_idx_reg] <= tx_config_current;
						phy_hdr_config_current_next[tx_queue_idx_reg] <= phy_hdr_config_current;
						tx_config_current <= tx_config_current_prev;
						phy_hdr_config_current <= phy_hdr_config_current_prev;

						high_tx_ctl_state <= PREP_PHY_HDR;

					end else if(high_prio_pkt_waiting || tx_config_fifo_empty[tx_queue_idx_reg]) begin
						pkt_cnt <= pkt_cnt + 1;
						len_ht <= len_ht + len_psdu;
						len_pkt_sym <= (len_ht + len_psdu) >> 3;

						high_tx_ctl_state <= PREP_PHY_HDR;

					end else begin
						pkt_cnt <= pkt_cnt + 1;
						len_ht <= len_ht + len_psdu;
						len_pkt_sym <= (len_ht + len_psdu) >> 3;

						tx_config_current_prev <= tx_config_current;
						phy_hdr_config_current_prev <= phy_hdr_config_current;

						tx_config_fifo_rden <= (1 << tx_queue_idx_reg);
                        high_tx_ctl_state  <= PREPARE_TX_FETCH;
					end
				end
			end
          end

          PREP_PHY_HDR: begin

			// 802.11ag packets
			if(use_ht_rate == 0) begin

				len_legacy <= len_psdu[11:0] + 4;	// CRC to be calculated
				len_legacy_ready <= 1;
				high_tx_ctl_state <= DO_PHY_HDR1;

			// 802.11n packets
			end else begin

				// Calculate the length field of the legacy signal
				if(div_valid == 1) begin

					if(num_data_sym_ready == 0) begin

						// Long guard interval
						if(use_short_gi == 0) begin
							len_legacy <= 3*(4 + num_data_sym[10:0]) - 3;

							num_data_sym_ready <= 1;
							len_legacy_ready <= 1;

						// Short guard interval
						// Calculate number of LEGACY data symbols
						end else begin
							dividend <= 72*num_data_sym[9:0];
							divisor <= 80;
							div_start <= 1;

							num_data_sym_ready <= 1;
						end

					end else if(len_legacy_ready == 0) begin

						len_legacy <= 3*(4 + num_data_sym[10:0]) - 3;
						len_legacy_ready <= 1;
					end

				// Calculate number of HT data symbols
				end else if(div_busy == 0 && num_data_sym_ready == 0 && len_legacy_ready == 0) begin

					dividend <= 16 + {len_ht[12:0], 3'd0} + 6;
					divisor <= {7'd0, dbps_ht};
					div_start <= 1;

				end else begin
					div_start <= 0;
				end

				// Calculate the CRC field of the HT signal
				if(ht_sig_crc_valid == 1) begin
					ht_sig_crc_reg <= ht_sig_crc;
					ht_sig_crc_ready <= 1;
					high_tx_ctl_state <= DO_PHY_HDR1;  // ht_sig_crc always gets ready after len_legacy. Thus it suffies to issue state change here

				end else if(ht_sig_crc_busy == 0 && ht_sig_crc_ready == 0) begin

				    ht_sig_data <= {2'd0, use_short_gi, 3'd0, use_ht_aggr, 3'b111, len_ht, 1'd0, 3'd0, rate_hw_value};
					ht_sig_crc_start <= 1;

				end else begin
					ht_sig_crc_start <= 0;
				end
			end
          end

          DO_PHY_HDR1: begin

			wea_internal<=1;
			addra_internal<=0;
			dina_internal<={32'h0, 7'd0, use_ht_rate , 6'd0, l_sig_parity, l_sig_data};

			num_data_sym_ready <= 0;
			len_legacy_ready <= 0;

			if(use_ht_rate == 1) begin
				high_tx_ctl_state <= DO_PHY_HDR2;

			end else begin
				wr_counter <= 2;
				read_from_s_axis_en <= 1;
				high_tx_ctl_state <= DO_TX;
			end
          end

          DO_PHY_HDR2: begin

			wea_internal<=1;
			addra_internal<=1;
			dina_internal<={16'd0, 6'd0, ht_sig_crc_reg, ht_sig_data};

			ht_sig_crc_ready <= 0;

			wr_counter <= 2;
			read_from_s_axis_en <= 1;
			high_tx_ctl_state <= DO_TX;
          end
          
          DO_TX: begin
            wea_internal<= wea_high;
            addra_internal<=wr_counter;
            dina_internal<=data_from_s_axis;

            wr_counter <= ( wea_high?(wr_counter + 1):wr_counter );
            if (wr_counter == (2 + len_pkt_sym-1))
              read_from_s_axis_en<= 0;
            else
              read_from_s_axis_en<= read_from_s_axis_en;

            high_tx_ctl_state<= ( tx_end_from_acc?WAIT_TO_TRIG:high_tx_ctl_state );
            cts_toself_rf_is_ongoing<=( tx_end_from_acc?0:cts_toself_rf_is_ongoing );
          end

        endcase
      end
    end

    // // watch dog for debug
    //(* mark_debug = "true" *) reg [11:0] watch_dog_timer;
    //always @(posedge clk) begin                                                                     
    //  if ( rstn == 0 || (high_tx_ctl_state==DO_TX && high_tx_ctl_state_old!=DO_TX) ) begin 
    //    watch_dog_timer    <= 0;
    //  end else if ( high_tx_ctl_state==DO_TX ) begin
    //    watch_dog_timer<=(tsf_pulse_1M?(watch_dog_timer+1):watch_dog_timer);
    //  end
    //end
    // // watch dog for duplicated sn
    // (* mark_debug = "true" *) reg [9:0] duplicated_sn;
    // (* mark_debug = "true" *) reg duplicated_sn_catch;
    //always @(posedge clk) begin                                                                     
    //  if ( rstn == 0 ) begin 
    //    duplicated_sn    <= 10'd123;
    //    duplicated_sn_catch <= 0;
    //  end else if (tx_try_complete) begin
    //    duplicated_sn <= bd_wr_idx;
    //    duplicated_sn_catch <= (duplicated_sn==bd_wr_idx?1:0);
    //  end
    //end

    // store tx configuration into fifo
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            bd_wr_idx <= 0;
            // tx_pkt_num_dma_byte<=0;
            linux_prio <= 0;

            start_delay0<=0;
            start_delay1<=0;
            start_delay2<=0;
            start_delay3<=0;
            start_delay4<=0;
            start_delay5<=0;

            tx_try_complete_dl0<=0;
            tx_try_complete_dl1<=0;
            tx_try_complete_dl2<=0;

            fcs_in_strobe_dl0<=0;
            fcs_in_strobe_dl1<=0;
            
            tx_config_fifo_wren <= 4'b0000;
            s_axis_recv_data_from_high_delay <= 0;
        end 
      else
        begin
            if (tx_try_complete) begin
              bd_wr_idx <= tx_config_current[25:20];
              linux_prio <= tx_config_current[27:26];
            end

            tx_try_complete_dl0<=tx_try_complete;
            tx_try_complete_dl1<=tx_try_complete_dl0;
            tx_try_complete_dl2<=tx_try_complete_dl1;

            fcs_in_strobe_dl0<=fcs_in_strobe;
            fcs_in_strobe_dl1<=fcs_in_strobe_dl0;
            
            start_delay0<= ( ack_tx_flag?start_tx_ack:(retrans_in_progress==1?start_retrans:(addra==num_dma_symbol_th && num_dma_symbol_th!=0)) );//controle the width of tx pulse
            start_delay1<=start_delay0;
            start_delay2<=start_delay1;
            start_delay3<=start_delay2;
            start_delay4<=start_delay3;
            start_delay5<=start_delay4;

            s_axis_recv_data_from_high_delay<=s_axis_recv_data_from_high;
            tx_config_fifo_wren<= (s_axis_recv_data_from_high_valid << tx_queue_idx_indication_from_ps);//assure DMA is done
        end
    end

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(64),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(64),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo64_1clk_dep64_i0 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(tx_config_fifo_rd_data0),
      .empty(tx_config_fifo_empty[0]),
      .full(tx_config_fifo_full[0]),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(tx_config_fifo_data_count0),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din({cts_toself_config,tx_config}),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[0]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[0])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i0 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(phy_hdr_config_fifo_rd_data0),
      .empty(),
      .full(),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(phy_hdr_config),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[0]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[0])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(64),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(64),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo64_1clk_dep64_i1 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(tx_config_fifo_rd_data1),
      .empty(tx_config_fifo_empty[1]),
      .full(tx_config_fifo_full[1]),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(tx_config_fifo_data_count1),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din({cts_toself_config,tx_config}),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[1]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[1])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i1 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(phy_hdr_config_fifo_rd_data1),
      .empty(),
      .full(),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(phy_hdr_config),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[1]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[1])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(64),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(64),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo64_1clk_dep64_i2 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(tx_config_fifo_rd_data2),
      .empty(tx_config_fifo_empty[2]),
      .full(tx_config_fifo_full[2]),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(tx_config_fifo_data_count2),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din({cts_toself_config,tx_config}),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[2]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[2])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i2 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(phy_hdr_config_fifo_rd_data2),
      .empty(),
      .full(),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(phy_hdr_config),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[2]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[2])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(64),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(64),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo64_1clk_dep64_i3 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(tx_config_fifo_rd_data3),
      .empty(tx_config_fifo_empty[3]),
      .full(tx_config_fifo_full[3]),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(tx_config_fifo_data_count3),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din({cts_toself_config,tx_config}),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[3]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[3])
    );

    xpm_fifo_sync #(
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(0),     // DECIMAL
      .FIFO_WRITE_DEPTH(64),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(7),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("fwft"),         // String
      .USE_ADV_FEATURES("0404"), // only enable rd_data_count and wr_data_count
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(7)    // DECIMAL
    ) fifo32_1clk_dep64_i3 (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(phy_hdr_config_fifo_rd_data3),
      .empty(),
      .full(),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(phy_hdr_config),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(tx_config_fifo_rden[3]),
      .rst(!rstn),
      .sleep(),
      .wr_clk(clk),
      .wr_en(tx_config_fifo_wren[3])
    );

    xpm_memory_tdpram # (
      // Common module parameters
//    +---------------------------------------------------------------------------------------------------------------------+
//    | MEMORY_SIZE             | Integer            | Must be integer multiple of [WRITE|READ]_DATA_WIDTH_[A|B]            |
//    |---------------------------------------------------------------------------------------------------------------------|
//    | Specify the total memory array size, in bits.                                                                       |
//    | For example, enter 65536 for a 2kx32 RAM.                                                                           |
      //.MEMORY_SIZE        (262144),            //4096*64
      //.MEMORY_SIZE        (12800),            //(1500+100)*8 = (MTU+100)*8 
      .MEMORY_SIZE        (8*8192),
      .MEMORY_PRIMITIVE   ("block"),          //string; "auto", "distributed", "block" or "ultra";
      .CLOCKING_MODE      ("common_clock"),  //string; "common_clock", "independent_clock" 
      .MEMORY_INIT_FILE   ("none"),          //string; "none" or "<filename>.mem" 
      .MEMORY_INIT_PARAM  (""    ),          //string;
      .USE_MEM_INIT       (0),               //integer; 0,1
      .WAKEUP_TIME        ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin" 
      .MESSAGE_CONTROL    (0),               //integer; 0,1
    
      // Port A module parameters
      .WRITE_DATA_WIDTH_A (64),              //positive integer
      .READ_DATA_WIDTH_A  (64),              //positive integer
      .BYTE_WRITE_WIDTH_A (64),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
      .ADDR_WIDTH_A       (10),               //positive integer
      .READ_RESET_VALUE_A ("0"),             //string
      .READ_LATENCY_A     (1),               //non-negative integer
      .WRITE_MODE_A       ("write_first"),     //string; "write_first", "read_first", "no_change" 
    
      // Port B module parameters
      .WRITE_DATA_WIDTH_B (64),              //positive integer
      .READ_DATA_WIDTH_B  (64),              //positive integer
      .BYTE_WRITE_WIDTH_B (64),              //integer; 8, 9, or WRITE_DATA_WIDTH_B value
      .ADDR_WIDTH_B       (10),               //positive integer
      .READ_RESET_VALUE_B ("0"),             //vector of READ_DATA_WIDTH_B bits
      .READ_LATENCY_B     (1),               //non-negative integer
      .WRITE_MODE_B       ("write_first")      //string; "write_first", "read_first", "no_change" 
    
    ) xpm_memory_tdpram_inst (
    
      // Common module ports
      .sleep          (1'b0),
    
      // Port A module ports
      .clka           (clk),
      .rsta           (~rstn),
      .ena            (1'b1),
      .regcea         (1'b1),
      .wea            (wea),
      .addra          (addra),
      .dina           (dina),
      .injectsbiterra (1'b0),  //do not change
      .injectdbiterra (1'b0),  //do not change
      .douta          (douta), //for changing some bits to indicate it is the 1st pkt or retransmitted pkt
      .sbiterra       (),      //do not change
      .dbiterra       (),      //do not change
    
      // Port B module ports
      .clkb           (clk),
      .rstb           (1'b0),
      .enb            (1'b1),
      .regceb         (1'b1),
      .web            (1'b0),
      .addrb          (bram_addr),
      .dinb           (32'd0),
      .injectsbiterrb (1'b0),  //do not change
      .injectdbiterrb (1'b0),  //do not change
      .doutb          (bram_data_to_acc_int),
      .sbiterrb       (),      //do not change
      .dbiterrb       ()       //do not change
    
    );

	endmodule
