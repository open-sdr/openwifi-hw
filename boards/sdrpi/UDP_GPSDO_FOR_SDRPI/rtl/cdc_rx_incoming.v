

// liwei 715713994@qq.com  

/*
rx_incoming rx_incoming (
.phy_rx_clk(),
.clk_125m(),
.phy_rx_dv(),
.phy_rx_din (),
.rx_dat(),
.rx_dv() 
);
*/

module cdc_rx_incoming (
input phy_rx_clk,clk_125m,
input phy_rx_dv,
input [7:0] phy_rx_din ,
output[7:0] rx_dat,
output rx_dv 
);

wire phy_rx_dv_delay ;
wire [7:0] phy_rxd_delay ;
             
(* IOB = "TRUE" *)   reg phy_rx_dv_r;       always@(posedge  phy_rx_clk)phy_rx_dv_r <= phy_rx_dv ;
(* IOB = "TRUE" *)   reg [7:0] phy_rxd_r ;  always@(posedge  phy_rx_clk)phy_rxd_r <= phy_rx_din ;
 regs#(.w(1),.l( 3 + 8 )) dv_regs (  .clk(phy_rx_clk),   .d(phy_rx_dv_r),   .q(phy_rx_dv_delay)  );
 regs#(.w(8),.l( 3   )) data_regs (  .clk(phy_rx_clk),  .d(phy_rxd_r),  .q(phy_rxd_delay) );
 
 
wire rx_dat_vd ;
wire [7:0] rx_dat_int ;

//cdc_fifo_riffa  
cdc_fifo_oc
//cdc_fifo_xil
cdc_fifo_phy2fpga (
.wr_clk( phy_rx_clk ),.wr_en( phy_rx_dv_delay) ,.wr_dat( phy_rxd_delay ),
.rst( 1'b0 ),.rd_clk(clk_125m ),.rd_dat( rx_dat  ),.rd_vd( rx_dv ) 
);

endmodule 
 