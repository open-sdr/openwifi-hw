////////////////////////////////////////////////////////////////////////////////
//
// Filename:	laststage.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This is part of an FPGA implementation that will process
//		the final stage of a decimate-in-frequency FFT, running
//	through the data at one sample per clock.
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
module	laststage(i_clk, i_reset, i_ce, i_sync, i_val, o_val, o_sync);
	parameter	IWIDTH=16,OWIDTH=IWIDTH+1, SHIFT=0;
	input	wire				i_clk, i_reset, i_ce, i_sync;
	input	wire	[(2*IWIDTH-1):0]	i_val;
	output	wire	[(2*OWIDTH-1):0]	o_val;
	output	reg				o_sync;

	reg	signed	[(IWIDTH-1):0]	m_r, m_i;
	wire	signed	[(IWIDTH-1):0]	i_r, i_i;

	assign	i_r = i_val[(2*IWIDTH-1):(IWIDTH)]; 
	assign	i_i = i_val[(IWIDTH-1):0]; 

	// Don't forget that we accumulate a bit by adding two values
	// together. Therefore our intermediate value must have one more
	// bit than the two originals.
	reg	signed	[(IWIDTH):0]	rnd_r, rnd_i, sto_r, sto_i;
	reg				wait_for_sync, stage;
	reg		[1:0]		sync_pipe;

	initial	wait_for_sync = 1'b1;
	initial	stage         = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
	begin
		wait_for_sync <= 1'b1;
		stage         <= 1'b0;
	end else if ((i_ce)&&((!wait_for_sync)||(i_sync))&&(!stage))
	begin
		wait_for_sync <= 1'b0;
		//
		stage <= 1'b1;
		//
	end else if (i_ce)
		stage <= 1'b0;

	initial	sync_pipe = 0;
	always @(posedge i_clk)
	if (i_reset)
		sync_pipe <= 0;
	else if (i_ce)
		sync_pipe <= { sync_pipe[0], i_sync };

	initial	o_sync = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		o_sync <= 1'b0;
	else if (i_ce)
		o_sync <= sync_pipe[1];

	always @(posedge i_clk)
	if (i_ce)
	begin
		if (!stage)
		begin
			// Clock 1
			m_r <= i_r;
			m_i <= i_i;
			// Clock 3
			rnd_r <= sto_r;
			rnd_i <= sto_i;
			//
		end else begin
			// Clock 2
			rnd_r <= m_r + i_r;
			rnd_i <= m_i + i_i;
			//
			sto_r <= m_r - i_r;
			sto_i <= m_i - i_i;
			//
		end
	end

	// Now that we have our results, let's round them and report them
	wire	signed	[(OWIDTH-1):0]	o_r, o_i;

	convround #(IWIDTH+1,OWIDTH,SHIFT) do_rnd_r(i_clk, i_ce, rnd_r, o_r);
	convround #(IWIDTH+1,OWIDTH,SHIFT) do_rnd_i(i_clk, i_ce, rnd_i, o_i);

	assign	o_val  = { o_r, o_i };

`ifdef	FORMAL
	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

`ifdef	LASTSTAGE
	always @(posedge i_clk)
		assume((i_ce)||($past(i_ce))||($past(i_ce,2)));
`endif

	initial	assert(IWIDTH+1 == OWIDTH);

	reg	signed	[IWIDTH-1:0]	f_piped_real	[0:3];
	reg	signed	[IWIDTH-1:0]	f_piped_imag	[0:3];
	always @(posedge i_clk)
	if (i_ce)
	begin
		f_piped_real[0] <= i_val[2*IWIDTH-1:IWIDTH];
		f_piped_imag[0] <= i_val[  IWIDTH-1:0];

		f_piped_real[1] <= f_piped_real[0];
		f_piped_imag[1] <= f_piped_imag[0];

		f_piped_real[2] <= f_piped_real[1];
		f_piped_imag[2] <= f_piped_imag[1];

		f_piped_real[3] <= f_piped_real[2];
		f_piped_imag[3] <= f_piped_imag[2];
	end

	wire	f_syncd;
	reg	f_rsyncd;

	initial	f_rsyncd	= 0;
	always @(posedge i_clk)
	if (i_reset)
		f_rsyncd <= 1'b0;
	else if (!f_rsyncd)
		f_rsyncd <= o_sync;
	assign	f_syncd = (f_rsyncd)||(o_sync);

	reg	f_state;
	initial	f_state = 0;
	always @(posedge i_clk)
	if (i_reset)
		f_state <= 0;
	else if ((i_ce)&&((!wait_for_sync)||(i_sync)))
		f_state <= f_state + 1;

	always @(*)
	if (f_state != 0)
		assume(!i_sync);

	always @(*)
		assert(stage == f_state[0]);

	always @(posedge i_clk)
	if ((f_state == 1'b1)&&(f_syncd))
	begin
		assert(o_r == f_piped_real[2] + f_piped_real[1]);
		assert(o_i == f_piped_imag[2] + f_piped_imag[1]);
	end

	always @(posedge i_clk)
	if ((f_state == 1'b0)&&(f_syncd))
	begin
		assert(!o_sync);
		assert(o_r == f_piped_real[3] - f_piped_real[2]);
		assert(o_i == f_piped_imag[3] - f_piped_imag[2]);
	end

	always @(*)
	if (wait_for_sync)
	begin
		assert(!f_rsyncd);
		assert(!o_sync);
		assert(f_state == 0);
	end

`endif // FORMAL
endmodule
