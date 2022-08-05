
// liwei 715713994@qq.com  
 
/*


 cdc_fifo cdc_fifo(
.wr_clk( ), 
.rst( ),
.wr_en( ) ,
.wr_dat( ),
.rd_clk( ),
.rd_en( ),
.rd_dat( ),
.rd_vd( )
);


*/


 


/*

*/

 

 

module cdc_fifo_oc # (parameter aw = 5 ,parameter dw =8 )(
        input wr_clk, rst,wr_en ,
        input [7:0] wr_dat,
        input rd_clk,
        output reg [7:0] rd_dat,
        output reg rd_vd
    );
    
    
    
    reg wr_en_r ;        always @(posedge wr_clk) wr_en_r <= wr_en ;
    reg [7:0] wr_dat_r; always @(posedge wr_clk) wr_dat_r <= wr_dat ;
        
        
    wire [7:0] rd_dat_w;
    
    reg rd_vdr;

    wire rst_n  = ~ rst ;
    reg[7:0] st ;
        wire [1:0]rd_level,wr_level;
        wire empty ;
    wire rd_fifo = ( st == 20 ) && ( ~empty ) ;
    always @ (posedge rd_clk ) rd_vdr <= rd_fifo ;
    always @ (posedge rd_clk ) rd_vd  <= rd_vdr ;
    always @ (posedge rd_clk ) rd_dat <= rd_dat_w;
 
    generic_fifo_dc_gray #(.aw(aw),.dw(dw)) generic_fifo_dc_gray (
                             .rd_clk(rd_clk) ,
                             .wr_clk(wr_clk) ,
                             .rst(rst_n) ,
                             .clr(~rst_n) ,
                             .din(wr_dat_r ) ,
                             .we(wr_en_r) ,
                             .dout(rd_dat_w ) ,
                             .re(rd_fifo ) ,
                             .full( ) ,
                             .empty(empty )  ,
                             .wr_level(wr_level) ,
                             .rd_level(rd_level)
                         );
                         
                         reg empty_r ,empty_1r ,empty_2r;
                         always @ (posedge rd_clk) empty_r <= empty;
                         always @ (posedge rd_clk) empty_1r <= empty_r;                  
                         always @ (posedge rd_clk) empty_2r <= empty_1r;                  
                                                  
    always @ (posedge rd_clk or posedge  rst) if ( rst )  st <= 0;else case (st)
        0: st<=10;
        10: if (empty_2r==0 )st<=20;
        20: if (empty) st<=10;
        default  st<=0;endcase 
        
endmodule 
