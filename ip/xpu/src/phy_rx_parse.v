// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module phy_rx_parse #
	(
	)
	(
        input wire clk,
        input wire rstn,

        input wire [15:0] ofdm_byte_index,
        input wire [7:0] ofdm_byte,
        input wire ofdm_byte_valid,

        output reg [31:0] FC_DI,
        output reg FC_DI_valid,
        
        output reg [47:0] rx_addr,
        output reg rx_addr_valid,
        
        output reg [47:0] tx_addr,
        output reg tx_addr_valid,
        
        output reg [47:0] dst_addr,
        output reg dst_addr_valid,
        
        output reg [15:0] SC,
        output reg SC_valid,
        
        output reg [47:0] src_addr,
        output reg src_addr_valid,
        
        /* ---------- Block acknowledgment request ---------- */
        output reg [15:0] blk_ack_req_ctrl,
        output reg blk_ack_req_ctrl_valid,

        output reg [15:0] blk_ack_req_ssc,
        output reg blk_ack_req_ssc_valid,
        /* -------------------------------------------------- */

        /* ---------- Block acknowledgment response ---------- */
         output reg [11:0] blk_ack_resp_ssn,
        output reg blk_ack_resp_ssn_valid,

        output reg [63:0] blk_ack_resp_bitmap,
        output reg blk_ack_resp_bitmap_valid,
        /* --------------------------------------------------- */

        /* ---------- QoS control field ---------- */
        output reg [3:0] qos_tid,
        output reg [1:0] qos_ack_policy,
        output reg qos_tid_valid,
        output reg qos_ack_policy_valid
        /* --------------------------------------- */
	);

    always @( posedge clk )
    if ( rstn == 1'b0 )
        begin
        FC_DI <= 0;
        FC_DI_valid <= 0;
        
        rx_addr <= 0;
        rx_addr_valid <= 0;
        
        tx_addr <= 0;
        tx_addr_valid <= 0;
        
        dst_addr <= 0;
        dst_addr_valid <= 0;
        
        SC <= 0;
        SC_valid <= 0;
        
        src_addr <= 0;
        src_addr_valid <= 0;
        
        /* ---------- Block acknowledgment request ---------- */
        qos_tid <= 0;
        qos_tid_valid <= 0;
        
        blk_ack_req_ctrl <= 0;
        blk_ack_req_ctrl_valid <= 0;
        
        blk_ack_req_ssc <= 0;
        blk_ack_req_ssc_valid <= 0;
        /* -------------------------------------------------- */

        /* ---------- Block acknowledgment response ---------- */
        blk_ack_resp_ssn <= 0;
        blk_ack_resp_ssn_valid <= 0;

        blk_ack_resp_bitmap <= 0;
        blk_ack_resp_bitmap_valid <= 0;
        /* --------------------------------------- ----------- */
        end
    else
        if (ofdm_byte_valid) begin
            
            // 2 bytes frame control, 2 bytes duration ID
            if (ofdm_byte_index==(0)) begin
                FC_DI[7:0] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(1)) begin
                FC_DI[15:8] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(2)) begin
                FC_DI[23:16] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(3)) begin
                FC_DI[31:24] <= ofdm_byte;
                FC_DI_valid <=1;
            end
            
            // 6 bytes rx_addr
            else if (ofdm_byte_index==(4)) begin
                rx_addr[7:0] <= ofdm_byte;
                FC_DI_valid <=0;
            end
            else if (ofdm_byte_index==(5)) begin
                rx_addr[15:8] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(6)) begin
                rx_addr[23:16] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(7)) begin
                rx_addr[31:24] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(8)) begin
                rx_addr[39:32] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(9)) begin
                rx_addr[47:40] <= ofdm_byte;
                rx_addr_valid<=1;
            end
            
            // 6 bytes tx_addr
            else if (ofdm_byte_index==(10)) begin
                tx_addr[7:0] <= ofdm_byte;
                rx_addr_valid<=0;
            end
            else if (ofdm_byte_index==(11)) begin
                tx_addr[15:8] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(12)) begin
                tx_addr[23:16] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(13)) begin
                tx_addr[31:24] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(14)) begin
                tx_addr[39:32] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(15)) begin
                tx_addr[47:40] <= ofdm_byte;
                tx_addr_valid <= 1;
            end
            
            else begin
                // Block ack request frame (i.e. type == 1 and subtype == 8)
                if(FC_DI[3:2] == 2'b01 && FC_DI[7:4] == 4'b1000) begin
                    // Block ack control
                    if (ofdm_byte_index==(16)) begin
                        blk_ack_req_ctrl[7:0] <= ofdm_byte;
                        src_addr_valid <=0;
                    end
                    else if (ofdm_byte_index==(17)) begin
                        blk_ack_req_ctrl[15:8] <= ofdm_byte;
                        blk_ack_req_ctrl_valid <=1;
                    end

                    // Block ack starting sequence control (ssc)
                    else if (ofdm_byte_index==(18)) begin
                        blk_ack_req_ssc[7:0] <= ofdm_byte;
                        blk_ack_req_ctrl_valid <=0;
                    end
                    else if (ofdm_byte_index==(19)) begin
                        blk_ack_req_ssc[15:8] <= ofdm_byte;
                        blk_ack_req_ssc_valid <=1;
                    end

                    else if (ofdm_byte_index==(20)) begin
                        blk_ack_req_ssc_valid <=0;
                    end
                end

                // Block ack response frame (i.e. type == 1 and subtype == 9)
                else if(FC_DI[3:2] == 2'b01 && FC_DI[7:4] == 4'b1001) begin
                    // Block ack starting sequence control (ssc)
                    if (ofdm_byte_index==(18)) begin
                        	blk_ack_resp_ssn[3:0] <= ofdm_byte[7:4];
                        tx_addr_valid <=0;
                    end
                    else if (ofdm_byte_index==(19)) begin
                        blk_ack_resp_ssn[11:4] <= ofdm_byte;
                        blk_ack_resp_ssn_valid <=1;
                    end

                    else if (ofdm_byte_index==(20)) begin
                        blk_ack_resp_bitmap[7:0] <= ofdm_byte;
                        blk_ack_resp_ssn_valid <=0;
                    end
                    else if (ofdm_byte_index==(21)) begin
                        blk_ack_resp_bitmap[15:8] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(22)) begin
                        blk_ack_resp_bitmap[23:16] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(23)) begin
                        blk_ack_resp_bitmap[31:24] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(24)) begin
                        blk_ack_resp_bitmap[39:32] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(25)) begin
                        blk_ack_resp_bitmap[47:40] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(26)) begin
                        blk_ack_resp_bitmap[55:48] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(27)) begin
                        blk_ack_resp_bitmap[63:56] <= ofdm_byte;
                        blk_ack_resp_bitmap_valid <=1;
                    end

                    else if (ofdm_byte_index==(28)) begin
                        blk_ack_resp_bitmap_valid <=0;
                    end
                end

                else begin
                    // 6 bytes dst_addr
                    if (ofdm_byte_index==(16)) begin
                        dst_addr[7:0] <= ofdm_byte;
                        tx_addr_valid <= 0;
                    end
                    else if (ofdm_byte_index==(17)) begin
                        dst_addr[15:8] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(18)) begin
                        dst_addr[23:16] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(19)) begin
                        dst_addr[31:24] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(20)) begin
                        dst_addr[39:32] <= ofdm_byte;
                    end
                    else if (ofdm_byte_index==(21)) begin
                        dst_addr[47:40] <= ofdm_byte;
                        dst_addr_valid<=1;
                    end
                    
                    // 2 bytes sequence control
                    else if (ofdm_byte_index==(22)) begin
                        SC[7:0] <= ofdm_byte;
                        dst_addr_valid<=0;
                    end
                    else if (ofdm_byte_index==(23)) begin
                        SC[15:8] <= ofdm_byte;
                        SC_valid <=1;
                    end

                    else begin
                        // 6 bytes src_addr (i.e. To DS == 1 and From DS == 1)
                        if(FC_DI[9:8] == 2'b11) begin
                            if (ofdm_byte_index==(24)) begin
                                src_addr[7:0] <= ofdm_byte;
                                SC_valid <=0;
                            end
                            else if (ofdm_byte_index==(25)) begin
                                src_addr[15:8] <= ofdm_byte;
                            end
                            else if (ofdm_byte_index==(26)) begin
                                src_addr[23:16] <= ofdm_byte;
                            end
                            else if (ofdm_byte_index==(27)) begin
                                src_addr[31:24] <= ofdm_byte;
                            end
                            else if (ofdm_byte_index==(28)) begin
                                src_addr[39:32] <= ofdm_byte;
                            end
                            else if (ofdm_byte_index==(29)) begin
                                src_addr[47:40] <= ofdm_byte;
                                src_addr_valid<=1;
                            end

                            // Qos Cpntrol field
                            else if (ofdm_byte_index==(30)) begin
                                qos_tid <= ofdm_byte[3:0];
                                qos_ack_policy <= ofdm_byte[6:5];

                                qos_tid_valid <=1;
                                qos_ack_policy_valid <=1;
                                src_addr_valid<=0;
                            end

                            else if (ofdm_byte_index==(31)) begin
                                qos_tid_valid <=0;
                                qos_ack_policy_valid <=0;
                            end
                        end

                        // Qos Cpntrol field
                        else begin
                            if (ofdm_byte_index==(24)) begin
                                qos_tid <= ofdm_byte[3:0];
                                qos_ack_policy <= ofdm_byte[6:5];

                                qos_tid_valid <=1;
                                qos_ack_policy_valid <=1;
                                SC_valid <=0;
                            end

                            else if (ofdm_byte_index==(25)) begin
                                qos_tid_valid <=0;
                                qos_ack_policy_valid <=0;
                            end
                        end
                    end
                end
            end
        end

	endmodule
