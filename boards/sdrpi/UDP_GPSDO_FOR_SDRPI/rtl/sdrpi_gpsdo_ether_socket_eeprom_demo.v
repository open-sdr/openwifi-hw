


// liwei 715713994@qq.com  


module sdrpi_gpsdo_ether_socket_eeprom_demo (
input clk_40m,
// iic eeprom
inout scl,sda,
// gpsdo interface
output dac_nsyc,dac_clk,dac_din,
output gps_pl_led, sel_clk_src,
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


assign sel_clk_src = 1; // select ref_clk source .

wire  gpsdo_model = 1 ;
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// demo how to wrte and read 24c02 eeprom .
// access by 64bit word .
// byte adderss equ or more than 240 will never allowed to write to .
// protect region PWR_ON_DAC_VALUE(240~247) and DNA_ID(248~255).
/*
reg rd_req ,wr_req ;
reg [7:0] wr_addr ;
reg [7:0] rd_addr ;
reg [64-1:0]wr_u64 ;
wire [64-1:0] rd_u64 ; 

 reg [31:0] d;
 wire d_of = d ==1000*1000*125 ;
 reg [7:0] sec_n ;
 
 always @(posedge clk_125m) if (rst) d<=0; else if ( ~d_of )d<=d+1;else d<=0  ;
 always @(posedge clk_125m) if (rst) sec_n<=0; else if ( d_of )sec_n<=sec_n+1 ;

 reg [7:0] st ;   
 always @(posedge clk_125m) if (rst) st<=0; else case (st)
 0  : st<=10;
 10 : if ( sec_n == 2) st<=20;  
 
 20 : if (eeprom_idle) st <= 21 ;
 21 : if (wr_done) st<=22 ;
 22 : st <= 23 ;
 23 : st <= 40 ;
 
 40 : if (eeprom_idle)st <= 41 ;
 41 : if (rd_done) st<=42;
 42 : st <= 43 ;
 43 : st <= 50 ;
 
 50 : st <= 50 ; 
 default st <= 0 ; 
 endcase
 
 wire  eeprom_wr_rd_test_ok = (st==50) && (rd_u64 == wr_u64) ; //indicate write and read back good .
 
 always @(posedge clk_125m)  wr_req <=  st == 20 && eeprom_idle==1   ;
 always @(posedge clk_125m)  rd_req <=  st == 40 && eeprom_idle==1   ;
 
 always @(posedge clk_125m)  if  ( st == 20 && eeprom_idle==1 )   wr_addr <= 16 ;//16~23
 always @(posedge clk_125m)  if  ( st == 40 && eeprom_idle==1 )   rd_addr <= 16 ;//16~23
 always @(posedge clk_125m)  if  ( st == 20 )   wr_u64  <= 64'h01_23_45_67_89_ab_cd_ef  ;
 
 */

////////////////////////////////////////////////////////////////////////////////////////////////////////

assign phy_gtx_clk= clk_125m_eth ;

sdrpi_gpsdo_ether_socket_eeprom 

#(
.my_ip({8'd192,8'd168,8'd3,8'd128} ) , 
.my_mac( 48'h0002_1234_5678 ) ,  
.my_rcv_port_a( 8080 ) , 
.my_rcv_port_b( 8090 ) 
)

sdrpi_gpsdo_ether_socket_eeprom (
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
//.phy_gtx_clk( phy_gtx_clk ),
.phy_reset_n(phy_reset_n),
.phy_rx_din( phy_rx_din ),
.phy_rx_dv( phy_rx_dv ),
.phy_rx_clk( phy_rx_clk ),
     
// sokect interface 		

.socket0_pl2net_d( socket0_pl2net_d ),
.socket0_pl2net_wr( socket0_pl2net_wr ),
.socket0_pl2net_full( socket0_pl2net_full ), //ignore it in this demo
.socket0_net2pl_d( socket0_net2pl_d ),
.socket0_net2pl_wr( socket0_net2pl_wr ),

.socket1_pl2net_d( socket1_pl2net_d ),
.socket1_pl2net_wr( socket1_pl2net_wr ),
.socket1_pl2net_full( socket1_pl2net_full ),//ignore it in this demo
.socket1_net2pl_d( socket1_net2pl_d ),
.socket1_net2pl_wr( socket1_net2pl_wr ),

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
