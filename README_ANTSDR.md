# antsdr for openwifi-hw

## Introduction
[ANTSDR](https://github.com/MicroPhase/antsdr-fw) is a SDR hardware platform based on [xilinx zynq7020](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html) and [adi ad936x](https://www.analog.com/en/products/ad9361.html). It could be used as a traditional SDR device such as PlutoSDR or FMCOMMS2/3/4 with Xilinx evaluation board, and it also be used as hardware platform to support openwifi.
This README file will give the instructions about how to make the openwifi-hw project for antsdr in the [antsdr branch](https://github.com/MicroPhase/openwifi-hw/tree/antsdr) of openwifi-hw project.

## Preparation
- Install Xilinx Vivado (also SDK and HLS) 2018.3.
- Install the evaluation license of [Xilinx Viterbi Decoder](https://www.xilinx.com/products/intellectual-property/viterbi_decoder.html) into Vivado. Otherwise there will be errors when you build the whole FPGA design. 
- clone the openwifi-hw project and checkout to antsdr branch
  ```bash
  git clone https://github.com/MicroPhase/openwifi-hw.git
  git checkout antsdr
  ```
- Prepare environment variables for antsdr
  ```bash
  export XILINX_DIR=your_Xilinx_directory
  export BOARD_NAME=yuor_board_name
  ```
  For example:
  ```bash
  export XILINX_DIR=/opt/Xilinx
  export BOARD_NAME=antsdr
  ```

## Build Instructions
- In Linux, prepare Analgo Devices HDL library (only run once):
  ```
  ./prepare_adi_lib.sh $XILINX_DIR
  ```
- In Linux, prepare Analgo Devices board specific ip (only run once for each board you have):
  ```
  ./prepare_adi_board_ip.sh $XILINX_DIR $BOARD_NAME
  ```
  (Don't need to wait till the building end. When you see "Building ABCD project [...", you can stop it.)

- Change to openwifi-hw/boards/board_name/ directory by "cd" command, start the vivado GUI.
  ```bash
  cd openwifi-hw/boards/antsdr/
  source /opt/Xilinx/Vivado/2018.3/settings64.sh
  vivado
  ```
- In vivado Tcl console, run the tcl script to build to project.
  ```bash
  source ./openwifi.tcl
  ```
  After the build finished, there are three IPs Needs to be upgrade.
- In Vivado:
  ```
  Open Block Design
  Tools --> Report --> Report IP Status
  Generate Bitstream
  (Will take a while)
  File --> Export --> Export Hardware... --> Include bitstream --> OK
  File --> Launch SDK --> OK, then close SDK
  ```
- In Linux:
  ```
  cd openwifi-hw/boards
  ./sdk_update.sh board_name
  git commit -a -m "new fpga img for openwifi (or comments you want to make)"
  git push origin antsdr
  (Above make sure you can pull this new FPGA from openwifi submodule directory: openwifi-hw)
  ```

## Work to be done
The antsdr has RF switch in the front-end, for now, the RF switch is fixed at a higer range, which will isolation the frequency below 3GHz and pass the frequency at 3GHz~6GHz. 
For future work, it can add the rf swicth control in the devicetree, and this will change the rf switch with the frequency change.

