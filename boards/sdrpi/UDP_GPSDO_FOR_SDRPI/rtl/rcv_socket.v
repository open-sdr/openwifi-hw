 

// liwei 715713994@qq.com  

			 
module rcv_socket (
input clk, rst ,
input [15:0] my_port,s_udp_dst_port,
input [31:0] my_ip,s_udp_dst_ip,


input [15:0] from_port,s_udp_src_port,
input [31:0] from_ip,s_udp_src_ip,

output reg [15:0] src_port ,
output reg [31:0] src_ip ,
input [7:0] s_udp_dout,
input s_udp_sof,s_udp_eof,s_udp_valid,
output reg fifo_wr,
output reg [7:0] fifo_dout
);


always @(posedge clk)  if (rst)src_port<=0;else if (s_udp_valid&s_udp_sof)src_port <= s_udp_src_port ;
always @(posedge clk)  if (rst)src_ip<=0;  else if (s_udp_valid&s_udp_sof)src_ip <= s_udp_src_ip ;

wire my_port_hit =  my_port=='hffff  ||  my_port == s_udp_dst_port ;
wire my_ip_hit =  my_ip=='hffff_ffff ||  my_ip == s_udp_dst_ip ;

wire from_port_hit =  from_port=='hffff  ||  from_port == s_udp_src_port ;
wire from_ip_hit =  from_ip=='hffff_ffff ||  from_ip == s_udp_src_ip ;

wire hit = my_port_hit & my_ip_hit & from_port_hit & from_ip_hit ;

reg [7:0] st ; 
always @(posedge clk)if (rst) st<=0;else case (st)
0  : st<=10;
10 : if ( s_udp_sof & s_udp_valid & hit )  st<= (s_udp_eof) ? 30 : 20 ;
20 : if (s_udp_eof &   s_udp_valid )  st<=30;
30 : st<=10;
default st<=0;
endcase  

always @ (posedge clk) fifo_dout <= s_udp_dout ;
always @ (posedge clk)  case (st)10:fifo_wr <= s_udp_sof & s_udp_valid & hit ; 20:fifo_wr<=1;default fifo_wr<=0; endcase

endmodule 




