# openwifi-hw
<img src="./openwifi-logo.png" width="300">

**openwifi:** Linux mac80211 compatible full-stack IEEE802.11/Wi-Fi design based on SDR (Software Defined Radio).

This repository includes Hardware/FPGA design. To be used together with [openwifi driver and software repository](https://github.com/open-sdr/openwifi).

Openwifi code has dual licenses. AGPLv3 is the opensource license. For non-opensource license, please contact Filip.Louagie@UGent.be. Openwifi project also leverages some 3rd party modules. It is user's duty to check and follow licenses of those modules according to the purpose/usage. You can find [an example explanation from Analog Devices](https://github.com/analogdevicesinc/hdl/blob/master/LICENSE) for this compound license conditions. [[How to contribute]](https://github.com/open-sdr/openwifi-hw/blob/master/CONTRIBUTING.md).

**Pre-compiled FPGA files:**

Directory boards/board_name/sdk/ includes FPGA bit file and other necessary SDK files for openwifi driver and software repository.

board_name|actual boards used
-------|-------
zc706_fmcs2|Xilinx ZC706 dev board + FMCOMMS2/3/4
adrv9361z7035|ADRV9361Z7035 SOM + ADRV1CRR-BOB carrier board
adrv9361z7035_fmc|ADRV9361Z7035 SOM + ADRV1CRR-FMC carrier board

**Build FPGA:** (Xilinx Vivado (also SDK and HLS) 2017.4.1 is needed. Example instructions are verified on Ubuntu 16/18)

* In Linux:

```
export XILINX_DIR=your_Xilinx_directory
git submodule init adi-hdl
git submodule update adi-hdl
(Will take a while)
cd adi-hdl/library
git reset --hard 2018_r1
source $XILINX_DIR/Vivado/2017.4/settings64.sh
make
(Will take a while)
```
* Open Vivado, then in Vivado Tcl Console:
```
export BOARD_NAME=your_board_name
cd boards/$BOARD_NAME/
source ./openwifi.tcl
```
* In Vivado:
```
Open Block Desing
Tools --> Report --> Report IP Status
Generate Bitstream
(Will take a while)
File --> Export --> Export Hardware... --> Include bitstream --> OK
File --> Launch SDK --> OK, then close SDK
```
* In Linux:
```
cp openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.sdk/system_top_hw_platform_0 ./sdk/ -rf
cp openwifi_$BOARD_NAME/openwifi_$BOARD_NAME.runs/impl_1/system_top.ltx ./sdk/
(system_top.ltx will be needed if you want to debug FPGA via ila probe later)
git commit -a -m "new fpga img for openwifi (or comments you want to make)"
git push
(Above make sure you can pull this new FPGA from openwifi submodule)
```
**Modify IP cores:**

IP core source files are in "ip" directory. After IP is modified, export the IP core into "ip_repo" directory. Then re-run the full FPGA build procedure.

* ***IP cores designed by HLS (mixer_ddc and mixer_duc). mixer_ddc as example:***

```
Create a project "mixer_ddc" with file in ip/mixer_ddc/src directory in Vivado HLS.
During creating, set mixer_ddc as top, select zc706 board as "Part" and set Clock Period 5 (means 200MHz).
Run C synthesis.
Click solution1, Solution --> Export RTL
Copy project_directory/solution1/impl/ip to ip_repo/mixer_ddc
```
* ***IP cores designed by block-diagram (ddc_bank_core, fifo32_1clk, etc). fifo32_1clk as example:***

```
Open Vivado, then in Vivado Tcl Console:
cd ip/fifo32_1clk
source ./fifo32_1clk.tcl
In Vivado:
Open Block Design
Tools --> Report --> Report IP Status
Tools --> Create and Package New IP... --> Next --> Package a block design from ... --> Next --> set "ip_repo/fifo32_1clk" as target directory --> Next --> OK -- Finish
In new opened temporary project: Review and Package --> Package IP --> Yes
```
* ***IP cores designed by verilog (rx_intf, xpu, etc). xpu as example:***

```
Open Vivado, then in Vivado Tcl Console:
cd ip/xpu
source ./xpu.tcl
In Vivado:
Tools --> Report --> Report IP Status
Tools --> Create and Package New IP... --> Next --> Next --> set "ip_repo/xpu" as target directory --> Next --> OK -- Finish
In new opened temporary project: Review and Package --> Package IP --> Yes
```
* ***openofdm_rx:***
You need to apply the evaluation license of [Xilinx Viterbi Decoder](https://www.xilinx.com/products/intellectual-property/viterbi_decoder.html) and install on your PC firstly.

  * In Linux:
  
        cd ip/
        git submodule init openofdm_rx
        git submodule update openofdm_rx
        cd openofdm_rx
        git checkout dot11zynq
        git pull
  * Open Vivado, then in Vivado Tcl Console:
        
        cd ip/openofdm_rx
        source ./openofdm_rx.tcl
  * In Vivado:
  
        Tools --> Report --> Report IP Status
        Tools --> Create and Package New IP... --> Next --> Next --> set "ip_repo/openofdm_rx" as target directory --> Next --> OK -- Finish
        In new opened temporary project: Review and Package --> Package IP --> Yes

***Note: openwifi adds necessary modules/modifications on top of [Analog Devices HDL reference design](https://github.com/analogdevicesinc/hdl). For general issues, Analog Devices wiki pages would be helpful!***

***Notes: The 802.11 ofdm receiver is based on [openofdm project](https://github.com/jhshi/openofdm). You can find our patch (bug-fix, improvement) [here](https://github.com/open-sdr/openofdm/tree/dot11zynq) which is mapped to ip/openofdm_rx.***
