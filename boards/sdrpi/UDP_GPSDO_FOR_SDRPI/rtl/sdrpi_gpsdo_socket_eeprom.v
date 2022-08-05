 

// liwei 715713994@qq.com  

module sdrpi_gpsdo_ether_socket_eeprom (

input clk_125m, rst,// clk_40m,
input clk_125m_eth,rst_eth,

// iic eeprom
input scl_i,
output scl_o,scl_t,
input sda_i,
output sda_o,sda_t,

// gpsdo interface
output dac_nsyc,dac_clk,dac_din,
output gps_pl_led, osc_locked  ,gps_locked,
input  pps_in ,   
input gpsdo_model ,

		//phy interface
		output   [7:0] phy_tx_dout ,
        output phy_tx_err,
        output   phy_tx_en,
        input phy_tx_clk,
        output phy_gtx_clk,phy_reset_n,
        input [7:0] phy_rx_din,
        input phy_rx_dv ,phy_rx_clk, 
		
 
        
// sokect interface 		
input [7:0]   socket0_pl2net_d,
input         socket0_pl2net_wr,
output        socket0_pl2net_full,

output [7:0]  socket0_net2pl_d,
output        socket0_net2pl_wr,


input [7:0]   socket1_pl2net_d,
input         socket1_pl2net_wr,
output        socket1_pl2net_full,

output [7:0]  socket1_net2pl_d,
output        socket1_net2pl_wr,

	/*
		// eeprom interface
		output eeprom_idle ,
		input wr_req,
		input [7:0] wr_addr,
		input [63:0] wr_u64,
		output   wr_done ,
	
  	    // eeprom interface	
		input rd_req,
		input  [7:0] rd_addr,
		output    [63:0] rd_u64,
		output   rd_done   ,
		
		*/
		
		output    do_halt 
		
); 


parameter [ 31: 0 ] my_ip = { 8'd192,8'd168,8'd3,8'd128 }  ;
parameter [ 47: 0 ] my_mac = 48'h00_02_00_00_00_00; 

parameter [ 15: 0 ] my_rcv_port_a = 8080 ;
parameter [ 15: 0 ] my_rcv_port_b = 8090 ; 

/*
wire [ 31: 0 ] my_ip = { 8'd192,8'd168,8'd31,8'd128 }  ;
wire [ 47: 0 ] my_mac = 48'h00_02_00_00_00_00; 

wire [ 15: 0 ] my_rcv_port_a = 8080 ;
wire [ 15: 0 ] my_rcv_port_b = 8090 ; 
*/

 

wire [31:0] a_rcv_src_ip,a_snd_dst_ip ; 
assign a_snd_dst_ip = a_rcv_src_ip ;

wire [31:0] b_rcv_src_ip,b_snd_dst_ip ; 
assign b_snd_dst_ip = b_rcv_src_ip ;
 



sdrpi_gpsdo_udp_eeprom  #(.product_mode(1)) sdrpi_gpsdo_udp_eeprom (
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
.gpsdo_model( gpsdo_model ),
//phy interface
.phy_tx_dout( phy_tx_dout ),
.phy_tx_err( phy_tx_err ),
.phy_tx_en( phy_tx_en ),
.phy_tx_clk(phy_tx_clk),
.phy_gtx_clk( phy_gtx_clk ),
.phy_reset_n(phy_reset_n),
.phy_rx_din( phy_rx_din ),
.phy_rx_dv( phy_rx_dv ),
.phy_rx_clk( phy_rx_clk ),
//ip address and mac address
.cfg_my_ip( my_ip ),
.cfg_my_mac( my_mac ),

// udp  interface 		
 // pc -> user A interface 
.a_rcv_from_ip( 32'hffff_ffff    ),
.a_rcv_my_port(  my_rcv_port_a  ),
.a_rcv_from_port(16'hffff),
.a_rcv_valid( socket0_net2pl_wr ),
.a_rcv_dout( socket0_net2pl_d ),
.a_rcv_udp_src_port(   ),
.a_rcv_udp_src_ip( a_rcv_src_ip ),
//user A to pc .
.a_snd_dst_ip( a_snd_dst_ip ),
.a_snd_dst_port( my_rcv_port_a ),
.a_snd_my_port( my_rcv_port_a ),
.a_snd_wr_fifo( socket0_pl2net_wr ),
.a_snd_fifo_last( 1'b0 ),
.a_snd_fifo_din( socket0_pl2net_d ),
.a_snd_full( socket0_pl2net_full ),

 
// udp  interface 		
 // pc -> user A interface 
.b_rcv_from_ip( 32'hffff_ffff    ),
.b_rcv_my_port(  my_rcv_port_b  ),
.b_rcv_from_port(16'hffff),
.b_rcv_valid( socket1_net2pl_wr ),
.b_rcv_dout( socket1_net2pl_d ),
.b_rcv_udp_src_port(   ),
.b_rcv_udp_src_ip( b_rcv_src_ip ),
//user A to pc .
.b_snd_dst_ip( b_snd_dst_ip ),
.b_snd_dst_port( my_rcv_port_b ),
.b_snd_my_port( my_rcv_port_b ),
.b_snd_wr_fifo( socket1_pl2net_wr ),
.b_snd_fifo_last( 1'b0 ),
.b_snd_fifo_din( socket1_pl2net_d ),
.b_snd_full( socket1_pl2net_full ),

 
		// eeprom interface
//.eeprom_idle( eeprom_idle ),
//.wr_req( wr_req ),
//.wr_addr( wr_addr ),
//.wr_u64( wr_u64 ),
//.wr_done( wr_done ),
//  	    // eeprom interface	
//.rd_req( rd_req ),
//.rd_addr( rd_addr ),
//.rd_u64( rd_u64 ),
//.rd_done( rd_done ),
.do_halt( do_halt )
);

endmodule 


  



