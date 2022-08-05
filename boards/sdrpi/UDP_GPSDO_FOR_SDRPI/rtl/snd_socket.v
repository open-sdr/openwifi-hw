
// liwei 715713994@qq.com  


module trans_socket #( 
        parameter AW = 12 , // NOT LESS THAN 10
        parameter DW = 8,  // 16 FOR SIMULATION ,8 FOR REAL USE 
        parameter MAX_PACK_LEN = 8100, 
		  parameter PADDING_INFO_LEN = 0 //0...8
	)(
	input clk,rst,	//cfg if 	//axi stream to ether if 
	input [DW-1:0]fifo_dat,
	input fifo_wr,
	output   fifo_full,
	//ether udp if 
    input m_udp_pack_ready ,
	output reg m_udp_pack_valid = 0 ,
    output reg [15:0]m_udp_tx_len=0,
    output reg [DW-1:0]m_udp_tx_dat=0,
    output reg m_udp_tx_start =0 , 
    output reg m_udp_tx_end =0 ,
	 input [7:0]inf0,inf1,inf2,inf3,inf4,inf5,inf6,inf7,
	 output reg [7:0]  st 
	); 
	localparam MAX_PACK_LEN_P4 = MAX_PACK_LEN + PADDING_INFO_LEN ; 
	///always @ (posedge clk ) if (s_valid) m_udp_port <= cfg_udp_port ;
	
	wire [DW-1:0] fifo_u8 ,fwft_dout;
	wire [AW:0] fifo_cntr;
	wire [DW-1:0]  u8 ;
	reg rd_fifo ;
	wire wr_fifo =  fifo_wr & ~full  ;

		
sc_fifo_4_socket#(
.AW(AW),
.DW(DW)
)sc_fifo_4_socket(

.clk(clk),
.rst(rst),

.din(fifo_dat),
.wr( wr_fifo ),
.full( full ),
.dout( fifo_u8 ),
.rd(rd_fifo),
.empty(empty),
.fwft_dout(fwft_dout),
.fifo_cntr(fifo_cntr) 
);
 
reg [15:0] wait_cntr ; 
wire wait_cntr_of = wait_cntr  >=  512 ;/// |wait_cntr [15:8];///>= 256  ;
wire fifo_cntr_of = fifo_cntr >= MAX_PACK_LEN ;  


reg [7:0]inf0r,inf1r,inf2r,inf3r,inf4r,inf5r,inf6r,inf7r ;
always@(posedge clk)  inf0r<=inf0;
always@(posedge clk)  inf1r<=inf1;
always@(posedge clk)  inf2r<=inf2;
always@(posedge clk)  inf3r<=inf3;
always@(posedge clk)  inf4r<=inf4;
always@(posedge clk)  inf5r<=inf5;
always@(posedge clk)  inf6r<=inf6;
always@(posedge clk)  inf7r<=inf7;

always @(posedge clk) case (st) 
32:m_udp_tx_dat <= inf0r;
33:m_udp_tx_dat <= inf1r;
34:m_udp_tx_dat <= inf2r;
35:m_udp_tx_dat <= inf3r;
36:m_udp_tx_dat <= inf4r;
37:m_udp_tx_dat <= inf5r;
38:m_udp_tx_dat <= inf6r;
39:m_udp_tx_dat <= inf7r; 
default
m_udp_tx_dat <= fifo_u8 ; 
endcase 

always @ (posedge clk) if (rst | empty | wr_fifo | m_udp_tx_start) wait_cntr<=0;
else  if ( wait_cntr_of == 0  ) wait_cntr<= wait_cntr+1 ; 
 
 
reg [15:0]fifo_rd_len ;
reg [15:0] c; always @ (posedge clk) case (st) 20 : c<=1+c;default c<=1;endcase  
reg m_udp_tx_start_d1 , m_udp_tx_start_d2  ;
always @( posedge clk ) m_udp_tx_start_d1 <= ( st==20) &&  (c ==1  );//cam accept one as less as one byte
always @( posedge clk ) m_udp_tx_start_d2  <=  m_udp_tx_start_d1 ;
always @( posedge clk ) m_udp_tx_start    <=  m_udp_tx_start_d2 ;
wire [15:0]fifo_cntr_p4 = fifo_cntr + PADDING_INFO_LEN ;
always @( posedge clk ) if (st==11)m_udp_tx_len<=  (fifo_cntr_of)? (MAX_PACK_LEN_P4) :( fifo_cntr_p4 );
always @( posedge clk ) if (st==11)fifo_rd_len<=  (fifo_cntr_of)? (MAX_PACK_LEN) :( fifo_cntr );


always@(posedge clk)m_udp_pack_valid <=  st==11 ;

always@(posedge clk)if (rst) st<=0; else case (st ) 
0  : st <= 10  ;
10 : if ( wait_cntr_of ==1 || fifo_cntr_of==1 ) st<= 11;
11 : if ( m_udp_pack_ready ) st<=20;//wait ready 
20 : if (c == fifo_rd_len  ) st<=30;//dump bytes 
30,31,32,33,34,35,36,37,38,39,40,41,42: st<=st+1; // wait periods
43 :  st<=10 ;
default st<=0; 
endcase

always@(posedge clk) rd_fifo <= st == 20 ;

assign fifo_full  =  full  ;	

 

endmodule

 

module sc_fifo_4_socket#(
        parameter AW = 5 ,
        parameter DW = 64
    )(
        input clk,rst,
        input [ DW-1:0] din,
        input wr,rd,
        output full,empty,
        output  reg  [ DW-1:0] dout,
        output   [ DW-1:0] fwft_dout,
        output reg [ AW:0] fifo_cntr
    );
    parameter MAX_FIFO_LEN = (1<<AW ) ;
    reg [ DW-1:0] buff[0:  MAX_FIFO_LEN -1] ;
    reg [ AW-1:0] wr_ptr, rd_ptr ;
    assign full  = fifo_cntr >= (  MAX_FIFO_LEN - 16  ) ;
    assign empty = fifo_cntr == 0 ;

    wire valid_rd =   rd ;
    wire valid_wr =   wr ;

    always@(posedge clk) if (rst) wr_ptr <= 0;else if(valid_wr)wr_ptr<=wr_ptr+1;
    always@(posedge clk) if (rst)rd_ptr <= 0 ;else if (valid_rd)rd_ptr <= rd_ptr+1;
    always@(posedge clk) 
	 casex ({rst,valid_wr,valid_rd})
        3'b1xx : fifo_cntr<=0;
        3'b010 : fifo_cntr<=fifo_cntr+1;
        3'b001 : fifo_cntr<=fifo_cntr-1;
        3'b011 ,3'b000 :fifo_cntr<=fifo_cntr ;
    endcase

    always@(posedge clk) if (valid_wr) buff[wr_ptr] <=din ;
    always@(posedge clk) if (valid_rd) dout <= buff[rd_ptr] ;
    assign  fwft_dout = buff[rd_ptr] ;
endmodule


