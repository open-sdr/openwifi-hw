////////////////////////////////////////////////////////////////////////////////
//
// Filename:	butterfly.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This routine caculates a butterfly for a decimation
//		in frequency version of an FFT.  Specifically, given
//	complex Left and Right values together with a coefficient, the output
//	of this routine is given by:
//
//		L' = L + R
//		R' = (L - R)*C
//
//	The rest of the junk below handles timing (mostly), to make certain
//	that L' and R' reach the output at the same clock.  Further, just to
//	make certain that is the case, an 'aux' input exists.  This aux value
//	will come out of this routine synchronized to the values it came in
//	with.  (i.e., both L', R', and aux all have the same delay.)  Hence,
//	a caller of this routine may set aux on the first input with valid
//	data, and then wait to see aux set on the output to know when to find
//	the first output with valid data.
//
//	All bits are preserved until the very last clock, where any more bits
//	than OWIDTH will be quietly discarded.
//
//	This design features no overflow checking.
//
// Notes:
//	CORDIC:
//		Much as we might like, we can't use a cordic here.
//		The goal is to accomplish an FFT, as defined, and a
//		CORDIC places a scale factor onto the data.  Removing
//		the scale factor would cost two multiplies, which
//		is precisely what we are trying to avoid.
//
//
//	3-MULTIPLIES:
//		It should also be possible to do this with three multiplies
//		and an extra two addition cycles.
//
//		We want
//			R+I = (a + jb) * (c + jd)
//			R+I = (ac-bd) + j(ad+bc)
//		We multiply
//			P1 = ac
//			P2 = bd
//			P3 = (a+b)(c+d)
//		Then
//			R+I=(P1-P2)+j(P3-P2-P1)
//
//		WIDTHS:
//		On multiplying an X width number by an
//		Y width number, X>Y, the result should be (X+Y)
//		bits, right?
//		-2^(X-1) <= a <= 2^(X-1) - 1
//		-2^(Y-1) <= b <= 2^(Y-1) - 1
//		(2^(Y-1)-1)*(-2^(X-1)) <= ab <= 2^(X-1)2^(Y-1)
//		-2^(X+Y-2)+2^(X-1) <= ab <= 2^(X+Y-2) <= 2^(X+Y-1) - 1
//		-2^(X+Y-1) <= ab <= 2^(X+Y-1)-1
//		YUP!  But just barely.  Do this and you'll really want
//		to drop a bit, although you will risk overflow in so
//		doing.
//
//	20150602 -- The sync logic lines have been completely redone.  The
//		synchronization lines no longer go through the FIFO with the
//		left hand sum, but are kept out of memory.  This allows the
//		butterfly to use more optimal memory resources, while also
//		guaranteeing that the sync lines can be properly reset upon
//		any reset signal.
//
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
module	butterfly(i_clk, i_reset, i_ce, i_coef, i_left, i_right, i_aux,
		o_left, o_right, o_aux);
	// Public changeable parameters ...
	parameter IWIDTH=16,CWIDTH=20,OWIDTH=17;
	parameter	SHIFT=0;
	// The number of clocks per each i_ce.  The actual number can be
	// more, but the algorithm depends upon at least this many for
	// extra internal processing.
	parameter	CKPCE=1;
	//
	// Local/derived parameters that are calculated from the above
	// params.  Apart from algorithmic changes below, these should not
	// be adjusted
	//
	// The first step is to calculate how many clocks it takes our
	// multiply to come back with an answer within.  The time in the
	// multiply depends upon the input value with the fewest number of
	// bits--to keep the pipeline depth short.  So, let's find the
	// fewest number of bits here.
	localparam MXMPYBITS = 
		((IWIDTH+2)>(CWIDTH+1)) ? (CWIDTH+1) : (IWIDTH + 2);
	//
	// Given this "fewest" number of bits, we can calculate the
	// number of clocks the multiply itself will take.
	localparam	MPYDELAY=((MXMPYBITS+1)/2)+2;
	//
	// In an environment when CKPCE > 1, the multiply delay isn't
	// necessarily the delay felt by this algorithm--measured in
	// i_ce's.  In particular, if the multiply can operate with more
	// operations per clock, it can appear to finish "faster".
	// Since most of the logic in this core operates on the slower
	// clock, we'll need to map that speed into the number of slower
	// clock ticks that it takes.
	localparam	LCLDELAY = (CKPCE == 1) ? MPYDELAY
		: (CKPCE == 2) ? (MPYDELAY/2+2)
		: (MPYDELAY/3 + 2);
	localparam	LGDELAY = (MPYDELAY>64) ? 7
			: (MPYDELAY > 32) ? 6
			: (MPYDELAY > 16) ? 5
			: (MPYDELAY >  8) ? 4
			: (MPYDELAY >  4) ? 3
			: 2;
	localparam	AUXLEN=(LCLDELAY+3);
	localparam	MPYREMAINDER = MPYDELAY - CKPCE*(MPYDELAY/CKPCE);


	input	wire	i_clk, i_reset, i_ce;
	input	wire	[(2*CWIDTH-1):0] i_coef;
	input	wire	[(2*IWIDTH-1):0] i_left, i_right;
	input	wire	i_aux;
	output	wire	[(2*OWIDTH-1):0] o_left, o_right;
	output	reg	o_aux;

`ifdef	FORMAL
	localparam	F_LGDEPTH = (AUXLEN > 64) ? 7
			: (AUXLEN > 32) ? 6
			: (AUXLEN > 16) ? 5
			: (AUXLEN >  8) ? 4
			: (AUXLEN >  4) ? 3 : 2;

	localparam	F_DEPTH = AUXLEN;
	localparam	[F_LGDEPTH-1:0]	F_D = F_DEPTH[F_LGDEPTH-1:0]-1;

	reg	signed	[IWIDTH-1:0]	f_dlyleft_r  [0:F_DEPTH-1];
	reg	signed	[IWIDTH-1:0]	f_dlyleft_i  [0:F_DEPTH-1];
	reg	signed	[IWIDTH-1:0]	f_dlyright_r [0:F_DEPTH-1];
	reg	signed	[IWIDTH-1:0]	f_dlyright_i [0:F_DEPTH-1];
	reg	signed	[CWIDTH-1:0]	f_dlycoeff_r [0:F_DEPTH-1];
	reg	signed	[CWIDTH-1:0]	f_dlycoeff_i [0:F_DEPTH-1];
	reg	signed	[F_DEPTH-1:0]	f_dlyaux;

	wire	signed	[IWIDTH:0]		f_predifr, f_predifi;
	wire	signed	[IWIDTH+CWIDTH+3-1:0]	f_predifrx, f_predifix;
	wire	signed	[CWIDTH:0]		f_sumcoef;
	wire	signed	[IWIDTH+1:0]		f_sumdiff;
	wire	signed	[IWIDTH:0]		f_sumr, f_sumi;
	wire	signed	[IWIDTH+CWIDTH+3-1:0]	f_sumrx, f_sumix;
	wire	signed	[IWIDTH:0]		f_difr, f_difi;
	wire	signed	[IWIDTH+CWIDTH+3-1:0]	f_difrx, f_difix;
	wire	signed	[IWIDTH+CWIDTH+3-1:0]	f_widecoeff_r, f_widecoeff_i;

	wire	[(CWIDTH):0]	fp_one_ic, fp_two_ic, fp_three_ic, f_p3c_in;
	wire	[(IWIDTH+1):0]	fp_one_id, fp_two_id, fp_three_id, f_p3d_in;
`endif

	reg	[(2*IWIDTH-1):0]	r_left, r_right;
	reg	[(2*CWIDTH-1):0]	r_coef, r_coef_2;
	wire	signed	[(IWIDTH-1):0]	r_left_r, r_left_i, r_right_r, r_right_i;
	assign	r_left_r  = r_left[ (2*IWIDTH-1):(IWIDTH)];
	assign	r_left_i  = r_left[ (IWIDTH-1):0];
	assign	r_right_r = r_right[(2*IWIDTH-1):(IWIDTH)];
	assign	r_right_i = r_right[(IWIDTH-1):0];

	reg	signed	[(IWIDTH):0]	r_sum_r, r_sum_i, r_dif_r, r_dif_i;

	reg	[(LGDELAY-1):0]	fifo_addr;
	wire	[(LGDELAY-1):0]	fifo_read_addr;
	assign	fifo_read_addr = fifo_addr - LCLDELAY[(LGDELAY-1):0];
	reg	[(2*IWIDTH+1):0]	fifo_left [ 0:((1<<LGDELAY)-1)];

	// Set up the input to the multiply
	always @(posedge i_clk)
	if (i_ce)
	begin
		// One clock just latches the inputs
		r_left <= i_left;	// No change in # of bits
		r_right <= i_right;
		r_coef  <= i_coef;
		// Next clock adds/subtracts
		r_sum_r <= r_left_r + r_right_r; // Now IWIDTH+1 bits
		r_sum_i <= r_left_i + r_right_i;
		r_dif_r <= r_left_r - r_right_r;
		r_dif_i <= r_left_i - r_right_i;
		// Other inputs are simply delayed on second clock
		r_coef_2<= r_coef;
	end

	// Don't forget to record the even side, since it doesn't need
	// to be multiplied, but yet we still need the results in sync
	// with the answer when it is ready.
	initial fifo_addr = 0;
	always @(posedge i_clk)
	if (i_reset)
		fifo_addr <= 0;
	else if (i_ce)
		// Need to delay the sum side--nothing else happens
		// to it, but it needs to stay synchronized with the
		// right side.
		fifo_addr <= fifo_addr + 1;

	always @(posedge i_clk)
	if (i_ce)
		fifo_left[fifo_addr] <= { r_sum_r, r_sum_i };

	wire	signed	[(CWIDTH-1):0]	ir_coef_r, ir_coef_i;
	assign	ir_coef_r = r_coef_2[(2*CWIDTH-1):CWIDTH];
	assign	ir_coef_i = r_coef_2[(CWIDTH-1):0];
	wire	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	p_one, p_two, p_three;


	// Multiply output is always a width of the sum of the widths of
	// the two inputs.  ALWAYS.  This is independent of the number of
	// bits in p_one, p_two, or p_three.  These values needed to
	// accumulate a bit (or two) each.  However, this approach to a
	// three multiply complex multiply cannot increase the total
	// number of bits in our final output.  We'll take care of
	// dropping back down to the proper width, OWIDTH, in our routine
	// below.


	// We accomplish here "Karatsuba" multiplication.  That is,
	// by doing three multiplies we accomplish the work of four.
	// Let's prove to ourselves that this works ... We wish to
	// multiply: (a+jb) * (c+jd), where a+jb is given by
	//	a + jb = r_dif_r + j r_dif_i, and
	//	c + jd = ir_coef_r + j ir_coef_i.
	// We do this by calculating the intermediate products P1, P2,
	// and P3 as
	//	P1 = ac
	//	P2 = bd
	//	P3 = (a + b) * (c + d)
	// and then complete our final answer with
	//	ac - bd = P1 - P2 (this checks)
	//	ad + bc = P3 - P2 - P1
	//	        = (ac + bc + ad + bd) - bd - ac
	//	        = bc + ad (this checks)


	// This should really be based upon an IF, such as in
	// if (IWIDTH < CWIDTH) then ...
	// However, this is the only (other) way I know to do it.
	generate if (CKPCE <= 1)
	begin

		wire	[(CWIDTH):0]	p3c_in;
		wire	[(IWIDTH+1):0]	p3d_in;
		assign	p3c_in = ir_coef_i + ir_coef_r;
		assign	p3d_in = r_dif_r + r_dif_i;

		// We need to pad these first two multiplies by an extra
		// bit just to keep them aligned with the third,
		// simpler, multiply.
		longbimpy #(CWIDTH+1,IWIDTH+2) p1(i_clk, i_ce,
				{ir_coef_r[CWIDTH-1],ir_coef_r},
				{r_dif_r[IWIDTH],r_dif_r}, p_one
`ifdef	FORMAL
				, fp_one_ic, fp_one_id
`endif
			);
		longbimpy #(CWIDTH+1,IWIDTH+2) p2(i_clk, i_ce,
				{ir_coef_i[CWIDTH-1],ir_coef_i},
				{r_dif_i[IWIDTH],r_dif_i}, p_two
`ifdef	FORMAL
				, fp_two_ic, fp_two_id
`endif
			);
		longbimpy #(CWIDTH+1,IWIDTH+2) p3(i_clk, i_ce,
				p3c_in, p3d_in, p_three
`ifdef	FORMAL
				, fp_three_ic, fp_three_id
`endif
			);

	end else if (CKPCE == 2)
	begin : CKPCE_TWO
		// Coefficient multiply inputs
		reg		[2*(CWIDTH)-1:0]	mpy_pipe_c;
		// Data multiply inputs
		reg		[2*(IWIDTH+1)-1:0]	mpy_pipe_d;
		wire	signed	[(CWIDTH-1):0]	mpy_pipe_vc;
		wire	signed	[(IWIDTH):0]	mpy_pipe_vd;
		//
		reg	signed	[(CWIDTH+1)-1:0]	mpy_cof_sum;
		reg	signed	[(IWIDTH+2)-1:0]	mpy_dif_sum;

		assign	mpy_pipe_vc =  mpy_pipe_c[2*(CWIDTH)-1:CWIDTH];
		assign	mpy_pipe_vd =  mpy_pipe_d[2*(IWIDTH+1)-1:IWIDTH+1];

		reg			mpy_pipe_v;
		reg			ce_phase;

		reg	signed	[(CWIDTH+IWIDTH+3)-1:0]	mpy_pipe_out;
		reg	signed [IWIDTH+CWIDTH+3-1:0]	longmpy;

`ifdef	FORMAL
		wire	[CWIDTH:0]	f_past_ic;
		wire	[IWIDTH+1:0]	f_past_id;
		wire	[CWIDTH:0]	f_past_mux_ic;
		wire	[IWIDTH+1:0]	f_past_mux_id;

		reg	[CWIDTH:0]	f_rpone_ic, f_rptwo_ic, f_rpthree_ic,
					f_rp2one_ic, f_rp2two_ic, f_rp2three_ic;
		reg	[IWIDTH+1:0]	f_rpone_id, f_rptwo_id, f_rpthree_id,
					f_rp2one_id, f_rp2two_id, f_rp2three_id;
`endif


		initial	ce_phase = 1'b0;
		always @(posedge i_clk)
		if (i_reset)
			ce_phase <= 1'b0;
		else if (i_ce)
			ce_phase <= 1'b1;
		else
			ce_phase <= 1'b0;

		always @(*)
			mpy_pipe_v = (i_ce)||(ce_phase);

		always @(posedge i_clk)
		if (ce_phase)
		begin
			mpy_pipe_c[2*CWIDTH-1:0] <=
					{ ir_coef_r, ir_coef_i };
			mpy_pipe_d[2*(IWIDTH+1)-1:0] <=
					{ r_dif_r, r_dif_i };

			mpy_cof_sum  <= ir_coef_i + ir_coef_r;
			mpy_dif_sum <= r_dif_r + r_dif_i;

		end else if (i_ce)
		begin
			mpy_pipe_c[2*(CWIDTH)-1:0] <= {
				mpy_pipe_c[(CWIDTH)-1:0], {(CWIDTH){1'b0}} };
			mpy_pipe_d[2*(IWIDTH+1)-1:0] <= {
				mpy_pipe_d[(IWIDTH+1)-1:0], {(IWIDTH+1){1'b0}} };
		end

		longbimpy #(CWIDTH+1,IWIDTH+2) mpy0(i_clk, mpy_pipe_v,
				mpy_cof_sum, mpy_dif_sum, longmpy
`ifdef	FORMAL
				, f_past_ic, f_past_id
`endif
			);

		longbimpy #(CWIDTH+1,IWIDTH+2) mpy1(i_clk, mpy_pipe_v,
				{ mpy_pipe_vc[CWIDTH-1], mpy_pipe_vc },
				{ mpy_pipe_vd[IWIDTH  ], mpy_pipe_vd },
				mpy_pipe_out
`ifdef	FORMAL
				, f_past_mux_ic, f_past_mux_id
`endif
			);

		reg	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]
					rp_one, rp_two, rp_three,
					rp2_one, rp2_two, rp2_three;

		always @(posedge i_clk)
		if (((i_ce)&&(!MPYDELAY[0]))
			||((ce_phase)&&(MPYDELAY[0])))
		begin
			rp_one <= mpy_pipe_out;
`ifdef	FORMAL
			f_rpone_ic <= f_past_mux_ic;
			f_rpone_id <= f_past_mux_id;
`endif
		end

		always @(posedge i_clk)
		if (((i_ce)&&(MPYDELAY[0]))
			||((ce_phase)&&(!MPYDELAY[0])))
		begin
			rp_two <= mpy_pipe_out;
`ifdef	FORMAL
			f_rptwo_ic <= f_past_mux_ic;
			f_rptwo_id <= f_past_mux_id;
`endif
		end

		always @(posedge i_clk)
		if (i_ce)
		begin
			rp_three <= longmpy;
`ifdef	FORMAL
			f_rpthree_ic <= f_past_ic;
			f_rpthree_id <= f_past_id;
`endif
		end


		// Our outputs *MUST* be set on a clock where i_ce is
		// true for the following logic to work.  Make that
		// happen here.
		always @(posedge i_clk)
		if (i_ce)
		begin
			rp2_one<= rp_one;
			rp2_two <= rp_two;
			rp2_three<= rp_three;
`ifdef	FORMAL
			f_rp2one_ic <= f_rpone_ic;
			f_rp2one_id <= f_rpone_id;

			f_rp2two_ic <= f_rptwo_ic;
			f_rp2two_id <= f_rptwo_id;

			f_rp2three_ic <= f_rpthree_ic;
			f_rp2three_id <= f_rpthree_id;
`endif
		end

		assign	p_one	= rp2_one;
		assign	p_two	= (!MPYDELAY[0])? rp2_two  : rp_two;
		assign	p_three	= ( MPYDELAY[0])? rp_three : rp2_three;

		// verilator lint_off UNUSED
		wire	[2*(IWIDTH+CWIDTH+3)-1:0]	unused;
		assign	unused = { rp2_two, rp2_three };
		// verilator lint_on  UNUSED

`ifdef	FORMAL
		assign fp_one_ic = f_rp2one_ic;
		assign fp_one_id = f_rp2one_id;

		assign fp_two_ic = (!MPYDELAY[0])? f_rp2two_ic : f_rptwo_ic;
		assign fp_two_id = (!MPYDELAY[0])? f_rp2two_id : f_rptwo_id;

		assign fp_three_ic= (MPYDELAY[0])? f_rpthree_ic : f_rp2three_ic;
		assign fp_three_id= (MPYDELAY[0])? f_rpthree_id : f_rp2three_id;
`endif

	end else if (CKPCE <= 3)
	begin : CKPCE_THREE
		// Coefficient multiply inputs
		reg		[3*(CWIDTH+1)-1:0]	mpy_pipe_c;
		// Data multiply inputs
		reg		[3*(IWIDTH+2)-1:0]	mpy_pipe_d;
		wire	signed	[(CWIDTH):0]	mpy_pipe_vc;
		wire	signed	[(IWIDTH+1):0]	mpy_pipe_vd;

		assign	mpy_pipe_vc =  mpy_pipe_c[3*(CWIDTH+1)-1:2*(CWIDTH+1)];
		assign	mpy_pipe_vd =  mpy_pipe_d[3*(IWIDTH+2)-1:2*(IWIDTH+2)];

		reg			mpy_pipe_v;
		reg		[2:0]	ce_phase;

		reg	signed	[  (CWIDTH+IWIDTH+3)-1:0]	mpy_pipe_out;

`ifdef	FORMAL
		wire	[CWIDTH:0]	f_past_ic;
		wire	[IWIDTH+1:0]	f_past_id;

		reg	[CWIDTH:0]	f_rpone_ic, f_rptwo_ic, f_rpthree_ic,
					f_rp2one_ic, f_rp2two_ic, f_rp2three_ic,
					f_rp3one_ic;
		reg	[IWIDTH+1:0]	f_rpone_id, f_rptwo_id, f_rpthree_id,
					f_rp2one_id, f_rp2two_id, f_rp2three_id,
					f_rp3one_id;
`endif

		initial	ce_phase = 3'b011;
		always @(posedge i_clk)
		if (i_reset)
			ce_phase <= 3'b011;
		else if (i_ce)
			ce_phase <= 3'b000;
		else if (ce_phase != 3'b011)
			ce_phase <= ce_phase + 1'b1;

		always @(*)
			mpy_pipe_v = (i_ce)||(ce_phase < 3'b010);

		always @(posedge i_clk)
		if (ce_phase == 3'b000)
		begin
			// Second clock
			mpy_pipe_c[3*(CWIDTH+1)-1:(CWIDTH+1)] <= {
				ir_coef_r[CWIDTH-1], ir_coef_r,
				ir_coef_i[CWIDTH-1], ir_coef_i };
			mpy_pipe_c[CWIDTH:0] <= ir_coef_i + ir_coef_r;
			mpy_pipe_d[3*(IWIDTH+2)-1:(IWIDTH+2)] <= {
				r_dif_r[IWIDTH], r_dif_r,
				r_dif_i[IWIDTH], r_dif_i };
			mpy_pipe_d[(IWIDTH+2)-1:0] <= r_dif_r + r_dif_i;

		end else if (mpy_pipe_v)
		begin
			mpy_pipe_c[3*(CWIDTH+1)-1:0] <= {
				mpy_pipe_c[2*(CWIDTH+1)-1:0], {(CWIDTH+1){1'b0}} };
			mpy_pipe_d[3*(IWIDTH+2)-1:0] <= {
				mpy_pipe_d[2*(IWIDTH+2)-1:0], {(IWIDTH+2){1'b0}} };
		end

		longbimpy #(CWIDTH+1,IWIDTH+2) mpy(i_clk, mpy_pipe_v,
				mpy_pipe_vc, mpy_pipe_vd, mpy_pipe_out
`ifdef	FORMAL
				, f_past_ic, f_past_id
`endif
			);

		reg	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]
				rp_one,  rp_two,  rp_three,
				rp2_one, rp2_two, rp2_three,
				rp3_one;

		always @(posedge i_clk)
		if (MPYREMAINDER == 0)
		begin

			if (i_ce)
			begin
				rp_two   <= mpy_pipe_out;
`ifdef	FORMAL
				f_rptwo_ic <= f_past_ic;
				f_rptwo_id <= f_past_id;
`endif
			end else if (ce_phase == 3'b000)
			begin
				rp_three <= mpy_pipe_out;
`ifdef	FORMAL
				f_rpthree_ic <= f_past_ic;
				f_rpthree_id <= f_past_id;
`endif
			end else if (ce_phase == 3'b001)
			begin
				rp_one   <= mpy_pipe_out;
`ifdef	FORMAL
				f_rpone_ic <= f_past_ic;
				f_rpone_id <= f_past_id;
`endif
			end
		end else if (MPYREMAINDER == 1)
		begin

			if (i_ce)
			begin
				rp_one   <= mpy_pipe_out;
`ifdef	FORMAL
				f_rpone_ic <= f_past_ic;
				f_rpone_id <= f_past_id;
`endif
			end else if (ce_phase == 3'b000)
			begin
				rp_two   <= mpy_pipe_out;
`ifdef	FORMAL
				f_rptwo_ic <= f_past_ic;
				f_rptwo_id <= f_past_id;
`endif
			end else if (ce_phase == 3'b001)
			begin
				rp_three <= mpy_pipe_out;
`ifdef	FORMAL
				f_rpthree_ic <= f_past_ic;
				f_rpthree_id <= f_past_id;
`endif
			end
		end else // if (MPYREMAINDER == 2)
		begin

			if (i_ce)
			begin
				rp_three <= mpy_pipe_out;
`ifdef	FORMAL
				f_rpthree_ic <= f_past_ic;
				f_rpthree_id <= f_past_id;
`endif
			end else if (ce_phase == 3'b000)
			begin
				rp_one   <= mpy_pipe_out;
`ifdef	FORMAL
				f_rpone_ic <= f_past_ic;
				f_rpone_id <= f_past_id;
`endif
			end else if (ce_phase == 3'b001)
			begin
				rp_two   <= mpy_pipe_out;
`ifdef	FORMAL
				f_rptwo_ic <= f_past_ic;
				f_rptwo_id <= f_past_id;
`endif
			end
		end

		always @(posedge i_clk)
		if (i_ce)
		begin
			rp2_one   <= rp_one;
			rp2_two   <= rp_two;
			rp2_three <= (MPYREMAINDER == 2) ? mpy_pipe_out : rp_three;
			rp3_one   <= (MPYREMAINDER == 0) ? rp2_one : rp_one;
`ifdef	FORMAL
			f_rp2one_ic <= f_rpone_ic;
			f_rp2one_id <= f_rpone_id;

			f_rp2two_ic <= f_rptwo_ic;
			f_rp2two_id <= f_rptwo_id;

			f_rp2three_ic <= (MPYREMAINDER==2) ? f_past_ic : f_rpthree_ic;
			f_rp2three_id <= (MPYREMAINDER==2) ? f_past_id : f_rpthree_id;
			f_rp3one_ic <= (MPYREMAINDER==0) ? f_rp2one_ic : f_rpone_ic;
			f_rp3one_id <= (MPYREMAINDER==0) ? f_rp2one_id : f_rpone_id;
`endif
		end

		assign	p_one   = rp3_one;
		assign	p_two   = rp2_two;
		assign	p_three = rp2_three;

`ifdef	FORMAL
		assign	fp_one_ic = f_rp3one_ic;
		assign	fp_one_id = f_rp3one_id;

		assign	fp_two_ic = f_rp2two_ic;
		assign	fp_two_id = f_rp2two_id;

		assign	fp_three_ic = f_rp2three_ic;
		assign	fp_three_id = f_rp2three_id;
`endif

	end endgenerate
	// These values are held in memory and delayed during the
	// multiply.  Here, we recover them.  During the multiply,
	// values were multiplied by 2^(CWIDTH-2)*exp{-j*2*pi*...},
	// therefore, the left_x values need to be right shifted by
	// CWIDTH-2 as well.  The additional bits come from a sign
	// extension.
	wire	signed	[(IWIDTH+CWIDTH):0]	fifo_i, fifo_r;
	reg		[(2*IWIDTH+1):0]	fifo_read;
	assign	fifo_r = { {2{fifo_read[2*(IWIDTH+1)-1]}},
		fifo_read[(2*(IWIDTH+1)-1):(IWIDTH+1)], {(CWIDTH-2){1'b0}} };
	assign	fifo_i = { {2{fifo_read[(IWIDTH+1)-1]}},
		fifo_read[((IWIDTH+1)-1):0], {(CWIDTH-2){1'b0}} };


	reg	signed	[(CWIDTH+IWIDTH+3-1):0]	mpy_r, mpy_i;

	// Let's do some rounding and remove unnecessary bits.
	// We have (IWIDTH+CWIDTH+3) bits here, we need to drop down to
	// OWIDTH, and SHIFT by SHIFT bits in the process.  The trick is
	// that we don't need (IWIDTH+CWIDTH+3) bits.  We've accumulated
	// them, but the actual values will never fill all these bits.
	// In particular, we only need:
	//	 IWIDTH bits for the input
	//	     +1 bit for the add/subtract
	//	+CWIDTH bits for the coefficient multiply
	//	     +1 bit for the add/subtract in the complex multiply
	//	 ------
	//	 (IWIDTH+CWIDTH+2) bits at full precision.
	//
	// However, the coefficient multiply multiplied by a maximum value
	// of 2^(CWIDTH-2).  Thus, we only have
	//	   IWIDTH bits for the input
	//	       +1 bit for the add/subtract
	//	+CWIDTH-2 bits for the coefficient multiply
	//	       +1 (optional) bit for the add/subtract in the cpx mpy.
	//	 -------- ... multiply.  (This last bit may be shifted out.)
	//	 (IWIDTH+CWIDTH) valid output bits.
	// Now, if the user wants to keep any extras of these (via OWIDTH),
	// or if he wishes to arbitrarily shift some of these off (via
	// SHIFT) we accomplish that here.

	wire	signed	[(OWIDTH-1):0]	rnd_left_r, rnd_left_i, rnd_right_r, rnd_right_i;

	wire	signed	[(CWIDTH+IWIDTH+3-1):0]	left_sr, left_si;
	assign	left_sr = { {(2){fifo_r[(IWIDTH+CWIDTH)]}}, fifo_r };
	assign	left_si = { {(2){fifo_i[(IWIDTH+CWIDTH)]}}, fifo_i };

	convround #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_left_r(i_clk, i_ce,
				left_sr, rnd_left_r);

	convround #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_left_i(i_clk, i_ce,
				left_si, rnd_left_i);

	convround #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_r(i_clk, i_ce,
				mpy_r, rnd_right_r);

	convround #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_i(i_clk, i_ce,
				mpy_i, rnd_right_i);

	always @(posedge i_clk)
	if (i_ce)
	begin
		// First clock, recover all values
		fifo_read <= fifo_left[fifo_read_addr];
		// These values are IWIDTH+CWIDTH+3 bits wide
		// although they only need to be (IWIDTH+1)
		// + (CWIDTH) bits wide.  (We've got two
		// extra bits we need to get rid of.)
		mpy_r <= p_one - p_two;
		mpy_i <= p_three - p_one - p_two;
	end

	reg	[(AUXLEN-1):0]	aux_pipeline;
	initial	aux_pipeline = 0;
	always @(posedge i_clk)
	if (i_reset)
		aux_pipeline <= 0;
	else if (i_ce)
		aux_pipeline <= { aux_pipeline[(AUXLEN-2):0], i_aux };

	initial o_aux = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		o_aux <= 1'b0;
	else if (i_ce)
	begin
		// Second clock, latch for final clock
		o_aux <= aux_pipeline[AUXLEN-1];
	end

	// As a final step, we pack our outputs into two packed two's
	// complement numbers per output word, so that each output word
	// has (2*OWIDTH) bits in it, with the top half being the real
	// portion and the bottom half being the imaginary portion.
	assign	o_left = { rnd_left_r, rnd_left_i };
	assign	o_right= { rnd_right_r,rnd_right_i};

`ifdef	FORMAL
	initial	f_dlyaux[0] = 0;
	always @(posedge i_clk)
	if (i_reset)
		f_dlyaux	<= 0;
	else if (i_ce)
		f_dlyaux	<= { f_dlyaux[F_DEPTH-2:0], i_aux };

	always @(posedge i_clk)
	if (i_ce)
	begin
		f_dlyleft_r[0]   <= i_left[ (2*IWIDTH-1):IWIDTH];
		f_dlyleft_i[0]   <= i_left[ (  IWIDTH-1):0];
		f_dlyright_r[0]  <= i_right[(2*IWIDTH-1):IWIDTH];
		f_dlyright_i[0]  <= i_right[(  IWIDTH-1):0];
		f_dlycoeff_r[0]  <= i_coef[ (2*CWIDTH-1):CWIDTH];
		f_dlycoeff_i[0]  <= i_coef[ (  CWIDTH-1):0];
	end

	genvar	k;
	generate for(k=1; k<F_DEPTH; k=k+1)
	begin : F_PROPAGATE_DELAY_LINES


		always @(posedge i_clk)
		if (i_ce)
		begin
			f_dlyleft_r[k]  <= f_dlyleft_r[ k-1];
			f_dlyleft_i[k]  <= f_dlyleft_i[ k-1];
			f_dlyright_r[k] <= f_dlyright_r[k-1];
			f_dlyright_i[k] <= f_dlyright_i[k-1];
			f_dlycoeff_r[k] <= f_dlycoeff_r[k-1];
			f_dlycoeff_i[k] <= f_dlycoeff_i[k-1];
		end

	end endgenerate

`ifndef VERILATOR
	//
	// Make some i_ce restraining assumptions.  These are necessary
	// to get the design to pass induction.
	//
	generate if (CKPCE <= 1)
	begin

		// No primary i_ce assumption.  i_ce can be anything
		//
		// First induction i_ce assumption: No more than one
		// empty cycle between used cycles.  Without this
		// assumption, or one like it, induction would never
		// complete.
		always @(posedge i_clk)
		if ((!$past(i_ce)))
			assume(i_ce);

		// Second induction i_ce assumption: avoid skipping an
		// i_ce and thus stretching out the i_ce cycle two i_ce
		// cycles in a row.  Without this assumption, induction
		// would still complete, it would just take longer
		always @(posedge i_clk)
		if (($past(i_ce))&&(!$past(i_ce,2)))
			assume(i_ce);

	end else if (CKPCE == 2)
	begin : F_CKPCE_TWO

		// Primary i_ce assumption: Every i_ce cycle is followed
		// by a non-i_ce cycle, so the multiplies can be
		// multiplexed
		always @(posedge i_clk)
		if ($past(i_ce))
			assume(!i_ce);
		// First induction assumption: Don't let this stretch
		// out too far.  This is necessary to pass induction
		always @(posedge i_clk)
		if ((!$past(i_ce))&&(!$past(i_ce,2)))
			assume(i_ce);

		always @(posedge i_clk)
		if ((!$past(i_ce))&&($past(i_ce,2))
				&&(!$past(i_ce,3))&&(!$past(i_ce,4)))
			assume(i_ce);

	end else if (CKPCE == 3)
	begin : F_CKPCE_THREE

		// Primary i_ce assumption: Following any i_ce cycle,
		// there must be two clock cycles with i_ce de-asserted
		always @(posedge i_clk)
		if (($past(i_ce))||($past(i_ce,2)))
			assume(!i_ce);

		// Induction assumption: Allow i_ce's every third or
		// fourth clock, but don't allow them to be separated
		// further than that
		always @(posedge i_clk)
		if ((!$past(i_ce))&&(!$past(i_ce,2))&&(!$past(i_ce,3)))
			assume(i_ce);

		// Second induction assumption, to speed up the proof:
		// If it's the earliest possible opportunity for an
		// i_ce, and the last i_ce was late, don't let this one
		// be late as well.
		always @(posedge i_clk)
		if ((!$past(i_ce))&&(!$past(i_ce,2))
			&&($past(i_ce,3))&&(!$past(i_ce,4))
			&&(!$past(i_ce,5))&&(!$past(i_ce,6)))
			assume(i_ce);

	end endgenerate
`endif

	reg	[F_LGDEPTH:0]	f_startup_counter;
	initial	f_startup_counter = 0;
	always @(posedge i_clk)
	if (i_reset)
		f_startup_counter <= 0;
	else if ((i_ce)&&(!(&f_startup_counter)))
		f_startup_counter <= f_startup_counter + 1;

	always @(*)
	begin
		f_sumr = f_dlyleft_r[F_D] + f_dlyright_r[F_D];
		f_sumi = f_dlyleft_i[F_D] + f_dlyright_i[F_D];
	end

	assign	f_sumrx = { {(4){f_sumr[IWIDTH]}}, f_sumr, {(CWIDTH-2){1'b0}} };
	assign	f_sumix = { {(4){f_sumi[IWIDTH]}}, f_sumi, {(CWIDTH-2){1'b0}} };

	always @(*)
	begin
		f_difr = f_dlyleft_r[F_D] - f_dlyright_r[F_D];
		f_difi = f_dlyleft_i[F_D] - f_dlyright_i[F_D];
	end

	assign	f_difrx = { {(CWIDTH+2){f_difr[IWIDTH]}}, f_difr };
	assign	f_difix = { {(CWIDTH+2){f_difi[IWIDTH]}}, f_difi };

	assign	f_widecoeff_r ={ {(IWIDTH+3){f_dlycoeff_r[F_D][CWIDTH-1]}},
						f_dlycoeff_r[F_D] };
	assign	f_widecoeff_i ={ {(IWIDTH+3){f_dlycoeff_i[F_D][CWIDTH-1]}},
						f_dlycoeff_i[F_D] };

	always @(posedge i_clk)
	if (f_startup_counter > {1'b0, F_D})
	begin
		assert(aux_pipeline == f_dlyaux);
		assert(left_sr == f_sumrx);
		assert(left_si == f_sumix);
		assert(aux_pipeline[AUXLEN-1] == f_dlyaux[F_D]);

		if ((f_difr == 0)&&(f_difi == 0))
		begin
			assert(mpy_r == 0);
			assert(mpy_i == 0);
		end else if ((f_dlycoeff_r[F_D] == 0)
				&&(f_dlycoeff_i[F_D] == 0))
		begin
			assert(mpy_r == 0);
			assert(mpy_i == 0);
		end

		if ((f_dlycoeff_r[F_D] == 1)&&(f_dlycoeff_i[F_D] == 0))
		begin
			assert(mpy_r == f_difrx);
			assert(mpy_i == f_difix);
		end

		if ((f_dlycoeff_r[F_D] == 0)&&(f_dlycoeff_i[F_D] == 1))
		begin
			assert(mpy_r == -f_difix);
			assert(mpy_i ==  f_difrx);
		end

		if ((f_difr == 1)&&(f_difi == 0))
		begin
			assert(mpy_r == f_widecoeff_r);
			assert(mpy_i == f_widecoeff_i);
		end

		if ((f_difr == 0)&&(f_difi == 1))
		begin
			assert(mpy_r == -f_widecoeff_i);
			assert(mpy_i ==  f_widecoeff_r);
		end
	end

	// Let's see if we can improve our performance at all by
	// moving our test one clock earlier.  If nothing else, it should
	// help induction finish one (or more) clocks ealier than
	// otherwise


	always @(*)
	begin
		f_predifr = f_dlyleft_r[F_D-1] - f_dlyright_r[F_D-1];
		f_predifi = f_dlyleft_i[F_D-1] - f_dlyright_i[F_D-1];
	end

	assign	f_predifrx = { {(CWIDTH+2){f_predifr[IWIDTH]}}, f_predifr };
	assign	f_predifix = { {(CWIDTH+2){f_predifi[IWIDTH]}}, f_predifi };

	always @(*)
	begin
		f_sumcoef = f_dlycoeff_r[F_D-1] + f_dlycoeff_i[F_D-1];
		f_sumdiff = f_predifr + f_predifi;
	end

	// Induction helpers
	always @(posedge i_clk)
	if (f_startup_counter >= { 1'b0, F_D })
	begin
		if (f_dlycoeff_r[F_D-1] == 0)
			assert(p_one == 0);
		if (f_dlycoeff_i[F_D-1] == 0)
			assert(p_two == 0);

		if (f_dlycoeff_r[F_D-1] == 1)
			assert(p_one == f_predifrx);
		if (f_dlycoeff_i[F_D-1] == 1)
			assert(p_two == f_predifix);

		if (f_predifr == 0)
			assert(p_one == 0);
		if (f_predifi == 0)
			assert(p_two == 0);

		// verilator lint_off WIDTH
		if (f_predifr == 1)
			assert(p_one == f_dlycoeff_r[F_D-1]);
		if (f_predifi == 1)
			assert(p_two == f_dlycoeff_i[F_D-1]);
		// verilator lint_on  WIDTH

		if (f_sumcoef == 0)
			assert(p_three == 0);
		if (f_sumdiff == 0)
			assert(p_three == 0);
		// verilator lint_off WIDTH
		if (f_sumcoef == 1)
			assert(p_three == f_sumdiff);
		if (f_sumdiff == 1)
			assert(p_three == f_sumcoef);
		// verilator lint_on  WIDTH
`ifdef	VERILATOR
		// Check that the multiplies match--but *ONLY* if using
		// Verilator, and not if using formal proper
		assert(p_one   == f_predifr * f_dlycoeff_r[F_D-1]);
		assert(p_two   == f_predifi * f_dlycoeff_i[F_D-1]);
		assert(p_three == f_sumdiff * f_sumcoef);
`endif	// VERILATOR
	end

	// The following logic formally insists that our version of the
	// inputs to the multiply matches what the (multiclock) multiply
	// thinks its inputs were.  While this may seem redundant, the
	// proof will not complete in any reasonable amount of time
	// without these assertions.

	assign	f_p3c_in = f_dlycoeff_i[F_D-1] + f_dlycoeff_r[F_D-1];
	assign	f_p3d_in = f_predifi + f_predifr;

	always @(*)
	if (f_startup_counter >= { 1'b0, F_D })
	begin
		assert(fp_one_ic == { f_dlycoeff_r[F_D-1][CWIDTH-1],
				f_dlycoeff_r[F_D-1][CWIDTH-1:0] });
		assert(fp_two_ic == { f_dlycoeff_i[F_D-1][CWIDTH-1],
				f_dlycoeff_i[F_D-1][CWIDTH-1:0] });
		assert(fp_one_id == { f_predifr[IWIDTH], f_predifr });
		assert(fp_two_id == { f_predifi[IWIDTH], f_predifi });
		assert(fp_three_ic == f_p3c_in);
		assert(fp_three_id == f_p3d_in);
	end

	// F_CHECK will be set externally by the solver, so that we can
	// double check that the solver is actually testing what we think
	// it is testing.  We'll set it here to MPYREMAINDER, which will
	// essentially eliminate the check--unless overridden by the
	// solver.
	parameter	F_CHECK = MPYREMAINDER;
	initial	assert(MPYREMAINDER == F_CHECK);

`endif // FORMAL
endmodule
