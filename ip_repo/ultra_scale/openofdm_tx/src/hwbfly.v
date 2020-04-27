////////////////////////////////////////////////////////////////////////////////
//
// Filename:	hwbfly.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This routine is identical to the butterfly.v routine found
//		in 'butterfly.v', save only that it uses the verilog
//	operator '*' in hopes that the synthesizer would be able to optimize
//	it with hardware resources.
//
//	It is understood that a hardware multiply can complete its operation in
//	a single clock.
//
// Operation:
//
//	Given two inputs, A (i_left) and B (i_right), and a complex
//	coefficient C (i_coeff), return two outputs, O1 and O2, where:
//
//		O1 = A + B, and
//		O2 = (A - B)*C
//
//	This operation is commonly known as a Decimation in Frequency (DIF)
//	Radix-2 Butterfly.
//	O1 and O2 are rounded before being returned in (o_left) and o_right
//	to OWIDTH bits.  If SHIFT is one, an extra bit is dropped from these
//	values during the rounding process.
//
//	Further, since these outputs will take some number of clocks to
//	calculate, we'll pipe a value (i_aux) through the system and return
//	it with the results (o_aux), so you can synchronize to the outgoing
//	output stream.
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
module	hwbfly(i_clk, i_reset, i_ce, i_coef, i_left, i_right, i_aux,
		o_left, o_right, o_aux);
	// Public changeable parameters ...
	//	- IWIDTH, number of bits in each component of the input
	//	- CWIDTH, number of bits in each component of the twiddle factor
	//	- OWIDTH, number of bits in each component of the output
	parameter IWIDTH=16,CWIDTH=IWIDTH+4,OWIDTH=IWIDTH+1;
	// Drop an additional bit on the output?
	parameter		SHIFT=0;
	// The number of clocks per clock enable, 1, 2, or 3.
	parameter	[1:0]	CKPCE=1;
	//
	input	wire	i_clk, i_reset, i_ce;
	input	wire	[(2*CWIDTH-1):0]	i_coef;
	input	wire	[(2*IWIDTH-1):0]	i_left, i_right;
	input	wire	i_aux;
	output	wire	[(2*OWIDTH-1):0]	o_left, o_right;
	output	reg	o_aux;


	reg	[(2*IWIDTH-1):0]	r_left, r_right;
	reg				r_aux, r_aux_2;
	reg	[(2*CWIDTH-1):0]	r_coef;
	wire	signed	[(IWIDTH-1):0]	r_left_r, r_left_i, r_right_r, r_right_i;
	assign	r_left_r  = r_left[ (2*IWIDTH-1):(IWIDTH)];
	assign	r_left_i  = r_left[ (IWIDTH-1):0];
	assign	r_right_r = r_right[(2*IWIDTH-1):(IWIDTH)];
	assign	r_right_i = r_right[(IWIDTH-1):0];
	reg	signed	[(CWIDTH-1):0]	ir_coef_r, ir_coef_i;

	reg	signed	[(IWIDTH):0]	r_sum_r, r_sum_i, r_dif_r, r_dif_i;

	reg	[(2*IWIDTH+2):0]	leftv, leftvv;

	// Set up the input to the multiply
	initial r_aux   = 1'b0;
	initial r_aux_2 = 1'b0;
	always @(posedge i_clk)
		if (i_reset)
		begin
			r_aux <= 1'b0;
			r_aux_2 <= 1'b0;
		end else if (i_ce)
		begin
			// One clock just latches the inputs
			r_aux <= i_aux;
			// Next clock adds/subtracts
			// Other inputs are simply delayed on second clock
			r_aux_2 <= r_aux;
		end
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
			ir_coef_r <= r_coef[(2*CWIDTH-1):CWIDTH];
			ir_coef_i <= r_coef[(CWIDTH-1):0];
		end


	// See comments in the butterfly.v source file for a discussion of
	// these operations and the appropriate bit widths.

	wire	signed	[((IWIDTH+1)+(CWIDTH)-1):0]	p_one, p_two;
	wire	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	p_three;

	initial leftv    = 0;
	initial leftvv   = 0;
	always @(posedge i_clk)
		if (i_reset)
		begin
			leftv <= 0;
			leftvv <= 0;
		end else if (i_ce)
		begin
			// Second clock, pipeline = 1
			leftv <= { r_aux_2, r_sum_r, r_sum_i };

			// Third clock, pipeline = 3
			//   As desired, each of these lines infers a DSP48
			leftvv <= leftv;
		end

	generate if (CKPCE <= 1)
	begin : CKPCE_ONE
		// Coefficient multiply inputs
		reg	signed	[(CWIDTH-1):0]	p1c_in, p2c_in;
		// Data multiply inputs
		reg	signed	[(IWIDTH):0]	p1d_in, p2d_in;
		// Product 3, coefficient input
		reg	signed	[(CWIDTH):0]	p3c_in;
		// Product 3, data input
		reg	signed	[(IWIDTH+1):0]	p3d_in;

		reg	signed	[((IWIDTH+1)+(CWIDTH)-1):0]	rp_one, rp_two;
		reg	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	rp_three;

		always @(posedge i_clk)
		if (i_ce)
		begin
			// Second clock, pipeline = 1
			p1c_in <= ir_coef_r;
			p2c_in <= ir_coef_i;
			p1d_in <= r_dif_r;
			p2d_in <= r_dif_i;
			p3c_in <= ir_coef_i + ir_coef_r;
			p3d_in <= r_dif_r + r_dif_i;
		end

`ifndef	FORMAL
		always @(posedge i_clk)
		if (i_ce)
		begin
			// Third clock, pipeline = 3
			//   As desired, each of these lines infers a DSP48
			rp_one   <= p1c_in * p1d_in;
			rp_two   <= p2c_in * p2d_in;
			rp_three <= p3c_in * p3d_in;
		end
`else
		wire	signed	[((IWIDTH+1)+(CWIDTH)-1):0]	pre_rp_one, pre_rp_two;
		wire	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	pre_rp_three;

		abs_mpy #(CWIDTH,IWIDTH+1,1'b1)
			onei(p1c_in, p1d_in, pre_rp_one);
		abs_mpy #(CWIDTH,IWIDTH+1,1'b1)
			twoi(p2c_in, p2d_in, pre_rp_two);
		abs_mpy #(CWIDTH+1,IWIDTH+2,1'b1)
			threei(p3c_in, p3d_in, pre_rp_three);

		always @(posedge i_clk)
		if (i_ce)
		begin
			rp_one   = pre_rp_one;
			rp_two   = pre_rp_two;
			rp_three = pre_rp_three;
		end
`endif // FORMAL

		assign	p_one   = rp_one;
		assign	p_two   = rp_two;
		assign	p_three = rp_three;

	end else if (CKPCE <= 2)
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

		reg	signed	[(CWIDTH+IWIDTH+1)-1:0]	mpy_pipe_out;
		reg	signed [IWIDTH+CWIDTH+3-1:0]	longmpy;


		initial	ce_phase = 1'b1;
		always @(posedge i_clk)
		if (i_reset)
			ce_phase <= 1'b1;
		else if (i_ce)
			ce_phase <= 1'b0;
		else
			ce_phase <= 1'b1;

		always @(*)
			mpy_pipe_v = (i_ce)||(!ce_phase);

		always @(posedge i_clk)
		if (!ce_phase)
		begin
			// Pre-clock
			mpy_pipe_c[2*CWIDTH-1:0] <=
					{ ir_coef_r, ir_coef_i };
			mpy_pipe_d[2*(IWIDTH+1)-1:0] <=
					{ r_dif_r, r_dif_i };

			mpy_cof_sum  <= ir_coef_i + ir_coef_r;
			mpy_dif_sum <= r_dif_r + r_dif_i;

		end else if (i_ce)
		begin
			// First clock
			mpy_pipe_c[2*(CWIDTH)-1:0] <= {
				mpy_pipe_c[(CWIDTH)-1:0], {(CWIDTH){1'b0}} };
			mpy_pipe_d[2*(IWIDTH+1)-1:0] <= {
				mpy_pipe_d[(IWIDTH+1)-1:0], {(IWIDTH+1){1'b0}} };
		end

`ifndef	FORMAL
		always @(posedge i_clk)
		if (i_ce) // First clock
			longmpy <= mpy_cof_sum * mpy_dif_sum;

		always @(posedge i_clk)
		if (mpy_pipe_v)
			mpy_pipe_out <= mpy_pipe_vc * mpy_pipe_vd;
`else
		wire	signed [IWIDTH+CWIDTH+3-1:0]	pre_longmpy;
		wire	signed	[(CWIDTH+IWIDTH+1)-1:0]	pre_mpy_pipe_out;

		abs_mpy	#(CWIDTH+1,IWIDTH+2,1)
			longmpyi(mpy_cof_sum, mpy_dif_sum, pre_longmpy);

		always @(posedge i_clk)
		if (i_ce)
			longmpy <= pre_longmpy;


		abs_mpy #(CWIDTH,IWIDTH+1,1)
			mpy_pipe_outi(mpy_pipe_vc, mpy_pipe_vd, pre_mpy_pipe_out);

		always @(posedge i_clk)
		if (mpy_pipe_v)
			mpy_pipe_out <= pre_mpy_pipe_out;
`endif

		reg	signed	[((IWIDTH+1)+(CWIDTH)-1):0]	rp_one,
							rp2_one, rp_two;
		reg	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	rp_three;

		always @(posedge i_clk)
		if (!ce_phase) // 1.5 clock
			rp_one <= mpy_pipe_out;
		always @(posedge i_clk)
		if (i_ce) // two clocks
			rp_two <= mpy_pipe_out;
		always @(posedge i_clk)
		if (i_ce) // Second clock
			rp_three<= longmpy;
		always @(posedge i_clk)
		if (i_ce)
			rp2_one<= rp_one;

		assign	p_one  = rp2_one;
		assign	p_two  = rp_two;
		assign	p_three= rp_three;

	end else if (CKPCE <= 2'b11)
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

`ifndef	FORMAL
		always @(posedge i_clk)
			if (mpy_pipe_v)
				mpy_pipe_out <= mpy_pipe_vc * mpy_pipe_vd;

`else	// FORMAL
		wire	signed	[  (CWIDTH+IWIDTH+3)-1:0] pre_mpy_pipe_out;

		abs_mpy #(CWIDTH+1,IWIDTH+2,1)
			mpy_pipe_outi(mpy_pipe_vc, mpy_pipe_vd, pre_mpy_pipe_out);
		always @(posedge i_clk)
			if (mpy_pipe_v)
				mpy_pipe_out <= pre_mpy_pipe_out;
`endif	// FORMAL

		reg	signed	[((IWIDTH+1)+(CWIDTH)-1):0]	rp_one, rp_two,
						rp2_one, rp2_two;
		reg	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	rp_three, rp2_three;

		always @(posedge i_clk)
		if(i_ce)
			rp_one <= mpy_pipe_out[(CWIDTH+IWIDTH):0];
		always @(posedge i_clk)
		if(ce_phase == 3'b000)
			rp_two <= mpy_pipe_out[(CWIDTH+IWIDTH):0];
		always @(posedge i_clk)
		if(ce_phase == 3'b001)
			rp_three <= mpy_pipe_out;
		always @(posedge i_clk)
		if (i_ce)
		begin
			rp2_one<= rp_one;
			rp2_two<= rp_two;
			rp2_three<= rp_three;
		end
		assign	p_one	= rp2_one;
		assign	p_two	= rp2_two;
		assign	p_three	= rp2_three;

	end endgenerate
	wire	signed	[((IWIDTH+2)+(CWIDTH+1)-1):0]	w_one, w_two;
	assign	w_one = { {(2){p_one[((IWIDTH+1)+(CWIDTH)-1)]}}, p_one };
	assign	w_two = { {(2){p_two[((IWIDTH+1)+(CWIDTH)-1)]}}, p_two };

	// These values are held in memory and delayed during the
	// multiply.  Here, we recover them.  During the multiply,
	// values were multiplied by 2^(CWIDTH-2)*exp{-j*2*pi*...},
	// therefore, the left_x values need to be right shifted by
	// CWIDTH-2 as well.  The additional bits come from a sign
	// extension.
	wire	aux_s;
	wire	signed	[(IWIDTH+CWIDTH):0]	left_si, left_sr;
	reg		[(2*IWIDTH+2):0]	left_saved;
	assign	left_sr = { {2{left_saved[2*(IWIDTH+1)-1]}}, left_saved[(2*(IWIDTH+1)-1):(IWIDTH+1)], {(CWIDTH-2){1'b0}} };
	assign	left_si = { {2{left_saved[(IWIDTH+1)-1]}}, left_saved[((IWIDTH+1)-1):0], {(CWIDTH-2){1'b0}} };
	assign	aux_s = left_saved[2*IWIDTH+2];

	(* use_dsp48="no" *)
	reg	signed	[(CWIDTH+IWIDTH+3-1):0]	mpy_r, mpy_i;

	initial left_saved = 0;
	initial o_aux      = 1'b0;
	always @(posedge i_clk)
		if (i_reset)
		begin
			left_saved <= 0;
			o_aux <= 1'b0;
		end else if (i_ce)
		begin
			// First clock, recover all values
			left_saved <= leftvv;

			// Second clock, round and latch for final clock
			o_aux <= aux_s;
		end
	always @(posedge i_clk)
		if (i_ce)
		begin
			// These values are IWIDTH+CWIDTH+3 bits wide
			// although they only need to be (IWIDTH+1)
			// + (CWIDTH) bits wide.  (We've got two
			// extra bits we need to get rid of.)

			// These two lines also infer DSP48's.
			// To keep from using extra DSP48 resources,
			// they are prevented from using DSP48's
			// by the (* use_dsp48 ... *) comment above.
			mpy_r <= w_one - w_two;
			mpy_i <= p_three - w_one - w_two;
		end

	// Round the results
	wire	signed	[(OWIDTH-1):0]	rnd_left_r, rnd_left_i, rnd_right_r, rnd_right_i;

	convround #(CWIDTH+IWIDTH+1,OWIDTH,SHIFT+2) do_rnd_left_r(i_clk, i_ce,
				left_sr, rnd_left_r);

	convround #(CWIDTH+IWIDTH+1,OWIDTH,SHIFT+2) do_rnd_left_i(i_clk, i_ce,
				left_si, rnd_left_i);

	convround #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_r(i_clk, i_ce,
				mpy_r, rnd_right_r);

	convround #(CWIDTH+IWIDTH+3,OWIDTH,SHIFT+4) do_rnd_right_i(i_clk, i_ce,
				mpy_i, rnd_right_i);

	// As a final step, we pack our outputs into two packed two's
	// complement numbers per output word, so that each output word
	// has (2*OWIDTH) bits in it, with the top half being the real
	// portion and the bottom half being the imaginary portion.
	assign	o_left = { rnd_left_r, rnd_left_i };
	assign	o_right= { rnd_right_r,rnd_right_i};

`ifdef	FORMAL
	localparam	F_LGDEPTH = 3;
	localparam	F_DEPTH = 5;
	localparam	[F_LGDEPTH-1:0]	F_D = F_DEPTH-1;

	reg	signed	[IWIDTH-1:0]	f_dlyleft_r  [0:F_DEPTH-1];
	reg	signed	[IWIDTH-1:0]	f_dlyleft_i  [0:F_DEPTH-1];
	reg	signed	[IWIDTH-1:0]	f_dlyright_r [0:F_DEPTH-1];
	reg	signed	[IWIDTH-1:0]	f_dlyright_i [0:F_DEPTH-1];
	reg	signed	[CWIDTH-1:0]	f_dlycoeff_r [0:F_DEPTH-1];
	reg	signed	[CWIDTH-1:0]	f_dlycoeff_i [0:F_DEPTH-1];
	reg	signed	[F_DEPTH-1:0]	f_dlyaux;

	always @(posedge i_clk)
	if (i_reset)
		f_dlyaux <= 0;
	else if (i_ce)
		f_dlyaux <= { f_dlyaux[F_DEPTH-2:0], i_aux };

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

	endgenerate

`ifdef	VERILATOR
`else
	always @(posedge i_clk)
	if ((!$past(i_ce))&&(!$past(i_ce,2))&&(!$past(i_ce,3))
			&&(!$past(i_ce,4)))
		assume(i_ce);

	generate if (CKPCE <= 1)
	begin

		// i_ce is allowed to be anything in this mode

	end else if (CKPCE == 2)
	begin : F_CKPCE_TWO

		always @(posedge i_clk)
			if ($past(i_ce))
				assume(!i_ce);

	end else if (CKPCE == 3)
	begin : F_CKPCE_THREE

		always @(posedge i_clk)
			if (($past(i_ce))||($past(i_ce,2)))
				assume(!i_ce);

	end endgenerate
`endif
	reg	[F_LGDEPTH-1:0]	f_startup_counter;
	initial	f_startup_counter = 0;
	always @(posedge i_clk)
	if (i_reset)
		f_startup_counter <= 0;
	else if ((i_ce)&&(!(&f_startup_counter)))
		f_startup_counter <= f_startup_counter + 1;

	wire	signed	[IWIDTH:0]	f_sumr, f_sumi;
	always @(*)
	begin
		f_sumr = f_dlyleft_r[F_D] + f_dlyright_r[F_D];
		f_sumi = f_dlyleft_i[F_D] + f_dlyright_i[F_D];
	end

	wire	signed	[IWIDTH+CWIDTH:0]	f_sumrx, f_sumix;
	assign	f_sumrx = { {(2){f_sumr[IWIDTH]}}, f_sumr, {(CWIDTH-2){1'b0}} };
	assign	f_sumix = { {(2){f_sumi[IWIDTH]}}, f_sumi, {(CWIDTH-2){1'b0}} };

	wire	signed	[IWIDTH:0]	f_difr, f_difi;
	always @(*)
	begin
		f_difr = f_dlyleft_r[F_D] - f_dlyright_r[F_D];
		f_difi = f_dlyleft_i[F_D] - f_dlyright_i[F_D];
	end

	wire	signed	[IWIDTH+CWIDTH+3-1:0]	f_difrx, f_difix;
	assign	f_difrx = { {(CWIDTH+2){f_difr[IWIDTH]}}, f_difr };
	assign	f_difix = { {(CWIDTH+2){f_difi[IWIDTH]}}, f_difi };

	wire	signed	[IWIDTH+CWIDTH+3-1:0]	f_widecoeff_r, f_widecoeff_i;
	assign	f_widecoeff_r = {{(IWIDTH+3){f_dlycoeff_r[F_D][CWIDTH-1]}},
			f_dlycoeff_r[F_D] };
	assign	f_widecoeff_i = {{(IWIDTH+3){f_dlycoeff_i[F_D][CWIDTH-1]}},
			f_dlycoeff_i[F_D] };

	always @(posedge i_clk)
	if (f_startup_counter > F_D)
	begin
		assert(left_sr == f_sumrx);
		assert(left_si == f_sumix);
		assert(aux_s == f_dlyaux[F_D]);

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


	wire	signed	[IWIDTH:0]	f_predifr, f_predifi;
	always @(*)
	begin
		f_predifr = f_dlyleft_r[F_D-1] - f_dlyright_r[F_D-1];
		f_predifi = f_dlyleft_i[F_D-1] - f_dlyright_i[F_D-1];
	end

	wire	signed	[IWIDTH+CWIDTH+1-1:0]	f_predifrx, f_predifix;
	assign	f_predifrx = { {(CWIDTH){f_predifr[IWIDTH]}}, f_predifr };
	assign	f_predifix = { {(CWIDTH){f_predifi[IWIDTH]}}, f_predifi };

	wire	signed	[CWIDTH:0]	f_sumcoef;
	wire	signed	[IWIDTH+1:0]	f_sumdiff;
	always @(*)
	begin
		f_sumcoef = f_dlycoeff_r[F_D-1] + f_dlycoeff_i[F_D-1];
		f_sumdiff = f_predifr + f_predifi;
	end

	// Induction helpers
	always @(posedge i_clk)
	if (f_startup_counter >= F_D)
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
		assert(p_one   == f_predifr * f_dlycoeff_r[F_D-1]);
		assert(p_two   == f_predifi * f_dlycoeff_i[F_D-1]);
		assert(p_three == f_sumdiff * f_sumcoef);
`endif	// VERILATOR
	end

`endif // FORMAL
endmodule
