`timescale 1ns/100ps

module system_top (
  output MDIO_PHY_mdc,
  inout MDIO_PHY_mdio_io,
  input [3:0] RGMII_rd,
  input RGMII_rx_ctl,
  input RGMII_rxc,
  output [3:0] RGMII_td,
  output RGMII_tx_ctl,
  output RGMII_txc,

  inout [14:0] ddr_addr,
  inout [2:0] ddr_ba,
  inout ddr_cas_n,
  inout ddr_ck_n,
  inout ddr_ck_p,
  inout ddr_cke,
  inout ddr_cs_n,
  inout [3:0] ddr_dm,
  inout [31:0] ddr_dq,
  inout [3:0] ddr_dqs_n,
  inout [3:0] ddr_dqs_p,
  inout ddr_odt,
  inout ddr_ras_n,
  inout ddr_reset_n,
  inout ddr_we_n,

  inout fixed_io_ddr_vrn,
  inout fixed_io_ddr_vrp,
  inout [53:0] fixed_io_mio,
  inout fixed_io_ps_clk,
  inout fixed_io_ps_porb,
  inout fixed_io_ps_srstb,

  inout iic_scl,
  inout iic_sda,

  input rx_clk_in_p,
  input rx_clk_in_n,
  input rx_frame_in_p,
  input rx_frame_in_n,
  input [5:0] rx_data_in_p,
  input [5:0] rx_data_in_n,
  output tx_clk_out_p,
  output tx_clk_out_n,
  output tx_frame_out_p,
  output tx_frame_out_n,
  output [5:0] tx_data_out_p,
  output [5:0] tx_data_out_n,

  output enable,
  output txnrx,
  inout gpio_resetb,
  inout gpio_sync,
  inout gpio_en_agc,
  inout [3:0] gpio_ctl,
  input [7:0] gpio_status,

  output spi_csn,
  output spi_clk,
  output spi_mosi,
  input spi_miso,

  output pll_le,
  output pll_clk,
  output pll_mosi,
  input i_clk
);

  wire [63:0] gpio_i;
  wire [63:0] gpio_o;
  wire [63:0] gpio_t;

  // GPIO[46:40] are the AD9361 control lines on the PlutoSky R2 schematic.
  ad_iobuf #(.DATA_WIDTH(7)) i_ad9361_gpio (
    .dio_t(gpio_t[46:40]),
    .dio_i(gpio_o[46:40]),
    .dio_o(gpio_i[46:40]),
    .dio_p({gpio_resetb, gpio_sync, gpio_en_agc, gpio_ctl})
  );

  assign gpio_i[63:47] = gpio_o[63:47];
  assign gpio_i[39:0] = gpio_o[39:0];

  system_wrapper i_system_wrapper (
    .MDIO_PHY_mdc(MDIO_PHY_mdc),
    .MDIO_PHY_mdio_io(MDIO_PHY_mdio_io),
    .RGMII_rd(RGMII_rd),
    .RGMII_rx_ctl(RGMII_rx_ctl),
    .RGMII_rxc(RGMII_rxc),
    .RGMII_td(RGMII_td),
    .RGMII_tx_ctl(RGMII_tx_ctl),
    .RGMII_txc(RGMII_txc),
    .ddr_addr(ddr_addr),
    .ddr_ba(ddr_ba),
    .ddr_cas_n(ddr_cas_n),
    .ddr_ck_n(ddr_ck_n),
    .ddr_ck_p(ddr_ck_p),
    .ddr_cke(ddr_cke),
    .ddr_cs_n(ddr_cs_n),
    .ddr_dm(ddr_dm),
    .ddr_dq(ddr_dq),
    .ddr_dqs_n(ddr_dqs_n),
    .ddr_dqs_p(ddr_dqs_p),
    .ddr_odt(ddr_odt),
    .ddr_ras_n(ddr_ras_n),
    .ddr_reset_n(ddr_reset_n),
    .ddr_we_n(ddr_we_n),
    .enable(enable),
    .fixed_io_ddr_vrn(fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp(fixed_io_ddr_vrp),
    .fixed_io_mio(fixed_io_mio),
    .fixed_io_ps_clk(fixed_io_ps_clk),
    .fixed_io_ps_porb(fixed_io_ps_porb),
    .fixed_io_ps_srstb(fixed_io_ps_srstb),
    .gpio_i(gpio_i),
    .gpio_o(gpio_o),
    .gpio_status(gpio_status),
    .gpio_t(gpio_t),
    .hdmi_data(),
    .hdmi_data_e(),
    .hdmi_hsync(),
    .hdmi_out_clk(),
    .hdmi_vsync(),
    .iic_main_scl_io(iic_scl),
    .iic_main_sda_io(iic_sda),
    .rx_clk_in_n(rx_clk_in_n),
    .rx_clk_in_p(rx_clk_in_p),
    .rx_data_in_n(rx_data_in_n),
    .rx_data_in_p(rx_data_in_p),
    .rx_frame_in_n(rx_frame_in_n),
    .rx_frame_in_p(rx_frame_in_p),
    .spdif(),
    .spi0_clk_i(1'b0),
    .spi0_clk_o(spi_clk),
    .spi0_csn_0_o(spi_csn),
    .spi0_csn_1_o(),
    .spi0_csn_2_o(),
    .spi0_csn_i(1'b1),
    .spi0_sdi_i(spi_miso),
    .spi0_sdo_i(1'b0),
    .spi0_sdo_o(spi_mosi),
    .spi1_clk_i(1'b0),
    .spi1_clk_o(),
    .spi1_csn_0_o(),
    .spi1_csn_1_o(),
    .spi1_csn_2_o(),
    .spi1_csn_i(1'b1),
    .spi1_sdi_i(1'b0),
    .spi1_sdo_i(1'b0),
    .spi1_sdo_o(),
    .tdd_sync_i(1'b0),
    .tdd_sync_o(),
    .tdd_sync_t(),
    .tx_clk_out_n(tx_clk_out_n),
    .tx_clk_out_p(tx_clk_out_p),
    .tx_data_out_n(tx_data_out_n),
    .tx_data_out_p(tx_data_out_p),
    .tx_frame_out_n(tx_frame_out_n),
    .tx_frame_out_p(tx_frame_out_p),
    .txnrx(txnrx),
    .up_enable(gpio_o[47]),
    .up_txnrx(gpio_o[48])
  );

  reg [2:0] cnt;
  reg adf4001_spi_clk;
  always @(posedge i_clk) begin
    cnt <= cnt + 1'b1;
    if (cnt == 3'd3)
      adf4001_spi_clk <= 1'b1;
    else if (cnt == 3'd7) begin
      adf4001_spi_clk <= 1'b0;
      cnt <= 3'b0;
    end
  end

  ADF4001_init i_adf4001_init (
    .clk(adf4001_spi_clk),
    .rst_n(1'b1),
    .SPI_LE(pll_le),
    .SPI_SCLK(pll_clk),
    .SPI_MOSI(pll_mosi)
  );
endmodule
