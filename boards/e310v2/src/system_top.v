// ***************************************************************************
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
// based on Analog Devices HDL reference design. openwifi add necessary modules/modifications.
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  inout   [14:0]  ddr_addr,
  inout   [ 2:0]  ddr_ba,
  inout           ddr_cas_n,
  inout           ddr_ck_n,
  inout           ddr_ck_p,
  inout           ddr_cke,
  inout           ddr_cs_n,
  inout   [ 3:0]  ddr_dm,
  inout   [31:0]  ddr_dq,
  inout   [ 3:0]  ddr_dqs_n,
  inout   [ 3:0]  ddr_dqs_p,
  inout           ddr_odt,
  inout           ddr_ras_n,
  inout           ddr_reset_n,
  inout           ddr_we_n,

  inout           fixed_io_ddr_vrn,
  inout           fixed_io_ddr_vrp,
  inout   [53:0]  fixed_io_mio,
  inout           fixed_io_ps_clk,
  inout           fixed_io_ps_porb,
  inout           fixed_io_ps_srstb,

  output          mdio_phy_mdc,
  inout           mdio_phy_mdio_io,
  input   [3:0]   rgmii_rd,
  input           rgmii_rx_ctl,
  input           rgmii_rxc,
  output  [3:0]   rgmii_td,
  output          rgmii_tx_ctl,
  output          rgmii_txc,
  output          phy_rst_n   ,


  inout           iic_scl,
  inout           iic_sda,

  input           rx_clk_in_p,
  input           rx_clk_in_n,
  input           rx_frame_in_p,
  input           rx_frame_in_n,
  input   [ 5:0]  rx_data_in_p,
  input   [ 5:0]  rx_data_in_n,
  output          tx_clk_out_p,
  output          tx_clk_out_n,
  output          tx_frame_out_p,
  output          tx_frame_out_n,
  output  [ 5:0]  tx_data_out_p,
  output  [ 5:0]  tx_data_out_n,

  output          enable,
  output          txnrx,

  inout           gpio_clksel,
  inout           gpio_resetb,
  inout           gpio_sync,
  inout           gpio_en_agc,
  inout   [ 3:0]  gpio_ctl,
  input   [ 7:0]  gpio_status,

  output          spi_csn,
  output          spi_clk,
  output          spi_mosi,
  input           spi_miso,

  // clock form vctcxo
  input  wire	 			      CLK_40MHz_FPGA  ,
  // PPS or 10 MHz
  input  wire             PPS_IN          ,
  input  wire             CLKIN_10MHz     ,

  // Clock disciplining / AD5660 controls
  output wire             CLK_40M_DAC_nSYNC,
  output wire             CLK_40M_DAC_SCLK ,
  output wire             CLK_40M_DAC_DIN ,

  output wire             FE_TXRX2_SEL1 ,
  output wire             FE_TXRX1_SEL1 ,
  output wire             FE_RX2_SEL1 ,
  output wire             FE_RX1_SEL1 ,


  output wire             GPS_RSTN,
  output wire             GPS_PWEN,
  input  wire             GPS_PPS,
  input  wire             GPS_RXD,
  output wire             GPS_TXD,
  output wire             PPS_LED   ,
  output wire             REF_PPS_LOCK  ,
  output wire             REF_10M_LOCK  ,

  output wire             tx_amp_en1,
  output wire             tx_amp_en2
  );


  // internal signals

  wire    [31:0]  gp_out_s;
  wire    [31:0]  gp_in_s;
  wire    [63:0]  gpio_i;
  wire    [63:0]  gpio_o;
  wire    [63:0]  gpio_t;
  wire    [7:0]   gpio_status_dummy;


  wire            ispps       ;
  wire            is10meg     ;
  wire            ppsgps;
  wire            ppsext;
  wire    [1:0]   pps_sel;
  wire            lpps;
  wire            ref_locked        ;
  wire            pll_locked        ;

  // assignments
  assign phy_rst_n = 1'b1;
  assign tx_amp_en = 1'b1;
  assign gp_in_s[31:0] = gp_out_s[31:0];
  assign GPS_RSTN = 1'b1;
  assign GPS_PWEN = 1'b1;

  // board gpio - 31-0

  assign gpio_i[28:0] = gpio_o[28:0];


  // ad9361 gpio - 63-32

  assign gpio_i[63:52] = gpio_o[63:52];
  assign gpio_i[50:47] = gpio_o[50:47];

  ad_iobuf #(.DATA_WIDTH(16)) i_iobuf (
    .dio_t ({gpio_t[51], gpio_t[46:32]}),
    .dio_i ({gpio_o[51], gpio_o[46:32]}),
    .dio_o ({gpio_i[51], gpio_i[46:32]}),
    .dio_p ({ gpio_clksel,        // 51:51
              gpio_resetb,        // 46:46
              gpio_sync,          // 45:45
              gpio_en_agc,        // 44:44
              gpio_ctl,           // 43:40
              gpio_status_dummy}));     // 39:32

  // assign gpio_i[32] = ref_locked;
  // assign ext_ref_is_pps = gpio_o[33];
  // assign ref_sel = gpio_o[34];

  assign tx_amp_en1 = 1'b1;
  assign tx_amp_en2 = 1'b1;
  assign eth_rst_n = 1'b1;


  assign FE_TXRX2_SEL1 = 1'b0;
  assign FE_TXRX1_SEL1 = 1'b1;
  assign FE_RX2_SEL1 = 1'b0;
  assign FE_RX1_SEL1 = 1'b1;


  assign pps_sel = gpio_o[31:30];
  assign gpio_i[29] = ref_locked;
  assign ppsext = pps_sel==2'b11 ? PPS_IN : 1'b0;
  assign ppsgps = GPS_PPS;
  assign PPS_LED = GPS_PPS;
  assign REF_10M_LOCK = is10meg & ref_locked;
  assign REF_PPS_LOCK = ispps & ref_locked;

  ppsloop #(.DEVICE("AD5640")
  )u_ppsloop(
      .xoclk   ( CLK_40MHz_FPGA   ),
      .ppsgps  ( ppsgps  ),
      .ppsext  ( ppsext  ),
      .refsel  ( pps_sel ),
      .lpps    ( lpps    ),
      .is10meg ( is10meg ),
      .ispps   ( ispps ),
      .reflck  ( ref_locked ),
      .plllck  ( pll_locked ),
      .sclk    ( CLK_40M_DAC_SCLK    ),
      .mosi    ( CLK_40M_DAC_DIN    ),
      .sync_n  ( CLK_40M_DAC_nSYNC  ),
      .dac_dflt  ( 16'hBfff )
  );

          

  // instantiations

  system_wrapper i_system_wrapper (
    .ddr_addr (ddr_addr),
    .ddr_ba (ddr_ba),
    .ddr_cas_n (ddr_cas_n),
    .ddr_ck_n (ddr_ck_n),
    .ddr_ck_p (ddr_ck_p),
    .ddr_cke (ddr_cke),
    .ddr_cs_n (ddr_cs_n),
    .ddr_dm (ddr_dm),
    .ddr_dq (ddr_dq),
    .ddr_dqs_n (ddr_dqs_n),
    .ddr_dqs_p (ddr_dqs_p),
    .ddr_odt (ddr_odt),
    .ddr_ras_n (ddr_ras_n),
    .ddr_reset_n (ddr_reset_n),
    .ddr_we_n (ddr_we_n),
    .enable (enable),
    .fixed_io_ddr_vrn (fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp (fixed_io_ddr_vrp),
    .fixed_io_mio (fixed_io_mio),
    .fixed_io_ps_clk (fixed_io_ps_clk),
    .fixed_io_ps_porb (fixed_io_ps_porb),
    .fixed_io_ps_srstb (fixed_io_ps_srstb),
    .GPS_UART_rxd(GPS_RXD),
    .GPS_UART_txd(GPS_TXD),
    .gp_in_0 (gp_in_s[31:0]),
    .gp_out_0 (gp_out_s[31:0]),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_status(gpio_status),
    .gpio_t (gpio_t),

    .mdio_phy_mdc (mdio_phy_mdc),
    .mdio_phy_mdio_io (mdio_phy_mdio_io),
    .rgmii_rd (rgmii_rd),
    .rgmii_rx_ctl (rgmii_rx_ctl),
    .rgmii_rxc (rgmii_rxc),
    .rgmii_td (rgmii_td),
    .rgmii_tx_ctl (rgmii_tx_ctl),
    .rgmii_txc (rgmii_txc),
    .gps_pps (1'b0),
    .iic_main_scl_io (iic_scl),
    .iic_main_sda_io (iic_sda),
    .otg_vbusoc (1'b0),
    .rx_clk_in_n (rx_clk_in_n),
    .rx_clk_in_p (rx_clk_in_p),
    .rx_data_in_n (rx_data_in_n),
    .rx_data_in_p (rx_data_in_p),
    .rx_frame_in_n (rx_frame_in_n),
    .rx_frame_in_p (rx_frame_in_p),
    .spi0_clk_i (1'b0),
    .spi0_clk_o (spi_clk),
    .spi0_csn_0_o (spi_csn),
    .spi0_csn_1_o (),
    .spi0_csn_2_o (),
    .spi0_csn_i (1'b1),
    .spi0_sdi_i (spi_miso),
    .spi0_sdo_i (1'b0),
    .spi0_sdo_o (spi_mosi),
    .spi1_clk_i (1'b0),
    .spi1_clk_o (),
    .spi1_csn_0_o (),
    .spi1_csn_1_o (),
    .spi1_csn_2_o (),
    .spi1_csn_i (1'b1),
    .spi1_sdi_i (1'b0),
    .spi1_sdo_i (1'b0),
    .spi1_sdo_o (),
    .tdd_sync_i (1'b0),
    .tdd_sync_o (),
    .tdd_sync_t (),
    .tx_clk_out_n (tx_clk_out_n),
    .tx_clk_out_p (tx_clk_out_p),
    .tx_data_out_n (tx_data_out_n),
    .tx_data_out_p (tx_data_out_p),
    .tx_frame_out_n (tx_frame_out_n),
    .tx_frame_out_p (tx_frame_out_p),
    .txnrx (txnrx),
    .up_enable (gpio_o[47]),
    .up_txnrx (gpio_o[48]));

endmodule

// ***************************************************************************
// ***************************************************************************
