// file: clk_wiz_v3_6.v
// 
// (c) Copyright 2008 - 2011 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
// "Output    Output      Phase     Duty      Pk-to-Pk        Phase"
// "Clock    Freq (MHz) (degrees) Cycle (%) Jitter (ps)  Error (ps)"
//----------------------------------------------------------------------------
// CLK_OUT1___100.000______0.000______50.0______180.876____191.950
// CLK_OUT2___125.000______0.000______50.0______171.779____191.950
// CLK_OUT3___250.000______0.000______50.0______152.906____191.950
// CLK_OUT4___500.000______0.000______50.0______137.555____191.950
//
//----------------------------------------------------------------------------
// "Input Clock   Freq (MHz)    Input Jitter (UI)"
//----------------------------------------------------------------------------
// __primary______________40____________0.010

`timescale 1ps/1ps

(* CORE_GENERATION_INFO = "clk_wiz_v3_6,clk_wiz_v3_6,{component_name=clk_wiz_v3_6,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,feedback_source=FDBK_AUTO,primtype_sel=MMCM_ADV,num_out_clk=4,clkin1_period=25.000,clkin2_period=10.0,use_power_down=false,use_reset=false,use_locked=true,use_inclk_stopped=false,use_status=false,use_freeze=false,use_clk_valid=false,feedback_type=SINGLE,clock_mgr_type=MANUAL,manual_override=false}" *)
module clk_wiz_v3_6
 (// Clock in ports
  input         CLK_40M,
  // Clock out ports
  output        CLK_100M,
  output        CLK_125M,
  output        CLK_250M,
  output        CLK_500M,
  // Status and control signals
  output        LOCKED
 );

  // Input buffering
  //------------------------------------
  IBUFG clkin1_buf
   (.O (clkin1),
    .I (CLK_40M));


  // Clocking primitive
  //------------------------------------
  // Instantiation of the MMCM primitive
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        clkfbout;
  wire        clkfbout_buf;
  wire        clkfboutb_unused;
  wire        clkout0b_unused;
  wire        clkout1b_unused;
  wire        clkout2b_unused;
  wire        clkout3b_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (25.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (10.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (8),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (4),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKOUT3_DIVIDE       (2),
    .CLKOUT3_PHASE        (0.000),
    .CLKOUT3_DUTY_CYCLE   (0.500),
    .CLKOUT3_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (25.000),
    .REF_JITTER1          (0.010))
  mmcm_adv_inst
    // Output clocks
   (.CLKFBOUT            (clkfbout),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clkout0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clkout1),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf),
    .CLKIN1              (clkin1),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (LOCKED),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

  // Output buffering
  //-----------------------------------
  BUFG clkf_buf
   (.O (clkfbout_buf),
    .I (clkfbout));

  BUFG clkout1_buf
   (.O   (CLK_100M),
    .I   (clkout0));


  BUFG clkout2_buf
   (.O   (CLK_125M),
    .I   (clkout1));

  BUFG clkout3_buf
   (.O   (CLK_250M),
    .I   (clkout2));

  BUFG clkout4_buf
   (.O   (CLK_500M),
    .I   (clkout3));



endmodule
