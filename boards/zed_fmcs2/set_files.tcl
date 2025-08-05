# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2025 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# files and directories for the board

set files [list \
 [file normalize "${origin_dir}/../../adi-hdl/library/common/ad_iobuf.v"] \
 [file normalize "${origin_dir}/src/system_wrapper.v"] \
 [file normalize "${origin_dir}/src/system.bd" ]\
 [file normalize "${origin_dir}/src/system_top.v" ]\
]

set files_xdc [list \
 [file normalize "$origin_dir/../../adi-hdl/projects/fmcomms2/zed/system_constr.xdc"]\
 [file normalize "$origin_dir/../../adi-hdl/projects/common/zed/zed_system_constr.xdc"]\
 [file normalize "$origin_dir/src/system.xdc"]\
]

set ip_repos [list \
 [file normalize "$origin_dir/../../adi-hdl/library"]\
 [file normalize "$origin_dir/ip_repo/"]\
]

set board_part_repos []
