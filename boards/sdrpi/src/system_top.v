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
/*
  inout           iic_scl,
  inout           iic_sda,
*/

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

  inout           gpio_resetb,
  inout           gpio_sync,
  inout           gpio_en_agc,
  inout   [ 3:0]  gpio_ctl,
  input   [ 7:0]  gpio_status,

  output          spi_csn,
  output          spi_clk,
  output          spi_mosi,
  input           spi_miso,
  
  output tx1_en, tx2_en ,
  output sel_clk_src ,
  
  input clk_40m,
// iic eeprom
inout scl,sda,
// gpsdo interface
output dac_nsyc,dac_clk,dac_din,
output gps_pl_led,
input  pps_in ,   


//phy interface
output   [7:0] phy_tx_dout ,
output phy_tx_err,
input phy_tx_clk,
output   phy_tx_en,
output phy_gtx_clk,phy_reset_n,
input [7:0] phy_rx_din,
input phy_rx_dv ,phy_rx_clk,phy_rx_err
 
);



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


wire scl_o , scl_t , sda_o , sda_t ;

wire  scl_i = scl ;assign scl = (scl_t )?1'bz: scl_o;
wire  sda_i = sda ;assign sda = (sda_t )?1'bz: sda_o;

clk_wiz_v3_6  clk_wiz_v3_6 ( .CLK_40M(clk_40m),.CLK_100M(),.CLK_125M(clk_125m),.CLK_250M(),.CLK_500M(),.LOCKED(PLL_LOCKED));

wire clk_125m_eth = clk_125m ;

wire  rst , rst_eth ;
por_rst #( .CNTR(1000) ) por_rst( .clk(clk_125m) ,.rst(0), .por(rst) )  ;
por_rst #( .CNTR(1000) ) por_rst_eth ( .clk(clk_125m_eth) ,.rst(0), .por(rst_eth) )  ;


wire [7:0]socket0_pl2net_d ,socket0_net2pl_d ;
assign socket0_pl2net_d = socket0_net2pl_d ;

wire socket0_pl2net_wr,socket0_net2pl_wr;
assign socket0_pl2net_wr = socket0_net2pl_wr ;

wire [7:0]socket1_pl2net_d ,socket1_net2pl_d ;
assign socket1_pl2net_d = socket1_net2pl_d ;

wire socket1_pl2net_wr,socket1_net2pl_wr;
assign socket1_pl2net_wr = socket1_net2pl_wr ;
 
 wire osc_locked ;
 wire gps_locked ; 

 

assign phy_gtx_clk= clk_125m_eth ;

sdrpi_gpsdo_ether_socket_eeprom # (

.my_ip({8'd192,8'd168,8'd3,8'd128} ) , 
.my_mac( 48'h0002_1234_5678 ) ,  
.my_rcv_port_a( 8080 ) , 
.my_rcv_port_b( 8090 ) 

) sdrpi_gpsdo_ether_socket_eeprom (
.clk_125m( clk_125m ),
.rst( rst ),
.clk_125m_eth( clk_125m_eth ),
.rst_eth( rst_eth ),
// iic eeprom
.scl_i( scl_i ),
.scl_o( scl_o ),
.scl_t( scl_t ),
.sda_i( sda_i ),
.sda_o( sda_o ),
.sda_t( sda_t ),
// gpsdo interface
.dac_nsyc( dac_nsyc ),
.dac_clk( dac_clk ),
.dac_din( dac_din ),
.gps_pl_led( gps_pl_led ),
.osc_locked(osc_locked),
.gps_locked(gps_locked),
.pps_in( pps_in ),
.gpsdo_model( 1 ),
		//phy interface
.phy_tx_dout( phy_tx_dout ),
.phy_tx_err( phy_tx_err ),
.phy_tx_clk(phy_tx_clk),
.phy_tx_en( phy_tx_en ),
//.phy_gtx_clk( phy_gtx_clk ),
.phy_reset_n(phy_reset_n),
.phy_rx_din( phy_rx_din ),
.phy_rx_dv( phy_rx_dv ),
.phy_rx_clk( phy_rx_clk ),
     
// sokect interface 		

.socket0_pl2net_d( socket0_pl2net_d ),
.socket0_pl2net_wr( socket0_pl2net_wr ),
.socket0_pl2net_full(  ), //ignore it in this demo
.socket0_net2pl_d( socket0_net2pl_d ),
.socket0_net2pl_wr( socket0_net2pl_wr ),

.socket1_pl2net_d( socket1_pl2net_d ),
.socket1_pl2net_wr( socket1_pl2net_wr ),
.socket1_pl2net_full(  ),//ignore it in this demo
.socket1_net2pl_d( socket1_net2pl_d ),
.socket1_net2pl_wr( socket1_net2pl_wr ),

.do_halt(   )
);



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





 
  wire   gpio_clksel ;


assign {tx1_en,tx2_en, sel_clk_src }  = 3'b111;

	// internal signals

	wire    [31:0]  gp_out_s;
	wire    [31:0]  gp_in_s;
	wire    [63:0]  gpio_i;
	wire    [63:0]  gpio_o;
	wire    [63:0]  gpio_t;
	wire    [7:0]   gpio_status_dummy;
	wire    [27:0]  gp_out;
	wire    [27:0]  gp_in;
 
 
	assign gp_out[27:0] = gp_out_s[27:0];
	assign gp_in_s[31:28] = gp_out_s[31:28];
	assign gp_in_s[27: 0] = gp_in[27:0];

 

  // board gpio - 31-0

  assign gpio_i[31:11] = gpio_o[31:11];


wire   [10:0]  gpio_bd;


  ad_iobuf #(.DATA_WIDTH(11)) i_iobuf_bd (
    .dio_t (gpio_t[10:0]),
    .dio_i (gpio_o[10:0]),
    .dio_o (gpio_i[10:0]),
    .dio_p (gpio_bd));

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
    .gp_in_0 (gp_in_s[31:0]),
    .gp_out_0 (gp_out_s[31:0]),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_status(gpio_status),
    .gpio_t (gpio_t),
//    .gps_pps (1'b0),
//    .iic_main_scl_io (iic_scl),
//    .iic_main_sda_io (iic_sda),
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
