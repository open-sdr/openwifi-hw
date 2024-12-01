# openwifi-hw
<img src="./openwifi-logo.png" width="300">

**openwifi:** Linux mac80211 compatible full-stack IEEE802.11/Wi-Fi design based on SDR (Software Defined Radio).

[[Introduction](#Introduction)]
[[Build FPGA](#Build-FPGA)]
[[Modify IP cores](#Modify-IP-cores)]
[[Simulate IP cores](#Simulate-IP-cores)]
[[Conditional compile by verilog macro](#Conditional-compile-by-verilog-macro)]
[[Migrate openwifi to new ADI release and Vivado](#Migrate-openwifi-to-new-ADI-release-and-Vivado)]
[[GPIO/LED definitions](gpio_led.md)]

[[**Tips for Windows users**](https://github.com/open-sdr/openwifi/discussions/341)]

## Introduction

This repository includes Hardware/FPGA design. To be used together with **openwifi** repository (driver and software tools).

Openwifi code has dual licenses. [AGPLv3](https://github.com/open-sdr/openwifi/blob/master/LICENSE) is the opensource license. For non-opensource and advanced feature license, please contact Filip.Louagie@UGent.be. Openwifi project also leverages some 3rd party modules. It is user's duty to check and follow licenses of those modules according to the purpose/usage. You can find [an example explanation from Analog Devices](https://github.com/analogdevicesinc/hdl/blob/master/LICENSE) for this compound license conditions. [[How to contribute]](https://github.com/open-sdr/openwifi-hw/blob/master/CONTRIBUTING.md).

**Pre-compiled FPGA files:** **openwifi-hw-img** repository, boards/**$BOARD_NAME**/sdk/ has FPGA bit file, ila .ltx file (if ila inserted) and other initilization files.

Environment variable **BOARD_NAME** options:
- **zc706_fmcs2** ([Xilinx ZC706 board](https://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html) + [FMCOMMS2/3/4](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad-fmcomms2.html))
- **zed_fmcs2** ([Xilinx zed board](https://www.xilinx.com/products/boards-and-kits/1-8dyf-11.html) + [FMCOMMS2/3/4](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad-fmcomms2.html)) -- Vivado license **NOT** needed
- **adrv9364z7020** ([ADRV9364-Z7020 + ADRV1CRR-BOB](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adrv9364-z7020.html)) -- Vivado license **NOT** needed
- **adrv9361z7035** ([ADRV9361-Z7035 + ADRV1CRR-BOB/FMC](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/ADRV9361-Z7035.html))
- **zc702_fmcs2** ([Xilinx ZC702 board](https://www.xilinx.com/products/boards-and-kits/ek-z7-zc702-g.html) + [FMCOMMS2/3/4](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad-fmcomms2.html)) -- Vivado license **NOT** needed
- **antsdr** ([MicroPhase](https://github.com/MicroPhase/) enhanced ADALM-PLUTO SDR. [Notes](boards/antsdr/notes.md)) -- Vivado license **NOT** needed
- **antsdr_e200** ([MicroPhase](https://github.com/MicroPhase/) enhanced ADALM-PLUTO SDR (smaller/cheaper). [Notes](boards/antsdr_e200/README.md)) -- Vivado license **NOT** needed
- **sdrpi** ([HexSDR](https://github.com/hexsdr/) SDR in Raspberry Pi size [Notes](boards/sdrpi/notes.md)) -- Vivado license **NOT** needed
- **neptunesdr** Low cost Zynq 7020 + AD9361 board -- Vivado license **NOT** needed
- **zcu102_fmcs2** ([Xilinx ZCU102 board](https://www.xilinx.com/products/boards-and-kits/ek-u1-zcu102-g.html) + [FMCOMMS2/3/4](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad-fmcomms2.html))

## Build FPGA

* Pre-conditions: 
  * Vivado 2021.1 with Vitis. You should have: your_Xilinx_install_directory/Vitis (NOT Vitis_HLS!)
    * You can add Vitis by running "Xilinx Design Tools --> Add Design Tools for Devices 2021.1" from Xilinx program group/menu in your OS start menu, or Help menu of Vivado.
  * Install the evaluation license of [Xilinx Viterbi Decoder](https://www.xilinx.com/products/intellectual-property/viterbi_decoder.html) into Vivado.
  * Ubuntu 18/20/22 LTS release (We test in these OS. Other OS might also work.)
  * Install required packages, such as `sudo apt install libtinfo5`

* Prepare Analgo Devices HDL library (only run once):
```
export XILINX_DIR=your_Xilinx_install_directory
(Example: export XILINX_DIR=/opt/Xilinx. The Xilinx directory should include sth like: Downloads, SDK, Vivado, xic)
./prepare_adi_lib.sh $XILINX_DIR
```
* Prepare Analgo Devices specific ip (only run once for each board you have):
```
export BOARD_NAME=your_board_name
(Example: export BOARD_NAME=zc706_fmcs2)
./prepare_adi_board_ip.sh $XILINX_DIR $BOARD_NAME
(Don't need to wait till the building end. When you see "Building ABCD project [...", you can stop it.)
```
* Get the openofdm_rx into ip directory (only run once after openofdm is udpated):
```
./get_ip_openofdm_rx.sh
```
* Generate ip_repo for the top level FPGA project (will take a while):
```
cd openwifi-hw/boards/$BOARD_NAME/
../create_ip_repo.sh $XILINX_DIR
```
* In the Vivado
```
source ./openwifi.tcl
Click "Generate Bitstream" in the Vivado GUI.
(Will take a while)
File --> Export --> Export Hardware --> Next --> Include bitstream --> Next --> Next --> Finish
```
* In Linux, store the FPGA files to a specific directory:
```
cd openwifi-hw/boards
./sdk_update.sh $BOARD_NAME $OPENWIFI_HW_IMG_DIR
```
Above command will store the FPGA img (.xsa .ltx) and the related git info into another directory $OPENWIFI_HW_IMG_DIR that can be picked up by openwifi software building environment later on. Please check README of the openwifi repository.

## Modify IP cores

IP core project files are in "ip/ip_name" directory. "ip_name" example: xpu, tx_intf, etc. To create the IP project and do necessary work (modification, simulation, etc.), go to the ip/ip_name directory, then:
```
../create_vivado_proj.sh $XILINX_DIR ip_name.tcl
```
To apply your new/modified IP to the top level FPGA project, start from "../create_ip_repo.sh $XILINX_DIR" in the board directory (Build FPGA section) to integrate your modified IP to the board FPGA design.

If your IP modification is complicated and encounter error while running create_ip_repo.sh, you should check create_ip_repo.sh/ip_repo_gen.tcl/etc, understand and modify them accordingly (for example to include your new added files).

**Change the baseband clock:**

![](./bb-clk.jpg)

By default, 100MHz baseband clock is used. You can change the baseband clock by changing the NUM_CLK_PER_US at the beginning of openwifi.tcl. Available options:  240/100MHz for zcu102; 100/200MHz for zc706 and adrv9361z7035; 100MHz for the rest. Then re-run openwifi.tcl to create the new FPGA project.

## Simulate IP cores

* Create the ip core project in Vivado. To achieve this, you need to follow the "Modify IP cores" section to create the IP's Vivado project.
* Normally you should see the top level testbench (..._tb.v) of that ip core in the Vivado "Sources" window (take openofdm_rx as example):

        Go to the openofdm_rx IP directory, then run:
        ./create_vivado_proj.sh $XILINX_DIR openofdm_rx.tcl 
        Then in Vivado
        Sources --> Simulation Sources --> sim_1 --> dot11_tb
* To run the simulation, click "Run Simulation" --> "Run Behavoiral Simulation" under the "SIMULATION" in the "PROJECT MANAGER" window. It will take quite long time for the 1st time run due to the sub-ip-core compiling. Fortunately the sub-ip-core compiling is a time consuming step that occurs only one time.
* When the previous step is finished, you should see a simulation window displays many variable names and waveforms. Now click the small triangle, which points to the right and has "Run All (F3)" hints, on top to start the simulation.
* Please check the ..._tb.v to see how do we use $fopen, $fscanf and $fwrite to read test vectors and save the variables for checking later. Of course you can also check everything in the waveform window. 
* The openofdm_rx_pre_def.v also includes important definitions for the simulation.
* After you modify some design files, just click the small circle with arrow, which has "Relaunch Simulation" hints, on top to re-launch the simulation.
* You can always drag the signals you need from the "SIMULATION" --> "Scope" window to the waveform window, and relaunch the simulation to check those signals' waveform. An example:
        
        SIMULATION --> Scope --> Name --> dot11_tb --> dot11_inst --> ofdm_decoder_inst --> viterbi_inst

## Conditional compile by verilog macro

While working on a stand alone IP, the create_vivado_proj.sh could accept more arguments. Some arguments will be converted to verilog macro pre-defines into ip_name_pre_def.v, which can be included by IP source files to enable/disable some code blocks. Check more info by running create_vivado_proj.sh:
```
usage:
Need at least 2 arguments: $XILINX_DIR $TCL_FILENAME
More arguments (max 7) will be passed as arguments to the .tcl script to create ip_name_pre_def.v
Among these max 7 arguments:
- the 1st:     BOARD_NAME (antsdr zc706_fmcs2 zed_fmcs2 zc702_fmcs2 adrv9361z7035 adrv9364z7020 zcu102_fmcs2)
- the 2nd:     NUM_CLK_PER_US (for example: input 100 for 100MHz)
- the 3rd-7th: User pre defines (assume it is ABC) for conditional compiling. Will be `define IP_NAME_ABC in ip_name_pre_def.v
  - the 3rd exception: in the case of openofdm_rx, it indicates SAMPLE_FILE for simulation. Can be changed later in openofdm_rx_pre_def.v
```
While working on the top level FPGA project, the same verilog macro pre-defines should also be specified when running create_ip_repo.sh if you want the IP to be conditional compiled in the same way when you working on it in stand alone mode (when the IP project is created by create_vivado_proj.sh). Check more info by running create_ip_repo.sh:
```
usage:
create_ip_repo.sh $XILINX_DIR
or
create_ip_repo.sh $XILINX_DIR $IP1_NAME $DEF1 $DEF2 ... $IP2_NAME $DEF1 ...
 -IP_NAME: only xpu/tx_intf/rx_intf/openofdm_tx/openofdm_rx/side_ch are allowed
 -   DEFx: will be "`define IP_NAME_DEFx" in ip_name_pre_def.v for $IP_NAME
```
Example of enabling all ILA/DEBUG macros in all IPs:
```
./create_ip_repo.sh $XILINX_DIR xpu ENABLE_DBG tx_intf ENABLE_DBG rx_intf ENABLE_DBG openofdm_tx ENABLE_DBG openofdm_rx ENABLE_DBG side_ch ENABLE_DBG
```

## Migrate openwifi to new ADI release and Vivado

There are two possible ways to upgrade openwifi design to new ADI release and Vivado.

Method 1: Vivado auto upgrading
- Create the openwifi design in the old/current Vivado version
- Open the openwifi project in the new/target Vivado version
  - Let Vivado do the upgrading
- After upgrading, the system.bd is the new bd file for the new/target Vivado version
- Export the openwifi project in the new/target Vivado as .tcl file
  - Compare this new .tcl file with the original openwifi.tcl to find out what need to be changed
  - You can check our commit on openwifi.tcl to find out what we have changed by the comparison

Method 2: Start from new Vivado and ADI HDL reference design, then add openwifi IP
- Create the openwifi design in the old/current Vivado version
- Open the openwifi design with the new/target Vivado version
- Use write_bd_tcl to write openwifi_ip Hierarchy to a .tcl
  ```
  write_bd_tcl -hier_blks [get_bd_cells /hier_mig] ./mig_hierarchy.tcl
  ```
- Create/open the new (or your own) ADI HDL reference design with the new/target Vivado version, then:
  ```
  source ./mig_hierarchy.tcl
  create_hier_cell_hier_mig / my_new_hierarchy
  ```
- The openwifi_ip sub-block (Hierarchy) should appear in your new design with new Vivado version.

Main reference: Vivado Design Suite User Guide: Designing IP Subsystems Using IP Integrator (UG994). Main command in that UG:
```
write_bd_tcl -hier_blks [get_bd_cells /hier_mig] ./mig_hierarchy.tcl
source ./mig_hierarchy.tcl
create_hier_cell_hier_mig / my_new_hierarchy
```

***Note: openwifi adds necessary modules/modifications on top of [Analog Devices HDL reference design](https://github.com/analogdevicesinc/hdl). For general issues, Analog Devices wiki pages would be helpful!***

***Notes: The 802.11 ofdm receiver is based on [openofdm project](https://github.com/jhshi/openofdm). You can find our improvements in our openofdm fork (dot11zynq branch) which is mapped to ip/openofdm_rx.***
