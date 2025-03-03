// Original: https://github.com/KennethWilke/sv-dpram/blob/master/dpram.sv
// Modified to Verilog by xianjun.jiao@imec.be; putaoshu@msn.com
// License: https://github.com/KennethWilke/sv-dpram/blob/master/LICENSE
// Copyright (c) 2023, Kenneth Wilke <kenneth.wilke@gmail.com>

// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.

// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
// REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
// INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
// OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
// PERFORMANCE OF THIS SOFTWARE.

// Dual-ported parameterized RAM module

`timescale 1ns/1ns

module dpram
#(parameter DATA_WIDTH = 8,
  parameter ADDRESS_WIDTH = 8) (
  input clock,
  input reset,

  input enable_a,
  input write_enable,
  input [ADDRESS_WIDTH-1:0] write_address,
  input [DATA_WIDTH-1:0] write_data,
  output reg [DATA_WIDTH-1:0] read_data_a,

  input enable_b,
  input [ADDRESS_WIDTH-1:0] read_address,
  output reg [DATA_WIDTH-1:0] read_data
);

  reg [DATA_WIDTH-1:0] memory [(1<<ADDRESS_WIDTH)-1:0];
  
  // integer i;

  always @ (posedge clock) begin
    if (reset) begin
      read_data_a <= 0;
      read_data <= 0;
      // // DO NOT use this for loop initialization! It will cause resource explosion!
      // for(i = 0; i<(1<<ADDRESS_WIDTH); i = i + 1)
      //   memory[i] <= 0;
    end else begin
      if (enable_b) begin
        read_data <= memory[read_address];
      end
      if (enable_a) begin
        read_data_a <= memory[write_address];
        if (write_enable) begin
          memory[write_address] <= write_data;
        end
      end
    end
  end

endmodule
