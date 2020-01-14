// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module tsf_timer #
	(
		parameter integer TIMER_WIDTH = 64
	)
	(
		input wire  clk,
		input wire  rstn,
        input wire  tsf_load_control, //rising edge will load load_val into timer
        input wire  [(TIMER_WIDTH-1) : 0] tsf_load_val,
        output reg  [(TIMER_WIDTH-1) : 0] tsf_runtime_val,
        output reg  tsf_pulse_1M
	);

    reg [7:0] counter_1M; // assum clk at 200MHz
    reg tsf_load_control_reg;
     
    always @( posedge clk )
    begin
      if ( rstn == 1'b0 )
        begin
            counter_1M <= 8'd0;
            tsf_runtime_val <= 0;
            tsf_pulse_1M <= 0;
            tsf_load_control_reg <= 0;
        end 
      else
        begin
            tsf_load_control_reg <= tsf_load_control;
            if (counter_1M == 8'd199 || (tsf_load_control==0 && tsf_load_control_reg==1)) begin
                counter_1M <= 8'd0;
            end else begin
                counter_1M <= counter_1M + 1'b1;
            end
            
            if (tsf_load_control==0 && tsf_load_control_reg==1) begin
                tsf_pulse_1M <= 0;
                tsf_runtime_val <= tsf_load_val;
            end else begin
                if (counter_1M == 8'd0) begin
                    tsf_pulse_1M <= 1;
                    tsf_runtime_val <= tsf_runtime_val + 1'b1;
                end else begin
                    tsf_pulse_1M <= 0;
                    tsf_runtime_val <= tsf_runtime_val;
                end
            end
        end
    end    
    
	endmodule
