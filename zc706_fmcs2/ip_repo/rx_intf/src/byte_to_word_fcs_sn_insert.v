// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

module byte_to_word_fcs_sn_insert
(
    input wire clk,
    input wire rstn,
    input wire rstn_sn,

    input [7:0]  byte_in,
    input        byte_in_strobe,
    input [15:0] byte_count,
    input [15:0] num_byte,
    input fcs_in_strobe,
    input fcs_ok,
    input wire rx_pkt_sn_plus_one,

    output reg [63:0] word_out,
    output reg word_out_strobe
);

reg [63:0] byte_buf;

reg [7:0] byte_in_dly0;
reg [7:0] byte_in_dly1;
reg byte_in_strobe_dly0;
reg byte_in_strobe_dly1;
reg [15:0] byte_count_dly0;
reg [15:0] byte_count_dly1;
reg [6:0] rx_pkt_sn;

wire [7:0] byte_in_final;
wire byte_in_strobe_final;
wire [15:0] byte_count_final;

assign byte_in_final = (fcs_in_strobe?{fcs_ok,rx_pkt_sn}:byte_in_dly1);
assign byte_in_strobe_final = byte_in_strobe_dly1;
assign byte_count_final = byte_count_dly1;

always @(posedge clk) begin
    if (rstn_sn==1'b0) begin
        rx_pkt_sn<=0;
    end else  begin
        rx_pkt_sn <= (rx_pkt_sn_plus_one?(rx_pkt_sn+1):rx_pkt_sn);
    end 
end

// delay and select to insert fcs
always @(posedge clk) begin
    if (rstn==1'b0) begin
        byte_in_dly0<=0;
        byte_in_dly1<=0;
        byte_in_strobe_dly0<=0;
        byte_in_strobe_dly1<=0;
        byte_count_dly0<=0;
        byte_count_dly1<=0;
    end else  begin
        byte_in_dly0<=byte_in;
        byte_in_dly1<=byte_in_dly0;
        byte_in_strobe_dly0<=byte_in_strobe;
        byte_in_strobe_dly1<=byte_in_strobe_dly0;
        byte_count_dly0<=byte_count;
        byte_count_dly1<=byte_count_dly0;
    end 
end

// byte to word
always @(posedge clk) begin
    if (rstn==1'b0) begin
        byte_buf <= 0;
        word_out <= 0;
        word_out_strobe <= 0;
    end else if (byte_in_strobe_final) begin
        byte_buf[63:56] <= byte_in_final;
        byte_buf[55:0] <= byte_buf[63:8];
        word_out_strobe <= (byte_count_final[2:0]==7?1:0);
        word_out <= byte_count_final[2:0]==7?{byte_in_final, byte_buf[63:8]}:word_out;
    end else if (byte_count_final==num_byte) begin
        word_out_strobe <= (byte_count_final[2:0]==0?0:1);
        case (byte_count_final[2:0])
            3'b001: begin word_out <= {56'b0,byte_buf[63:56]}; end
            3'b010: begin word_out <= {48'b0,byte_buf[63:48]}; end
            3'b011: begin word_out <= {40'b0,byte_buf[63:40]}; end
            3'b100: begin word_out <= {32'b0,byte_buf[63:32]}; end
            3'b101: begin word_out <= {24'b0,byte_buf[63:24]}; end
            3'b110: begin word_out <= {16'b0,byte_buf[63:16]}; end
            3'b111: begin word_out <= { 8'b0,byte_buf[63: 8]}; end
            default: word_out <= word_out;
        endcase
    end else begin
        word_out_strobe <= 0;
    end
end
endmodule
