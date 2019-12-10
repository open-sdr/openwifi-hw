// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tx_control #
	(
	   parameter integer RSSI_HALF_DB_WIDTH = 11,
	   parameter integer C_S00_AXIS_TDATA_WIDTH	= 64
	)
	(// main function: after receive data, send ack; after send data, disable tx for a while because need to wait for ack from peer.
        input wire clk,
        input wire rstn,
        
        input wire [6:0] preamble_sig_time,
        input wire [4:0] ofdm_symbol_time,
        input wire [6:0] sifs_time,
        input wire [3:0] max_num_retrans,
        input wire tx_pkt_need_ack,
        input wire [3:0] tx_pkt_retrans_limit,
        input wire signed [14:0] send_ack_wait_top,//0 means 2.4GHz, non-zeros means 5GHz
        input wire signed [14:0] recv_ack_timeout_top_adj,
        input wire signed [14:0] recv_ack_sig_valid_timeout_top,
        input wire recv_ack_fcs_valid_disable,
        input wire pulse_tx_bb_end_almost,
        input wire phy_tx_done,
        input wire sig_valid,
        input wire [7:0] signal_rate,
        input wire [15:0] signal_len,
        input wire fcs_valid,
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

        output wire tx_control_state_idle,
        output wire ack_cts_is_ongoing,
        output reg retrans_in_progress,
        output reg start_retrans,
        output reg tx_try_complete,
        output reg [4:0] tx_status,
        output reg ack_tx_flag,
        output reg wea,
        output reg [9:0] addra,
        output reg [(C_S00_AXIS_TDATA_WIDTH-1):0] dina
	);

  localparam [2:0]   IDLE =                     3'b000,
                      SEND_ACK=                  3'b001,
                      RECV_ACK_JUDGE =           3'b010,
                      RECV_ACK_WAIT_TX_BB_DONE = 3'b011,
                      RECV_ACK_WATI_SIG_VALID  = 3'b100,
                      RECV_ACK       =           3'b101;

  (* mark_debug = "true" *) wire [3:0] retrans_limit;
  (* mark_debug = "true" *) reg [3:0] num_retrans;
  reg signed [14:0] ack_timeout_count;
  (* mark_debug = "true" *) reg [5:0] send_ack_count;
  (* mark_debug = "true" *) reg [47:0] ack_addr;
  reg [15:0] duration_received;
  reg FC_more_frag_received;
  (* mark_debug = "true" *) reg [2:0] tx_control_state;
  (* mark_debug = "true" *) reg [2:0] tx_control_state_priv;
  wire is_data;
  wire is_management;
  wire is_blockackreq;
  wire is_blockack;
  wire is_pspoll;
  wire is_rts;
  wire [3:0] ackcts_rate;
  wire ackcts_signal_parity;
  wire [11:0] ackcts_signal_len;

  reg [63:0] douta_reg;
  reg [1:0] tx_dpram_op_counter;

  wire [4:0] num_data_ofdm_symbol;
  wire [7:0] ackcts_n_sym;
  wire [7:0] ackcts_time;

  reg signed [14:0] recv_ack_timeout_top;

  reg [15:0] duration_new;
  reg [1:0]  FC_type_new;
  reg [3:0]  FC_subtype_new;
  reg is_data_received;
  reg is_management_received;
  reg is_blockackreq_received;
  reg is_blockack_received;
  reg is_pspoll_received;
  reg is_rts_received;

  assign tx_control_state_idle = ( (tx_control_state==IDLE)&&(retrans_in_progress==0) );

  assign retrans_limit = (max_num_retrans>0?max_num_retrans:tx_pkt_retrans_limit);

  assign is_data =        ((FC_type==2'b10)?1:0);
  assign is_management =  (((FC_type==2'b00)&&(FC_subtype!=4'b1110))?1:0);
  assign is_blockackreq = (((FC_type==2'b01) && (FC_subtype==4'b1000))?1:0);
  assign is_blockack =    (((FC_type==2'b01) && (FC_subtype==4'b1001))?1:0);
  assign is_pspoll =      (((FC_type==2'b01) && (FC_subtype==4'b1010))?1:0);
  assign is_rts =         (((FC_type==2'b01) && (FC_subtype==4'b1011) && (signal_len==20))?1:0);

  assign ack_cts_is_ongoing = (tx_control_state==SEND_ACK);

  assign ackcts_rate = (cts_torts_rate[4]?signal_rate[3:0]:cts_torts_rate[3:0]);
  assign ackcts_signal_parity = (~(^ackcts_rate));//because the cts and ack pkt length field is always 14: 1110 that always has 3 1s
  assign ackcts_signal_len = 14;

  assign ackcts_time = preamble_sig_time + ofdm_symbol_time*ackcts_n_sym;

  n_sym_len14_pkt # (
  ) n_sym_len14_pkt_i0 (
    .ht_flag(signal_rate[7]),
    .rate_mcs(signal_rate[3:0]),
    .n_sym(num_data_ofdm_symbol[2:0])
  );

  n_sym_len14_pkt # (
  ) n_sym_len14_pkt_i1 (
    .ht_flag(0),
    .rate_mcs(ackcts_rate),
    .n_sym(ackcts_n_sym[2:0])
  );

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
          tx_control_state_priv <= IDLE;
          tx_try_complete<=0;
          tx_status<=0;
          num_retrans<=0;
          start_retrans<=0;
          retrans_in_progress<=0;
          tx_dpram_op_counter<=0;
          douta_reg<=0;
          recv_ack_timeout_top<=0;
          duration_new<=0;
          FC_type_new<=0;
          FC_subtype_new<=0;
          duration_received<=0;
          FC_more_frag_received<=0;
          is_data_received<=0;
          is_management_received<=0;
          is_blockackreq_received<=0;
          is_blockack_received<=0;
          is_pspoll_received<=0;
          is_rts_received<=0;
        end
      else begin
        tx_control_state_priv<=tx_control_state;
        case (tx_control_state)
          IDLE: begin
            ack_tx_flag<=0;
            wea<=0;
            addra<=0;
            dina<=0;
            ack_timeout_count<=0;
            send_ack_count <= 0;
            tx_try_complete<=0;
            tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            num_retrans<=num_retrans;
            start_retrans<=0;
            retrans_in_progress<=retrans_in_progress;
            tx_dpram_op_counter<=0;
            douta_reg<=0;
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
            is_blockack_received<=is_blockack;
            is_pspoll_received<=is_pspoll;
            is_rts_received<=is_rts;
            //8.3.1.4 ACK frame format: The RA field of the ACK frame is copied from the Address 2 field of the immediately previous individually
            //addressed data, management, BlockAckReq, BlockAck, or PS-Poll frames.
            if ( fcs_valid && (is_data||is_management||is_blockackreq||is_blockack||is_pspoll||(is_rts&&(!cts_torts_disable))) 
                           && (self_mac_addr==addr1) && (retrans_in_progress==0) ) // only when we are not in retransmit process, need to send ACK! send ACK will not back to this IDLE until the last IQ sample sent.
              begin
                  tx_control_state  <= SEND_ACK; //we also send cts (if rts is received) in SEND_ACK status
              end
            //else if ( pulse_tx_bb_end_almost && tx_pkt_type[0]==1 && (core_state_old!=SEND_ACK) )// need to recv ACK! We need to miss this pulse_tx_bb_end_almost intentionally when send ACK, because ACK don't need ACK
            //else if ( phy_tx_done && (core_state_old!=SEND_ACK) )// need to recv ACK! We need to miss this pulse_tx_bb_end_almost intentionally when send ACK, because ACK don't need ACK
            else if ( phy_tx_done && cts_toself_bb_is_ongoing==0 ) // because SEND_ACK won't be back until phy_tx_done. So here phy_tx_done must be from high layer
              begin
                  tx_control_state  <= RECV_ACK_JUDGE;
              end
            else
              begin
                  tx_control_state  <= tx_control_state;
              end
          end

          SEND_ACK: begin // data is calculated by calc_phy_header C program
            ack_tx_flag<=1;
            ack_addr <= ack_addr;
            tx_try_complete<=0;
            tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            num_retrans<=num_retrans;
            start_retrans<=0;
            retrans_in_progress<=retrans_in_progress;
            tx_dpram_op_counter<=0;
            douta_reg<=0;
            recv_ack_timeout_top<=0;

            //standard: For ACK frames sent by non-QoS STAs, if the More Fragments bit was equal to 0 in the Frame Control field
            //of the immediately previous individually addressed data or management frame, the duration value is set to 0.
            if ( (is_data_received||is_management_received) && (FC_more_frag_received==0)) begin
              duration_new<=duration_extra+0;
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1101;
            end else if (is_data_received||is_management_received||is_blockackreq_received||is_blockack_received||is_pspoll_received) begin
            //standard: In other ACK frames sent by non-QoS STAs, the duration value is the value obtained from the Duration/ID
            //field of the immediately previous data, management, PS-Poll, BlockAckReq, or BlockAck frame minus the
            //time, in microseconds, required to transmit the ACK frame and its SIFS interval.
            //assume we use 6M for ack(14byte): n_ofdm=6=(22+14*8)/24; time_us=20(preamble+SIGNAL)+6*4=44;
              //duration_new<= duration_extra+(duration_received-44-sifs_time);//SIFS 2.4GHz 10us; 5GHz 16us
              duration_new<= duration_extra+(duration_received-ackcts_time-sifs_time);
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1101;
            end else if (is_rts_received) begin
              //duration_new<= duration_extra+(duration_received-44-sifs_time);//SIFS 2.4GHz 10us; 5GHz 16us
              duration_new<= duration_extra+(duration_received-ackcts_time-sifs_time);
              FC_type_new<=2'b01;
              FC_subtype_new<=4'b1100;
            end

            if (ack_timeout_count == send_ack_wait_top) begin
              ack_timeout_count <= ack_timeout_count;
              if (send_ack_count==0)
                  begin
                  wea<=1;
                  addra<=0;
                  //dina<={32'h0, 32'h000001cb}; // rate 6M len 14
                  dina<={32'h0, 14'd0, ackcts_signal_parity, ackcts_signal_len, 1'b0, ackcts_rate};
                  send_ack_count <= send_ack_count + 1;
                  tx_control_state  <= tx_control_state;
                  end
              else if (send_ack_count==1)
                  begin
                  wea<=1;
                  addra<=1;
                  dina<={32'h0, 32'h0};
                  send_ack_count <= send_ack_count + 1;
                  tx_control_state  <= tx_control_state;
                  end
              else if (send_ack_count==2)
                  begin
                  wea<=1;
                  addra<=2;
                  //dina<={ack_addr[31:0], 32'h000000d4};
                  dina<={ack_addr[31:0], duration_new, 8'd0, FC_subtype_new, FC_type_new, 2'd0};
                  send_ack_count <= send_ack_count + 1;
                  tx_control_state  <= tx_control_state;
                  end
              else if (send_ack_count==3)
                  begin
                  wea<=1;
                  addra<=3;
                  dina<={48'h0,ack_addr[47:32]};
                  send_ack_count <= send_ack_count + 1;
                  tx_control_state  <= tx_control_state;
                  end
              else if (send_ack_count<32) // to make sure ack_tx_flag cover the wait time before actual ack tx is ongoing. for disabling duc tx action from high layer
                  begin
                  wea<=0;
                  addra<=0;
                  dina<=0;
                  send_ack_count <= send_ack_count + 1;
                  tx_control_state  <= tx_control_state;
                  end
              else
                  begin
                  wea<=0;
                  addra<=0;
                  dina<=0;
                  send_ack_count <= send_ack_count;
                  tx_control_state  <= (phy_tx_done?IDLE:tx_control_state);
                  end
            end else begin
              ack_timeout_count <= ack_timeout_count + 1;
              wea<=wea;
              addra<=addra;
              dina<=dina;
              send_ack_count <= send_ack_count;
              tx_control_state  <= tx_control_state;
            end
          end
          
          RECV_ACK_JUDGE: begin
            ack_tx_flag<=0;
            wea<=0;
            dina<=0;
            send_ack_count <= 0;
            ack_addr <= 0;
            ack_timeout_count<=0;
            start_retrans<=0;
            tx_dpram_op_counter<=0;
            douta_reg<=0;
            recv_ack_timeout_top<=0;
                
            if (tx_pkt_need_ack==1) // continue to actual ACK receiving
                begin
                tx_control_state<= RECV_ACK_WAIT_TX_BB_DONE;
                addra<=2;
                tx_try_complete<=0;
                tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
                num_retrans<=num_retrans;
                retrans_in_progress<=1;
                end
            else
                begin
                tx_control_state<= IDLE;
                addra<=0;
                tx_try_complete<=1;
                tx_status<={1'b0,num_retrans}; // because interrupt will be raised, set status
                num_retrans<=0;
                retrans_in_progress<=0;
                end

          end

          RECV_ACK_WAIT_TX_BB_DONE: begin
            ack_tx_flag<=0;
            recv_ack_timeout_top<=0;

            addra<=addra;
            if (tx_dpram_op_counter==0) begin //read
                wea<=wea;
                dina<=dina;
                douta_reg<=douta_reg;
                tx_dpram_op_counter <= tx_dpram_op_counter + 1;
                end
            else if (tx_dpram_op_counter==1) begin //read
                wea<=wea;
                dina<=dina;
                douta_reg<=douta_reg;
                tx_dpram_op_counter <= tx_dpram_op_counter + 1;
                end
            else if (tx_dpram_op_counter==2) begin //read
                wea<=1;
                dina<=dina;
                douta_reg<={douta[63:12], 1'b1, douta[10:0]};// if in the future retransmit, mark as retry pkt
                tx_dpram_op_counter <= tx_dpram_op_counter + 1;
                end
            else begin //read
                wea<=1;
                dina<=douta_reg;
                douta_reg<=douta_reg;// if in the future retransmit, mark as retry pkt
                tx_dpram_op_counter <= tx_dpram_op_counter;
                end

            send_ack_count <= 0;
            ack_addr <= 0;
            ack_timeout_count<=0;
            tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
            num_retrans<=num_retrans;
            tx_try_complete<=0;
            start_retrans<=0;
            retrans_in_progress<=retrans_in_progress;

            if (pulse_tx_bb_end_almost)                 begin
                tx_control_state<= RECV_ACK_WATI_SIG_VALID;
            end
            else                begin
                tx_control_state<= tx_control_state;
            end
            
          end

          RECV_ACK_WATI_SIG_VALID: begin
            ack_tx_flag<=0;
            wea<=0;
            addra<=0;
            dina<=0;
            send_ack_count <= 0;
            ack_addr <= 0;
            ack_timeout_count<=ack_timeout_count+1;
            tx_dpram_op_counter<=0;
            douta_reg<=0;
            recv_ack_timeout_top<=0;

            if ( (ack_timeout_count<recv_ack_sig_valid_timeout_top) && sig_valid && (signal_len==14)) //before timeout, we detect a sig valid, signal length field is ACK
                begin
                tx_control_state<= RECV_ACK;
                tx_try_complete<=0;
                tx_status<=tx_status;
                num_retrans<=num_retrans;
                start_retrans<=0;
                retrans_in_progress<=retrans_in_progress;
                ack_timeout_count<=0;
                recv_ack_timeout_top <= ((num_data_ofdm_symbol<<2)*200)+recv_ack_timeout_top_adj;
                end
            else if ( ack_timeout_count==recv_ack_sig_valid_timeout_top ) // sig valid timeout
                begin
                tx_control_state<= IDLE;
                if  ((num_retrans==retrans_limit) || (retrans_limit==0)) // should not run into this state. but just in case
                    begin
                    tx_try_complete<=1;
                    tx_status<={1'b1,num_retrans};
                    num_retrans<=0;
                    start_retrans<=0;
                    retrans_in_progress<=0;
                    end
                else 
                    begin
                    tx_try_complete<=0;
                    tx_status<=tx_status;
                    num_retrans<=num_retrans+1;
                    start_retrans<=1;
                    retrans_in_progress<=retrans_in_progress;
                    end
                end
            else
                begin
                tx_control_state<= tx_control_state;
                tx_try_complete<=0;
                tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
                num_retrans<=num_retrans;
                start_retrans<=0;
                retrans_in_progress<=retrans_in_progress;
                end
          end

          RECV_ACK: begin
            ack_tx_flag<=0;
            wea<=0;
            addra<=0;
            dina<=0;
            send_ack_count <= 0;
            ack_addr <= 0;
            ack_timeout_count<=ack_timeout_count+1;
            tx_dpram_op_counter<=0;
            douta_reg<=0;
            recv_ack_timeout_top <= recv_ack_timeout_top;
            if ( (ack_timeout_count<recv_ack_timeout_top) && (recv_ack_fcs_valid_disable|fcs_valid) && (FC_type==2'b01) && (FC_subtype==4'b1101) && (self_mac_addr==addr1)) //before timeout, we detect a ACK type frame fcs valid
                begin
                tx_control_state<= IDLE;
                tx_try_complete<=1;
                tx_status<={1'b0,num_retrans};
                num_retrans<=0;
                start_retrans<=0;
                retrans_in_progress<=0;
                end
            else if ( ack_timeout_count==recv_ack_timeout_top ) // timeout
                begin
                tx_control_state<= IDLE;
                if  ((num_retrans==retrans_limit) || (retrans_limit==0)) // should not run into this state. but just in case
                    begin
                    tx_try_complete<=1;
                    tx_status<={1'b1,num_retrans};
                    num_retrans<=0;
                    start_retrans<=0;
                    retrans_in_progress<=0;
                    end
                else 
                    begin
                    tx_try_complete<=0;
                    tx_status<=tx_status;
                    num_retrans<=num_retrans+1;
                    start_retrans<=1;
                    retrans_in_progress<=retrans_in_progress;
                    end
                end
            else
                begin
                tx_control_state<= tx_control_state;
                tx_try_complete<=0;
                tx_status<=tx_status; //maintain status from state RECV_ACK for ARM reading
                num_retrans<=num_retrans;
                start_retrans<=0;
                retrans_in_progress<=retrans_in_progress;
                end
          end
        endcase
      end
    end

	endmodule
