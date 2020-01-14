/*
 * openofdm_tx - TODO
 *
 * Xianjun Jiao xianjun.jiao@ugent.be
 * Michael Tetemke Mehari mehari.michael@gmail.com
 */

module openofdm_tx #
(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 7
)
(
    input  wire        clk,
    input  wire        phy_tx_arestn,

    input  wire        phy_tx_start,
    output wire        phy_tx_done,
    output wire        phy_tx_started,

    input  wire [63:0] bram_din,
    output wire [9:0] bram_addr,

    input  wire        result_iq_hold,
    output wire        result_iq_valid,
    output wire [15:0] result_i,
    output wire [15:0] result_q,

    input  wire s00_axi_aclk,
    input  wire s00_axi_aresetn,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input  wire [2 : 0] s00_axi_awprot,
    input  wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input  wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input  wire s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input  wire [2 : 0] s00_axi_arprot,
    input  wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input  wire s00_axi_rready
);

    // reg0~19 for config write; from reg20 for reading status
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg0;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg1;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg2;
    /*
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg3; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg4; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg5; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg6; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg7; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg8;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg9; //
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg10;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg11;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg12;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg13;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg14;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg15;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg16;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg17;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg18;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg19; */
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg20; // read openofdm rx core internal state
    /*
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg21;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg22;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg23;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg24;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg25;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg26;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg27;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg28;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg29;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg30;
    wire [(C_S00_AXI_DATA_WIDTH-1):0] slv_reg31;
    */

dot11_tx dot11_tx (
    .clk(clk),
    .phy_tx_arest((~phy_tx_arestn)|slv_reg0[0]),

    .phy_tx_start(phy_tx_start),
    .phy_tx_done(phy_tx_done),
    .phy_tx_started(phy_tx_started),

    .init_pilot_scram_state(slv_reg1[6:0]),
    .init_data_scram_state(slv_reg2[6:0]),

    .bram_din(bram_din),
    .bram_addr(bram_addr),

    .result_iq_ready(~result_iq_hold),
    .result_iq_valid(result_iq_valid),
    .result_i(result_i),
    .result_q(result_q)
);

//assign bram_wen = 0;

openofdm_tx_s_axi # (
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) openofdm_tx_s_axi_i (
        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready),

        .SLV_REG0(slv_reg0),
        .SLV_REG1(slv_reg1),
        .SLV_REG2(slv_reg2), /*,
        .SLV_REG3(slv_reg3),
        .SLV_REG4(slv_reg4),
        .SLV_REG5(slv_reg5),
        .SLV_REG6(slv_reg6),
        .SLV_REG7(slv_reg7),
        .SLV_REG8(slv_reg8),
        .SLV_REG9(slv_reg9),
        .SLV_REG10(slv_reg10),
        .SLV_REG11(slv_reg11),
        .SLV_REG12(slv_reg12),
        .SLV_REG13(slv_reg13),
        .SLV_REG14(slv_reg14),
        .SLV_REG15(slv_reg15),
        .SLV_REG16(slv_reg16),
        .SLV_REG17(slv_reg17),
        .SLV_REG18(slv_reg18),
        .SLV_REG19(slv_reg19),*/
        .SLV_REG20(slv_reg20)/*
        .SLV_REG21(slv_reg21),
        .SLV_REG22(slv_reg22),
        .SLV_REG23(slv_reg23),
        .SLV_REG24(slv_reg24),
        .SLV_REG25(slv_reg25),
        .SLV_REG26(slv_reg26),
        .SLV_REG27(slv_reg27),
        .SLV_REG28(slv_reg28),
        .SLV_REG29(slv_reg29),
        .SLV_REG30(slv_reg30),
        .SLV_REG31(slv_reg31)*/
    );

endmodule
