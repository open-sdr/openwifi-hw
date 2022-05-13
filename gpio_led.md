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

