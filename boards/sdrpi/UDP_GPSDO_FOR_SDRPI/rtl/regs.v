

//from https://blog.csdn.net/mcupro/article/details/9900559
 
// liwei 715713994@qq.com  

 /*
 
 regs#(.w(1),.l(8)) regs (
 clk(clk),
 d(d),
 q(q)
);
 
 */

module regs#(parameter w=1,parameter l=1) (
input clk,
input [w-1:0] d,
output [w-1:0] q
);
 
reg [w-1:0]R [ 0 : l- 1]; 
genvar   i;
generate
        for(i=0;i<l ;i=i+1)
        begin : genN
        always @ (posedge clk)
        if (i==0)R[0]<=d;
        else 
        R[i]<=R[i-1];
        end        
endgenerate
        assign q = R[ l - 1 ];
endmodule  