# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# fpga_size_flag: 0 small; 1 big

if {$BOARD_NAME=="zed_fmcs2"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg484-1"
   set board_part_string []
   set board_id_string "zed"
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="zcu102_fmcs2"} {
   set ultra_scale_flag 1
   set part_string "xczu9eg-ffvb1156-2-e"
   set board_part_string "xilinx.com:zcu102:part0:3.4"
   set board_id_string "zcu102"
   set fpga_size_flag 1
} elseif {$BOARD_NAME=="zc706_fmcs2"} {
   set ultra_scale_flag 0
   set part_string "xc7z045ffg900-2"
   set board_part_string []
   set board_id_string "zc706"
   set fpga_size_flag 1
} elseif {$BOARD_NAME=="zc702_fmcs2"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg484-1"
   set board_part_string []
   set board_id_string "zc702"
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="antsdr"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg400-1"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="antsdr_e200"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg400-1"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="sdrpi"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg400-1"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="adrv9361z7035"} {
   set ultra_scale_flag 0
   set part_string "xc7z035ifbg676-2L"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 1
} elseif {$BOARD_NAME=="adrv9364z7020"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg400-1"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="neptunesdr"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg400-1"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 0
} elseif {$BOARD_NAME=="e310v2"} {
   set ultra_scale_flag 0
   set part_string "xc7z020clg400-1"
   set board_part_string []
   set board_id_string []
   set fpga_size_flag 0
} else {
   set ultra_scale_flag []
   set part_string []
   set fpga_size_flag []
   set board_part_string []
   set board_id_string []
   puts "$BOARD_NAME is not valid!"
}
