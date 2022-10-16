# constraints (pzsdr1.b)
# ad9361

set_property  -dict {PACKAGE_PIN  Y16  IOSTANDARD LVCMOS25} [get_ports enable]                            ; ## IO_L10P_T1_AD11P_35          U1,K19,IO_L10_35_ENABLE
set_property  -dict {PACKAGE_PIN  W14  IOSTANDARD LVCMOS25} [get_ports txnrx]                             ; ## IO_L11N_T1_SRCC_35           U1,L17,IO_L11_35_TXNRX

set_property  -dict {PACKAGE_PIN  W16  IOSTANDARD LVCMOS25} [get_ports gpio_status[0]]                    ; ## IO_L19P_T3_35                U1,H15,IO_L19_35_CTRL_OUT0
set_property  -dict {PACKAGE_PIN  W18  IOSTANDARD LVCMOS25} [get_ports gpio_status[1]]                    ; ## IO_L19N_T3_VREF_35           U1,G15,IO_L19_35_CTRL_OUT1
set_property  -dict {PACKAGE_PIN  Y18  IOSTANDARD LVCMOS25} [get_ports gpio_status[2]]                    ; ## IO_L20P_T3_AD6P_35           U1,K14,IO_L20_35_CTRL_OUT2
set_property  -dict {PACKAGE_PIN  U17  IOSTANDARD LVCMOS25} [get_ports gpio_status[3]]                    ; ## IO_L20N_T3_AD6N_35           U1,J14,IO_L20_35_CTRL_OUT3
set_property  -dict {PACKAGE_PIN  V18  IOSTANDARD LVCMOS25} [get_ports gpio_status[4]]                    ; ## IO_L21P_T3_DQS_AD14P_35      U1,N15,IO_L21_35_CTRL_OUT4
set_property  -dict {PACKAGE_PIN  V17  IOSTANDARD LVCMOS25} [get_ports gpio_status[5]]                    ; ## IO_L21N_T3_DQS_AD14N_35      U1,N16,IO_L21_35_CTRL_OUT5
set_property  -dict {PACKAGE_PIN  R16  IOSTANDARD LVCMOS25} [get_ports gpio_status[6]]                    ; ## IO_L22P_T3_AD7P_35           U1,L14,IO_L22_35_CTRL_OUT6
set_property  -dict {PACKAGE_PIN  T17  IOSTANDARD LVCMOS25} [get_ports gpio_status[7]]                    ; ## IO_L22N_T3_AD7N_35           U1,L15,IO_L22_35_CTRL_OUT7
set_property  -dict {PACKAGE_PIN  W19  IOSTANDARD LVCMOS25} [get_ports gpio_ctl[0]]                       ; ## IO_L23P_T3_34                U1,N17,IO_L23_34_CTRL_IN0
set_property  -dict {PACKAGE_PIN  V20  IOSTANDARD LVCMOS25} [get_ports gpio_ctl[1]]                       ; ## IO_L23N_T3_34                U1,P18,IO_L23_34_CTRL_IN1
set_property  -dict {PACKAGE_PIN  W20  IOSTANDARD LVCMOS25} [get_ports gpio_ctl[2]]                       ; ## IO_L24P_T3_34                U1,P15,IO_L24_34_CTRL_IN2
set_property  -dict {PACKAGE_PIN  Y19  IOSTANDARD LVCMOS25} [get_ports gpio_ctl[3]]                       ; ## IO_L24N_T3_34                U1,P16,IO_L24_34_CTRL_IN3
set_property  -dict {PACKAGE_PIN  W15  IOSTANDARD LVCMOS25} [get_ports gpio_en_agc]                       ; ## IO_L11P_T1_SRCC_35           U1,L16,IO_L11_35_EN_AGC
set_property  -dict {PACKAGE_PIN  V15  IOSTANDARD LVCMOS25} [get_ports gpio_sync]                         ; ## IO_L10N_T1_AD11N_35          U1,J19,IO_L10_35_SYNC_IN
set_property  -dict {PACKAGE_PIN  Y14  IOSTANDARD LVCMOS25} [get_ports gpio_resetb]                       ; ## IO_0_35                      U1,G14,IO_00_35_AD9364_RST
set_property  -dict {PACKAGE_PIN  R19  IOSTANDARD LVCMOS25} [get_ports gpio_clksel]                       ; ## IO_0_34 NO USE                     U1,R19,IO_00_34_AD9364_CLKSEL

set_property  -dict {PACKAGE_PIN  U15  IOSTANDARD LVCMOS25  PULLTYPE PULLUP} [get_ports spi_csn]          ; ## IO_L23P_T3_35                U1,M14,IO_L23_35_SPI_ENB
set_property  -dict {PACKAGE_PIN  V13  IOSTANDARD LVCMOS25} [get_ports spi_clk]                           ; ## IO_L23N_T3_35                U1,M15,IO_L23_35_SPI_CLK
set_property  -dict {PACKAGE_PIN  T16  IOSTANDARD LVCMOS25} [get_ports spi_mosi]                          ; ## IO_L24P_T3_AD15P_35          U1,K16,IO_L24_35_SPI_DI
set_property  -dict {PACKAGE_PIN  T15  IOSTANDARD LVCMOS25} [get_ports spi_miso]                          ; ## IO_L24N_T3_AD15N_35          U1,J16,IO_L24_35_SPI_DO

set_property  -dict {PACKAGE_PIN  N18  IOSTANDARD LVCMOS25} [get_ports clkout_in]                         ; ## IO_25_35                     U1,J15,IO_25_35_AD9364_CLKOUT

# iic

set_property  -dict {PACKAGE_PIN  T11   IOSTANDARD LVCMOS25 PULLTYPE PULLUP} [get_ports iic_scl]           ; ## IO_L22N_T3_13                U1,W6,SCL,JX2,17,I2C_SCL
set_property  -dict {PACKAGE_PIN  T10   IOSTANDARD LVCMOS25 PULLTYPE PULLUP} [get_ports iic_sda]           ; ## IO_L22P_T3_13                U1,V6,SDA,JX2,19,I2C_SDA