# // Author: Fu Wenbo
# // SPDX-FileCopyrightText: 2026 Fu Wenbo
# // SPDX-License-Identifier: AGPL-3.0-or-later

# files and directories for the board

set files [list \
 [file normalize "${origin_dir}/../../adi-hdl/library/common/ad_iobuf.v"] \
 [file normalize "${origin_dir}/src/ADF4001_init.v"] \
 [file normalize "${origin_dir}/src/ADF4001_spi_drive.v"] \
 [file normalize "${origin_dir}/src/system_wrapper.v"] \
 [file normalize "${origin_dir}/src/system.bd" ]\
 [file normalize "${origin_dir}/src/system_top.v" ]\
]

set files_xdc [list \
 [file normalize "$origin_dir/src/plutosky_r2_constr.xdc"]\
 [file normalize "$origin_dir/src/system.xdc"]\
]

set ip_repos [list \
 [file normalize "$origin_dir/../../adi-hdl/library"]\
 [file normalize "$origin_dir/ip_repo/"]\
]

set board_part_repos []
