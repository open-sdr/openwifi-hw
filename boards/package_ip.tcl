# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

set part_string [lindex $argv 0]
set src_dir [lindex $argv 1]
set ip_dir [lindex $argv 2]

exec rm -rf project_1
exec rm -rf $ip_dir

# create_project project_1 ./project_1 -part xc7z020clg484-1
create_project project_1 ./project_1 -part $part_string
# set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

# set files [glob /home/jxj/git/openwifi-hw/boards/antsdr/ip_repo_src/rx_intf/src/*.v]
set files [glob $src_dir/*]
add_files $files
# set files [list [file normalize "./ip_repo/openwifi_hw_git_rev.v"] [file normalize "./ip_repo/board_def.v"] [file normalize "./ip_repo/clock_speed.v"] [file normalize "./ip_repo/has_side_ch_flag.v"] [file normalize "./ip_repo/fpga_scale.v"]]
# add_files $files
update_compile_order -fileset sources_1
update_compile_order -fileset sources_1

# ipx::package_project -root_dir /home/jxj/git/openwifi-hw/boards/antsdr/ip_repo/rx_intf -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
ipx::package_project -root_dir $ip_dir -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false
# ipx::unload_core /home/jxj/git/openwifi-hw/boards/antsdr/ip_repo/rx_intf/component.xml
ipx::unload_core $ip_dir/component.xml
# ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory /home/jxj/git/openwifi-hw/boards/antsdr/ip_repo/rx_intf /home/jxj/git/openwifi-hw/boards/antsdr/ip_repo/rx_intf/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $ip_dir $ip_dir/component.xml

update_compile_order -fileset sources_1
set_property core_revision 2 [ipx::current_core]

ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]

close_project -delete
# set_property  ip_repo_paths  /home/jxj/git/openwifi-hw/boards/antsdr/ip_repo/rx_intf [current_project]
# update_ip_catalog

close_project -delete

