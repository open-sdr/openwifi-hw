////////////////////////////////////////////////////////////////////////////////
//
// Filename:	qtrstage.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This file encapsulates the 4 point stage of a decimation in
//		frequency FFT.  This particular implementation is optimized
//	so that all of the multiplies are accomplished by additions and
//	multiplexers only.
//
// Operation:
// 	The operation of this stage is identical to the regular stages of
// 	the FFT (see them for details), with one additional and critical
// 	difference: this stage doesn't require any hardware multiplication.
// 	The multiplies within it may all be accomplished using additions and
// 	subtractions.
//
// 	Let's see how this is done.  Given x[n] and x[n+2], cause thats the
// 	stage we are working on, with i_sync true for x[0] being input,
// 	produce the output:
//
// 	y[n  ] = x[n] + x[n+2]
// 	y[n+2] = (x[n] - x[n+2]) * e^{-j2pi n/2}	(forward transform)
// 	       = (x[n] - x[n+2]) * -j^n
//
// 	y[n].r = x[n].r + x[n+2].r	(This is the easy part)
// 	y[n].i = x[n].i + x[n+2].i
//
// 	y[2].r = x[0].r - x[2].r
// 	y[2].i = x[0].i - x[2].i
//
// 	y[3].r =   (x[1].i - x[3].i)		(forward transform)
// 	y[3].i = - (x[1].r - x[3].r)
//
// 	y[3].r = - (x[1].i - x[3].i)		(inverse transform)
// 	y[3].i =   (x[1].r - x[3].r)		(INVERSE = 1)
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
module	qtrstage(i_clk, i_reset, i_ce, i_sync, i_data, o_data, o_sync);
	parameter	IWIDTH=16, OWIDTH=IWIDTH+1;
	parameter	LGWIDTH=8, INVERSE=0,SHIFT=0;
	input	wire				i_clk, i_reset, i_ce, i_sync;
	input	wire	[(2*IWIDTH-1):0]	i_data;
	output	reg	[(2*OWIDTH-1):0]	o_data;
	output	reg				o_sync;
	
	reg		wait_for_sync;
	reg	[2:0]	pipeline;

	reg	signed [(IWIDTH):0]	sum_r, sum_i, diff_r, diff_i;

	reg	[(2*OWIDTH-1):0]	ob_a;
	wire	[(2*OWIDTH-1):0]	ob_b;
	reg	[(OWIDTH-1):0]		ob_b_r, ob_b_i;
	assign	ob_b = { ob_b_r, ob_b_i };

	reg	[(LGWIDTH-1):0]		iaddr;
	reg	[(2*IWIDTH-1):0]	imem	[0:1];

	wire	signed	[(IWIDTH-1):0]	imem_r, imem_i;
	assign	imem_r = imem[1][(2*IWIDTH-1):(IWIDTH)];
	assign	imem_i = imem[1][(IWIDTH-1):0];

	wire	signed	[(IWIDTH-1):0]	i_data_r, i_data_i;
	assign	i_data_r = i_data[(2*IWIDTH-1):(IWIDTH)];
	assign	i_data_i = i_data[(IWIDTH-1):0];

	reg	[(2*OWIDTH-1):0]	omem [0:1];

	//
	// Round our output values down to OWIDTH bits
	//
	wire	signed	[(OWIDTH-1):0]	rnd_sum_r, rnd_sum_i,
			rnd_diff_r, rnd_diff_i, n_rnd_diff_r, n_rnd_diff_i;
	convround #(IWIDTH+1,OWIDTH,SHIFT)	do_rnd_sum_r(i_clk, i_ce,
				sum_r, rnd_sum_r);

	convround #(IWIDTH+1,OWIDTH,SHIFT)	do_rnd_sum_i(i_clk, i_ce,
				sum_i, rnd_sum_i);

	convround #(IWIDTH+1,OWIDTH,SHIFT)	do_rnd_diff_r(i_clk, i_ce,
				diff_r, rnd_diff_r);

	convround #(IWIDTH+1,OWIDTH,SHIFT)	do_rnd_diff_i(i_clk, i_ce,
				diff_i, rnd_diff_i);

	assign n_rnd_diff_r = - rnd_diff_r;
	assign n_rnd_diff_i = - rnd_diff_i;
	initial wait_for_sync = 1'b1;
	initial iaddr = 0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		wait_for_sync <= 1'b1;
		iaddr <= 0;
	end else if ((i_ce)&&((!wait_for_sync)||(i_sync)))
	begin
		iaddr <= iaddr + 1'b1;
		wait_for_sync <= 1'b0;
	end

	always @(posedge i_clk)
	if (i_ce)
	begin
		imem[0] <= i_data;
		imem[1] <= imem[0];
	end


	// Note that we don't check on wait_for_sync or i_sync here.
	// Why not?  Because iaddr will always be zero until after the
	// first i_ce, so we are safe.
	initial pipeline = 3'h0;
	always	@(posedge i_clk)
	if (i_reset)
		pipeline <= 3'h0;
	else if (i_ce) // is our pipeline process full?  Which stages?
		pipeline <= { pipeline[1:0], iaddr[1] };

	// This is the pipeline[-1] stage, pipeline[0] will be set next.
	always	@(posedge i_clk)
	if ((i_ce)&&(iaddr[1]))
	begin
		sum_r  <= imem_r + i_data_r;
		sum_i  <= imem_i + i_data_i;
		diff_r <= imem_r - i_data_r;
		diff_i <= imem_i - i_data_i;
	end

	// pipeline[1] takes sum_x and diff_x and produces rnd_x

	// Now for pipeline[2].  We can actually do this at all i_ce
	// clock times, since nothing will listen unless pipeline[3]
	// on the next clock.  Thus, we simplify this logic and do
	// it independent of pipeline[2].
	always	@(posedge i_clk)
	if (i_ce)
	begin
		ob_a <= { rnd_sum_r, rnd_sum_i };
		// on Even, W = e^{-j2pi 1/4 0} = 1
		if (!iaddr[0])
		begin
			ob_b_r <= rnd_diff_r;
			ob_b_i <= rnd_diff_i;
		end else if (INVERSE==0) begin
			// on Odd, W = e^{-j2pi 1/4} = -j
			ob_b_r <=   rnd_diff_i;
			ob_b_i <= n_rnd_diff_r;
		end else begin
			// on Odd, W = e^{j2pi 1/4} = j
			ob_b_r <= n_rnd_diff_i;
			ob_b_i <=   rnd_diff_r;
		end
	end

	always	@(posedge i_clk)
	if (i_ce)
	begin // In sequence, clock = 3
		omem[0] <= ob_b;
		omem[1] <= omem[0];
		if (pipeline[2])
			o_data <= ob_a;
		else
			o_data <= omem[1];
	end

	initial	o_sync = 1'b0;
	always	@(posedge i_clk)
	if (i_reset)
		o_sync <= 1'b0;
	else if (i_ce)
		o_sync <= (iaddr[2:0] == 3'b101);

`ifdef	FORMAL
	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid = 1'b1;

`ifdef	QTRSTAGE
	always @(posedge i_clk)
		assume((i_ce)||($past(i_ce))||($past(i_ce,2)));
`endif

	// The below logic only works if the rounding stage does nothing
	initial	assert(IWIDTH+1 == OWIDTH);

	reg	signed [IWIDTH-1:0]	f_piped_real	[0:7];
	reg	signed [IWIDTH-1:0]	f_piped_imag	[0:7];

	always @(posedge i_clk)
	if (i_ce)
	begin
		f_piped_real[0] <= i_data[2*IWIDTH-1:IWIDTH];
		f_piped_imag[0] <= i_data[  IWIDTH-1:0];

		f_piped_real[1] <= f_piped_real[0];
		f_piped_imag[1] <= f_piped_imag[0];

		f_piped_real[2] <= f_piped_real[1];
		f_piped_imag[2] <= f_piped_imag[1];

		f_piped_real[3] <= f_piped_real[2];
		f_piped_imag[3] <= f_piped_imag[2];

		f_piped_real[4] <= f_piped_real[3];
		f_piped_imag[4] <= f_piped_imag[3];

		f_piped_real[5] <= f_piped_real[4];
		f_piped_imag[5] <= f_piped_imag[4];

		f_piped_real[6] <= f_piped_real[5];
		f_piped_imag[6] <= f_piped_imag[5];

		f_piped_real[7] <= f_piped_real[6];
		f_piped_imag[7] <= f_piped_imag[6];
	end

	reg	f_rsyncd;
	wire	f_syncd;

	initial	f_rsyncd = 0;
	always @(posedge i_clk)
	if(i_reset)
		f_rsyncd <= 1'b0;
	else if (!f_rsyncd)
		f_rsyncd <= (o_sync);
	assign	f_syncd = (f_rsyncd)||(o_sync);

	reg	[1:0]	f_state;


	initial	f_state = 0;
	always @(posedge i_clk)
	if (i_reset)
		f_state <= 0;
	else if ((i_ce)&&((!wait_for_sync)||(i_sync)))
		f_state <= f_state + 1;

	always @(*)
	if (f_state != 0)
		assume(!i_sync);

	always @(posedge i_clk)
		assert(f_state[1:0] == iaddr[1:0]);

	wire	signed [2*IWIDTH-1:0]	f_i_real, f_i_imag;
	assign			f_i_real = i_data[2*IWIDTH-1:IWIDTH];
	assign			f_i_imag = i_data[  IWIDTH-1:0];

	wire	signed [OWIDTH-1:0]	f_o_real, f_o_imag;
	assign			f_o_real = o_data[2*OWIDTH-1:OWIDTH];
	assign			f_o_imag = o_data[  OWIDTH-1:0];

	always @(posedge i_clk)
	if (f_state == 2'b11)
	begin
		assume(f_piped_real[0] != 3'sb100);
		assume(f_piped_real[2] != 3'sb100);
		assert(sum_r  == f_piped_real[2] + f_piped_real[0]);
		assert(sum_i  == f_piped_imag[2] + f_piped_imag[0]);

		assert(diff_r == f_piped_real[2] - f_piped_real[0]);
		assert(diff_i == f_piped_imag[2] - f_piped_imag[0]);
	end

	always @(posedge i_clk)
	if ((f_state == 2'b00)&&((f_syncd)||(iaddr >= 4)))
	begin
		assert(rnd_sum_r  == f_piped_real[3]+f_piped_real[1]);
		assert(rnd_sum_i  == f_piped_imag[3]+f_piped_imag[1]);
		assert(rnd_diff_r == f_piped_real[3]-f_piped_real[1]);
		assert(rnd_diff_i == f_piped_imag[3]-f_piped_imag[1]);
	end

	always @(posedge i_clk)
	if ((f_state == 2'b10)&&(f_syncd))
	begin
		// assert(o_sync);
		assert(f_o_real == f_piped_real[5] + f_piped_real[3]);
		assert(f_o_imag == f_piped_imag[5] + f_piped_imag[3]);
	end

	always @(posedge i_clk)
	if ((f_state == 2'b11)&&(f_syncd))
	begin
		assert(!o_sync);
		assert(f_o_real == f_piped_real[5] + f_piped_real[3]);
		assert(f_o_imag == f_piped_imag[5] + f_piped_imag[3]);
	end

	always @(posedge i_clk)
	if ((f_state == 2'b00)&&(f_syncd))
	begin
		assert(!o_sync);
		assert(f_o_real == f_piped_real[7] - f_piped_real[5]);
		assert(f_o_imag == f_piped_imag[7] - f_piped_imag[5]);
	end

	always @(*)
	if ((iaddr[2:0] == 0)&&(!wait_for_sync))
		assume(i_sync);

	always @(*)
	if (wait_for_sync)
		assert((iaddr == 0)&&(f_state == 2'b00)&&(!o_sync)&&(!f_rsyncd));

	always @(posedge i_clk)
	if ((f_past_valid)&&($past(i_ce))&&($past(i_sync))&&(!$past(i_reset)))
		assert(!wait_for_sync);

	always @(posedge i_clk)
	if ((f_state == 2'b01)&&(f_syncd))
	begin
		assert(!o_sync);
		if (INVERSE)
		begin
			assert(f_o_real == -f_piped_imag[7]+f_piped_imag[5]);
			assert(f_o_imag ==  f_piped_real[7]-f_piped_real[5]);
		end else begin
			assert(f_o_real ==  f_piped_imag[7]-f_piped_imag[5]);
			assert(f_o_imag == -f_piped_real[7]+f_piped_real[5]);
		end
	end

`endif
endmodule
