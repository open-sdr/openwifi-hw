set ultra_scale_flag [lindex $argv 0]
set src_dir [lindex $argv 1]
set ip_dir [lindex $argv 2]

exec rm -rf project_1
exec rm -rf $ip_dir

set current_dir [pwd]
cd $src_dir/
if {$ultra_scale_flag > 0} {
    exec rm -rf openofdm_rx_ultra_scale
    source ./openofdm_rx_ultra_scale.tcl
} else {
    exec rm -rf openofdm_rx
    source ./openofdm_rx.tcl
}

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

cd $current_dir/
