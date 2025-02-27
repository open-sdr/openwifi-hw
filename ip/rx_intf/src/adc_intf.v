// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

module adc_intf #
(
  parameter integer IQ_DATA_WIDTH = 16
)
(
  input wire adc_rst,
  input wire adc_clk,
  input wire [(4*IQ_DATA_WIDTH-1) : 0] adc_data,
  input wire adc_data_valid,

  input wire acc_clk,
  input wire acc_rstn,

  input wire [2:0] bb_gain,
  output wire [(4*IQ_DATA_WIDTH-1) : 0] data_to_bb,
  output wire data_to_bb_valid
);
  reg [(4*IQ_DATA_WIDTH-1) : 0] adc_data_shift;
  reg adc_valid_count;
  wire adc_valid_decimate;
  wire [2:0] bb_gain_in_rf_domain;

  reg [(4*IQ_DATA_WIDTH-1) : 0] adc_data_shift_stage1;
  reg [(4*IQ_DATA_WIDTH-1) : 0] adc_data_shift_stage2;
  reg adc_valid_decimate_stage1;
  reg adc_valid_decimate_stage2;
  reg adc_valid_decimate_stage2_delay;

  assign adc_valid_decimate = (adc_valid_count==0);

  assign data_to_bb = adc_data_shift_stage2;
  assign data_to_bb_valid = (adc_valid_decimate_stage2_delay==0 && adc_valid_decimate_stage2==1);

  xpm_cdc_array_single #(
    //Common module parameters
    .DEST_SYNC_FF   (4), // integer; range: 2-10
    .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
    .WIDTH          (3)  // integer; range: 1-1024
  ) xpm_cdc_array_single_inst_ant_flag (
    .src_clk  (acc_clk),  // optional; required when SRC_INPUT_REG = 1
    .src_in   (bb_gain),
    .dest_clk (adc_clk),
    .dest_out (bb_gain_in_rf_domain)
  );

  always @( posedge adc_clk )
  begin
    if ( adc_rst == 1 ) begin
      adc_data_shift <= 0;
    end else begin
      if (adc_valid_decimate) begin
        case (bb_gain_in_rf_domain)
          3'b000 :  begin
                      adc_data_shift <= adc_data;
                    end
          3'b001 :  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] <= {adc_data[((1*IQ_DATA_WIDTH)-2) : (0*IQ_DATA_WIDTH)], 1'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] <= {adc_data[((2*IQ_DATA_WIDTH)-2) : (1*IQ_DATA_WIDTH)], 1'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] <= {adc_data[((3*IQ_DATA_WIDTH)-2) : (2*IQ_DATA_WIDTH)], 1'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] <= {adc_data[((4*IQ_DATA_WIDTH)-2) : (3*IQ_DATA_WIDTH)], 1'd0};
                    end
          3'b010 :  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] <= {adc_data[((1*IQ_DATA_WIDTH)-3) : (0*IQ_DATA_WIDTH)], 2'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] <= {adc_data[((2*IQ_DATA_WIDTH)-3) : (1*IQ_DATA_WIDTH)], 2'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] <= {adc_data[((3*IQ_DATA_WIDTH)-3) : (2*IQ_DATA_WIDTH)], 2'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] <= {adc_data[((4*IQ_DATA_WIDTH)-3) : (3*IQ_DATA_WIDTH)], 2'd0};
                    end
          3'b011 :  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] <= {adc_data[((1*IQ_DATA_WIDTH)-4) : (0*IQ_DATA_WIDTH)], 3'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] <= {adc_data[((2*IQ_DATA_WIDTH)-4) : (1*IQ_DATA_WIDTH)], 3'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] <= {adc_data[((3*IQ_DATA_WIDTH)-4) : (2*IQ_DATA_WIDTH)], 3'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] <= {adc_data[((4*IQ_DATA_WIDTH)-4) : (3*IQ_DATA_WIDTH)], 3'd0};
                    end
          3'b100 :  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] <= {adc_data[((1*IQ_DATA_WIDTH)-5) : (0*IQ_DATA_WIDTH)], 4'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] <= {adc_data[((2*IQ_DATA_WIDTH)-5) : (1*IQ_DATA_WIDTH)], 4'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] <= {adc_data[((3*IQ_DATA_WIDTH)-5) : (2*IQ_DATA_WIDTH)], 4'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] <= {adc_data[((4*IQ_DATA_WIDTH)-5) : (3*IQ_DATA_WIDTH)], 4'd0};
                    end
          3'b101 :  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] <= {adc_data[((1*IQ_DATA_WIDTH)-6) : (0*IQ_DATA_WIDTH)], 5'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] <= {adc_data[((2*IQ_DATA_WIDTH)-6) : (1*IQ_DATA_WIDTH)], 5'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] <= {adc_data[((3*IQ_DATA_WIDTH)-6) : (2*IQ_DATA_WIDTH)], 5'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] <= {adc_data[((4*IQ_DATA_WIDTH)-6) : (3*IQ_DATA_WIDTH)], 5'd0};
                    end
          3'b110 :  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] <= {adc_data[((1*IQ_DATA_WIDTH)-7) : (0*IQ_DATA_WIDTH)], 6'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] <= {adc_data[((2*IQ_DATA_WIDTH)-7) : (1*IQ_DATA_WIDTH)], 6'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] <= {adc_data[((3*IQ_DATA_WIDTH)-7) : (2*IQ_DATA_WIDTH)], 6'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] <= {adc_data[((4*IQ_DATA_WIDTH)-7) : (3*IQ_DATA_WIDTH)], 6'd0};
                    end
          default:  begin
                      adc_data_shift[((1*IQ_DATA_WIDTH)-1) : (0*IQ_DATA_WIDTH)] = {adc_data[((1*IQ_DATA_WIDTH)-5) : (0*IQ_DATA_WIDTH)], 4'd0};
                      adc_data_shift[((2*IQ_DATA_WIDTH)-1) : (1*IQ_DATA_WIDTH)] = {adc_data[((2*IQ_DATA_WIDTH)-5) : (1*IQ_DATA_WIDTH)], 4'd0};
                      adc_data_shift[((3*IQ_DATA_WIDTH)-1) : (2*IQ_DATA_WIDTH)] = {adc_data[((3*IQ_DATA_WIDTH)-5) : (2*IQ_DATA_WIDTH)], 4'd0};
                      adc_data_shift[((4*IQ_DATA_WIDTH)-1) : (3*IQ_DATA_WIDTH)] = {adc_data[((4*IQ_DATA_WIDTH)-5) : (3*IQ_DATA_WIDTH)], 4'd0};
                    end
        endcase
      end
    end
  end

  //for decimate
  always @( posedge adc_clk )
  begin
    if ( adc_rst == 1 ) begin
      adc_valid_count <= 0;
    end else begin
      if (adc_data_valid == 1)
        adc_valid_count <= adc_valid_count + 1;
    end
  end

  always @( posedge acc_clk )
  begin
    if ( acc_rstn == 0 ) begin
      adc_data_shift_stage1 <= 0;
      adc_data_shift_stage2 <= 0;
      adc_valid_decimate_stage1 <= 0;
      adc_valid_decimate_stage2 <= 0;
      adc_valid_decimate_stage2_delay <= 0;
    end else begin
      adc_data_shift_stage1 <= adc_data_shift;
      adc_data_shift_stage2 <= adc_data_shift_stage1;
      adc_valid_decimate_stage1 <= adc_valid_decimate;
      adc_valid_decimate_stage2 <= adc_valid_decimate_stage1;
      adc_valid_decimate_stage2_delay <= adc_valid_decimate_stage2;
    end
  end

// // ---------for debug purpose------------
//     (* mark_debug = "true" *) reg adc_clk_in_bb_domain;
//     (* mark_debug = "true" *) reg adc_valid_in_bb_domain;
//     (* mark_debug = "true" *) reg FULL_internal_in_bb_domain;
//     (* mark_debug = "true" *) reg [3:0] wren_count;
//     (* mark_debug = "true" *) reg [3:0] rden_count;
//     reg adc_valid_decimate_reg;
//     wire valid;
//     reg  valid_reg;
//     assign valid = (!EMPTY_internal);
//     always @( posedge acc_clk )
//     begin
//       if ( acc_rstn == 1'b0 ) begin
//         adc_clk_in_bb_domain <= 0;
//         adc_valid_in_bb_domain <= 0;
//         FULL_internal_in_bb_domain <= 0;
//         wren_count <= 0;
//         rden_count <= 0;
//         adc_valid_decimate_reg <= 0;
//         valid_reg <= 0;
//       end
//       else begin
//         adc_clk_in_bb_domain <= adc_clk;
//         adc_valid_in_bb_domain <= adc_data_valid;
//         FULL_internal_in_bb_domain <= FULL_internal;
//         adc_valid_decimate_reg <= adc_valid_decimate;
//         valid_reg <= valid;
//         if (adc_valid_decimate==1 && adc_valid_decimate_reg==0)
//           wren_count <= 0;
//         else
//           wren_count <= wren_count + 1;

//         if (valid==1 && valid_reg==0)
//           rden_count <= 0;
//         else
//           rden_count <= rden_count + 1;
//       end
//     end
// // ------------end of debug----------

endmodule
