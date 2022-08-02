- style: flip -- the line/led flip per rising edge of the FPGA signal event
- style: raw  -- the line/led always reflects the raw 1/0 state of the FPGA signal

## adrv9361z7035

type     |voltage |style|name on board    |name in schemetic|name in FPGA code|comment
---------|--------|-----|-----------------|-----------------|-----------------|-------
led/gpio |LVCMOS25|flip |P2,4,  GPIO_3 DS6|LED_GPIO_3       |cycle_start0_led, xpu.v  |cycle start
led/gpio |LVCMOS25|flip |P13,3, GPIO_2 DS5|LED_GPIO_2       |sig_valid_led, xpu.v     |receiver detects a valid packet SIGNAL field
led/gpio |LVCMOS25|flip |P13,4, GPIO_1 DS4|LED_GPIO_1       |phy_tx_started_led, xpu.v|start to transmit a packet
gpio     |LVCMOS25|raw  |P2,58            |IO_L23_13_JX2_N  |slice_en[0], xpu.v       |gate of queue0. 0/1: close/open
gpio     |LVCMOS25|raw  |P2,56            |IO_L23_13_JX2_P  |slice_en[1], xpu.v       |gate of queue1. 0/1: close/open
gpio     |LVCMOS25|raw  |P2,54            |IO_L21_13_JX2_N  |slice_en[2], xpu.v       |gate of queue2. 0/1: close/open
gpio     |LVCMOS25|raw  |P2,52            |IO_L21_13_JX2_P  |slice_en[3], xpu.v       |gate of queue3. 0/1: close/open
gpio     |LVCMOS25|flip |P2,42            |IO_L17_13_JX2_P  |cycle_start0_led, xpu.v  |cycle start
gpio     |LVCMOS25|flip |P2,46            |IO_L19_13_JX2_P  |sig_valid_led, xpu.v     |receiver detects a valid packet SIGNAL field
gpio     |LVCMOS25|flip |P2,48            |IO_L19_13_JX2_N  |phy_tx_started_led, xpu.v|start to transmit a packet

## zcu102_fmcs2

type     |voltage |style|name on board    |name in schemetic|name in FPGA code|comment
---------|--------|-----|-----------------|-----------------|-----------------|-------
led      |LVCMOS33|raw  |PL LEDs LED0 DS38|GPIO_LED_0       |locked of clk_wiz_0|RF-BB clk locked
led      |LVCMOS33|flip |PL LEDs LED1 DS37|GPIO_LED_1       |tx_itrpt_led, tx_intf.v  |interrupt after pkt sent by FPGA
led      |LVCMOS33|flip |PL LEDs LED2 DS39|GPIO_LED_2       |tx_end_led, tx_intf.v|openofdm_tx finishes 1 pkt I/Q gen
led      |LVCMOS33|flip |PL LEDs LED3 DS40|GPIO_LED_3       |fcs_ok_led, rx_intf.v|openofdm_rx gives CRC OK for 1 pkt
led      |LVCMOS33|flip |PL LEDs LED4 DS41|GPIO_LED_4       |demod_is_ongoing_led, xpu.v|openofdm_rx working on 1 pkt
gpio     |LVCMOS33|raw  |PL PMOD 1 J87 1  |PMOD1_0          |tx_bb_is_ongoing, xpu.v       |pkt I/Q sending at bb
gpio     |LVCMOS33|raw  |PL PMOD 1 J87 3  |PMOD1_1          |tx_rf_is_ongoing, xpu.v       |pkt signal at antenna (delayed to bb)
gpio     |LVCMOS33|raw  |PL PMOD 1 J87 5  |PMOD1_2          |demod_is_ongoing, openofdm_rx.v|openofdm_rx working on 1 pkt
