`include "clock_speed.v"
`include "spi_command.v"
`define CLK_DIV (`NUM_CLK_PER_US+99)/100 // ceil for maximum 50 MHz SPI clock  
`timescale 1 ns / 1 ps

    module spi_module #
    (
    )
    (
        input wire clk,
        input wire rstn,
        input wire tx_chain_on,  
        input wire ps_clk, 
        input wire spi0_sclk,
        input wire spi0_mosi,
        input wire spi0_csn,   
        input wire spi_disable,
        output wire spi_sclk, 	
        output wire spi_csn, 
        output wire spi_mosi
    );

    wire spi0_csn_fpga;  
    // clock domain crossing circuit for spi0_csn signal 
    xpm_cdc_array_single #(
      //Common module parameters
      .DEST_SYNC_FF   (4), // integer; range: 2-10
      .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
      .WIDTH          (1)  // integer; range: 1-1024
    ) xpm_cdc_array_single_inst_spi0_csn (
      .src_clk  (ps_clk),  // optional; required when SRC_INPUT_REG = 1
      .src_in   (spi0_csn),
      .dest_clk (clk),
      .dest_out (spi0_csn_fpga)
    );

	// states 
    localparam [1:0] DISABLED = 2'b00;
    localparam [1:0] IDLE = 2'b01;
    localparam [1:0] ACTIVE = 2'b11;

    localparam [4:0] DATA_LENGTH = 24; 
    localparam [23:0] data_tx_high = `SPI_HIGH;
    localparam [23:0] data_tx_low = `SPI_LOW; 

    localparam [3:0] clk_div = `CLK_DIV; 
    
    reg spif_sclk; 
    reg spif_mosi; 
    reg spif_csn; 
    reg [DATA_LENGTH-1:0] data;
    reg tx_chain_on_old; 
    reg spi_tx_high;
    reg spi_tx_low;
    reg [1:0] state;
    reg [3:0] clk_counter;
    reg [4:0] data_counter; 

    // select SPI from FPGA only if chip select is low, otherwise from CPU
    assign spi_sclk = spif_csn == 0 ? spif_sclk : spi0_sclk;
    assign spi_csn = spif_csn == 0 ? spif_csn : spi0_csn;
    assign spi_mosi = spif_csn == 0 ? spif_mosi : spi0_mosi;

    always @(posedge clk) begin
        if (rstn == 0) begin
            state <= IDLE;
            clk_counter <= 0;
            data_counter <= 0; 
            spif_sclk <= 0;
            spif_mosi <= 0; 
            spif_csn <= 1;		
            data <= 0; 	
            tx_chain_on_old <= 0; 
            spi_tx_high <= 0; 
            spi_tx_low <= 0; 
        end else begin
            case (state)
                DISABLED: begin 
                    if (!spi_disable) begin // Tx LO should be off/RF port B should be selected if enabled 
                        spi_tx_high <= 1; 
                        state <= IDLE; 
                    end 
                end
                IDLE: begin
                    clk_counter <= 0;
                    data_counter <= 0;
                    if (spi_disable) begin // Tx LO should be on/RF port A should be selected all the time if disabled
                        spi_tx_low <= 1; 
                    end else if (!tx_chain_on & tx_chain_on_old) begin // tx_chain_on goes low
                        spi_tx_high <= 1; 
                    end else if (tx_chain_on & !tx_chain_on_old) begin // tx_chain_on goes high
                        spi_tx_low <= 1;
                    end
                    tx_chain_on_old <= tx_chain_on;
                    if (spi0_csn_fpga == 1) begin  // chip select from CPU should not be active
                        if (spi_tx_high & !tx_chain_on) begin // prevent switching if transmission is ongoing (only possible when wait was needed)
                            data <= data_tx_high;
                            state <= ACTIVE;
                            spif_csn <= 0; 
                        end else if (spi_tx_low) begin
                            data <= data_tx_low; 	
                            state <= ACTIVE;
                            spif_csn <= 0; 
                        end 
                    end
                end
                ACTIVE: begin 
                    if (data_counter < DATA_LENGTH) begin
                        spif_mosi <= data[data_counter]; // provide data on MOSI
                        clk_counter <= clk_counter + 1;
                        if (clk_counter == 0) begin  // generate SPI clk
                            spif_sclk <= 1;
                        end else if (clk_counter == clk_div) begin                        
                            spif_sclk <= 0;	
                        end 
                        if (clk_counter == 2*clk_div-1) begin 
                            data_counter <= data_counter + 1; // next data bit
                            clk_counter <= 0;
                        end
                    end else begin
                        if (data == data_tx_high)
                            spi_tx_high <= 0; 
                        else 
                            spi_tx_low <= 0;  
                        if (spi_disable & data == data_tx_low) // go to disable state only if switching has happened
                            state <= DISABLED; 
                        else 
                            state <= IDLE;
                        spif_csn <= 1; 
                        spif_sclk <= 0; 
                        spif_mosi <= 0; 
                    end	
                end 
                default: state <= IDLE;		
            endcase
        end
    end	
    endmodule
