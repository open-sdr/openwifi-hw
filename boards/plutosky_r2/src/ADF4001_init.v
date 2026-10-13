module ADF4001_init#
(
    parameter SPI_CLK_FREQ_MHZ = 5 
)(
// Clock and reset
	input 				clk,
	input 				rst_n,
	
// ADF4001 SPI interface
	output				SPI_LE,
	output				SPI_SCLK,
	output				SPI_MOSI,
// Status	
	output 	reg		    init_done
);

// SPI driver instance
wire 			spi_wr_start;
wire 			spi_wr_done;
reg [23:0] 	    spi_wr_data;
reg 			spi_wr_en;

ADF4001_spi_drive ADF4001_spi_drive_u(
    .clk				(clk),
    .rst_n				(rst_n),
	
    .wr_start			(spi_wr_start),
    .wr_done			(spi_wr_done),

    .wr_en				(spi_wr_en),
    .wr_data			(spi_wr_data),

    .spi_clk			(SPI_SCLK),
    .spi_csn			(SPI_LE),
    .spi_sdo			(SPI_MOSI)
);

reg	   [ 1:0]	reset_index;
reg	   [ 7:0]	index;          
reg	   [ 2:0]	state;
reg    [31:0] 	delay_cnt;

    
always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) begin 
        index       <= 0;       // first LUT entry
        init_done   <= 0;       // not initialised yet
        state       <= 0;       // state machine
        delay_cnt   <= 0;       // inter-word delay
        spi_wr_en   <= 0;       // SPI write enable
        reset_index <= 0;
    end
    else 
        case (state)    
            3'd0    :   begin 
                            spi_wr_data <= ADF4001_lut(index);
                            spi_wr_en   <= 1'b0;	
                            state 		<= 3'd1;
            end  
            
            3'd1    :   begin 
                            spi_wr_en   <= 1'b1;	
                            state 		<= 3'd2;
                        end  

            3'd2    :   begin
                            if(spi_wr_start) begin 
                                state <= 3'd3;
                                spi_wr_en   <= 1'b0;
                            end
                        end
            3'd3    :   begin
                            if(spi_wr_done) begin 
                                state <= 3'd4;
                            end
                        end       
            3'd4    :   begin 
                            if(delay_cnt <= SPI_CLK_FREQ_MHZ * 2000)   // 2 ms
                                delay_cnt <= delay_cnt + 1;
                            else begin
                                delay_cnt <= 0;   
                                if(index == 8'd3) begin
                                state <= 3'd5;
                                end
                                else begin
                                    state <= 3'd0;
                                    index <= index + 8'd1;
                                end
                            end
                        end                        
            3'd5    :   begin 
                            state <= state;
                            init_done <= 1'b1;
                        end
                        
            default :   state <= 3'd0;
            
        endcase
end
	

function [23:0] ADF4001_lut;
    input [7:0] index;              // entry to fetch
    reg [23:0] ADF4001_lut_d;       // temporary
    begin
        case(index)
            8'd0:  ADF4001_lut_d = 24'h1F_8093;		
            8'd1:  ADF4001_lut_d = 24'h1F_8092;	 			
            8'd2:  ADF4001_lut_d = 24'h00_0004;                                          
            8'd3:  ADF4001_lut_d = 24'h00_0401;	
        endcase   
        ADF4001_lut = ADF4001_lut_d;            // return the selected word
    end   
endfunction   
     
endmodule
