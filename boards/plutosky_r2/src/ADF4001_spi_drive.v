module ADF4001_spi_drive(
// Clock and reset
    input 				clk,
    input				rst_n,
	
// Control
    input 				wr_en,          // write enable, active high
    input 		[23:0]  wr_data,        // word to send
    output 	reg 		wr_done,        // write complete, active high
    output 	reg 		wr_start,       // write started
	
// SPI interface
    output	reg 		spi_clk,
    output	reg		    spi_csn,
    output	 			spi_sdo
);

reg	   [4:0]   bit_cnt;	            // bits shifted out so far
reg	   [23:0]  command;
reg	   [2:0]   state;
//SPI state    
localparam     IDLE			= 0,            // idle
			   START		= 1,            // latch the word to send
			   TR			= 2,            // SCLK rising edge
			   TR_0			= 3,            // SCLK falling edge
			   DONE			= 4;

// Shift out MSB first
assign spi_sdo = command[23];
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        state       <= IDLE;
        spi_csn     <= 0;           
        bit_cnt     <= 0;
        wr_done 	<= 0;
        spi_clk     <= 0;           // SCLK idles low
    end
    else 
        case (state)
            IDLE   :   if (wr_en)                       
                            begin
                                state   <= START;
                                bit_cnt <= 5'd0;	
                                wr_done <= 1'b0;
                                spi_clk <= 0;
                                spi_csn <= 0;
                            end 

            START :     begin
                                state   <= TR;
                                wr_start<= 1'b1;
                                command <= wr_data;//{1'b0,wr_addr,wr_data};
                                spi_csn <= 1'b0;
                        end
            TR      :   if (bit_cnt <= 5'd23) 
                            begin
                                bit_cnt <= bit_cnt + 5'd1;
                                spi_clk <= 1;
                                state   <= TR_0;
                            end
                        else 
                            begin
                                spi_csn <= 1'b0;
                                bit_cnt <= 5'd0;
                                spi_clk <= 0;
                                state   <= DONE;
                            end
            
            TR_0    :   begin
                            spi_clk <= 0;
                            command <= command << 1;
                            state   <= TR;
                        end

            DONE    :   begin 
                            wr_done  <= 1'b1;
                            wr_start <= 1'b0;
                            spi_csn  <= 1'b1;
                            state <= IDLE;
                        end
            
            default :   state <= IDLE;
        endcase
end
       
endmodule