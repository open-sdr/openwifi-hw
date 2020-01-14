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
        
        output reg [47:0] dst_addr,
        output reg dst_addr_valid,
        
        output reg [47:0] tx_addr,
        output reg tx_addr_valid,
        
        output reg [15:0] SC,
        output reg SC_valid,
        
        output reg [47:0] src_addr,
        output reg src_addr_valid
	);

    always @( posedge clk )
    if ( rstn == 1'b0 )
        begin
        FC_DI <= 0;
        FC_DI_valid <= 0;
        
        rx_addr <= 0;
        rx_addr_valid <= 0;
        
        dst_addr <= 0;
        dst_addr_valid <= 0;
        
        tx_addr <= 0;
        tx_addr_valid <= 0;
        
        SC <= 0;
        SC_valid <= 0;
        
        src_addr <= 0;
        src_addr_valid <= 0;
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
            
            // 6 bytes dst_addr
            else if (ofdm_byte_index==(10)) begin
                dst_addr[7:0] <= ofdm_byte;
                rx_addr_valid<=0;
            end
            else if (ofdm_byte_index==(11)) begin
                dst_addr[15:8] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(12)) begin
                dst_addr[23:16] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(13)) begin
                dst_addr[31:24] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(14)) begin
                dst_addr[39:32] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(15)) begin
                dst_addr[47:40] <= ofdm_byte;
                dst_addr_valid <= 1;
            end
            
            // 6 bytes tx_addr
            else if (ofdm_byte_index==(16)) begin
                tx_addr[7:0] <= ofdm_byte;
                dst_addr_valid <= 0;
            end
            else if (ofdm_byte_index==(17)) begin
                tx_addr[15:8] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(18)) begin
                tx_addr[23:16] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(19)) begin
                tx_addr[31:24] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(20)) begin
                tx_addr[39:32] <= ofdm_byte;
            end
            else if (ofdm_byte_index==(21)) begin
                tx_addr[47:40] <= ofdm_byte;
                tx_addr_valid<=1;
            end
            
            // 2 bytes sequence control
            else if (ofdm_byte_index==(22)) begin
                SC[7:0] <= ofdm_byte;
                tx_addr_valid<=0;
            end
            else if (ofdm_byte_index==(23)) begin
                SC[15:8] <= ofdm_byte;
                SC_valid <=1;
            end
            
            // 6 bytes src_addr
            else if (ofdm_byte_index==(24)) begin
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

            else if (ofdm_byte_index==(30)) begin
                src_addr_valid<=0;
            end
            
        end

	endmodule
