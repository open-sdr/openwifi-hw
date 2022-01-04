
`timescale 1 ns / 1 ps

// `define DEBUG_PREFIX (*mark_debug="true",DONT_TOUCH="TRUE"*)
`define DEBUG_PREFIX

module cw_exp #
(

)
(
    input wire  clk,
	input wire  rstn,
    input wire tx_try_complete,
    input wire [31:0] cw_combined,
    input wire start_retrans,
    input wire [1:0] tx_queue_idx,
     `DEBUG_PREFIX output reg [3:0] cw_exp
);
(* mark_debug = "true", DONT_TOUCH = "TRUE" *) 
reg [3:0] cw_min;
(* mark_debug = "true", DONT_TOUCH = "TRUE" *) 
reg [3:0] cw_max;
reg [1:0] tx_queue_idx_reg;
(* mark_debug = "true", DONT_TOUCH = "TRUE" *) 
reg cw_update;

always @(tx_queue_idx,cw_combined) begin
    case(tx_queue_idx)
        2'b00:  begin 
                    cw_min=cw_combined[3:0]; 
                    cw_max=cw_combined[7:4]; 
                end 
        2'b01:  begin 
                    cw_min=cw_combined[11:8];
                    cw_max=cw_combined[15:12]; 
                end
        2'b10:  begin 
                    cw_min=cw_combined[19:16];
                    cw_max=cw_combined[23:20]; 
                end    
        2'b11:  begin
                    cw_min=cw_combined[27:24]; 
                    cw_max=cw_combined[31:28];                    
                end            
        default:begin
                    cw_min=cw_combined[3:0]; 
                    cw_max=cw_combined[7:4];                 
                end     
    endcase
end

always @( posedge clk )
begin
    if ( rstn == 0 )
    begin
        cw_exp <= cw_min;
    end else begin
        if (cw_update==1 || tx_try_complete) begin
            cw_exp <= cw_min ; 
        end else begin
            if (start_retrans && (cw_exp < cw_max)) begin
                cw_exp <= cw_exp + 1'b1; 
            end else begin
                cw_exp <= cw_exp ;
            end
        end
    end
end

always @( posedge clk )
begin
if ( rstn == 0 )
    begin
        tx_queue_idx_reg <= 0;
        cw_update <= 0;
    end else begin
        tx_queue_idx_reg <= tx_queue_idx ;
        if(tx_queue_idx_reg != tx_queue_idx) begin
            cw_update <= 1;
        end else begin
            cw_update <= 0;
        end
    end
end 
endmodule