// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module time_slice_gen #
	(
	)
	(// generate time slice for tx_control.v
        input wire clk,
        input wire rstn,
        
        input wire tsf_pulse_1M,

        input wire [19:0] count_total0,
        input wire [19:0] count_start0,
        input wire [19:0] count_end0,
        input wire [19:0] count_total1,
        input wire [19:0] count_start1,
        input wire [19:0] count_end1,

        output reg slice_en0,
        output reg slice_en1
	);

  reg [19:0] counter0;
  reg [19:0] counter1;

  always @( posedge clk )
  begin
    if ( rstn == 0 )
      begin
          counter0 <= 0;
          counter1 <= 0;
          slice_en0 <= 0;
          slice_en1 <= 0;
      end 
    else
      begin
          counter0 <= ( tsf_pulse_1M?( counter0==count_total0? 0 : (counter0 + 1) ):counter0 );
          counter1 <= ( tsf_pulse_1M?( counter1==count_total1? 0 : (counter1 + 1) ):counter1 );
          slice_en0 <= ( (counter0<=count_end0) && (counter0>=count_start0) );
          slice_en1 <= ( (counter1<=count_end1) && (counter1>=count_start1) );
      end
  end

	endmodule
