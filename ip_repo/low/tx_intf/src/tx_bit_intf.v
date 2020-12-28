// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
`include "clock_speed.v"
`include "board_def.v"

`timescale 1 ns / 1 ps

//`define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`define DEBUG_PREFIX

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
	    
	    input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] data_from_s_axis,
	    output wire ask_data_from_s_axis,
	    input wire  emptyn_from_s_axis,
	    output wire [1:0] tx_queue_idx,
      output reg  [1:0] linux_prio,
	    
	    //input wire src_indication,//0-s_axis-->phy_tx-->iq-->duc; 1-s_axis-->iq-->duc
	    input wire auto_start_mode,
	    input wire [9:0] num_dma_symbol_th,
	    input wire [31:0] num_dma_symbol_total,
	    input wire [1:0] tx_queue_idx_indication_from_ps,
	    input wire s_axis_recv_data_from_high,
	    output wire start,

      output wire [6:0] num_dma_symbol_fifo_data_count0,
      output wire [6:0] num_dma_symbol_fifo_data_count1,
      output wire [6:0] num_dma_symbol_fifo_data_count2,
      output wire [6:0] num_dma_symbol_fifo_data_count3,

      `DEBUG_PREFIX input wire tx_iq_fifo_empty,
      input wire [31:0] cts_toself_config,
      input wire [13:0] send_cts_toself_wait_sifs_top, //between cts and following frame, there should be a sifs waiting period
      input wire [47:0] mac_addr,
      `DEBUG_PREFIX input wire tx_try_complete,
      `DEBUG_PREFIX input wire retrans_in_progress,
      `DEBUG_PREFIX input wire start_retrans,
      `DEBUG_PREFIX input wire start_tx_ack,
	    `DEBUG_PREFIX input wire high_tx_allowed0,
	    `DEBUG_PREFIX input wire high_tx_allowed1,
	    `DEBUG_PREFIX input wire high_tx_allowed2,
	    `DEBUG_PREFIX input wire high_tx_allowed3,
	    input wire tx_bb_is_ongoing,
	    input wire ack_tx_flag,
	    input wire wea_from_xpu,
      input wire [9:0] addra_from_xpu,
      input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_from_xpu,
      output wire tx_pkt_need_ack,
      `DEBUG_PREFIX output reg quit_retrans,
      output wire [3:0] tx_pkt_retrans_limit,
      output reg [9:0] tx_pkt_sn,
      // output reg [15:0] tx_pkt_num_dma_byte,
      output wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] douta,
      output reg cts_toself_bb_is_ongoing,
      output reg cts_toself_rf_is_ongoing,
	    
	    // port to phy_tx
	    input wire tx_end_from_acc,
	    output wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] bram_data_to_acc,
      input wire  [(WIFI_TX_BRAM_ADDR_WIDTH-1):0] bram_addr,

      input wire tsf_pulse_1M
	);
    
    localparam [2:0]   WAIT_CHANCE =                    3'b000,
                       PREPARE_TX_FETCH=                3'b001,
                       PREPARE_TX_JUDGE=                3'b010,
                       DO_CTS_TOSELF=                   3'b011,
                       WAIT_SIFS =                      3'b100,
                       DO_TX =                          3'b101,
                       WAIT_TX_COMP =                   3'b110;
    `DEBUG_PREFIX reg [2:0] high_tx_ctl_state;
    `DEBUG_PREFIX reg [2:0] high_tx_ctl_state_old;
    
    reg  [13:0] send_cts_toself_wait_count;
    reg  [12:0] wr_counter;
    reg read_from_s_axis_en;
    
    `DEBUG_PREFIX wire wea_high;
    `DEBUG_PREFIX wire wea;
    `DEBUG_PREFIX wire [9:0] addra;
    `DEBUG_PREFIX wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina;
    wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] bram_data_to_acc_int;

    reg wea_internal;
    reg [12:0] addra_internal;
    reg [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_internal;
    
    wire [63:0] num_dma_symbol_fifo_rd_data0;
    wire [63:0] num_dma_symbol_fifo_rd_data1;
    wire [63:0] num_dma_symbol_fifo_rd_data2;
    wire [63:0] num_dma_symbol_fifo_rd_data3;

    `DEBUG_PREFIX reg [63:0] num_dma_symbol_total_current;

    reg num_dma_symbol_total_rden0;
    reg num_dma_symbol_total_rden1;
    reg num_dma_symbol_total_rden2;
    reg num_dma_symbol_total_rden3;

    reg num_dma_symbol_total_wren0;
    reg num_dma_symbol_total_wren1;
    reg num_dma_symbol_total_wren2;
    reg num_dma_symbol_total_wren3;

    wire num_dma_symbol_fifo_empty0;
    wire num_dma_symbol_fifo_empty1;
    wire num_dma_symbol_fifo_empty2;
    wire num_dma_symbol_fifo_empty3;

    wire num_dma_symbol_fifo_full0;
    wire num_dma_symbol_fifo_full1;
    wire num_dma_symbol_fifo_full2;
    wire num_dma_symbol_fifo_full3;

    wire s_axis_recv_data_from_high_valid;
    reg [1:0] tx_queue_idx_reg;
    
    reg start_delay0;
    reg start_delay1;
    reg start_delay2;
    reg start_delay3;
    reg start_delay4;
    reg start_delay5;

    reg tx_try_complete_dl0;
    reg tx_try_complete_dl1;
    reg tx_try_complete_dl2;
    
    reg s_axis_recv_data_from_high_delay;

    reg [3:0] cts_toself_rate;
    wire cts_toself_signal_parity;
    wire [11:0] cts_toself_signal_len;

    reg [47:0] mac_addr_reg;

    reg [13:0] send_cts_toself_wait_sifs_top_scale;

    assign ask_data_from_s_axis = read_from_s_axis_en;
    assign start = ( (auto_start_mode==1'b0)?(1'b0): (start_delay0|start_delay1|start_delay2|start_delay3|start_delay4|start_delay5) );

    assign wea_high = (read_from_s_axis_en&emptyn_from_s_axis);
    assign wea = ( (retrans_in_progress)?wea_from_xpu:wea_internal );
    assign addra = ( (retrans_in_progress)?addra_from_xpu:addra_internal );
    assign dina = ( (retrans_in_progress)?dina_from_xpu:dina_internal );
    assign bram_data_to_acc = (ack_tx_flag? dina_from_xpu:bram_data_to_acc_int);

    assign tx_pkt_need_ack = num_dma_symbol_total_current[13];
    assign tx_pkt_retrans_limit = num_dma_symbol_total_current[17:14];
    
    assign s_axis_recv_data_from_high_valid = ( ((s_axis_recv_data_from_high==0) && (s_axis_recv_data_from_high_delay==1))?1:0 );
    
    assign tx_queue_idx = tx_queue_idx_reg;

    assign cts_toself_signal_parity = (~(^cts_toself_rate)); //because the cts and ack pkt length field is always 14: 1110 that always has 3 1s
    assign cts_toself_signal_len = 14;
    
    // state machine to do tx for high layer if high_tx_allowed
	  always @(posedge clk)                                             
    begin
      if (!rstn)
      // Synchronous reset (active low)                                       
        begin
          wea_internal<=0;
          addra_internal<=0;
          dina_internal<=0;

          cts_toself_rate<=0;
          send_cts_toself_wait_sifs_top_scale <= 0;

          read_from_s_axis_en <= 0;      
          num_dma_symbol_total_current <= 0;                            
          num_dma_symbol_total_rden0<= 0;   
          num_dma_symbol_total_rden1<= 0;   
          num_dma_symbol_total_rden2<= 0;   
          num_dma_symbol_total_rden3<= 0;   
          high_tx_ctl_state <= WAIT_CHANCE;
          high_tx_ctl_state_old<=WAIT_CHANCE;
          wr_counter <= 13'b0;
          tx_queue_idx_reg<=0;
          send_cts_toself_wait_count<=0;

          cts_toself_bb_is_ongoing<=0;
          cts_toself_rf_is_ongoing<=0;
          quit_retrans<=0;
          mac_addr_reg<=0;
        end                                                                   
      else begin
        high_tx_ctl_state_old <= high_tx_ctl_state;
        //cts_toself_config[31:0] restored to num_dma_symbol_total_current[63:32] before actual tx
        //cts_toself_config[31]/num_dma_symbol_total_current[63] enable/disable cts to self
        //cts_toself_config[30]/num_dma_symbol_total_current[62] select cts to self rate. 1 select the actual traffic pkt rate that is in cts_toself_config[3:0]/num_dma_symbol_total_current[35:32]
        //cts_toself_config[30]/num_dma_symbol_total_current[62] select cts to self rate. 0 select specified cts to self rate by mac80211 in cts_toself_config[7:4]/num_dma_symbol_total_current[39:36]
        //cts_toself_config[23:8]/num_dma_symbol_total_current[55:40] cts to self duration 
        cts_toself_rate <= (num_dma_symbol_total_current[62]?num_dma_symbol_total_current[35:32]:num_dma_symbol_total_current[39:36]);//cts_toself_config[23:8]
        mac_addr_reg <= mac_addr;

        send_cts_toself_wait_sifs_top_scale <= (send_cts_toself_wait_sifs_top*`COUNT_SCALE);

        case (high_tx_ctl_state)                                                 
          WAIT_CHANCE: begin
            wea_internal<=0;
            addra_internal<=0;
            dina_internal<=0;

            cts_toself_bb_is_ongoing<=0;
            cts_toself_rf_is_ongoing<=0;

            read_from_s_axis_en <= 0;
            // num_dma_symbol_total_current <= num_dma_symbol_total_current;
            if ( high_tx_allowed0 && (~num_dma_symbol_fifo_empty0) && (~tx_bb_is_ongoing) && (~ack_tx_flag)) begin
                  num_dma_symbol_total_rden1<= 0;
                  num_dma_symbol_total_rden2<= 0;
                  num_dma_symbol_total_rden3<= 0;
                  if(retrans_in_progress == 1) begin
                    num_dma_symbol_total_rden0<= 0;
                    quit_retrans <= 1;
                    high_tx_ctl_state<=WAIT_TX_COMP;
                    tx_queue_idx_reg<=tx_queue_idx_reg;
                  end else begin 
                    num_dma_symbol_total_rden0<= 1;
                    quit_retrans<=0;
                    tx_queue_idx_reg<=0; 
                    high_tx_ctl_state<=PREPARE_TX_FETCH;
                  end
            end else if ( high_tx_allowed1 && (~num_dma_symbol_fifo_empty1) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && (~retrans_in_progress) ) begin
                  num_dma_symbol_total_rden0<= 0;
                  num_dma_symbol_total_rden1<= 1;
                  num_dma_symbol_total_rden2<= 0;
                  num_dma_symbol_total_rden3<= 0;
                  high_tx_ctl_state  <= PREPARE_TX_FETCH;
                  tx_queue_idx_reg<=1;
            end else if ( high_tx_allowed2 && (~num_dma_symbol_fifo_empty2) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && (~retrans_in_progress) ) begin
                  num_dma_symbol_total_rden0<= 0;
                  num_dma_symbol_total_rden1<= 0;
                  num_dma_symbol_total_rden2<= 1;
                  num_dma_symbol_total_rden3<= 0;
                  high_tx_ctl_state  <= PREPARE_TX_FETCH;
                  tx_queue_idx_reg<=2;
            end else if ( high_tx_allowed3 && (~num_dma_symbol_fifo_empty3) && (~tx_bb_is_ongoing) && (~ack_tx_flag) && (~retrans_in_progress) ) begin
                  num_dma_symbol_total_rden0<= 0;
                  num_dma_symbol_total_rden1<= 0;
                  num_dma_symbol_total_rden2<= 0;
                  num_dma_symbol_total_rden3<= 1;
                  high_tx_ctl_state  <= PREPARE_TX_FETCH;
                  tx_queue_idx_reg<=3;
            end

            wr_counter <= 13'b0;
            send_cts_toself_wait_count<=0;
          end

          WAIT_TX_COMP: begin
            quit_retrans <= 0;
            if(tx_try_complete_dl2 == 1) begin
              high_tx_ctl_state  <= PREPARE_TX_FETCH;
              tx_queue_idx_reg<=0;
	      num_dma_symbol_total_rden0<= 1;
            end
          end
          PREPARE_TX_FETCH: begin
            // wea_internal<=wea_internal;
            // addra_internal<=addra_internal;
            // dina_internal<=dina_internal;
    
            // cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
            // cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;

            num_dma_symbol_total_current <= ( tx_queue_idx_reg[1]?(tx_queue_idx_reg[0]?num_dma_symbol_fifo_rd_data3:num_dma_symbol_fifo_rd_data2):(tx_queue_idx_reg[0]?num_dma_symbol_fifo_rd_data1:num_dma_symbol_fifo_rd_data0) );
            num_dma_symbol_total_rden0<= 0;
            num_dma_symbol_total_rden1<= 0;
            num_dma_symbol_total_rden2<= 0;
            num_dma_symbol_total_rden3<= 0;
            // read_from_s_axis_en <= read_from_s_axis_en;
            // wr_counter <= wr_counter;
            // tx_queue_idx_reg<=tx_queue_idx_reg;
            // send_cts_toself_wait_count<=send_cts_toself_wait_count;
            high_tx_ctl_state  <= PREPARE_TX_JUDGE;
          end

          PREPARE_TX_JUDGE: begin
            // num_dma_symbol_total_current <= num_dma_symbol_total_current;
            // num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            // num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;

            // cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
            // cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;

            if (num_dma_symbol_total_current[63]==1) begin // from cts_toself_config[31] in tx queue
              // read_from_s_axis_en <= read_from_s_axis_en;
              high_tx_ctl_state  <= DO_CTS_TOSELF;

              // wea_internal<=wea_internal;
              // addra_internal<=addra_internal;
              // dina_internal<=dina_internal;
            end else begin
              read_from_s_axis_en <= 1;
              high_tx_ctl_state  <= DO_TX;

              // wea_internal<=wea_high;
              // addra_internal<=wr_counter;
              // dina_internal<=data_from_s_axis;
            end
            // wr_counter <= wr_counter;
            // tx_queue_idx_reg<=tx_queue_idx_reg;
            // send_cts_toself_wait_count<=send_cts_toself_wait_count;
          end

          DO_CTS_TOSELF: begin
            // num_dma_symbol_total_current <= num_dma_symbol_total_current;
            // num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            // num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;
            // read_from_s_axis_en <= read_from_s_axis_en;

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
                dina_internal<={mac_addr_reg[31:0], num_dma_symbol_total_current[55:40], 8'd0, 4'b1100, 2'b01, 2'd0};//CTS FC_type 2'b01 FC_subtype 4'b1100 duration num_dma_symbol_total_current[55:40] from cts_toself_config[23:8] in tx queue
            end else if (send_cts_toself_wait_count==3) begin
                dina_internal<={48'h0,mac_addr_reg[47:32]};
            end 
            // else begin
            //     dina_internal<=dina_internal;
            // end

            // wr_counter <= wr_counter;
            // tx_queue_idx_reg<=tx_queue_idx_reg;
          end

          WAIT_SIFS: begin
            // num_dma_symbol_total_current <= num_dma_symbol_total_current;
            // num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            // num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;
            
            // cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
            // cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;

            send_cts_toself_wait_count <= send_cts_toself_wait_count+1;
            if (send_cts_toself_wait_count == send_cts_toself_wait_sifs_top_scale ) begin
              read_from_s_axis_en <= 1;
              high_tx_ctl_state  <= DO_TX;

              // wea_internal<=wea_high;
              // addra_internal<=wr_counter;
              // dina_internal<=data_from_s_axis;
              // send_cts_toself_wait_count <= send_cts_toself_wait_count;
            end 
            // else begin
            //   read_from_s_axis_en <= read_from_s_axis_en;
            //   high_tx_ctl_state  <= high_tx_ctl_state;

            //   wea_internal<=wea_internal;
            //   addra_internal<=addra_internal;
            //   dina_internal<=dina_internal;
            //   send_cts_toself_wait_count <= send_cts_toself_wait_count+1;
            // end
            // wr_counter <= wr_counter;
            // tx_queue_idx_reg<=tx_queue_idx_reg;
          end
          
          DO_TX: begin
            // num_dma_symbol_total_current <= num_dma_symbol_total_current;
            // num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            // num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;
            // send_cts_toself_wait_count<=send_cts_toself_wait_count;
            // tx_queue_idx_reg<=tx_queue_idx_reg;

            // cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;

            wea_internal<=wea_high;
            addra_internal<=wr_counter;
            dina_internal<=data_from_s_axis;

            wr_counter <= ( wea_high?(wr_counter + 1):wr_counter );
            if (wr_counter == (num_dma_symbol_total_current[12:0]-1))
              read_from_s_axis_en<= 0;
            else
              read_from_s_axis_en<= read_from_s_axis_en;

            high_tx_ctl_state<= ( tx_end_from_acc?WAIT_CHANCE:high_tx_ctl_state );
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
    //    duplicated_sn <= tx_pkt_sn;
    //    duplicated_sn_catch <= (duplicated_sn==tx_pkt_sn?1:0);
    //  end
    //end
    
    // store num_dma_symbol_total into fifo
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            tx_pkt_sn <= 0;
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
            
            num_dma_symbol_total_wren0 <= 0;
            num_dma_symbol_total_wren1 <= 0;
            num_dma_symbol_total_wren2 <= 0;
            num_dma_symbol_total_wren3 <= 0;
            s_axis_recv_data_from_high_delay <= 0;
        end 
      else
        begin
            if (tx_try_complete) begin
              tx_pkt_sn <= num_dma_symbol_total_current[29:20];
              // tx_pkt_num_dma_byte <= {num_dma_symbol_total_current[12:0],3'd0};
              linux_prio <= num_dma_symbol_total_current[31:30];
            end

            tx_try_complete_dl0<=tx_try_complete;
            tx_try_complete_dl1<=tx_try_complete_dl0;
            tx_try_complete_dl2<=tx_try_complete_dl1;
            
            start_delay0<= ( ack_tx_flag?start_tx_ack:(retrans_in_progress==1?start_retrans:(addra==num_dma_symbol_th)) );//controle the width of tx pulse
            start_delay1<=start_delay0;
            start_delay2<=start_delay1;
            start_delay3<=start_delay2;
            start_delay4<=start_delay3;
            start_delay5<=start_delay4;

            s_axis_recv_data_from_high_delay<=s_axis_recv_data_from_high;
            num_dma_symbol_total_wren0<= (tx_queue_idx_indication_from_ps==0?s_axis_recv_data_from_high_valid:0);//assure DMA is done
            num_dma_symbol_total_wren1<= (tx_queue_idx_indication_from_ps==1?s_axis_recv_data_from_high_valid:0);//assure DMA is done
            num_dma_symbol_total_wren2<= (tx_queue_idx_indication_from_ps==2?s_axis_recv_data_from_high_valid:0);//assure DMA is done
            num_dma_symbol_total_wren3<= (tx_queue_idx_indication_from_ps==3?s_axis_recv_data_from_high_valid:0);//assure DMA is done
        end
    end
    
    //fifio to store num_dma_symbol_total each time s_axis_recv_data_from_high becomes high
    fifo64_1clk_dep64 fifo64_1clk_dep64_i0 (// only store num_dma_symbol from high layer, not aware ack pkt
        .CLK(clk),
        .DATAO(num_dma_symbol_fifo_rd_data0),
        .DI({cts_toself_config,num_dma_symbol_total}),
        .EMPTY(num_dma_symbol_fifo_empty0),
        .FULL(num_dma_symbol_fifo_full0),
        .RDEN(num_dma_symbol_total_rden0),
        .RST(!rstn),
        .WREN(num_dma_symbol_total_wren0),
        .data_count(num_dma_symbol_fifo_data_count0)
    );

    //fifio to store num_dma_symbol_total each time s_axis_recv_data_from_high becomes high
    fifo64_1clk_dep64 fifo64_1clk_dep64_i1 (// only store num_dma_symbol from high layer, not aware ack pkt
        .CLK(clk),
        .DATAO(num_dma_symbol_fifo_rd_data1),
        .DI({cts_toself_config,num_dma_symbol_total}),
        .EMPTY(num_dma_symbol_fifo_empty1),
        .FULL(num_dma_symbol_fifo_full1),
        .RDEN(num_dma_symbol_total_rden1),
        .RST(!rstn),
        .WREN(num_dma_symbol_total_wren1),
        .data_count(num_dma_symbol_fifo_data_count1)
    );

    //fifio to store num_dma_symbol_total each time s_axis_recv_data_from_high becomes high
    fifo64_1clk_dep64 fifo64_1clk_dep64_i2 (// only store num_dma_symbol from high layer, not aware ack pkt
        .CLK(clk),
        .DATAO(num_dma_symbol_fifo_rd_data2),
        .DI({cts_toself_config,num_dma_symbol_total}),
        .EMPTY(num_dma_symbol_fifo_empty2),
        .FULL(num_dma_symbol_fifo_full2),
        .RDEN(num_dma_symbol_total_rden2),
        .RST(!rstn),
        .WREN(num_dma_symbol_total_wren2),
        .data_count(num_dma_symbol_fifo_data_count2)
    );

    //fifio to store num_dma_symbol_total each time s_axis_recv_data_from_high becomes high
    fifo64_1clk_dep64 fifo64_1clk_dep64_i3 (// only store num_dma_symbol from high layer, not aware ack pkt
        .CLK(clk),
        .DATAO(num_dma_symbol_fifo_rd_data3),
        .DI({cts_toself_config,num_dma_symbol_total}),
        .EMPTY(num_dma_symbol_fifo_empty3),
        .FULL(num_dma_symbol_fifo_full3),
        .RDEN(num_dma_symbol_total_rden3),
        .RST(!rstn),
        .WREN(num_dma_symbol_total_wren3),
        .data_count(num_dma_symbol_fifo_data_count3)
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
