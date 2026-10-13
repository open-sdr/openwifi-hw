<!--
SPDX-FileCopyrightText: 2026 Fu Wenbo
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# PlutoSky R2 OpenWiFi hardware port

This board definition targets PlutoSky R2 with `xc7z020clg484-2`, DDR3,
AD9361 LVDS, GEM0 RGMII Ethernet, and the board ADF4001.

`src/system.bd` retains the OpenWiFi AXI, DMA, interrupt, and register layout
from `zc702_fmcs2`. `retarget_system.tcl` applies the PlutoSky R2 PS7, clock
and Ethernet configuration when the project is recreated. It is picked up by
the shared `boards/openwifi.tcl` hook, so this board does not fork that
script.

The ADI HDL IP comes from the `adi-hdl` submodule, exactly like every other
board. Populate the submodules and package the IP that the block design uses
before building:

```bash
git submodule update --init adi-hdl ip/openofdm_rx
git -C adi-hdl checkout 2022_R2
./prepare_adi_lib.sh <XILINX_DIR>                    # Linux
.\prepare_adi_lib.ps1 -Vivado <path to vivado.bat>   # Windows
```

`adi-hdl` has to be at `2022_R2`. The commit this repository pins is from
January 2020, and its packaging scripts add the same constraint file to both
the source and the constraint fileset; Vivado 2020.2 rejects that with
`IP_Flow 19-851` and `axi_ad9361` cannot be packaged. `2022_R2` no longer does
this.

## Build

From this directory, with Vivado 2020.2:

```tcl
vivado -mode batch -source build_vivado_2020.tcl
```

Outputs:

```
openwifi_plutosky_r2/system_top.xsa                                  # for Buildroot
openwifi_plutosky_r2/openwifi_plutosky_r2.runs/impl_1/system_top.bit # FPGA bitstream
```

## Vivado version note

This board is built and tested with **Vivado 2020.2**, whereas the rest of the
repository targets Vivado 2022.2. Two project properties used by
`boards/openwifi.tcl` (`classic_soc_boot` and `revised_directory_structure`)
do not exist before Vivado 2021, so that script now sets them only when the
running Vivado exposes them. The behaviour on Vivado 2022.2 is unchanged.

The packaged-IP scripts under `ip/` derive the Vivado synthesis and
implementation flow names from `[version -short]` instead of pinning the 2022
release, which Vivado 2020.2 rejects outright. The `ip/openofdm_rx` submodule
needs the same treatment; see the companion change in `open-sdr/openofdm`.

## License requirement

The OpenWiFi OFDM receiver requires a Xilinx Viterbi Decoder evaluation or
production license. Configure `XILINXD_LICENSE_FILE` before starting Vivado.
Without that license, Vivado locks `openofdm_rx` and cannot generate a usable
bitstream. An evaluation build stops receiving after its evaluation interval.
