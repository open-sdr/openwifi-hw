// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module time_slice_gen #
	(
	)
	(// generate time slice for tx_control.v
        input wire clk,
        input wire rstn,
        
        input wire tsf_pulse_1M,

        input wire slv_reg_wren_signal,
        input wire [1:0]  count_total_slice_idx,
        input wire [19:0] count_total,
        input wire [1:0]  count_start_slice_idx,
        input wire [19:0] count_start,
        input wire [1:0]  count_end_slice_idx,
        input wire [19:0] count_end,

        output reg slice_en0,
        output reg slice_en1,
        output reg slice_en2,
        output reg slice_en3
	);

  reg [19:0] count_total0;
  reg [19:0] count_total1;
  reg [19:0] count_total2;
  reg [19:0] count_total3;

  reg [19:0] count_start0;
  reg [19:0] count_start1;
  reg [19:0] count_start2;
  reg [19:0] count_start3;

  reg [19:0] count_end0;
  reg [19:0] count_end1;
  reg [19:0] count_end2;
  reg [19:0] count_end3;

  reg [19:0] counter0;
  reg [19:0] counter1;
  reg [19:0] counter2;
  reg [19:0] counter3;

  always @( posedge clk ) begin
    if ( rstn == 0 ) begin
          count_total0 <= count_total0;
          count_total1 <= count_total1;
          count_total2 <= count_total2;
          count_total3 <= count_total3;

          count_start0 <= count_start0;
          count_start1 <= count_start1;
          count_start2 <= count_start2;
          count_start3 <= count_start3;

          count_end0 <= count_end0;
          count_end1 <= count_end1;
          count_end2 <= count_end2;
          count_end3 <= count_end3;

          counter0 <= 0;
          counter1 <= 0;
          counter2 <= 0;
          counter3 <= 0;

          slice_en0 <= 1;
          slice_en1 <= 1;
          slice_en2 <= 1;
          slice_en3 <= 1;
    end else begin
          // capture input value to correct slice register
          count_total0 <= ( (slv_reg_wren_signal==1 && count_total_slice_idx==0)?count_total:count_total0 );
          count_total1 <= ( (slv_reg_wren_signal==1 && count_total_slice_idx==1)?count_total:count_total1 );
          count_total2 <= ( (slv_reg_wren_signal==1 && count_total_slice_idx==2)?count_total:count_total2 );
          count_total3 <= ( (slv_reg_wren_signal==1 && count_total_slice_idx==3)?count_total:count_total3 );

          count_start0 <= ( (slv_reg_wren_signal==1 && count_start_slice_idx==0)?count_start:count_start0 );
          count_start1 <= ( (slv_reg_wren_signal==1 && count_start_slice_idx==1)?count_start:count_start1 );
          count_start2 <= ( (slv_reg_wren_signal==1 && count_start_slice_idx==2)?count_start:count_start2 );
          count_start3 <= ( (slv_reg_wren_signal==1 && count_start_slice_idx==3)?count_start:count_start3 );

          count_end0 <= ( (slv_reg_wren_signal==1 && count_end_slice_idx==0)?count_end:count_end0 );
          count_end1 <= ( (slv_reg_wren_signal==1 && count_end_slice_idx==1)?count_end:count_end1 );
          count_end2 <= ( (slv_reg_wren_signal==1 && count_end_slice_idx==2)?count_end:count_end2 );
          count_end3 <= ( (slv_reg_wren_signal==1 && count_end_slice_idx==3)?count_end:count_end3 );

          // generate slice enable signal
          counter0 <= ( tsf_pulse_1M?( counter0==count_total0? 0 : (counter0 + 1) ):counter0 );
          counter1 <= ( tsf_pulse_1M?( counter1==count_total1? 0 : (counter1 + 1) ):counter1 );
          counter2 <= ( tsf_pulse_1M?( counter2==count_total2? 0 : (counter2 + 1) ):counter2 );
          counter3 <= ( tsf_pulse_1M?( counter3==count_total3? 0 : (counter3 + 1) ):counter3 );

          slice_en0 <= ( (counter0<=count_end0) && (counter0>=count_start0) );
          slice_en1 <= ( (counter1<=count_end1) && (counter1>=count_start1) );
          slice_en2 <= ( (counter2<=count_end2) && (counter2>=count_start2) );
          slice_en3 <= ( (counter3<=count_end3) && (counter3>=count_start3) );
    end
  end

	endmodule
