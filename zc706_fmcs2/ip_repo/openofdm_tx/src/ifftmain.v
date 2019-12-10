////////////////////////////////////////////////////////////////////////////////
//
// Filename:	ifftmain.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This is the main module in the General Purpose FPGA FFT
//		implementation.  As such, all other modules are subordinate
//	to this one.  This module accomplish a fixed size Complex FFT on
//	64 data points.
//	The FFT is fully pipelined, and accepts as inputs one complex two's
//	complement sample per clock.
//
// Parameters:
//	i_clk	The clock.  All operations are synchronous with this clock.
//	i_reset	Synchronous reset, active high.  Setting this line will
//			force the reset of all of the internals to this routine.
//			Further, following a reset, the o_sync line will go
//			high the same time the first output sample is valid.
//	i_ce	A clock enable line.  If this line is set, this module
//			will accept one complex input value, and produce
//			one (possibly empty) complex output value.
//	i_sample	The complex input sample.  This value is split
//			into two two's complement numbers, 16 bits each, with
//			the real portion in the high order bits, and the
//			imaginary portion taking the bottom 16 bits.
//	o_result	The output result, of the same format as i_sample,
//			only having 16 bits for each of the real and imaginary
//			components, leading to 32 bits total.
//	o_sync	A one bit output indicating the first sample of the FFT frame.
//			It also indicates the first valid sample out of the FFT
//			on the first frame.
//
// Arguments:	This file was computer generated using the following command
//		line:
//
//		% ./fftgen -v -i -d ../../ifft64 -f 64 -1 -k 1 -p 12 -n 16 -m 16
//
//	This core will use hardware accelerated multiplies (DSPs)
//	for 4 of the 6 stages
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
//
//
module ifftmain(i_clk, i_reset, i_ce,
		i_sample, o_result, o_sync);
	// The bit-width of the input, IWIDTH, output, OWIDTH, and the log
	// of the FFT size.  These are localparams, rather than parameters,
	// because once the core has been generated, they can no longer be
	// changed.  (These values can be adjusted by running the core
	// generator again.)  The reason is simply that these values have
	// been hardwired into the core at several places.
	localparam	IWIDTH=16, OWIDTH=16, LGWIDTH=6;
	//
	input	wire				i_clk, i_reset, i_ce;
	//
	input	wire	[(2*IWIDTH-1):0]	i_sample;
	output	reg	[(2*OWIDTH-1):0]	o_result;
	output	reg				o_sync;


	// Outputs of the FFT, ready for bit reversal.
	wire				br_sync;
	wire	[(2*OWIDTH-1):0]	br_result;


	// A hardware optimized FFT stage
	wire		w_s64;
	wire	[31:0]	w_d64;
	fftstage	#(IWIDTH,IWIDTH+4,16,5,0,
			1, 1, "icmem_64.mem")
		stage_64(i_clk, i_reset, i_ce,
			(!i_reset), i_sample, w_d64, w_s64);


	// A hardware optimized FFT stage
	wire		w_s32;
	wire	[31:0]	w_d32;
	fftstage	#(16,20,16,4,0,
			1, 1, "icmem_32.mem")
		stage_32(i_clk, i_reset, i_ce,
			w_s64, w_d64, w_d32, w_s32);

	// A hardware optimized FFT stage
	wire		w_s16;
	wire	[31:0]	w_d16;
	fftstage	#(16,20,16,3,0,
			1, 1, "icmem_16.mem")
		stage_16(i_clk, i_reset, i_ce,
			w_s32, w_d32, w_d16, w_s16);

	// A hardware optimized FFT stage
	wire		w_s8;
	wire	[31:0]	w_d8;
	fftstage	#(16,20,16,2,0,
			1, 1, "icmem_8.mem")
		stage_8(i_clk, i_reset, i_ce,
			w_s16, w_d16, w_d8, w_s8);

	wire		w_s4;
	wire	[31:0]	w_d4;
	qtrstage	#(16,16,6,1,0)	stage_4(i_clk, i_reset, i_ce,
						w_s8, w_d8, w_d4, w_s4);
	wire		w_s2;
	wire	[31:0]	w_d2;
	laststage	#(16,16,1)	stage_2(i_clk, i_reset, i_ce,
					w_s4, w_d4, w_d2, w_s2);


	wire	br_start;
	reg	r_br_started;
	initial	r_br_started = 1'b0;
	always @(posedge i_clk)
		if (i_reset)
			r_br_started <= 1'b0;
		else if (i_ce)
			r_br_started <= r_br_started || w_s2;
	assign	br_start = r_br_started || w_s2;

	// Now for the bit-reversal stage.
	bitreverse	#(6,16)
		revstage(i_clk, i_reset,
			(i_ce & br_start), w_d2,
			br_result, br_sync);


	// Last clock: Register our outputs, we're done.
	initial	o_sync  = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		o_sync  <= 1'b0;
	else if (i_ce)
		o_sync  <= br_sync;

	always @(posedge i_clk)
	if (i_ce)
		o_result  <= br_result;


endmodule
