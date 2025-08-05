# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2025 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# common Vivado top project script for all boards

# https://adaptivesupport.amd.com/s/article/000034290?language=en_US
set_param gui.addressMap 0

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

source ./set_files.tcl

# Set board specific variables
set BOARD_NAME [lindex [split [exec pwd] /] end]
puts "openwifi.tcl BOARD_NAME $BOARD_NAME"
source ../../ip/parse_board_name.tcl

# This overrides the value in ip_repo_gen.tcl!
set NUM_CLK_PER_US 100
set  fd  [open  "./ip_repo/clock_speed.v"  w]
puts $fd "`define NUM_CLK_PER_US $NUM_CLK_PER_US"
if {$fpga_size_flag == 0} {
  puts $fd "`define SMALL_FPGA 1"
}
close $fd
exec cp ./ip_repo/clock_speed.v ./ip_repo/tx_intf/src/ -f
exec cp ./ip_repo/clock_speed.v ./ip_repo/rx_intf/src/ -f
exec cp ./ip_repo/clock_speed.v ./ip_repo/xpu/src/ -f

# -----------generate git rev info (overwrite ip_repo_gen.tcl)---
set  fd  [open  "./ip_repo/xpu/src/openwifi_hw_git_rev.v"  w]
set HASHCODE [exec ../../get_git_rev.sh]
puts $fd "`define OPENWIFI_HW_GIT_REV (32'h$HASHCODE)"
close $fd
# ----end of generate generate git rev info----------------------

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "openwifi_$BOARD_NAME"
exec rm -rf $_xil_proj_name_
exec git clean -dxf ./src/

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "openwifi.tcl"

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part $part_string

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part_repo_paths" -value "$board_part_repos" -objects $obj
set_property -name "board_part" -value "$board_part_string" -objects $obj
set_property -name "classic_soc_boot" -value "0" -objects $obj
set_property -name "compxlib.activehdl_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/activehdl" -objects $obj
set_property -name "compxlib.funcsim" -value "1" -objects $obj
set_property -name "compxlib.ies_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/ies" -objects $obj
set_property -name "compxlib.modelsim_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/modelsim" -objects $obj
set_property -name "compxlib.overwrite_libs" -value "0" -objects $obj
set_property -name "compxlib.questa_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/questa" -objects $obj
set_property -name "compxlib.riviera_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/riviera" -objects $obj
set_property -name "compxlib.timesim" -value "1" -objects $obj
set_property -name "compxlib.vcs_compiled_library_dir" -value "$proj_dir/${_xil_proj_name_}.cache/compile_simlib/vcs" -objects $obj
set_property -name "compxlib.xsim_compiled_library_dir" -value "" -objects $obj
set_property -name "corecontainer.enable" -value "0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_optional_runs_sta" -value "0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "generate_ip_upgrade_log" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_interface_inference_priority" -value "" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "legacy_ip_repo_paths" -value "" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj

#set_property -name "part" -value "$part_string" -objects $obj
#Above line causes error for rfsoc4x2 while openning .bd:
#ERROR: [IP_Flow 19-3461] Value 'dip_switches_4bits' is out of the range for parameter 'GPIO BOARD INTERFACE(GPIO_BOARD_INTERFACE)' for BD Cell 'sws_gpio' . Valid values are - Custom

set_property -name "platform.board_id" -value "$board_id_string" -objects $obj
set_property -name "platform.default_output_type" -value "undefined" -objects $obj
set_property -name "platform.design_intent.datacenter" -value "undefined" -objects $obj
set_property -name "platform.design_intent.embedded" -value "undefined" -objects $obj
set_property -name "platform.design_intent.external_host" -value "undefined" -objects $obj
set_property -name "platform.design_intent.server_managed" -value "undefined" -objects $obj
set_property -name "platform.rom.debug_type" -value "0" -objects $obj
set_property -name "platform.rom.prom_type" -value "0" -objects $obj
set_property -name "platform.slrconstraintmode" -value "0" -objects $obj
set_property -name "preferred_sim_model" -value "rtl" -objects $obj
set_property -name "project_type" -value "Default" -objects $obj
set_property -name "pr_flow" -value "0" -objects $obj
set_property -name "revised_directory_structure" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "sim.use_ip_compiled_libs" -value "1" -objects $obj
set_property -name "simulator.activehdl_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.activehdl_install_dir" -value "" -objects $obj
set_property -name "simulator.ies_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.ies_install_dir" -value "" -objects $obj
set_property -name "simulator.modelsim_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.modelsim_install_dir" -value "" -objects $obj
set_property -name "simulator.questa_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.questa_install_dir" -value "" -objects $obj
set_property -name "simulator.riviera_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.riviera_install_dir" -value "" -objects $obj
set_property -name "simulator.vcs_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.vcs_install_dir" -value "" -objects $obj
set_property -name "simulator.xcelium_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.xcelium_install_dir" -value "" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "source_mgmt_mode" -value "All" -objects $obj
set_property -name "target_language" -value "Verilog" -objects $obj
set_property -name "target_simulator" -value "XSim" -objects $obj
set_property -name "tool_flow" -value "Vivado" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj
set_property -name "xsim.array_display_limit" -value "1024" -objects $obj
set_property -name "xsim.radix" -value "hex" -objects $obj
set_property -name "xsim.time_unit" -value "ns" -objects $obj
set_property -name "xsim.trace_limit" -value "65536" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "$ip_repos" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Add local files from the original project (-no_copy_sources specified)
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "design_mode" -value "RTL" -objects $obj
set_property -name "edif_extra_search_paths" -value "" -objects $obj
set_property -name "elab_link_dcps" -value "1" -objects $obj
set_property -name "elab_load_timing_constraints" -value "1" -objects $obj
set_property -name "generic" -value "" -objects $obj
set_property -name "include_dirs" -value "" -objects $obj
set_property -name "lib_map_file" -value "" -objects $obj
set_property -name "loop_count" -value "1000" -objects $obj
set_property -name "name" -value "sources_1" -objects $obj
set_property -name "top" -value "system_top" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "verilog_version" -value "verilog_2001" -objects $obj
set_property -name "vhdl_version" -value "vhdl_2k" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
# Add/Import constrs files
add_files -norecurse -fileset $obj $files_xdc

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "32bit" -value "0" -objects $obj
set_property -name "force_compile_glbl" -value "0" -objects $obj
set_property -name "force_no_compile_glbl" -value "0" -objects $obj
set_property -name "generate_scripts_only" -value "0" -objects $obj
set_property -name "generic" -value "" -objects $obj
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "hw_emu.debug_mode" -value "wdb" -objects $obj
set_property -name "include_dirs" -value "" -objects $obj
set_property -name "incremental" -value "1" -objects $obj
set_property -name "name" -value "sim_1" -objects $obj
set_property -name "nl.cell" -value "" -objects $obj
set_property -name "nl.incl_unisim_models" -value "0" -objects $obj
set_property -name "nl.process_corner" -value "slow" -objects $obj
set_property -name "nl.rename_top" -value "" -objects $obj
set_property -name "nl.sdf_anno" -value "1" -objects $obj
set_property -name "nl.write_all_overrides" -value "0" -objects $obj
set_property -name "simmodel_value_check" -value "1" -objects $obj
set_property -name "simulator_launch_mode" -value "off" -objects $obj
set_property -name "source_set" -value "sources_1" -objects $obj
set_property -name "systemc_include_dirs" -value "" -objects $obj
set_property -name "top" -value "system_top" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "transport_int_delay" -value "0" -objects $obj
set_property -name "transport_path_delay" -value "0" -objects $obj
set_property -name "unifast" -value "0" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "xelab.dll" -value "0" -objects $obj
set_property -name "xsim.compile.tcl.pre" -value "" -objects $obj
set_property -name "xsim.compile.xsc.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvhdl.relax" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvlog.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.coverage.celldefine" -value "0" -objects $obj
set_property -name "xsim.elaborate.coverage.dir" -value "" -objects $obj
set_property -name "xsim.elaborate.coverage.library" -value "0" -objects $obj
set_property -name "xsim.elaborate.coverage.name" -value "" -objects $obj
set_property -name "xsim.elaborate.coverage.type" -value "" -objects $obj
set_property -name "xsim.elaborate.debug_level" -value "typical" -objects $obj
set_property -name "xsim.elaborate.load_glbl" -value "1" -objects $obj
set_property -name "xsim.elaborate.mt_level" -value "auto" -objects $obj
set_property -name "xsim.elaborate.rangecheck" -value "0" -objects $obj
set_property -name "xsim.elaborate.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.sdf_delay" -value "sdfmax" -objects $obj
set_property -name "xsim.elaborate.snapshot" -value "" -objects $obj
set_property -name "xsim.elaborate.xelab.more_options" -value "" -objects $obj
set_property -name "xsim.elaborate.xsc.more_options" -value "" -objects $obj
set_property -name "xsim.simulate.add_positional" -value "0" -objects $obj
set_property -name "xsim.simulate.custom_tcl" -value "" -objects $obj
set_property -name "xsim.simulate.log_all_signals" -value "0" -objects $obj
set_property -name "xsim.simulate.no_quit" -value "0" -objects $obj
set_property -name "xsim.simulate.runtime" -value "1000ns" -objects $obj
set_property -name "xsim.simulate.saif" -value "" -objects $obj
set_property -name "xsim.simulate.saif_all_signals" -value "0" -objects $obj
set_property -name "xsim.simulate.saif_scope" -value "" -objects $obj
set_property -name "xsim.simulate.tcl.post" -value "" -objects $obj
set_property -name "xsim.simulate.wdb" -value "" -objects $obj
set_property -name "xsim.simulate.xsim.more_options" -value "" -objects $obj

source ./synth_impl_strategy.tcl
source ./../post_script_common.tcl

# https://adaptivesupport.amd.com/s/article/000034290?language=en_US
set_param gui.addressMap 0

update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 8

wait_on_run impl_1

update_compile_order -fileset sources_1
write_hw_platform -fixed -include_bit -force -file ./openwifi_$BOARD_NAME/system_top.xsa
