// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module iq_rssi_to_db #
	(
		parameter integer IQ_DATA_WIDTH	= 16,
    parameter integer IQ_RSSI_HALF_DB_WIDTH	= 9
	)
	(
        input wire clk,
        input wire rstn,

	    // Ports to receive iq rssi from iq_abs_avg
        input wire signed [(IQ_DATA_WIDTH-1):0] iq_rssi,
        input wire iq_rssi_valid,

	      output wire signed [(IQ_RSSI_HALF_DB_WIDTH-1):0] iq_rssi_half_db, // step size is 0.5dB not 1dB!
        output wire iq_rssi_half_db_valid
	);

//let's use FSM to do calculation.
//remember, after a iq_rssi_valid, you have 8 clock to do the job
    localparam [2:0]   WAIT_FOR_VALID =  3'b000,
                       PREPARE_P1P2P3 =  3'b001,
                       MULT_P1P2      =  3'b010,
                       ADD_P1P2       =  3'b011,
                       ADD_P3         =  3'b100,
                       GEN_FINAL      =  3'b101;
    reg [2:0] calc_state;

    reg signed [(IQ_DATA_WIDTH-1):0] iq_rssi_reg;
    reg signed [(2*IQ_DATA_WIDTH-1):0] iq_rssi2;
    reg [4:0] num_shfit_bit;

    reg signed [32:0] p3;
    reg signed [16:0] p2;
    reg signed [2:0] p1;

    reg signed [(3+2*IQ_DATA_WIDTH-1):0] mult_p1;
    reg signed [(17+IQ_DATA_WIDTH-1):0] mult_p2;
    reg signed [(4+2*IQ_DATA_WIDTH-1):0] sum_p1p2;
    reg signed [(4+2*IQ_DATA_WIDTH-1):0] sum_p1p2p3;

    reg signed [(IQ_DATA_WIDTH-1):0] iq_rssi_half_db_reg;
    reg signed iq_rssi_half_db_valid_reg;

    assign iq_rssi_half_db = iq_rssi_half_db_reg;
    assign iq_rssi_half_db_valid = iq_rssi_half_db_valid_reg;

	always @(posedge clk)                                             
    begin
      if (!rstn)
      // Synchronous reset (active low)                                       
        begin
          calc_state<=WAIT_FOR_VALID;
          iq_rssi_reg<=0;
          iq_rssi2<=0;
          num_shfit_bit<=0;
          p3<=0;
          p2<=0;
          p1<=0;
          mult_p1<=0;
          mult_p2<=0;
          sum_p1p2<=0;
          sum_p1p2p3<=0;
          iq_rssi_half_db_reg<=0;
          iq_rssi_half_db_valid_reg<=0;
        end                                                                   
      else                                                                    
        case (calc_state)
          WAIT_FOR_VALID: begin
            if (iq_rssi_valid) begin
                calc_state <= PREPARE_P1P2P3;
                iq_rssi_reg <= iq_rssi;
                iq_rssi2 <= iq_rssi*iq_rssi;
                end
            else begin
                calc_state <= WAIT_FOR_VALID;
                iq_rssi_reg <= iq_rssi_reg;
                iq_rssi2 <= iq_rssi2;
                end

            num_shfit_bit<=num_shfit_bit;
            p3<=p3;
            p2<=p2;
            p1<=p1;
            mult_p1<=mult_p1;
            mult_p2<=mult_p2;
            sum_p1p2<=sum_p1p2;
            sum_p1p2p3<=sum_p1p2p3;
            iq_rssi_half_db_reg<=iq_rssi_half_db_reg;
            iq_rssi_half_db_valid_reg<=0;

          end

          PREPARE_P1P2P3: begin // data is calculated by calc_phy_header C program
            calc_state <= MULT_P1P2;
            if (iq_rssi_reg<=155) begin
                num_shfit_bit <= 10;
                p3 <= 62968;
                p2 <= 393;
                p1 <= -1;
                end
            else if (iq_rssi_reg<=516) begin
                num_shfit_bit <= 15;
                p3 <= 2701452;
                p2 <= 3770;
                p1 <= -3;
                end
            else if (iq_rssi_reg<=1733) begin
                num_shfit_bit <= 17;
                p3 <= 13556593;
                p2 <= 4505;
                p1 <= -1;
                end
            else if (iq_rssi_reg<=5790) begin
                num_shfit_bit <= 22;
                p3 <= 521903313;
                p2 <= 43032;
                p1 <= -3;
                end
            else begin
                num_shfit_bit <= 24;
                p3 <= 33'H91EC6D5E; //2448190814 in test_iq_rssi_interp.m
                p2 <= 49761;
                p1 <= -1;
                end
            
            iq_rssi_reg <= iq_rssi_reg;
            iq_rssi2 <= iq_rssi2;
            mult_p1<=mult_p1;
            mult_p2<=mult_p2;
            sum_p1p2<=sum_p1p2;
            sum_p1p2p3<=sum_p1p2p3;
            iq_rssi_half_db_reg<=iq_rssi_half_db_reg;
            iq_rssi_half_db_valid_reg<=iq_rssi_half_db_valid_reg;

          end
          
          MULT_P1P2: begin
            calc_state <= ADD_P1P2;
            mult_p1 <= p1*iq_rssi2;
            mult_p2 <= p2*iq_rssi_reg;

            num_shfit_bit <= num_shfit_bit;
            p3 <= p3;
            p2 <= p2;
            p1 <= p1;
            iq_rssi_reg <= iq_rssi_reg;
            iq_rssi2 <= iq_rssi2;
            sum_p1p2<=sum_p1p2;
            sum_p1p2p3<=sum_p1p2p3;
            iq_rssi_half_db_reg<=iq_rssi_half_db_reg;
            iq_rssi_half_db_valid_reg<=iq_rssi_half_db_valid_reg;

          end

          ADD_P1P2: begin
            calc_state <= ADD_P3;
            sum_p1p2 <= mult_p1 + mult_p2;

            mult_p1 <= mult_p1;
            mult_p2 <= mult_p2;
            num_shfit_bit <= num_shfit_bit;
            p3 <= p3;
            p2 <= p2;
            p1 <= p1;
            iq_rssi_reg <= iq_rssi_reg;
            iq_rssi2 <= iq_rssi2;
            sum_p1p2p3<=sum_p1p2p3;
            iq_rssi_half_db_reg<=iq_rssi_half_db_reg;
            iq_rssi_half_db_valid_reg<=iq_rssi_half_db_valid_reg;

          end

          ADD_P3: begin
            calc_state <= GEN_FINAL;
            sum_p1p2p3 <= sum_p1p2 + p3;

            sum_p1p2 <= sum_p1p2;
            mult_p1 <= mult_p1;
            mult_p2 <= mult_p2;
            num_shfit_bit <= num_shfit_bit;
            p3 <= p3;
            p2 <= p2;
            p1 <= p1;
            iq_rssi_reg <= iq_rssi_reg;
            iq_rssi2 <= iq_rssi2;
            iq_rssi_half_db_reg<=iq_rssi_half_db_reg;
            iq_rssi_half_db_valid_reg<=iq_rssi_half_db_valid_reg;

          end

          GEN_FINAL: begin
            calc_state <= WAIT_FOR_VALID;
            iq_rssi_half_db_reg <= (sum_p1p2p3>>num_shfit_bit);
            iq_rssi_half_db_valid_reg <= 1;

            sum_p1p2p3 <= sum_p1p2p3;
            sum_p1p2 <= sum_p1p2;
            mult_p1 <= mult_p1;
            mult_p2 <= mult_p2;
            num_shfit_bit <= num_shfit_bit;
            p3 <= p3;
            p2 <= p2;
            p1 <= p1;
            iq_rssi_reg <= iq_rssi_reg;
            iq_rssi2 <= iq_rssi2;

          end

        endcase                                                               
    end

	endmodule
