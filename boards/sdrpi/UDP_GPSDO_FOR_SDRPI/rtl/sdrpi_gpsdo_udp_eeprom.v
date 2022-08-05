 

// liwei 715713994@qq.com  

module sdrpi_gpsdo_udp_eeprom  #(parameter product_mode=1)(

input clk_125m, rst,// clk_40m,
input clk_125m_eth,rst_eth,

// iic eeprom
input scl_i,
output scl_o,scl_t,
input sda_i,
output sda_o,sda_t,  

// gpsdo interface
output dac_nsyc,dac_clk,dac_din,
output gps_pl_led,osc_locked, gps_locked,
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
		
		
        //ip address and mac address
        input [31:0] cfg_my_ip,
        input [47:0] cfg_my_mac,


// udp  interface 		
 // pc -> user A interface 
input [31:0] a_rcv_from_ip,
input [15:0]a_rcv_my_port,a_rcv_from_port,
output a_rcv_valid ,
output [7:0] a_rcv_dout,
output  [15:0]a_rcv_udp_src_port , 
output  [31:0]a_rcv_udp_src_ip ,

// pc -> user B interface 
input  [31:0]b_rcv_from_ip,
input  [15:0]b_rcv_my_port,b_rcv_from_port,
output  b_rcv_valid,
output [7:0]b_rcv_dout,
output  [15:0]b_rcv_udp_src_port , 
output  [31:0]b_rcv_udp_src_ip ,

//user A to pc .
input [31:0] a_snd_dst_ip,
input [15:0]a_snd_dst_port,
input [15:0]a_snd_my_port,
input a_snd_wr_fifo,a_snd_fifo_last,
input [7:0]a_snd_fifo_din,
output a_snd_full,

//user B to pc .
input  [31:0]b_snd_dst_ip,
input [15:0]b_snd_dst_port,
input [15:0]b_snd_my_port,
input b_snd_wr_fifo,b_snd_fifo_last,
input [7:0] b_snd_fifo_din,
output b_snd_full ,
		
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
		output   do_halt

); 

 

////////////////////////////////////////
//  rcv interface 

wire  [15:0]   rcv_udp_src_port , rcv_udp_dst_port; 
wire [31:0]  rcv_udp_src_ip ,rcv_udp_dst_ip;
wire [7:0] rcv_udp_dout ;
wire rcv_udp_sof,rcv_udp_eof,rcv_udp_valid ;


rcv_socket rcv_socket_A  (
.clk( clk_125m_eth )  , .rst( rst_eth )  ,.my_port( a_rcv_my_port ) ,.my_ip( cfg_my_ip ) ,.from_port( a_rcv_from_port) ,.s_udp_src_port( rcv_udp_src_port) ,.from_ip( a_rcv_from_ip) ,
.s_udp_dst_port( rcv_udp_dst_port ) ,.s_udp_src_ip( rcv_udp_src_ip) ,.s_udp_dst_ip(rcv_udp_dst_ip ) ,.s_udp_dout( rcv_udp_dout) ,.s_udp_sof(rcv_udp_sof ) ,.s_udp_eof(rcv_udp_eof ) ,.s_udp_valid( rcv_udp_valid) ,
.fifo_wr(a_rcv_valid ) ,.fifo_dout( a_rcv_dout ) ,.src_port(a_rcv_udp_src_port ) ,.src_ip(a_rcv_udp_src_ip) 
);
 		
rcv_socket rcv_socket_B  (
.clk( clk_125m_eth )  , .rst( rst_eth )  ,.my_port( b_rcv_my_port ) ,.my_ip( cfg_my_ip ) ,.from_port( b_rcv_from_port) ,.s_udp_src_port( rcv_udp_src_port) ,.from_ip( b_rcv_from_ip) ,
.s_udp_dst_port( rcv_udp_dst_port ) ,.s_udp_src_ip( rcv_udp_src_ip) ,.s_udp_dst_ip(rcv_udp_dst_ip ) ,.s_udp_dout( rcv_udp_dout) ,.s_udp_sof(rcv_udp_sof ) ,.s_udp_eof(rcv_udp_eof ) ,.s_udp_valid( rcv_udp_valid) ,
.fifo_wr( b_rcv_valid ) ,.fifo_dout( b_rcv_dout ) ,.src_port(b_rcv_udp_src_port ) ,.src_ip(b_rcv_udp_src_ip) 
);

 

////////////////////////////////////////
//  send  interface 
 
 

wire a_udp_pack_valid ,b_udp_pack_valid;
wire a_snd_udp_pack_valid,b_snd_udp_pack_valid ;
reg [7:0]  st ;
localparam DELAY_BIT =  4  ;
reg [DELAY_BIT:0] delay ; wire delay_over = delay[DELAY_BIT];
always @(posedge clk_125m_eth) 
case (st) 30,50: if (~delay_over)delay <= delay+1;default delay <=0;endcase 
wire udp_tx_busy ;
always @ (posedge clk_125m_eth) 
 if (rst) st<=0  ;else case (st)
0  : st <= 10  ;
10 : if ( ~udp_tx_busy)st <= 20 ;
20 : if ( a_snd_udp_pack_valid )  st <=30;else st<=40;
30 : if ( delay_over &  ~ udp_tx_busy )  st<=40;
40 : if ( b_snd_udp_pack_valid )  st<= 50;else st<=60;
50 : if ( delay_over & ~ udp_tx_busy )  st<=20;
60 : st<=20;
default st<=0;
endcase  


reg a_udp_tx_allowed, b_udp_tx_allowed; 
wire  [15:0] a_snd_udp_tx_len; 
wire  [7:0] a_snd_udp_tx_dat; 
wire a_snd_udp_tx_start ;

trans_socket   #( 
    .AW(14)   // 16K 
	)trans_socket_A(
	 .clk(clk_125m_eth ) ,
	 .rst(rst ) ,	//cfg if  
	.fifo_dat(  a_snd_fifo_din ) ,
	.fifo_wr( a_snd_wr_fifo ) , 
		.fifo_full( a_snd_full) ,	 
    .m_udp_pack_ready( a_udp_tx_allowed )  ,
	 .m_udp_pack_valid( a_snd_udp_pack_valid )  ,
    .m_udp_tx_len(a_snd_udp_tx_len )  ,
    .m_udp_tx_dat( a_snd_udp_tx_dat)  ,
    .m_udp_tx_start( a_snd_udp_tx_start)    
    //.m_udp_tx_end(a_snd_udp_tx_end )    
	); 
				 	 
wire  [15:0] b_snd_udp_tx_len; 
wire  [7:0] b_snd_udp_tx_dat; 
wire b_snd_udp_tx_start ;
wire [7:0] trans_socket_B_st ;
trans_socket   #( 
    .AW(14)   // 16K 
	)trans_socket_B(
	.clk(clk_125m_eth ) ,
	.rst(rst ) ,	//cfg if  
	.fifo_dat(  b_snd_fifo_din ) ,
	.fifo_wr(b_snd_wr_fifo ) , 
	.fifo_full( b_snd_full) ,	//ether udp if 
   .m_udp_pack_ready( b_udp_tx_allowed )  ,
	.m_udp_pack_valid( b_snd_udp_pack_valid )  ,
   .m_udp_tx_len(b_snd_udp_tx_len )  ,
   .m_udp_tx_dat( b_snd_udp_tx_dat)  ,
   .m_udp_tx_start( b_snd_udp_tx_start)  ,
   .st(trans_socket_B_st)  
	);
 
 
 

always @ (posedge clk_125m_eth)  a_udp_tx_allowed <=(st == 20)&&(a_snd_udp_pack_valid==1)&&(udp_tx_busy==0) ;
always @ (posedge clk_125m_eth)  b_udp_tx_allowed <=(st == 40)&&(b_snd_udp_pack_valid==1)&&(udp_tx_busy==0) ;

reg [31:0 ] snd_udp_dst_ip     ; 
reg [15:0]snd_udp_src_port   , snd_udp_dst_port  ; 
reg [15:0] snd_udp_tx_len   ; 
reg [7:0]snd_udp_tx_dat  ; 
reg snd_udp_tx_start ;
 
 
 
always @(posedge clk_125m_eth )case ( st ) 
20,30 : 
begin 
 snd_udp_dst_ip <=  a_snd_dst_ip ;
 snd_udp_dst_port <= a_snd_dst_port ;
 snd_udp_src_port <= a_snd_my_port ;
 snd_udp_tx_len <= a_snd_udp_tx_len  ;
 snd_udp_tx_dat <= a_snd_udp_tx_dat ;
 snd_udp_tx_start <=a_snd_udp_tx_start ;
end
40,50:  
begin 
 snd_udp_dst_ip <=  b_snd_dst_ip ;
 snd_udp_dst_port <= b_snd_dst_port ;
 snd_udp_src_port <= b_snd_my_port ;
 snd_udp_tx_len <= b_snd_udp_tx_len  ;
 snd_udp_tx_dat <= b_snd_udp_tx_dat ;
 snd_udp_tx_start <=b_snd_udp_tx_start ;
end 
default 
begin 
 snd_udp_dst_ip <=  'HX ;
 snd_udp_dst_port <= 'HX ;
 snd_udp_src_port <= 'HX ;
 snd_udp_tx_len <= 'HX  ;
 snd_udp_tx_dat <= 'Hx ;
 snd_udp_tx_start <='H0 ;
end 
endcase 
 
  

 
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 wire [7:0] w_rx_din ;
 wire w_rx_dv ;
 
cdc_rx_incoming cdc_rx_incoming ( .phy_rx_clk(phy_rx_clk), .clk_125m(clk_125m_eth), .phy_rx_dv(phy_rx_dv), .phy_rx_din (phy_rx_din), .rx_dat(w_rx_din), .rx_dv(w_rx_dv) );
 
sdrpi_gpsdo_ether_eeprom  sdrpi_gpsdo_ether_eeprom (
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
.phy_tx_clk(phy_tx_clk),
.phy_tx_en( phy_tx_en ),
.phy_gtx_clk( phy_gtx_clk ),
.phy_reset_n(phy_reset_n),
.phy_rx_din( w_rx_din ),
.phy_rx_dv( w_rx_dv ),
//.phy_rx_clk( phy_rx_clk ),
        //ip address and mac address
.cfg_my_ip( cfg_my_ip ),
.cfg_my_mac( cfg_my_mac ),
        // udp  port send 
.s_udp_dst_ip( snd_udp_dst_ip ),
.s_udp_src_port( snd_udp_src_port ),
.s_udp_dst_port( snd_udp_dst_port ),
.s_udp_tx_busy( udp_tx_busy ),
.s_udp_tx_len( snd_udp_tx_len ),
.s_udp_tx_dat( snd_udp_tx_dat ),
.s_udp_ip_id( 'hfeed ),
.s_udp_tx_start( snd_udp_tx_start ),
        // udp   port
.m_udp_len(   ),
.m_udp_dout( rcv_udp_dout ),
.m_udp_valid( rcv_udp_valid ),
.m_udp_sof( rcv_udp_sof ),
.m_udp_eof( rcv_udp_eof ),
.m_udp_chksum_ok( m_udp_chksum_ok ),
.m_udp_src_ip( rcv_udp_src_ip ),
.m_udp_dst_ip( rcv_udp_dst_ip ),
.m_udp_src_port( rcv_udp_src_port ),
.m_udp_dst_port( rcv_udp_dst_port ),

// eeprom interface

//.eeprom_idle( eeprom_idle ),
//.wr_req( wr_req ),
//.wr_addr( wr_addr ),
//.wr_u64( wr_u64 ),
//.wr_done( wr_done ),

// eeprom interface	

//.rd_req( rd_req ),
//.rd_addr( rd_addr ),
//.rd_u64( rd_u64 ),
//.rd_done( rd_done ),
.do_halt( do_halt )
);

endmodule 


