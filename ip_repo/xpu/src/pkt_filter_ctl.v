// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module pkt_filter_ctl #
	(
	)
	(
        input wire clk,
        input wire rstn,

        input wire [13:0] filter_cfg, //we don't support BSSID filter for now
        input wire [8:0] high_priority_discard_mask,

        output wire block_rx_dma_to_ps,
        output reg  block_rx_dma_to_ps_valid,
        input wire [47:0] self_mac_addr,
        input wire [47:0] self_bssid,
        
	    // Ports to phy_rx //
	    input wire ht_unsupport,

        input wire [1:0] FC_type,
        input wire [3:0] FC_subtype,
        input wire [1:0] FC_tofrom_ds,
        input wire FC_DI_valid,
        input wire [15:0] signal_len,
        input wire sig_valid,

        input wire [47:0] addr1, //no matter to DS or from DS, addr1 is always used for incoming pkt addr filter
        input wire addr1_valid,
        input wire [47:0] addr2, //no matter to DS or from DS, addr2 is always the target addr we ACK to
        input wire addr2_valid,
        input wire [47:0] addr3,
        input wire addr3_valid
	);

    // from enum ieee80211_filter_flags in mac80211.h
    localparam [13:0]   FIF_ALLMULTI =           14'b00000000000010, //get all mac addr like 01:00:5E:xx:xx:xx and 33:33:xx:xx:xx:xx through to ARM
                        FIF_FCSFAIL =            14'b00000000000100, //not support
                        FIF_PLCPFAIL =           14'b00000000001000, //not support
                        FIF_BCN_PRBRESP_PROMISC= 14'b00000000010000, 
                        FIF_CONTROL =            14'b00000000100000,
                        FIF_OTHER_BSS =          14'b00000001000000, 
                        FIF_PSPOLL =             14'b00000010000000,
                        FIF_PROBE_REQ =          14'b00000100000000,
                        UNICAST_FOR_US =         14'b00001000000000,
                        BROADCAST_ALL_ONE =      14'b00010000000000,
                        BROADCAST_ALL_ZERO =     14'b00100000000000,
                        MY_BEACON          =     14'b01000000000000,
                        MONITOR_ALL =            14'b10000000000000;

    localparam [2:0]   FILTER_IDLE     = 3'b000,
                       WAIT_FOR_ADDR1  = 3'b001,
                       WAIT_FOR_ADDR2  = 3'b010,
                       WAIT_FOR_ADDR3  = 3'b011,
                       FILTER_ACTION   = 3'b100,
                       ABNORMAL_STATE  = 3'b101;

    (* mark_debug = "true" *) reg [2:0] filter_state;
    (* mark_debug = "true" *) reg [2:0] filter_state_pre;

    reg [47:0] filter_bssid;
    reg filter_bssid_valid;

    (* mark_debug = "true" *) reg abnormal_flag;

    // low 9 bits are the same as mac80211 definition. [9] - unicast, [10] - broadcast ALL 0xFF, [11] - broadcast ALL 0x00, [12] monitor ALL!
    (* mark_debug = "true" *) reg [13:0] allow_rx_dma_to_ps_reg;
    (* mark_debug = "true" *) reg [8:0] high_priority_discard_reg;
    (* mark_debug = "true" *) wire block_rx_dma_to_ps_tmp;
    (* mark_debug = "true" *) wire high_priority_discard_flag;

    assign high_priority_discard_flag =((high_priority_discard_mask[0]&high_priority_discard_reg[0])|
                                        (high_priority_discard_mask[1]&high_priority_discard_reg[1])|
                                        (high_priority_discard_mask[2]&high_priority_discard_reg[2])|
                                        (high_priority_discard_mask[3]&high_priority_discard_reg[3])|
                                        (high_priority_discard_mask[4]&high_priority_discard_reg[4])|
                                        (high_priority_discard_mask[5]&high_priority_discard_reg[5])|
                                        (high_priority_discard_mask[6]&high_priority_discard_reg[6])|
                                        (high_priority_discard_mask[7]&high_priority_discard_reg[7])|
                                        (high_priority_discard_mask[8]&high_priority_discard_reg[8]));

    assign block_rx_dma_to_ps_tmp =  ( ~(allow_rx_dma_to_ps_reg[0]|
                                     allow_rx_dma_to_ps_reg[1]|
                                     allow_rx_dma_to_ps_reg[2]|
                                     allow_rx_dma_to_ps_reg[3]|
                                     allow_rx_dma_to_ps_reg[4]|
                                     allow_rx_dma_to_ps_reg[5]|
                                     allow_rx_dma_to_ps_reg[6]|
                                     allow_rx_dma_to_ps_reg[7]|
                                     allow_rx_dma_to_ps_reg[8]|
                                     allow_rx_dma_to_ps_reg[9]|
                                    allow_rx_dma_to_ps_reg[10]|
                                    allow_rx_dma_to_ps_reg[11]|
                                    allow_rx_dma_to_ps_reg[12]|
                                    allow_rx_dma_to_ps_reg[13]) );

    assign block_rx_dma_to_ps = (~((MONITOR_ALL&filter_cfg)!=0))&( block_rx_dma_to_ps_tmp|high_priority_discard_flag );

	always @(posedge clk)                                             
    begin
      if (rstn == 1'b0) 
        begin
          block_rx_dma_to_ps_valid <= 0;
          allow_rx_dma_to_ps_reg <= 0;
          high_priority_discard_reg<=0;
          filter_bssid <=0;
          filter_bssid_valid<=0;
          filter_state <= FILTER_IDLE;
          filter_state_pre <= FILTER_IDLE;
          abnormal_flag<=0;
        end                                                                   
      else                                                                    
        case (filter_state)
            FILTER_IDLE: 
                begin
                block_rx_dma_to_ps_valid <= 0;
                abnormal_flag<=0;
                filter_bssid <=filter_bssid;
                filter_bssid_valid<=filter_bssid_valid;
                if (sig_valid && ht_unsupport==0) 
                    begin
                    allow_rx_dma_to_ps_reg <= 0;
                    high_priority_discard_reg<=0;
                    filter_state_pre <= filter_state;
                    if (signal_len>=14) 
                        begin
                        filter_state <= WAIT_FOR_ADDR1;
                        end
                    else 
                        begin //abnormal
                        filter_state <= ABNORMAL_STATE;
                        end
                    end
                else 
                    begin
                    allow_rx_dma_to_ps_reg <= allow_rx_dma_to_ps_reg;
                    high_priority_discard_reg<=high_priority_discard_reg;
                    filter_state <= filter_state;
                    filter_state_pre <= filter_state_pre;
                    end
                end

            WAIT_FOR_ADDR1: 
                begin
                block_rx_dma_to_ps_valid <= block_rx_dma_to_ps_valid;
                allow_rx_dma_to_ps_reg <= allow_rx_dma_to_ps_reg;
                high_priority_discard_reg<=high_priority_discard_reg;
                abnormal_flag<=abnormal_flag;
                if (addr1_valid) 
                    begin
                    filter_state_pre <= filter_state;
                    if (FC_tofrom_ds==2'b10) 
                        begin
                        filter_bssid <= addr1;
                        filter_bssid_valid<=1;
                        end
                    else 
                        begin
                        filter_bssid<=filter_bssid;
                        filter_bssid_valid<=filter_bssid_valid;
                        end

                    if (signal_len==14) 
                        begin
                        filter_state <= FILTER_ACTION;
                        end
                    else if (signal_len>=20) 
                        begin
                        filter_state <= WAIT_FOR_ADDR2;
                        end
                    else 
                        begin // between 14 and 20. abnormal
                        filter_state <= ABNORMAL_STATE;
                        end
                    end
                else 
                    begin
                    filter_state <= filter_state;
                    filter_state_pre <= filter_state_pre;
                    filter_bssid<=filter_bssid;
                    filter_bssid_valid<=filter_bssid_valid;
                    end
                end

            WAIT_FOR_ADDR2:
                begin
                block_rx_dma_to_ps_valid <= block_rx_dma_to_ps_valid;
                allow_rx_dma_to_ps_reg <= allow_rx_dma_to_ps_reg;
                high_priority_discard_reg<=high_priority_discard_reg;
                abnormal_flag<=abnormal_flag;
                if (addr2_valid) 
                    begin
                    filter_state_pre <= filter_state;
                    if (FC_tofrom_ds==2'b01) 
                        begin
                        filter_bssid <= addr2;
                        filter_bssid_valid<=1;
                        end
                    else 
                        begin
                        filter_bssid<=filter_bssid;
                        filter_bssid_valid<=filter_bssid_valid;
                        end

                    if (signal_len==20) 
                        begin
                        filter_state <= FILTER_ACTION;
                        end
                    else if (signal_len>=26) 
                        begin
                        filter_state <= WAIT_FOR_ADDR3;
                        end
                    else 
                        begin // between 20 and 26. abnormal
                        filter_state <= ABNORMAL_STATE;
                        end
                    end
                else 
                    begin
                    filter_state <= filter_state;
                    filter_state_pre <= filter_state_pre;
                    filter_bssid<=filter_bssid;
                    filter_bssid_valid<=filter_bssid_valid;
                    end
                end

            WAIT_FOR_ADDR3:
                begin
                block_rx_dma_to_ps_valid <= block_rx_dma_to_ps_valid;
                allow_rx_dma_to_ps_reg <= allow_rx_dma_to_ps_reg;
                high_priority_discard_reg<=high_priority_discard_reg;
                abnormal_flag<=abnormal_flag;
                if (addr3_valid) 
                    begin
                    filter_state_pre <= filter_state;
                    filter_state <= FILTER_ACTION;
                    if (FC_tofrom_ds==2'b00) 
                        begin
                        filter_bssid <= addr3;
                        filter_bssid_valid<=1;
                        end
                    else 
                        begin
                        filter_bssid<=filter_bssid;
                        filter_bssid_valid<=filter_bssid_valid;
                        end
                    end
                else 
                    begin
                    filter_state <= filter_state;
                    filter_state_pre <= filter_state_pre;
                    filter_bssid<=filter_bssid;
                    filter_bssid_valid<=filter_bssid_valid;
                    end
                end

            FILTER_ACTION:
                begin
                block_rx_dma_to_ps_valid <= 1;

                allow_rx_dma_to_ps_reg[3:2] <= allow_rx_dma_to_ps_reg[3:2];
                allow_rx_dma_to_ps_reg[0] <= allow_rx_dma_to_ps_reg[0];

                high_priority_discard_reg[3:2]<=high_priority_discard_reg[3:2];
                high_priority_discard_reg[0]<=high_priority_discard_reg[0];

                if ( (FIF_ALLMULTI&filter_cfg) && ( (addr1[23:0]==24'H5E0001) || (addr1[15:0]==16'H3333) ) ) // pass all multicast frame like 01:00:5E:xx:xx:xx and 33:33:xx:xx:xx:xx to ARM
                    begin
                    allow_rx_dma_to_ps_reg[1] <= 1;
                    high_priority_discard_reg[1] <= high_priority_discard_reg[1];
                    end
                else
                    begin
                    allow_rx_dma_to_ps_reg[1] <= allow_rx_dma_to_ps_reg[1];
                    if ( (FIF_ALLMULTI&filter_cfg)==0 && ( (addr1[23:0]==24'H5E0001) || (addr1[15:0]==16'H3333) ) )
                        high_priority_discard_reg[1] <= 1;
                    else
                        high_priority_discard_reg[1] <= high_priority_discard_reg[1];
                    end

                if ( (FIF_BCN_PRBRESP_PROMISC&filter_cfg) && ( ( ((FC_type==0)&&(FC_subtype==8)) || ((FC_type==0)&&(FC_subtype==5)) ) ) ) // pass all beacon and probe response (even they are not for our ssid) to ARM
                    begin
                    allow_rx_dma_to_ps_reg[4] <= 1;
                    high_priority_discard_reg[4] <=high_priority_discard_reg[4];
                    end
                else
                    begin
                    allow_rx_dma_to_ps_reg[4] <= allow_rx_dma_to_ps_reg[4];
                    if ( (FIF_BCN_PRBRESP_PROMISC&filter_cfg)==0 && ( ( ((FC_type==0)&&(FC_subtype==8)) || ((FC_type==0)&&(FC_subtype==5)) ) ) && (filter_bssid_valid==1 && filter_bssid!=self_bssid) )
                        high_priority_discard_reg[4] <= 1;
                    else
                        high_priority_discard_reg[4] <=high_priority_discard_reg[4];
                    end
                
                if ( (FIF_CONTROL&filter_cfg) && ( (addr1==self_mac_addr) && ( (FC_type==1)&&(FC_subtype!=10) ) ) ) // pass control frames (except for PS Poll) addressed to this station to ARM
                    begin
                    allow_rx_dma_to_ps_reg[5] <= 1;
                    high_priority_discard_reg[5] <= high_priority_discard_reg[5];
                    end
                else
                    begin
                    allow_rx_dma_to_ps_reg[5] <= allow_rx_dma_to_ps_reg[5];
                    if ( (FIF_CONTROL&filter_cfg)==0 && ( (FC_type==1)&&(FC_subtype!=10) ) )
                        high_priority_discard_reg[5] <= 1;
                    else
                        high_priority_discard_reg[5] <= high_priority_discard_reg[5];
                    end

                if ( (FIF_OTHER_BSS&filter_cfg) && ( (filter_bssid_valid==1 && filter_bssid!=self_bssid) ) ) // pass frames destined to other BSSes to ARM
                    begin
                    allow_rx_dma_to_ps_reg[6] <= 1;
                    high_priority_discard_reg[6] <= high_priority_discard_reg[6];
                    end
                else
                    begin
                    allow_rx_dma_to_ps_reg[6] <= allow_rx_dma_to_ps_reg[6];
                    if ( (FIF_OTHER_BSS&filter_cfg)==0 && ( (filter_bssid_valid==1 && filter_bssid!=self_bssid) ) )
                        high_priority_discard_reg[6] <= 1;
                    else
                        high_priority_discard_reg[6] <= high_priority_discard_reg[6];
                    end

                if ( (FIF_PSPOLL&filter_cfg) && ( (FC_type==1)&&(FC_subtype==10) ) ) // pass PS Poll frames to ARM
                    begin
                    allow_rx_dma_to_ps_reg[7] <= 1;
                    high_priority_discard_reg[7] <= high_priority_discard_reg[7];
                    end
                else
                    begin
                    allow_rx_dma_to_ps_reg[7] <= allow_rx_dma_to_ps_reg[7];
                    if ( (FIF_PSPOLL&filter_cfg)==0 && ( (FC_type==1)&&(FC_subtype==10) ) )
                        high_priority_discard_reg[7] <= 1;
                    else
                        high_priority_discard_reg[7] <= high_priority_discard_reg[7];
                    end

                if ( (FIF_PROBE_REQ&filter_cfg) && ( (FC_type==0)&&(FC_subtype==4) ) ) // pass probe request frames to ARM
                    begin
                    allow_rx_dma_to_ps_reg[8] <= 1;
                    high_priority_discard_reg[8] <= high_priority_discard_reg[8];
                    end
                else
                    begin
                    allow_rx_dma_to_ps_reg[8] <= allow_rx_dma_to_ps_reg[8];
                    if ( (FIF_PROBE_REQ&filter_cfg)==0 && ( (FC_type==0)&&(FC_subtype==4) ) )
                        high_priority_discard_reg[8] <= 1;
                    else
                        high_priority_discard_reg[8] <= high_priority_discard_reg[8];
                    end

                if ( (UNICAST_FOR_US&filter_cfg) && (addr1==self_mac_addr) ) // pass unicast for us to ARM
                    allow_rx_dma_to_ps_reg[9] <= 1;
                else
                    allow_rx_dma_to_ps_reg[9] <= allow_rx_dma_to_ps_reg[9];

                if ( (BROADCAST_ALL_ONE&filter_cfg) && (addr1==48'HFFFFFFFFFFFF) ) // pass all 1 target addr packet to ARM
                    allow_rx_dma_to_ps_reg[10] <= 1;
                else
                    allow_rx_dma_to_ps_reg[10] <= allow_rx_dma_to_ps_reg[10];

                if ( (BROADCAST_ALL_ZERO&filter_cfg) && (addr1==48'H000000000000) ) // pass all 0 target addr packet to ARM
                    allow_rx_dma_to_ps_reg[11] <= 1;
                else
                    allow_rx_dma_to_ps_reg[11] <= allow_rx_dma_to_ps_reg[11];

                if ( (MY_BEACON&filter_cfg) && ( (filter_bssid_valid==1 && filter_bssid==self_bssid) && ((FC_type==0)&&(FC_subtype==8)) ) ) // pass only beacon in my ssid to ARM
                    allow_rx_dma_to_ps_reg[12] <= 1;
                else
                    allow_rx_dma_to_ps_reg[12] <= allow_rx_dma_to_ps_reg[12];

                if ( MONITOR_ALL&filter_cfg ) // pass all to ARM
                    allow_rx_dma_to_ps_reg[13] <= 1;
                else
                    allow_rx_dma_to_ps_reg[13] <= allow_rx_dma_to_ps_reg[13];

                filter_bssid <= filter_bssid;
                filter_bssid_valid <= filter_bssid_valid;
                filter_state <= FILTER_IDLE;
                filter_state_pre <= filter_state;
                abnormal_flag <= abnormal_flag;
                end

            ABNORMAL_STATE:
                begin
                block_rx_dma_to_ps_valid <= 1;
                allow_rx_dma_to_ps_reg <= 0;
                high_priority_discard_reg<=9'h1FF;
                filter_bssid <= filter_bssid;
                filter_bssid_valid <= filter_bssid_valid;
                filter_state <= FILTER_IDLE;
                filter_state_pre <= filter_state;
                abnormal_flag <= 1;
                end
        endcase                                                               
    end

`ifdef RTLXXXXXXXXX
    //reg fcs_valid_delay;
    //reg fcs_invalid_delay;
    //reg block_rx_dma_to_ps_delay;
    
    always @( posedge clk )
    if ( rstn == 1'b0 || pkt_header_valid_strobe )
        begin
        block_rx_dma_to_ps <= 0;
        end
    else
        begin
        if ( FC_DI_valid &&      ( ((FC_tofrom_ds==FC_tofrom_ds_filter0)&&FC_tofrom_ds_filter0_enable) || 
                                   ((FC_tofrom_ds==FC_tofrom_ds_filter1)&&FC_tofrom_ds_filter1_enable) || 
                                   ((FC_tofrom_ds==FC_tofrom_ds_filter2)&&FC_tofrom_ds_filter2_enable)    ) )
            begin
            block_rx_dma_to_ps<=1;
            end
        else if ( FC_DI_valid && ( (( ((FC_type==0)&&(FC_subtype==8))||((FC_type==0)&&(FC_subtype==5)) )&&FC_BCN_PRBRESP_filter_enable) || //beacon and probe response
                                   (( (FC_type==1)&&(FC_subtype!=10) )&&FC_CONTROL_filter_enable)     || //control frame except for PS Poll
                                   (( (FC_type==1)&&(FC_subtype==10) )&&FC_PSPOLL_filter_enable)      || //PS POLL frame
                                   (( (FC_type==0)&&(FC_subtype==4)  )&&FC_PROBE_REQ_filter_enable)         //PROBE_REQ
                                                                        ) )
            begin
            block_rx_dma_to_ps<=1;
            end
        else if ( dst_addr_valid && ( (dst_addr!=48'HFFFFFFFFFFFF || (!special_addr_filter0_enable)) && 
                                      (dst_addr!=48'H000000000000 || (!special_addr_filter1_enable)) && 
                                      (dst_addr!=self_mac_addr    || (!dst_addr_filter_enable)) ) )
            begin
            block_rx_dma_to_ps<=1;
            end
        else if ( bssid_valid && ((bssid!=self_bssid)&&bssid_filter_enable) )
            begin
            block_rx_dma_to_ps<=1;
            end
        //else if (fcs_valid_delay||fcs_invalid_delay)
        else if (pkt_header_valid_strobe)
            begin
            block_rx_dma_to_ps<=0;
            end
        
//        if ( (block_rx_dma_to_ps_delay==0) && (block_rx_dma_to_ps==1) )
//            begin
//            filter_count = filter_count + 1;
//            end
        end
`endif

	endmodule