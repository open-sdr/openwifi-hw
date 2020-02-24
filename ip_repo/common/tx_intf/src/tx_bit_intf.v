// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

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
	    
	    //input wire src_indication,//0-s_axis-->phy_tx-->iq-->duc; 1-s_axis-->iq-->duc
	    input wire auto_start_mode,
	    input wire [9:0] num_dma_symbol_th,
	    input wire [31:0] num_dma_symbol_total,
	    input wire [1:0] tx_queue_idx_indication_from_ps,
	    input wire s_axis_recv_data_from_high,
	    output wire start,

      output wire [6:0] num_dma_symbol_fifo_data_count0,
      output wire [6:0] num_dma_symbol_fifo_data_count1,

      input wire tx_iq_fifo_empty,
      input wire [31:0] cts_toself_config,
      input wire [11:0] send_cts_toself_wait_sifs_top, //between cts and following frame, there should be a sifs waiting period
      input wire [47:0] mac_addr,
      input wire tx_try_complete,
      input wire retrans_in_progress,
      input wire start_retrans,
	    input wire high_tx_allowed0,
	    input wire high_tx_allowed1,
	    input wire tx_bb_is_ongoing,
	    input wire ack_tx_flag,
	    input wire wea_from_xpu,
      input wire [9:0] addra_from_xpu,
      input wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_from_xpu,
      output wire tx_pkt_need_ack,
      output wire [3:0] tx_pkt_retrans_limit,
      output reg [11:0] tx_pkt_sn,
      output reg [15:0] tx_pkt_num_dma_byte,
      output wire [(WIFI_TX_BRAM_DATA_WIDTH-1):0] douta,
      (* mark_debug = "true" *) output reg cts_toself_bb_is_ongoing,
      (* mark_debug = "true" *) output reg cts_toself_rf_is_ongoing,
	    
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
                       DO_TX =                          3'b101;
    (* mark_debug = "true" *) reg [2:0] high_tx_ctl_state;
    (* mark_debug = "true" *) reg [2:0] high_tx_ctl_state_old;
    
    (* mark_debug = "true" *) reg  [11:0] send_cts_toself_wait_count;
    reg  [12:0] wr_counter;
    (* mark_debug = "true" *) reg read_from_s_axis_en;
    
    wire wea_high;
    (* mark_debug = "true" *) wire wea;
    (* mark_debug = "true" *) wire [9:0] addra;
    (* mark_debug = "true" *) wire [(C_S00_AXIS_TDATA_WIDTH-1):0] dina;

    reg wea_internal;
    reg [12:0] addra_internal;
    reg [(C_S00_AXIS_TDATA_WIDTH-1):0] dina_internal;
    
    wire [63:0] num_dma_symbol_fifo_rd_data0;
    wire [63:0] num_dma_symbol_fifo_rd_data1;
    (* mark_debug = "true" *) reg [63:0] num_dma_symbol_total_current;
    reg num_dma_symbol_total_rden0;
    reg num_dma_symbol_total_rden1;
    reg num_dma_symbol_total_wren0;
    reg num_dma_symbol_total_wren1;
    wire num_dma_symbol_fifo_empty0;
    wire num_dma_symbol_fifo_full0;
    wire num_dma_symbol_fifo_empty1;
    wire num_dma_symbol_fifo_full1;

    wire s_axis_recv_data_from_high_valid;
    reg tx_queue_idx_reg;
    
    (* mark_debug = "true" *) reg [9:0] timeout_timer_1M;
    reg start_delay0;
    reg start_delay1;
    reg start_delay2;
    reg start_delay3;
    reg start_delay4;
    reg start_delay5;
    
    reg s_axis_recv_data_from_high_delay;

    wire [3:0] cts_toself_rate;
    wire cts_toself_signal_parity;
    wire [11:0] cts_toself_signal_len;

    assign ask_data_from_s_axis = read_from_s_axis_en;
    assign start = ( (auto_start_mode==1'b0)?(1'b0): (start_delay0|start_delay1|start_delay2|start_delay3|start_delay4|start_delay5) );

    assign wea_high = (read_from_s_axis_en&emptyn_from_s_axis);
    assign wea = ( (ack_tx_flag|retrans_in_progress)?wea_from_xpu:wea_internal );
    assign addra = ( (ack_tx_flag|retrans_in_progress)?addra_from_xpu:addra_internal );
    assign dina = ( (ack_tx_flag|retrans_in_progress)?dina_from_xpu:dina_internal );

    assign tx_pkt_need_ack = num_dma_symbol_total_current[13];
    assign tx_pkt_retrans_limit = num_dma_symbol_total_current[17:14];
    
    assign s_axis_recv_data_from_high_valid = ( ((s_axis_recv_data_from_high==0) && (s_axis_recv_data_from_high_delay==1))?1:0 );
    
    assign tx_queue_idx = tx_queue_idx_reg;

    //cts_toself_config[31:0] restored to num_dma_symbol_total_current[63:32] before actual tx
    //cts_toself_config[31]/num_dma_symbol_total_current[63] enable/disable cts to self
    //cts_toself_config[30]/num_dma_symbol_total_current[62] select cts to self rate. 1 select the actual traffic pkt rate that is in cts_toself_config[3:0]/num_dma_symbol_total_current[35:32]
    //cts_toself_config[30]/num_dma_symbol_total_current[62] select cts to self rate. 0 select specified cts to self rate by mac80211 in cts_toself_config[7:4]/num_dma_symbol_total_current[39:36]
    //cts_toself_config[23:8]/num_dma_symbol_total_current[55:40] cts to self duration 
    assign cts_toself_rate = (num_dma_symbol_total_current[62]?num_dma_symbol_total_current[35:32]:num_dma_symbol_total_current[39:36]);//cts_toself_config[23:8]
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

          read_from_s_axis_en <= 0;      
          num_dma_symbol_total_current <= 0;                            
          num_dma_symbol_total_rden0<= 0;   
          num_dma_symbol_total_rden1<= 0;   
          high_tx_ctl_state <= WAIT_CHANCE;
          high_tx_ctl_state_old<=WAIT_CHANCE;
          timeout_timer_1M<=0;
          wr_counter <= 13'b0;
          tx_queue_idx_reg<=0;
          send_cts_toself_wait_count<=0;

          cts_toself_bb_is_ongoing<=0;
          cts_toself_rf_is_ongoing<=0;
        end                                                                   
      else begin
        high_tx_ctl_state_old <= high_tx_ctl_state;
        timeout_timer_1M<=( high_tx_ctl_state_old!=high_tx_ctl_state?0:(tsf_pulse_1M?(timeout_timer_1M+1):timeout_timer_1M) );
        case (high_tx_ctl_state)                                                 
          WAIT_CHANCE: begin
            wea_internal<=0;
            addra_internal<=0;
            dina_internal<=0;

            cts_toself_bb_is_ongoing<=0;
            cts_toself_rf_is_ongoing<=0;

            read_from_s_axis_en <= 0;
            num_dma_symbol_total_current <= num_dma_symbol_total_current;
            if ( high_tx_allowed0 && (~num_dma_symbol_fifo_empty0) && (~tx_bb_is_ongoing) && (~ack_tx_flag) )
              begin
                  num_dma_symbol_total_rden0<= 1;
                  num_dma_symbol_total_rden1<= 0;
                  high_tx_ctl_state  <= PREPARE_TX_FETCH;
                  tx_queue_idx_reg<=0;
              end
            else if ( high_tx_allowed1 && (~num_dma_symbol_fifo_empty1) && (~tx_bb_is_ongoing) && (~ack_tx_flag) )
              begin
                  num_dma_symbol_total_rden0<= 0;
                  num_dma_symbol_total_rden1<= 1;
                  high_tx_ctl_state  <= PREPARE_TX_FETCH;
                  tx_queue_idx_reg<=1;
              end
            else
              begin
                  num_dma_symbol_total_rden0<= 0;
                  num_dma_symbol_total_rden1<= 0;
                  high_tx_ctl_state  <= high_tx_ctl_state;
                  tx_queue_idx_reg<=tx_queue_idx_reg; // keep it as tx_pkt_sn in num_dma_symbol_total_current for SW to check
              end
            wr_counter <= 13'b0;
            send_cts_toself_wait_count<=0;
          end

          PREPARE_TX_FETCH: begin
            wea_internal<=wea_internal;
            addra_internal<=addra_internal;
            dina_internal<=dina_internal;
    
            cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
            cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;

            num_dma_symbol_total_current <= (tx_queue_idx_reg==0?num_dma_symbol_fifo_rd_data0:num_dma_symbol_fifo_rd_data1);
            num_dma_symbol_total_rden0<= 0;
            num_dma_symbol_total_rden1<= 0;
            read_from_s_axis_en <= read_from_s_axis_en;
            wr_counter <= wr_counter;
            tx_queue_idx_reg<=tx_queue_idx_reg;
            send_cts_toself_wait_count<=send_cts_toself_wait_count;
            high_tx_ctl_state  <= PREPARE_TX_JUDGE;
          end

          PREPARE_TX_JUDGE: begin
            num_dma_symbol_total_current <= num_dma_symbol_total_current;
            num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;

            cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
            cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;

            if (num_dma_symbol_total_current[63]==1) begin // from cts_toself_config[31] in tx queue
              read_from_s_axis_en <= read_from_s_axis_en;
              high_tx_ctl_state  <= DO_CTS_TOSELF;

              wea_internal<=wea_internal;
              addra_internal<=addra_internal;
              dina_internal<=dina_internal;
            end else begin
              read_from_s_axis_en <= 1;
              high_tx_ctl_state  <= DO_TX;

              wea_internal<=wea_high;
              addra_internal<=wr_counter;
              dina_internal<=data_from_s_axis;
            end
            wr_counter <= wr_counter;
            tx_queue_idx_reg<=tx_queue_idx_reg;
            send_cts_toself_wait_count<=send_cts_toself_wait_count;
          end

          DO_CTS_TOSELF: begin
            num_dma_symbol_total_current <= num_dma_symbol_total_current;
            num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;
            read_from_s_axis_en <= read_from_s_axis_en;
            if (send_cts_toself_wait_count==0) begin
                cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
                cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;
                wea_internal<=1;
                addra_internal<=0;
                //dina_internal<={32'h0, 32'h000001cb};
                dina_internal<={32'h0, 14'd0, cts_toself_signal_parity, cts_toself_signal_len, 1'b0, cts_toself_rate};
                send_cts_toself_wait_count <= send_cts_toself_wait_count + 1;
                high_tx_ctl_state  <= high_tx_ctl_state;
            end else if (send_cts_toself_wait_count==1) begin
                cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
                cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;
                wea_internal<=1;
                addra_internal<=1;
                dina_internal<={32'h0, 32'h0};
                send_cts_toself_wait_count <= send_cts_toself_wait_count + 1;
                high_tx_ctl_state  <= high_tx_ctl_state;
            end else if (send_cts_toself_wait_count==2)begin
                cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
                cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;
                wea_internal<=1;
                addra_internal<=2;
                dina_internal<={mac_addr[31:0], num_dma_symbol_total_current[55:40], 8'd0, 4'b1100, 2'b01, 2'd0};//CTS FC_type 2'b01 FC_subtype 4'b1100 duration num_dma_symbol_total_current[55:40] from cts_toself_config[23:8] in tx queue
                send_cts_toself_wait_count <= send_cts_toself_wait_count + 1;
                high_tx_ctl_state  <= high_tx_ctl_state;
            end else if (send_cts_toself_wait_count==3) begin
                cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
                cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;
                wea_internal<=1;
                addra_internal<=3;
                dina_internal<={48'h0,mac_addr[47:32]};
                send_cts_toself_wait_count <= send_cts_toself_wait_count + 1;
                high_tx_ctl_state  <= high_tx_ctl_state;
            end else if (send_cts_toself_wait_count<(20*200)) begin //let's wait for 20us to fill tx_iq fifo with preamble and SIGNAL
                cts_toself_bb_is_ongoing<=1;
                cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;
                wea_internal<=0;
                addra_internal<=0;
                dina_internal<=0;
                send_cts_toself_wait_count <= send_cts_toself_wait_count + 1;
                high_tx_ctl_state  <= high_tx_ctl_state;
            end else begin
                wea_internal<=wea_internal;
                addra_internal<=addra_internal;
                dina_internal<=dina_internal;
                cts_toself_rf_is_ongoing<=1; // to fill the gap between cts and following traffic packet for muting RX
                if (tx_iq_fifo_empty) begin
                  send_cts_toself_wait_count <= 0; // the counter will be resued for WAIT SIFS
                  high_tx_ctl_state  <= WAIT_SIFS;
                  cts_toself_bb_is_ongoing<=0;//this tx_iq_fifo_empty is after the phy_tx_done, so tx_control of xpu won't start waiting ack action triggered by phy_tx_done, because cts_toself_bb_is_ongoing is 1
                end else begin
                  send_cts_toself_wait_count <= send_cts_toself_wait_count; // the counter will be resued for WAIT SIFS
                  high_tx_ctl_state  <= high_tx_ctl_state;
                  cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
                end
            end
            wr_counter <= wr_counter;
            tx_queue_idx_reg<=tx_queue_idx_reg;
          end

          WAIT_SIFS: begin
            num_dma_symbol_total_current <= num_dma_symbol_total_current;
            num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;
            
            cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;
            cts_toself_rf_is_ongoing<=cts_toself_rf_is_ongoing;

            if (send_cts_toself_wait_count == send_cts_toself_wait_sifs_top) begin
              read_from_s_axis_en <= 1;
              high_tx_ctl_state  <= DO_TX;

              wea_internal<=wea_high;
              addra_internal<=wr_counter;
              dina_internal<=data_from_s_axis;
              send_cts_toself_wait_count <= send_cts_toself_wait_count;
            end else begin
              read_from_s_axis_en <= read_from_s_axis_en;
              high_tx_ctl_state  <= high_tx_ctl_state;

              wea_internal<=wea_internal;
              addra_internal<=addra_internal;
              dina_internal<=dina_internal;
              send_cts_toself_wait_count <= send_cts_toself_wait_count+1;
            end
            wr_counter <= wr_counter;
            tx_queue_idx_reg<=tx_queue_idx_reg;
          end
          
          DO_TX: begin
            num_dma_symbol_total_current <= num_dma_symbol_total_current;
            num_dma_symbol_total_rden0<= num_dma_symbol_total_rden0;
            num_dma_symbol_total_rden1<= num_dma_symbol_total_rden1;
            send_cts_toself_wait_count<=send_cts_toself_wait_count;
            tx_queue_idx_reg<=tx_queue_idx_reg;

            cts_toself_bb_is_ongoing<=cts_toself_bb_is_ongoing;

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
    
    // store num_dma_symbol_total into fifo
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            tx_pkt_sn <= 0;
            tx_pkt_num_dma_byte<=0;

            start_delay0<=0;
            start_delay1<=0;
            start_delay2<=0;
            start_delay3<=0;
            start_delay4<=0;
            start_delay5<=0;
            
            num_dma_symbol_total_wren0 <= 0;
            num_dma_symbol_total_wren1 <= 0;
            s_axis_recv_data_from_high_delay <= 0;
        end 
      else
        begin
            if (tx_try_complete) begin
              tx_pkt_sn <= num_dma_symbol_total_current[31:20];
              tx_pkt_num_dma_byte <= {num_dma_symbol_total_current[12:0],3'd0};
            end
            
            start_delay0<= ( retrans_in_progress==1?start_retrans:(addra==num_dma_symbol_th) );//controle the width of tx pulse
            start_delay1<=start_delay0;
            start_delay2<=start_delay1;
            start_delay3<=start_delay2;
            start_delay4<=start_delay3;
            start_delay5<=start_delay4;

            s_axis_recv_data_from_high_delay<=s_axis_recv_data_from_high;
            num_dma_symbol_total_wren0<= (tx_queue_idx_indication_from_ps[0]==0?s_axis_recv_data_from_high_valid:0);//assure DMA is done
            num_dma_symbol_total_wren1<= (tx_queue_idx_indication_from_ps[0]==1?s_axis_recv_data_from_high_valid:0);//assure DMA is done
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
      .doutb          (bram_data_to_acc),
      .sbiterrb       (),      //do not change
      .dbiterrb       ()       //do not change
    
    );

	endmodule
