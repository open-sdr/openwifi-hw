#sdrpi for openwifi-hw

## Introduction
[SDRPi](https://github.com/hexsdr/) is a SDR hardware platform based on [xilinx zynq7020](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html) and [adi ad936x](https://www.analog.com/en/products/ad9361.html). 

SDRPi is a smart and powerful SDR platform according Raspberry Pi size.Hareware feature is : ZYNQ 7Z020CLG400 ,1GB DDR3 memory fo PS, 1G Ethernet RJ45 for PS,1G Ethernet RJ45 for PL, USB OTG(act as USB host or USB SLAVE ), dual USB uarts for PS and PL,on board USB to JTAG debuger,TF card , bootable QSPI FLASH and also 27 IOs from PL bank; AD9361 RF design is based FMCOMMS3 with RF amplifier.it also has a Ublox m8t GPS module and 40MHZ VCXO.
It could be used as a traditional SDR device such as PlutoSDR or FMCOMMS2/3/4 with Xilinx evaluation board, and it also be used as hardware platform to support openwifi.