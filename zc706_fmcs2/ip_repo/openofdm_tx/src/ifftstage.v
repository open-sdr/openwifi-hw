////////////////////////////////////////////////////////////////////////////////
//
// Filename:	fftstage.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This file is (almost) a Verilog source file.  It is meant to
//		be used by a FFT core compiler to generate FFTs which may be
//	used as part of an FFT core.  Specifically, this file encapsulates
//	the options of an FFT-stage.  For any 2^N length FFT, there shall be
//	(N-1) of these stages.
//
//
// Operation:
// 	Given a stream of values, operate upon them as though they were
// 	value pairs, x[n] and x[n+N/2].  The stream begins when n=0, and ends
// 	when n=N/2-1 (i.e. there's a full set of N values).  When the value
// 	x[0] enters, the synchronization input, i_sync, must be true as well.
//
// 	For this stream, produce outputs
// 	y[n    ] = x[n] + x[n+N/2], and
// 	y[n+N/2] = (x[n] - x[n+N/2]) * c[n],
// 			where c[n] is a complex coefficient found in the
// 			external memory file COEFFILE.
// 	When y[0] is output, a synchronization bit o_sync will be true as
// 	well, otherwise it will be zero.
//
// 	Most of the work to do this is done within the butterfly, whether the
// 	hardware accelerated butterfly (uses a DSP) or not.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2019, Gisselquist Technology, LLC
//
// This file is part of the general purpose pipelined FFT project.
//
// The pipelined FFT project is free software (firmware): you can redistribute
// it and/or modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// The pipelined FFT project is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
// General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
//`default_nettype	none
//
module	fftstage(i_clk, i_reset, i_ce, i_sync, i_data, o_data, o_sync);
	parameter	IWIDTH=16,CWIDTH=20,OWIDTH=17;
	// Parameters specific to the core that should be changed when this
	// core is built ... Note that the minimum LGSPAN (the base two log
	// of the span, or the base two log of the current FFT size) is 3.
	// Smaller spans (i.e. the span of 2) must use the dbl laststage module.
	parameter	LGSPAN=5, BFLYSHIFT=0; // LGWIDTH=6
	parameter	[0:0]	OPT_HWMPY = 1;
	// Clocks per CE.  If your incoming data rate is less than 50% of your
	// clock speed, you can set CKPCE to 2'b10, make sure there's at least
	// one clock between cycles when i_ce is high, and then use two
	// multiplies instead of three.  Setting CKPCE to 2'b11, and insisting
	// on at least two clocks with i_ce low between cycles with i_ce high,
	// then the hardware optimized butterfly code will used one multiply
	// instead of two.
	parameter		CKPCE = 1;
	// The COEFFILE parameter contains the name of the file containing the
	// FFT twiddle factors
	parameter	COEFFILE="cmem_64.hex";

`ifdef	VERILATOR
	parameter [0:0] ZERO_ON_IDLE = 1'b0;
`else
	localparam [0:0] ZERO_ON_IDLE = 1'b0;
`endif // VERILATOR

	input	wire				i_clk, i_reset, i_ce, i_sync;
	input	wire	[(2*IWIDTH-1):0]	i_data;
	output	reg	[(2*OWIDTH-1):0]	o_data;
	output	reg				o_sync;

	// I am using the prefixes
	// 	ib_*	to reference the inputs to the butterfly, and
	// 	ob_*	to reference the outputs from the butterfly
	reg	wait_for_sync;
	reg	[(2*IWIDTH-1):0]	ib_a, ib_b;
	reg	[(2*CWIDTH-1):0]	ib_c;
	reg	ib_sync;

	reg	b_started;
	wire	ob_sync;
	wire	[(2*OWIDTH-1):0]	ob_a, ob_b;

	// cmem is defined as an array of real and complex values,
	// where the top CWIDTH bits are the real value and the bottom
	// CWIDTH bits are the imaginary value.
	//
	// cmem[i] = { (2^(CWIDTH-2)) * cos(2*pi*i/(2^LGWIDTH)),
	//		(2^(CWIDTH-2)) * sin(2*pi*i/(2^LGWIDTH)) };
	//
	reg	[(2*CWIDTH-1):0]	cmem [0:((1<<LGSPAN)-1)];
`ifdef	FORMAL
// Let the formal tool pick the coefficients
`else
	initial	$readmemh(COEFFILE,cmem);

`endif

	reg	[(LGSPAN):0]		iaddr;
	reg	[(2*IWIDTH-1):0]	imem	[0:((1<<LGSPAN)-1)];

	reg	[LGSPAN:0]		oaddr;
	reg	[(2*OWIDTH-1):0]	omem	[0:((1<<LGSPAN)-1)];

	initial wait_for_sync = 1'b1;
	initial iaddr = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		wait_for_sync <= 1'b1;
		iaddr <= 0;
	end else if ((i_ce)&&((!wait_for_sync)||(i_sync)))
	begin
		//
		// First step: Record what we're not ready to use yet
		//
		iaddr <= iaddr + { {(LGSPAN){1'b0}}, 1'b1 };
		wait_for_sync <= 1'b0;
	end
	always @(posedge i_clk) // Need to make certain here that we don't read
	if ((i_ce)&&(!iaddr[LGSPAN])) // and write the same address on
		imem[iaddr[(LGSPAN-1):0]] <= i_data; // the same clk

	//
	// Now, we have all the inputs, so let's feed the butterfly
	//
	// ib_sync is the synchronization bit to the butterfly.  It will
	// be tracked within the butterfly, and used to create the o_sync
	// value when the results from this output are produced
	initial ib_sync = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		ib_sync <= 1'b0;
	else if (i_ce)
	begin
		// Set the sync to true on the very first
		// valid input in, and hence on the very
		// first valid data out per FFT.
		ib_sync <= (iaddr==(1<<(LGSPAN)));
	end

	// Read the values from our input memory, and use them to feed first of two
	// butterfly inputs
	always	@(posedge i_clk)
	if (i_ce)
	begin
		// One input from memory, ...
		ib_a <= imem[iaddr[(LGSPAN-1):0]];
		// One input clocked in from the top
		ib_b <= i_data;
		// and the coefficient or twiddle factor
		ib_c <= cmem[iaddr[(LGSPAN-1):0]];
	end

	// The idle register is designed to keep track of when an input
	// to the butterfly is important and going to be used.  It's used
	// in a flag following, so that when useful values are placed
	// into the butterfly they'll be non-zero (idle=0), otherwise when
	// the inputs to the butterfly are irrelevant and will be ignored,
	// then (idle=1) those inputs will be set to zero.  This
	// functionality is not designed to be used in operation, but only
	// within a Verilator simulation context when chasing a bug.
	// In this limited environment, the non-zero answers will stand
	// in a trace making it easier to highlight a bug.
	reg	idle;
	generate if (ZERO_ON_IDLE)
	begin
		initial	idle = 1;
		always @(posedge i_clk)
		if (i_reset)
			idle <= 1'b1;
		else if (i_ce)
			idle <= (!iaddr[LGSPAN])&&(!wait_for_sync);

	end else begin

		always @(*) idle = 0;

	end endgenerate

// For the formal proof, we'll assume the outputs of hwbfly and/or
// butterfly, rather than actually calculating them.  This will simplify
// the proof and (if done properly) will be equivalent.  Be careful of
// defining FORMAL if you want the full logic!
`ifndef	FORMAL
	//
	generate if (OPT_HWMPY)
	begin : HWBFLY
		hwbfly #(.IWIDTH(IWIDTH),.CWIDTH(CWIDTH),.OWIDTH(OWIDTH),
				.CKPCE(CKPCE), .SHIFT(BFLYSHIFT))
			bfly(i_clk, i_reset, i_ce, (idle)?0:ib_c,
				(idle || (!i_ce)) ? 0:ib_a,
				(idle || (!i_ce)) ? 0:ib_b,
				(ib_sync)&&(i_ce),
				ob_a, ob_b, ob_sync);
	end else begin : FWBFLY
		butterfly #(.IWIDTH(IWIDTH),.CWIDTH(CWIDTH),.OWIDTH(OWIDTH),
				.CKPCE(CKPCE),.SHIFT(BFLYSHIFT))
			bfly(i_clk, i_reset, i_ce,
					(idle||(!i_ce))?0:ib_c,
					(idle||(!i_ce))?0:ib_a,
					(idle||(!i_ce))?0:ib_b,
					(ib_sync&&i_ce),
					ob_a, ob_b, ob_sync);
	end endgenerate
`endif

	//
	// Next step: recover the outputs from the butterfly
	//
	// The first output can go immediately to the output of this routine
	// The second output must wait until this time in the idle cycle
	// oaddr is the output memory address, keeping track of where we are
	// in this output cycle.
	initial oaddr     = 0;
	initial o_sync    = 0;
	initial b_started = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		oaddr     <= 0;
		o_sync    <= 0;
		// b_started will be true once we've seen the first ob_sync
		b_started <= 0;
	end else if (i_ce)
	begin
		o_sync <= (!oaddr[LGSPAN])?ob_sync : 1'b0;
		if (ob_sync||b_started)
			oaddr <= oaddr + 1'b1;
		if ((ob_sync)&&(!oaddr[LGSPAN]))
			// If b_started is true, then a butterfly output is available
			b_started <= 1'b1;
	end

	reg	[(LGSPAN-1):0]		nxt_oaddr;
	reg	[(2*OWIDTH-1):0]	pre_ovalue;
	always @(posedge i_clk)
	if (i_ce)
		nxt_oaddr[0] <= oaddr[0];
	generate if (LGSPAN>1)
	begin

		always @(posedge i_clk)
		if (i_ce)
			nxt_oaddr[LGSPAN-1:1] <= oaddr[LGSPAN-1:1] + 1'b1;

	end endgenerate

	// Only write to the memory on the first half of the outputs
	// We'll use the memory value on the second half of the outputs
	always @(posedge i_clk)
	if ((i_ce)&&(!oaddr[LGSPAN]))
		omem[oaddr[(LGSPAN-1):0]] <= ob_b;

	always @(posedge i_clk)
	if (i_ce)
		pre_ovalue <= omem[nxt_oaddr[(LGSPAN-1):0]];

	always @(posedge i_clk)
	if (i_ce)
		o_data <= (!oaddr[LGSPAN]) ? ob_a : pre_ovalue;

`ifdef	FORMAL
	// An arbitrary processing delay from butterfly input to
	// butterfly output(s)
	(* anyconst *) reg	[LGSPAN:0]	f_mpydelay;
	always @(*)
		assume(f_mpydelay > 1);

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	always @(posedge i_clk)
	if ((!f_past_valid)||($past(i_reset)))
	begin
		assert(iaddr == 0);
		assert(wait_for_sync);
		assert(o_sync == 0);
		assert(oaddr == 0);
		assert(!b_started);
		assert(!o_sync);
	end

	/////////////////////////////////////////
	//
	// Formally verify the input half, from the inputs to this module
	// to the inputs of the butterfly
	//
	/////////////////////////////////////////
	//
	// Let's  verify a specific set of inputs
	(* anyconst *)	reg	[LGSPAN:0]	f_addr;
	reg	[2*IWIDTH-1:0]			f_left, f_right;
	wire	[LGSPAN:0]			f_next_addr;

	always @(posedge i_clk)
	if ((!$past(i_ce))&&(!$past(i_ce,2))&&(!$past(i_ce,3))&&(!$past(i_ce,4)))
	assume(!i_ce);

	always @(*)
		assume(f_addr[LGSPAN]==1'b0);

	assign	f_next_addr = f_addr + 1'b1;

	always @(posedge i_clk)
	if ((i_ce)&&(iaddr[LGSPAN:0] == f_addr))
		f_left <= i_data;

	always @(*)
	if (wait_for_sync)
		assert(iaddr == 0);

	wire	[LGSPAN:0]	f_last_addr = iaddr - 1'b1;

	always @(posedge i_clk)
	if ((!wait_for_sync)&&(f_last_addr >= { 1'b0, f_addr[LGSPAN-1:0]}))
		assert(f_left == imem[f_addr[LGSPAN-1:0]]);

	always @(posedge i_clk)
	if ((i_ce)&&(iaddr == { 1'b1, f_addr[LGSPAN-1:0]}))
		f_right <= i_data;

	always @(posedge i_clk)
	if ((i_ce)&&(!wait_for_sync)&&(f_last_addr == { 1'b1, f_addr[LGSPAN-1:0]}))
	begin
		assert(ib_a == f_left);
		assert(ib_b == f_right);
		assert(ib_c == cmem[f_addr[LGSPAN-1:0]]);
	end

	/////////////////////////////////////////
	//
	// Formally verify the output half, from the output of the butterfly
	// to the outputs of this module
	//
	/////////////////////////////////////////
	reg	[2*OWIDTH-1:0]	f_oleft, f_oright;
	reg	[LGSPAN:0]	f_oaddr;
	wire	[LGSPAN:0]	f_oaddr_m1 = f_oaddr - 1'b1;

	always @(*)
		f_oaddr = iaddr - f_mpydelay + {1'b1,{(LGSPAN-1){1'b0}}};

	assign	f_oaddr_m1 = f_oaddr - 1'b1;

	reg	f_output_active;
	initial	f_output_active = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		f_output_active <= 1'b0;
	else if ((i_ce)&&(ob_sync))
		f_output_active <= 1'b1;

	always @(*)
		assert(f_output_active == b_started);

	always @(*)
	if (wait_for_sync)
		assert(!f_output_active);

	always @(*)
	if (f_output_active)
		assert(oaddr == f_oaddr);
	else
		assert(oaddr == 0);

	always @(*)
	if (wait_for_sync)
		assume(!ob_sync);

	always @(*)
		assume(ob_sync == (f_oaddr == 0));

	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_ce)))
	begin
		assume($stable(ob_a));
		assume($stable(ob_b));
	end

	initial	f_oleft  = 0;
	initial	f_oright = 0;
	always @(posedge i_clk)
	if ((i_ce)&&(f_oaddr == f_addr))
	begin
		f_oleft  <= ob_a;
		f_oright <= ob_b;
	end

	always @(posedge i_clk)
	if ((f_output_active)&&(f_oaddr_m1 >= { 1'b0, f_addr[LGSPAN-1:0]}))
		assert(omem[f_addr[LGSPAN-1:0]] == f_oright);

	always @(posedge i_clk)
	if ((i_ce)&&(f_oaddr_m1 == 0)&&(f_output_active))
		assert(o_sync);
	else if ((i_ce)||(!f_output_active))
		assert(!o_sync);

	always @(posedge i_clk)
	if ((i_ce)&&(f_output_active)&&(f_oaddr_m1 == f_addr))
		assert(o_data == f_oleft);
	always @(posedge i_clk)
	if ((i_ce)&&(f_output_active)&&(f_oaddr[LGSPAN])
			&&(f_oaddr[LGSPAN-1:0] == f_addr[LGSPAN-1:0]))
		assert(pre_ovalue == f_oright);
	always @(posedge i_clk)
	if ((i_ce)&&(f_output_active)&&(f_oaddr_m1[LGSPAN])
			&&(f_oaddr_m1[LGSPAN-1:0] == f_addr[LGSPAN-1:0]))
		assert(o_data == f_oright);

`endif
endmodule
