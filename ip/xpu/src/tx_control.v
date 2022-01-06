// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "clock_speed.v"
`include "board_def.v"

// `define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`define DEBUG_PREFIX


`timescale 1 ns / 1 ps

	module tx_control #
	(
	   parameter integer RSSI_HALF_DB_WIDTH = 11,
	   parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
     parameter integer WIFI_TX_BRAM_ADDR_WIDTH = 10
	)
	(// main function: after receive data, send ack; after send data, disable tx for a while because need to wait for ack from peer.
        input wire clk,
        input wire rstn,
        
        input wire ack_disable,
        input wire [6:0] preamble_sig_time,
        input wire [4:0] ofdm_symbol_time,
        input wire [6:0] sifs_time,
        input wire [3:0] max_num_retrans,
        input wire tx_pkt_need_ack,
        input wire [3:0] tx_pkt_retrans_limit,
        input wire tx_ht_aggr,
        input wire [14:0] send_ack_wait_top,//0 means 2.4GHz, non-zeros means 5GHz
        input wire [14:0] recv_ack_timeout_top_adj,
        input wire [14:0] recv_ack_sig_valid_timeout_top,
        input wire recv_ack_fcs_valid_disable,
        input wire pulse_tx_bb_end,
        input wire phy_tx_done,
        input wire sig_valid,
        input wire [7:0] signal_rate,
        input wire [15:0] signal_len,
        input wire fcs_valid,
        input wire fcs_in_strobe,
        input wire [1:0] FC_type,
        input wire [3:0] FC_subtype,
        input wire       FC_more_frag,
        input wire cts_torts_disable,
        input wire [4:0]  cts_torts_rate,
        input wire [15:0] duration_extra,
        input wire [15:0] duration,
        input wire [47:0] addr2,
        input wire [47:0] self_mac_addr,
        input wire [47:0] addr1,
        input wire [63:0] douta,
        input wire cts_toself_bb_is_ongoing,//this should rise before the phy tx end valid of phy tx IP core.
        input wire backoff_done,
        input wire [(WIFI_TX_BRAM_ADDR_WIDTH-1):0] bram_addr,

        input wire [3:0] ampdu_rx_tid,
        input wire ampdu_rx_start,

        input wire [11:0] SC_seq_num,
        input wire rx_ht_aggr,
        input wire rx_ht_aggr_last,

        input wire [3:0] qos_tid,
        input wire [15:0] blk_ack_req_ctrl,
        input wire [15:0] blk_ack_req_ssc,
        input wire [11:0] blk_ack_resp_ssn,
        input wire [63:0] blk_ack_resp_bitmap,

        output wire tx_control_state_idle,
        output wire ack_cts_is_ongoing,
        output reg retrans_in_progress,
        output reg start_retrans,
        input wire quit_retrans,
        `DEBUG_PREFIX output reg start_tx_ack,
        output reg retrans_trigger,
        output reg tx_try_complete,
        output reg [79:0] tx_status,
        output reg ack_tx_flag,
        output reg wea,
        output reg [9:0] addra,
        output reg [(C_S00_AXIS_TDATA_WIDTH-1):0] dina
	);

  localparam [3:0]    IDLE =                     4'b0000,
                      RESET_BLK_ACK_BITMAP =     4'b0001,
                      PREP_ACK=                  4'b0010,
                      SEND_DFL_ACK=              4'b0011,
                      SEND_BLK_ACK=              4'b0100,
                      RECV_ACK_JUDGE =           4'b0101,
                      RECV_ACK_WAIT_TX_BB_DONE = 4'b0110,
                      RECV_ACK_WAIT_SIG_VALID  = 4'b0111,
                      RECV_ACK       =           4'b1000,
                      RECV_ACK_WAIT_BACKOFF_DONE=4'b1001;

  `DEBUG_PREFIX wire [3:0] retrans_limit;
  `DEBUG_PREFIX reg [3:0] num_retrans;
  `DEBUG_PREFIX reg [14:0] ack_timeout_count;
  `DEBUG_PREFIX reg [2:0] send_ack_count;
  reg [47:0] ack_addr;
  reg [15:0] duration_received;
  reg FC_more_frag_received;
  `DEBUG_PREFIX reg [3:0] tx_control_state;
  `DEBUG_PREFIX reg [3:0] num_retrans_lock;
  reg [11:0] blk_ack_resp_ssn_lock;
  // reg [3:0] tx_control_state_priv;
  reg [63:0] blk_ack_bitmap_lock;
  wire is_data;
  wire is_management;
  wire is_blockackreq;
  wire  is_blockackresp;
  wire is_pspoll;
  wire is_rts;
  reg  [3:0] ackcts_rate;
  wire ackcts_signal_parity;
  wire [11:0] ackcts_signal_len;
  wire [11:0] blkack_signal_len;
  wire [3:0] blk_ack_req_tid;
  wire [11:0] blk_ack_req_ssn;
  reg [11:0] rx_ht_aggr_ssn;
  reg rx_ht_aggr_flag;
  reg rx_ht_aggr_last_flag;

  reg [6:0] bitmap_count;
  reg [127:0] blk_ack_bitmap_mem;
  reg ampdu_rx_start_reg;
  reg reset_blk_ack_bitmap_mem;

  `DEBUG_PREFIX reg [1:0] tx_dpram_op_counter;

  // `DEBUG_PREFIX wire [2:0] num_data_ofdm_symbol;
  // reg  [2:0] num_data_ofdm_symbol_reg;
  // `DEBUG_PREFIX wire [2:0] ackcts_n_sym;
  // reg  [2:0] ackcts_n_sym_reg;
  `DEBUG_PREFIX reg  [7:0] ackcts_time;
  reg  [6:0] sifs_time_reg;

  reg [14:0] recv_ack_timeout_top;

  `DEBUG_PREFIX reg [15:0] duration_new;
  `DEBUG_PREFIX reg [1:0]  FC_type_new;
  `DEBUG_PREFIX reg [3:0]  FC_subtype_new;
  reg is_data_received;
  reg is_management_received;
  reg is_blockackreq_received;
  reg is_pspoll_received;
  reg is_rts_received;

  reg [14:0] send_ack_wait_top_scale;
  reg [14:0] recv_ack_sig_valid_timeout_top_scale;
  reg [14:0] recv_ack_timeout_top_adj_scale;
  `DEBUG_PREFIX reg retrans_started ;

  assign tx_control_state_idle =((tx_control_state==IDLE) && (~retrans_started));

  assign retrans_limit = (max_num_retrans>0?max_num_retrans:tx_pkt_retrans_limit);

  assign is_data =        ((FC_type==2'b10)?1:0);
  assign is_management =  (((FC_type==2'b00) && (FC_subtype!=4'b1110))?1:0);
  assign is_blockackreq = (((FC_type==2'b01) && (FC_subtype==4'b1000))?1:0);
  assign is_blockackresp= (((FC_type==2'b01) && (FC_subtype==4'b1001))?1:0);
  assign is_pspoll =      (((FC_type==2'b01) && (FC_subtype==4'b1010))?1:0);
  assign is_rts =         (((FC_type==2'b01) && (FC_subtype==4'b1011) && (signal_len==20))?1:0);

  assign ack_cts_is_ongoing = ((tx_control_state==PREP_ACK) || (tx_control_state==SEND_DFL_ACK) || (tx_control_state==SEND_BLK_ACK));
  assign ackcts_signal_parity = (~(^ackcts_rate));//because the cts and ack pkt length field is always 14: 1110 that always has 3 1s
  assign ackcts_signal_len = 14;
  assign blkack_signal_len = 32;

  assign blk_ack_req_tid = blk_ack_req_ctrl[15:12];
  assign blk_ack_req_ssn = blk_ack_req_ssc[15:4];

  // // this is not needed. we should assume the peer always send us ack @ 6Mbps
  // n_sym_len14_pkt # (
  // ) n_sym_len14_pkt_i0 (
  //   .ht_flag(signal_rate[7]),
  //   .rate_mcs(signal_rate[3:0]),
  //   .n_sym(num_data_ofdm_symbol)
  // );

  // // this is not needed. we should assume the peer always send us ack @ 6Mbps
  // n_sym_len14_pkt # (
  // ) n_sym_len14_pkt_i1 (
  //   .ht_flag(0),
  //   .rate_mcs(ackcts_rate),
  //   .n_sym(ackcts_n_sym)
  // );

	always @(posedge clk)                                             
    begin
      if (!rstn)
      // Synchronous reset (active low)                                       
        begin
          wea<=0;
          addra<=0;
          dina<=0;
          ack_timeout_count<=0;
          ack_addr <=0;
          send_ack_count <= 0;
          ack_tx_flag<=0;
          tx_control_state  <= IDLE;
          // tx_control_state_priv <= IDLE;
          tx_try_complete<=0;
          tx_status<=0;
          num_retrans_lock <= 0;
          blk_ack_resp_ssn_lock <= 0;
          blk_ack_bitmap_lock <= 0;
          num_retrans<=0;
          start_retrans<=0;
          start_tx_ack<=0;
          retrans_started<=0;
          retrans_in_progress<=0;
          retrans_trigger<=0;
          tx_dpram_op_counter<=0;
          recv_ack_timeout_top<=0;
          duration_new<=0;
          FC_type_new<=0;
          FC_subtype_new<=0;
          duration_received<=0;
          FC_more_frag_received<=0;
          is_data_received<=0;
          is_management_received<=0;
          is_blockackreq_received<=0;
          is_pspoll_received<=0;
          is_rts_received<=0;

          rx_ht_aggr_ssn<=0;
          rx_ht_aggr_flag<=0;
          rx_ht_aggr_last_flag<=0;

          // num_data_ofdm_symbol_reg <= 0;
          // ackcts_n_sym_reg <= 0;

          bitmap_count <=0;
          reset_blk_ack_bitmap_mem <=0;

          send_ack_wait_top_scale <=0;
          recv_ack_sig_valid_timeout_top_scale <= 0;
          recv_ack_timeout_top_adj_scale <= 0;
        end
      else begin
        // tx_control_state_priv<=tx_control_state;
        
        //ackcts_rate <= (cts_torts_rate[4]?signal_rate[3:0]:cts_torts_rate[3:0]); // this is not needed. we should assume the peer always send us ack @ 6Mbps
        ackcts_rate <= 4'b1011; //6Mbps.

        // ackcts_time <= preamble_sig_time + ofdm_symbol_time*({4'd0,ackcts_n_sym_reg}); 
        ackcts_time <= preamble_sig_time + ofdm_symbol_time*({4'd0,3'd6}); // ack/cts use 6 ofdm symbols at 6Mbps
        sifs_time_reg   <= sifs_time;
        tx_status <= {blk_ack_bitmap_lock, blk_ack_resp_ssn_lock, num_retrans_lock};

        // num_data_ofdm_symbol_reg <= num_data_ofdm_symbol;
        // ackcts_n_sym_reg <= ackcts_n_sym;

        send_ack_wait_top_scale <= (send_ack_wait_top*`COUNT_SCALE);
        recv_ack_sig_valid_timeout_top_scale <= (recv_ack_sig_valid_timeout_top*`COUNT_SCALE);
        recv_ack_timeout_top_adj_scale <= (recv_ack_timeout_top_adj*`COUNT_SCALE);

        ampdu_rx_start_reg <= ampdu_rx_start;
        if((ampdu_rx_start ^ ampdu_rx_start_reg) == 1 && ampdu_rx_start_reg == 0)
            reset_blk_ack_bitmap_mem <= 1;

        case (tx_control_state)
          IDLE: begin
            ack_tx_flag<=0;
            wea<=0;
            addra<=0;
            dina<=0;
            ack_timeout_count<=0;
            send_ack_count <= 0;
            tx_try_complete<=0;
            start_retrans<=0;
            start_tx_ack<=0;
            tx_dpram_op_counter<=0;
            retrans_trigger<=0;
            recv_ack_timeout_top<=0;
            duration_new<=0;
            FC_type_new<=0;
            FC_subtype_new<=0;
            ack_addr <= addr2;
            duration_received<=duration;
            FC_more_frag_received<=FC_more_frag;
            is_data_received<=is_data;
            is_management_received<=is_management;
            is_blockackreq_received<=is_blockackreq;
            is_pspoll_received<=is_pspoll;
            is_rts_received<=is_rts;
            // tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            // num_retrans<=num_retrans;
            // retrans_in_progress<=retrans_in_progress;
            bitmap_count <= 0;

            // This is the last packet of aggregation
            if ( rx_ht_aggr_last )
              begin
                  if (fcs_valid && is_data && (self_mac_addr==addr1) && (ampdu_rx_tid == qos_tid) ) begin
                      // In case the last packet from A-MPDU makes it through
                      if(rx_ht_aggr_flag == 0) begin
                          rx_ht_aggr_flag <= 1;
                          rx_ht_aggr_ssn <= SC_seq_num;
                      // Sometimes, MPDUs come out-of-order (i.e. random seq_no) and in such cases, the starting sequence number should take the smallest value
                      end else if(SC_seq_num < rx_ht_aggr_ssn) begin
                          rx_ht_aggr_ssn <= SC_seq_num;
                      end
                      blk_ack_bitmap_mem[SC_seq_num[6:0]] <= 1'b1;
                      rx_ht_aggr_last_flag <= 1;
                      tx_control_state <= PREP_ACK;

                  end else if ( fcs_in_strobe == 1 && fcs_valid == 0 ) begin
                      // Since this MPDU is not valid, only send a block ack if there were previously received valid MPDUs
                      if(rx_ht_aggr_flag == 1) begin
                          rx_ht_aggr_last_flag <= 1;
                          tx_control_state <= PREP_ACK;
                      end
                  end

              end
            //8.3.1.4 ACK frame format: The RA field of the ACK frame is copied from the Address 2 field of the immediately previous individually
            //addressed data, management, BlockAckReq, BlockAck, or PS-Poll frames.
            else if ( fcs_valid && (is_data||is_management||is_blockackreq||is_pspoll||(is_rts&&(!cts_torts_disable))) 
                           && (self_mac_addr==addr1)) // send ACK will not back to this IDLE until the last IQ sample sent.
              begin
                  if(rx_ht_aggr && (rx_ht_aggr_last == 0) && (ampdu_rx_tid == qos_tid)) begin
                      // First packet from aggregated A-MPDU
                      if(rx_ht_aggr_flag == 0) begin
                          rx_ht_aggr_flag <= 1;
                          rx_ht_aggr_ssn <= SC_seq_num;
                      // Sometimes, MPDUs come out-of-order (i.e. random seq_no) and in such cases, the starting sequence number should take the smallest value
                      end else if(SC_seq_num < rx_ht_aggr_ssn) begin
                          rx_ht_aggr_ssn <= SC_seq_num;
                      end
                      blk_ack_bitmap_mem[SC_seq_num[6:0]] <= 1'b1;
                      tx_control_state <= IDLE;

                  end else begin
                      tx_control_state  <= (ack_disable?tx_control_state:PREP_ACK); //we also send cts (if rts is received) in PREP_ACK status
                  end
              end
            //else if ( pulse_tx_bb_end && tx_pkt_type[0]==1 && (core_state_old!=PREP_ACK) )// need to recv ACK! We need to miss this pulse_tx_bb_end intentionally when send ACK, because ACK don't need ACK
            //else if ( phy_tx_done && (core_state_old!=PREP_ACK) )// need to recv ACK! We need to miss this pulse_tx_bb_end intentionally when send ACK, because ACK don't need ACK
            else if ( phy_tx_done && cts_toself_bb_is_ongoing==0 ) // because PREP_ACK won't be back until phy_tx_done. So here phy_tx_done must be from high layer
              begin
                  tx_control_state  <= RECV_ACK_JUDGE;
              end
            else if ((quit_retrans == 1) && (retrans_in_progress == 1)) 
              begin 
                  //tx_control_state <= QUIT_RETX;
                  tx_control_state<= IDLE;
                  tx_try_complete<=1;
                  num_retrans_lock <= num_retrans;
                  blk_ack_resp_ssn_lock <= 0;
                  blk_ack_bitmap_lock <= 0;
                  num_retrans<=0;
                  retrans_in_progress<=0;
                  retrans_started<=0;
              end 
            else if ((backoff_done==1) && (retrans_in_progress==1) && (retrans_started==0))
              begin
                  tx_control_state  <= RECV_ACK_WAIT_BACKOFF_DONE;
              end
            else if (reset_blk_ack_bitmap_mem == 1)
              begin
                  reset_blk_ack_bitmap_mem <= 0;
                  tx_control_state <= RESET_BLK_ACK_BITMAP;
              end
          end

          RESET_BLK_ACK_BITMAP: begin
              blk_ack_bitmap_mem[bitmap_count] <= 1'b0;

              bitmap_count <= bitmap_count + 1;
              if(bitmap_count == 127)
                  tx_control_state <= IDLE;
           end

          PREP_ACK: begin // data is calculated by calc_phy_header C program
            ack_tx_flag<=1;
            // ack_addr <= ack_addr;
            // tx_try_complete<=tx_try_complete;
            // tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            // num_retrans<=num_retrans;
            // start_retrans<=start_retrans;
            // retrans_in_progress<=retrans_in_progress;
            // tx_dpram_op_counter<=tx_dpram_op_counter;
            // recv_ack_timeout_top<=recv_ack_timeout_top;

            if ((rx_ht_aggr_last_flag && (ampdu_rx_tid == qos_tid)) || (is_blockackreq_received && (ampdu_rx_tid == blk_ack_req_tid))) begin
              duration_new<= duration_extra+0;
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1001;

              // Prepare block ack response bitmap
              if(rx_ht_aggr_last_flag) begin
                  blk_ack_bitmap_lock[bitmap_count[5:0]] <= blk_ack_bitmap_mem[(rx_ht_aggr_ssn[6:0]+bitmap_count)];
                  // Clear past bitmap history
                  if(bitmap_count < 32)
                      blk_ack_bitmap_mem[(rx_ht_aggr_ssn[6:0]+bitmap_count+7'd64)] <= 0;
              end else begin
                  blk_ack_bitmap_lock[bitmap_count[5:0]] <= blk_ack_bitmap_mem[(blk_ack_req_ssn[6:0]+bitmap_count)];
                  // Clear past bitmap history
                  if(bitmap_count < 32)
                      blk_ack_bitmap_mem[(blk_ack_req_ssn[6:0]+bitmap_count+7'd64)] <= 0;
              end
              if(bitmap_count < 63)
                  bitmap_count <= bitmap_count + 1;

            //standard: For ACK frames sent by non-QoS STAs, if the More Fragments bit was equal to 0 in the Frame Control field
            //of the immediately previous individually addressed data or management frame, the duration value is set to 0.
            end else if ( (is_data_received||is_management_received) && (FC_more_frag_received==0)) begin
              duration_new<=duration_extra+0;
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1101;
            end else if (is_data_received||is_management_received||is_blockackreq_received||is_pspoll_received) begin
            //standard: In other ACK frames sent by non-QoS STAs, the duration value is the value obtained from the Duration/ID
            //field of the immediately previous data, management, PS-Poll, BlockAckReq, or BlockAck frame minus the
            //time, in microseconds, required to transmit the ACK frame and its SIFS interval.
            //assume we use 6M for ack(14byte): n_ofdm=6=(22+14*8)/24; time_us=20(preamble+SIGNAL)+6*4=44;
              //duration_new<= duration_extra+(duration_received-44-sifs_time);//SIFS 2.4GHz 10us; 5GHz 16us
              duration_new<= duration_extra+(duration_received==0?0:(duration_received-ackcts_time-sifs_time_reg));//avoid overflow corner case
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1101;
            end else if (is_rts_received) begin
              //duration_new<= duration_extra+(duration_received-44-sifs_time);//SIFS 2.4GHz 10us; 5GHz 16us
              duration_new<= duration_extra+(duration_received==0?0:(duration_received-ackcts_time-sifs_time_reg));
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1100;
            end

            ack_timeout_count <= ( ( ack_timeout_count != send_ack_wait_top_scale )?(ack_timeout_count + 1):ack_timeout_count );
            tx_control_state  <= ( ( ack_timeout_count != send_ack_wait_top_scale )?tx_control_state:((rx_ht_aggr_last_flag||is_blockackreq_received) ? SEND_BLK_ACK : SEND_DFL_ACK) );
            start_tx_ack <= ( ( ack_timeout_count != send_ack_wait_top_scale )? 0:1);
          end

          SEND_DFL_ACK: begin
            //send_ack_count <= ( send_ack_count!=4?(send_ack_count + 1):send_ack_count );
            // wea <= (send_ack_count<4?1:0);
            start_tx_ack <= 0; //wea <= 1; // replace wea by start_tx_ack, start_tx_ack is only one clock
            //addra <= send_ack_count; // no longer need addra, directly output to the tx core
            tx_control_state <=  (phy_tx_done?IDLE:tx_control_state);
            if(bram_addr==0) begin//if (send_ack_count==0) begin
                //dina<={32'h0, 32'h000001cb}; // rate 6M len 14
                dina<={32'h0, 14'd0, ackcts_signal_parity, ackcts_signal_len, 1'b0, ackcts_rate};
            end else if (bram_addr==2) begin//(send_ack_count==2) begin
                //dina<={ack_addr[31:0], 32'h000000d4};
                dina<={ack_addr[31:0], duration_new, 8'd0, FC_subtype_new, FC_type_new, 2'd0};
            end else if (bram_addr==3) begin//(send_ack_count==3) begin
                dina<={48'h0,ack_addr[47:32]};
            end
          end

          SEND_BLK_ACK: begin
            start_tx_ack <= 0;
            tx_control_state <= (phy_tx_done?IDLE:tx_control_state);
            rx_ht_aggr_flag <= (phy_tx_done?0:rx_ht_aggr_flag);
            rx_ht_aggr_last_flag <= (phy_tx_done?0:rx_ht_aggr_last_flag);
            if(bram_addr==0) begin
                dina<={32'h0, 14'd0, ackcts_signal_parity, blkack_signal_len, 1'b0, ackcts_rate};		// block ack and normal ack have identical signal parity and bit rate
            end else if (bram_addr==2) begin
                dina<={ack_addr[31:0], duration_new, 8'd0, FC_subtype_new, FC_type_new, 2'd0};
            end else if (bram_addr==3) begin
                dina<={self_mac_addr,ack_addr[47:32]};
            end else if (bram_addr==4) begin
                if(rx_ht_aggr_last_flag) begin
                    dina<={blk_ack_bitmap_lock[31:0], rx_ht_aggr_ssn, 4'd0, 4'd0, 7'd0, 4'b0010, 1'd0};
                end else begin
                    dina<={blk_ack_bitmap_lock[31:0], blk_ack_req_ssn, 4'd0, 4'd0, 7'd0, 4'b0010, 1'd0};
                end
            end else if (bram_addr==5) begin
                dina<={32'h0, blk_ack_bitmap_lock[63:32]};
            end
          end

          RECV_ACK_JUDGE: begin
            // ack_tx_flag<=ack_tx_flag;
            // wea<=wea;
            // dina<=dina;
            // send_ack_count <= send_ack_count;
            // ack_addr <= ack_addr;
            // ack_timeout_count<=ack_timeout_count;
            // start_retrans<=start_retrans;
            // tx_dpram_op_counter<=tx_dpram_op_counter;
            // recv_ack_timeout_top<=recv_ack_timeout_top;
            retrans_started<=0;
            if (tx_pkt_need_ack==1) // continue to actual ACK receiving
                begin
                tx_control_state<= RECV_ACK_WAIT_TX_BB_DONE;
                addra<=2;
                tx_try_complete<=0;
                // tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
                // num_retrans<=num_retrans;
                retrans_in_progress<=1;
                end
            else
                begin
                tx_control_state<= IDLE;
                // addra<=addra;
                tx_try_complete<=1;
                // tx_status<={1'b0,num_retrans}; // because interrupt will be raised, set status
                num_retrans_lock <= num_retrans;
                blk_ack_resp_ssn_lock <= 0;
                blk_ack_bitmap_lock <= 1;
                num_retrans<=0;
                retrans_in_progress<=0;
                end

          end

          RECV_ACK_WAIT_TX_BB_DONE: begin
            // ack_tx_flag<=ack_tx_flag;
            // recv_ack_timeout_top<=recv_ack_timeout_top;

            // addra<=addra;

            tx_dpram_op_counter <= ( tx_dpram_op_counter!=3?(tx_dpram_op_counter + 1):tx_dpram_op_counter );
            if(tx_ht_aggr==0 && tx_dpram_op_counter==2) begin
                wea <= 1;
                dina <= {douta[63:12], 1'b1, douta[10:0]};
            end else begin
                wea <= 0;
                dina <= douta;
            end

            // send_ack_count <= send_ack_count;
            // ack_addr <= ack_addr;
            // ack_timeout_count<=ack_timeout_count;
            // // tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            // num_retrans<=num_retrans;
            // tx_try_complete<=tx_try_complete;
            // start_retrans<=start_retrans;
            // retrans_in_progress<=retrans_in_progress;

            if (pulse_tx_bb_end) begin
                tx_control_state<= RECV_ACK_WAIT_SIG_VALID;
            end 
            // else begin
            //     tx_control_state<= tx_control_state;
            // end
            
          end

          RECV_ACK_WAIT_SIG_VALID: begin
            // ack_tx_flag<=ack_tx_flag;
            // wea<=wea;
            // addra<=addra;
            // dina<=dina;
            // send_ack_count <= send_ack_count;
            // ack_addr <= ack_addr;
            // tx_dpram_op_counter<=tx_dpram_op_counter;
            // recv_ack_timeout_top<=recv_ack_timeout_top;

            ack_timeout_count<= ( (sig_valid && (signal_len==14||signal_len==32))?0:(ack_timeout_count+1) );
            if ( (ack_timeout_count<recv_ack_sig_valid_timeout_top_scale) && sig_valid && (signal_len==14||signal_len==32) ) begin //before timeout, we detect a sig valid, signal length field is ACK/BLK_ACK
                tx_control_state<= RECV_ACK;
                // tx_try_complete<=tx_try_complete;
                // tx_status<=tx_status;
                // num_retrans<=num_retrans;
                // start_retrans<=start_retrans;
                // retrans_in_progress<=retrans_in_progress;
                // ack_timeout_count<=0;
                if(signal_len == 14)
                   recv_ack_timeout_top <= (({4'd6, 2'd0})*`NUM_CLK_PER_US)+recv_ack_timeout_top_adj_scale;	// ack/cts uses 6 ofdm symbols at 6Mbps
                else
                   recv_ack_timeout_top <= (({4'd12,2'd0})*`NUM_CLK_PER_US)+recv_ack_timeout_top_adj_scale;	// blk_ack_resp uses 12 ofdm symbols at 6Mbps
            end else if ( ack_timeout_count==recv_ack_sig_valid_timeout_top_scale ) begin // sig valid timeout
                tx_control_state<= IDLE;
                if  ((num_retrans==retrans_limit) || (retrans_limit==0)) begin// should not run into this state. but just in case
                    tx_try_complete<=1;
                    // tx_status<={1'b1,num_retrans};
                    num_retrans_lock <= num_retrans;
                    blk_ack_resp_ssn_lock <= 0;
                    blk_ack_bitmap_lock <= 0;
                    num_retrans<=0;
                    // start_retrans<=start_retrans;
                    retrans_in_progress<=0;
                end else begin
                    // tx_try_complete<=tx_try_complete;
                    // tx_status<=tx_status;
                    num_retrans<=num_retrans+1;
                    retrans_trigger<=1;// start retransmission if ack did not arrive in time --
                    // retrans_in_progress<=retrans_in_progress;
                end
            end 
            // else begin
            //     tx_control_state<= tx_control_state;
            //     tx_try_complete<=tx_try_complete;
            //     // tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            //     num_retrans<=num_retrans;
            //     start_retrans<=start_retrans;
            //     retrans_in_progress<=retrans_in_progress;
            // end
          end

          RECV_ACK: begin
            // ack_tx_flag<=ack_tx_flag;
            // wea<=wea;
            // addra<=addra;
            // dina<=dina;
            // send_ack_count <= send_ack_count;
            // ack_addr <= ack_addr;
            // tx_dpram_op_counter<=tx_dpram_op_counter;
            // recv_ack_timeout_top <= recv_ack_timeout_top;

            ack_timeout_count<=ack_timeout_count+1;
            // Detection of a normal ack packet is sufficient to acknowledge a traffic. However for aggregation traffic, a valid block ack response is required.
            if ( (ack_timeout_count<recv_ack_timeout_top) && (recv_ack_fcs_valid_disable|((fcs_in_strobe && signal_len==14) || (fcs_valid && signal_len==32))) && (FC_type==2'b01) && (FC_subtype==4'b1101) && (self_mac_addr==addr1)) begin//before timeout, we detect a ACK type frame fcs valid
                tx_control_state<= IDLE;
                tx_try_complete<=1;
                // tx_status<={1'b0,num_retrans};
                num_retrans_lock <= num_retrans;
                if (is_blockackresp) begin
                    blk_ack_resp_ssn_lock <= blk_ack_resp_ssn;
                    blk_ack_bitmap_lock <= blk_ack_resp_bitmap;
                end else begin
                    blk_ack_resp_ssn_lock <= 0;
                    blk_ack_bitmap_lock <= 1;
                end
                num_retrans<=0;
                // start_retrans<=start_retrans;
                retrans_in_progress<=0;
            end else if ( ack_timeout_count==recv_ack_timeout_top ) begin// timeout
                tx_control_state<= IDLE;
                if  ((num_retrans==retrans_limit) || (retrans_limit==0)) begin// should not run into this state. but just in case
                    tx_try_complete<=1;
                    // tx_status<={1'b1,num_retrans};
                    num_retrans_lock <= num_retrans;
                    blk_ack_resp_ssn_lock <= 0;
                    blk_ack_bitmap_lock <= 0;
                    num_retrans<=0;
                    // start_retrans<=start_retrans;
                    retrans_in_progress<=0;
                end else begin
                    // tx_try_complete<=tx_try_complete;
                    // tx_status<=tx_status;
                    num_retrans<=num_retrans+1;
                    retrans_trigger<=1; // start retranmission if ack did not receive in time -- 
                    // retrans_in_progress<=retrans_in_progress;
                end
            end 
            // else begin
            //     tx_control_state<= tx_control_state;
            //     tx_try_complete<=tx_try_complete;
            //     // tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            //     num_retrans<=num_retrans;
            //     start_retrans<=start_retrans;
            //     retrans_in_progress<=retrans_in_progress;
            // end

          end
          
          RECV_ACK_WAIT_BACKOFF_DONE: begin
            tx_control_state<= IDLE;
            if(quit_retrans) begin
              tx_try_complete<=1;
              num_retrans_lock <= num_retrans;
              blk_ack_resp_ssn_lock <= 0;
              blk_ack_bitmap_lock <= 0;
              num_retrans<=0;
              retrans_in_progress<=0;
              retrans_started<=0;
            end else if (backoff_done) begin
              start_retrans <= 1 ;
              retrans_started <= 1;
            end

          end

        endcase
      end
    end

	endmodule
