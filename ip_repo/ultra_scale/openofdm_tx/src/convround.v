////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	convround.v
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	A convergent rounding routine, also known as banker's
//		rounding, Dutch rounding, Gaussian rounding, unbiased
//	rounding, or ... more, at least according to Wikipedia.
//
//	This form of rounding works by rounding, when the direction is in
//	question, towards the nearest even value.
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
module	convround(i_clk, i_ce, i_val, o_val);
	parameter	IWID=16, OWID=8, SHIFT=0;
	input	wire				i_clk, i_ce;
	input	wire	signed	[(IWID-1):0]	i_val;
	output	reg	signed	[(OWID-1):0]	o_val;

	// Let's deal with three cases to be as general as we can be here
	//
	//	1. The desired output would lose no bits at all
	//	2. One bit would be dropped, so the rounding is simply
	//		adjusting the value to be the nearest even number in
	//		cases of being halfway between two.  If identically
	//		equal to a number, we just leave it as is.
	//	3. Two or more bits would be dropped.  In this case, we round
	//		normally unless we are rounding a value of exactly
	//		halfway between the two.  In the halfway case we round
	//		to the nearest even number.
	generate
	if (IWID == OWID) // In this case, the shift is irrelevant and
	begin // cannot be applied.  No truncation or rounding takes
	// effect here.

		always @(posedge i_clk)
		if (i_ce)	o_val <= i_val[(IWID-1):0];

	end else if (IWID-SHIFT < OWID)
	begin // No truncation or rounding, output drops no bits
	// Instead, we need to stuff the bits in the output

		always @(posedge i_clk)
		if (i_ce)	o_val <= { {(OWID-IWID+SHIFT){i_val[IWID-SHIFT-1]}}, i_val[(IWID-SHIFT-1):0] };

	end else if (IWID-SHIFT == OWID)
	begin // No truncation or rounding, output drops no bits

		always @(posedge i_clk)
		if (i_ce)	o_val <= i_val[(IWID-SHIFT-1):0];

	end else if (IWID-SHIFT-1 == OWID)
	begin // Output drops one bit, can only add one or ... not.
		wire	[(OWID-1):0]	truncated_value, rounded_up;
		wire			last_valid_bit, first_lost_bit;
		assign	truncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];
		assign	rounded_up=truncated_value + {{(OWID-1){1'b0}}, 1'b1 };
		assign	last_valid_bit = truncated_value[0];
		assign	first_lost_bit = i_val[0];

		always @(posedge i_clk)
		if (i_ce)
		begin
			if (!first_lost_bit) // Round down / truncate
				o_val <= truncated_value;
			else if (last_valid_bit)// Round up to nearest
				o_val <= rounded_up; // even value
			else // else round down to the nearest
				o_val <= truncated_value; // even value
		end

	end else // If there's more than one bit we are dropping
	begin
		wire	[(OWID-1):0]	truncated_value, rounded_up;
		wire			last_valid_bit, first_lost_bit;

		assign	truncated_value=i_val[(IWID-1-SHIFT):(IWID-SHIFT-OWID)];
		assign	rounded_up=truncated_value + {{(OWID-1){1'b0}}, 1'b1 };
		assign	last_valid_bit = truncated_value[0];
		assign	first_lost_bit = i_val[(IWID-SHIFT-OWID-1)];

		wire	[(IWID-SHIFT-OWID-2):0]	other_lost_bits;
		assign	other_lost_bits = i_val[(IWID-SHIFT-OWID-2):0];

		always @(posedge i_clk)
			if (i_ce)
			begin
				if (!first_lost_bit) // Round down / truncate
					o_val <= truncated_value;
				else if (|other_lost_bits) // Round up to
					o_val <= rounded_up; // closest value
				else if (last_valid_bit) // Round up to
					o_val <= rounded_up; // nearest even
				else	// else round down to nearest even
					o_val <= truncated_value;
			end
	end
	endgenerate

endmodule
