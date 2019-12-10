////////////////////////////////////////////////////////////////////////////////
//
// Filename:	bitreverse.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	This module bitreverses a pipelined FFT input.  It differes
//		from the dblreverse module in that this is just a simple and
//	straightforward bitreverse, rather than one written to handle two
//	words at once.
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
module	bitreverse(i_clk, i_reset, i_ce, i_in, o_out, o_sync);
	parameter			LGSIZE=5, WIDTH=24;
	input	wire			i_clk, i_reset, i_ce;
	input	wire	[(2*WIDTH-1):0]	i_in;
	output	reg	[(2*WIDTH-1):0]	o_out;
	output	reg			o_sync;
	reg	[(LGSIZE):0]	wraddr;
	wire	[(LGSIZE):0]	rdaddr;

	reg	[(2*WIDTH-1):0]	brmem	[0:((1<<(LGSIZE+1))-1)];

	genvar	k;
	generate for(k=0; k<LGSIZE; k=k+1)
	begin : DBL
		assign rdaddr[k] = wraddr[LGSIZE-1-k];
	end endgenerate
	assign	rdaddr[LGSIZE] = !wraddr[LGSIZE];

	reg	in_reset;

	initial	in_reset = 1'b1;
	always @(posedge i_clk)
		if (i_reset)
			in_reset <= 1'b1;
		else if ((i_ce)&&(&wraddr[(LGSIZE-1):0]))
			in_reset <= 1'b0;

	initial	wraddr = 0;
	always @(posedge i_clk)
		if (i_reset)
			wraddr <= 0;
		else if (i_ce)
		begin
			brmem[wraddr] <= i_in;
			wraddr <= wraddr + 1;
		end

	always @(posedge i_clk)
		if (i_ce) // If (i_reset) we just output junk ... not a problem
			o_out <= brmem[rdaddr]; // w/o a sync pulse

	initial	o_sync = 1'b0;
	always @(posedge i_clk)
		if (i_reset)
			o_sync <= 1'b0;
		else if ((i_ce)&&(!in_reset))
			o_sync <= (wraddr[(LGSIZE-1):0] == 0);

`ifdef	FORMAL
`define	ASSERT	assert
`ifdef	BITREVERSE
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	initial	`ASSUME(i_reset);
	always @(posedge i_clk)
	if ((!f_past_valid)||($past(i_reset)))
	begin
		`ASSERT(wraddr == 0);
		`ASSERT(in_reset);
		`ASSERT(!o_sync);
	end
`ifdef	BITREVERSE
	always @(posedge i_clk)
		assume((i_ce)||($past(i_ce))||($past(i_ce,2)));
`endif // BITREVERSE

		(* anyconst *) reg	[LGSIZE:0]	f_const_addr;
		wire	[LGSIZE:0]	f_reversed_addr;
		reg			f_addr_loaded;
		reg	[(2*WIDTH-1):0]	f_addr_value;

		generate for(k=0; k<LGSIZE; k=k+1)
			assign	f_reversed_addr[k] = f_const_addr[LGSIZE-1-k];
		endgenerate
		assign	f_reversed_addr[LGSIZE] = f_const_addr[LGSIZE];

		initial	f_addr_loaded = 1'b0;
		always @(posedge i_clk)
		if (i_reset)
			f_addr_loaded <= 1'b0;
		else if (i_ce)
		begin
			if (wraddr == f_const_addr)
				f_addr_loaded <= 1'b1;
			else if (rdaddr == f_const_addr)
				f_addr_loaded <= 1'b0;
		end

		always @(posedge i_clk)
		if ((i_ce)&&(wraddr == f_const_addr))
		begin
			f_addr_value <= i_in;
			`ASSERT(!f_addr_loaded);
		end

		always @(posedge i_clk)
		if ((f_past_valid)&&(!$past(i_reset))
				&&($past(f_addr_loaded))&&(!f_addr_loaded))
			assert(o_out == f_addr_value);

		always @(*)
		if (o_sync)
			assert(wraddr[LGSIZE-1:0] == 1);

		always @(*)
		if ((wraddr[LGSIZE]==f_const_addr[LGSIZE])
				&&(wraddr[LGSIZE-1:0]
						<= f_const_addr[LGSIZE-1:0]))
			`ASSERT(!f_addr_loaded);

		always @(*)
		if ((rdaddr[LGSIZE]==f_const_addr[LGSIZE])&&(f_addr_loaded))
			`ASSERT(wraddr[LGSIZE-1:0]
					<= f_reversed_addr[LGSIZE-1:0]+1);

		always @(*)
		if (f_addr_loaded)
			`ASSERT(brmem[f_const_addr] == f_addr_value);



`endif	// FORMAL
endmodule
