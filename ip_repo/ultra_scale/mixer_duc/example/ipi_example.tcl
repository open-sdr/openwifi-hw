# ==============================================================
# File generated on Mon Mar 09 18:12:46 CET 2020
# Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2018.3 (64-bit)
# SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
# IP Build 2404404 on Fri Dec  7 01:43:56 MST 2018
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# ==============================================================

namespace eval HLS {
############################################################
# constants/variables
############################################################
variable IP_INST hls_ip_0
variable MB_INST microblaze_0
variable MB_VER  9.5
variable PS_INST processing_system7_0
variable PS_VER  5.5

############################################################
# main entry
############################################################
proc create_ipi_example {part zipfile} {
    # {{{
    create_vivado_project project project $part
    set vlnv [import_hls_ip $zipfile]

    create_bd_design hls_bd_0
    instantiate_hls_ip $vlnv
    
    set target [get_target_device $vlnv] 

    if {$target == "zynq"} {
        setup_arm
        setup_hls_ip_for_arm
    } else {
        setup_microblaze
        setup_hls_ip_for_microblaze
    }

    assign_bd_address
    catch {validate_bd_design}
    save_bd_design
    # }}}
}

############################################################
# get target device of hls ip
############################################################
proc get_target_device {vlnv} {
    # {{{
    set ip_def [get_ipdefs $vlnv]
    set supported_families [get_property supported_families $ip_def]
    if {[string match *zynq* $supported_families]} {
        set target zynq
    } else {
        set target non-zynq
    }

    return $target
    # }}}
}

############################################################
# create vivado project
############################################################
proc create_vivado_project {name dir part} {
    # {{{
    create_project -force -part $part $name $dir
    # }}}
}

############################################################
# import hls ip
############################################################
proc import_hls_ip {zipfile} {
    # {{{
    set repo_dir ./repo
    file delete -force $repo_dir
    file mkdir $repo_dir

    set_property ip_repo_paths $repo_dir [current_fileset]
    update_ip_catalog -rebuild
    set old_ips [get_ipdefs]

    update_ip_catalog -add_ip $zipfile -repo_path $repo_dir
    set new_ips [get_ipdefs]

    # a silly way to get vlnv of the IP added :(
    foreach ip $new_ips {
        if {[lsearch $old_ips $ip] < 0} {
            return $ip
        }
    }

    return -code error "Failed importing HLS IP"
    # }}}
}

############################################################
# instantiate hls ip
############################################################
proc instantiate_hls_ip {vlnv} {
    # {{{
    variable IP_INST
    create_bd_cell -type ip -vlnv $vlnv $IP_INST
    # }}}
}

############################################################
# set up microblaze
############################################################
proc setup_microblaze {} {
    # {{{
    variable MB_INST
    variable MB_VER

    set has_aximm_slave [hls_ip_has_aximm_slave]
    if {!$has_aximm_slave} {
        return
    }

    set has_interrupt [hls_ip_has_interrupt]

    create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze $MB_INST
    apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config [dict create \
        local_mem "8KB" \
        ecc "None" \
        debug_module "Debug Only" \
        axi_periph "1" \
        axi_intc $has_interrupt \
        clk "New Clocking Wizard (100 MHz)"
    ] [get_bd_cells /$MB_INST]

    #Following lines have a lot of hardcoding to make the design functional and useful 
    # By default Block Automation of Microblaze instances an AXI Interconnect with two 
    # Masters So We Reconfigure it to have only One Master
    set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells /${MB_INST}_axi_periph]

    # By default Block Automation of Microblaze instances a Clock Wizard with 
    # differential pins but does not make them external so we reconfigure it
    # to make both the reset and the diff pairs external
    set clk_wiz_inst clk_wiz_1
    create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN1_D
    connect_bd_intf_net [get_bd_intf_ports /CLK_IN1_D] [get_bd_intf_pins /$clk_wiz_inst/CLK_IN1_D]

    # By default Block Automation of Microblaze instances a proc_sys_reset port
    # with dangling ext_reset_in and aux_reset_in. aux_reset_in is left unconnected
    # because it gets a good default value. ext_reset_in is connected to 
    # reset_rtl port that is an external port. The reset pin of clk_wiz is
    # also connected to the same port. This reset pin is Active High
    set proc_sys_reset_inst rst_clk_wiz_1_*
    create_bd_port -dir I reset_rtl -type rst
    set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports /reset_rtl]
    connect_bd_net [get_bd_ports /reset_rtl] [get_bd_pins /$proc_sys_reset_inst/ext_reset_in]
    connect_bd_net [get_bd_ports /reset_rtl] [get_bd_pins /$clk_wiz_inst/reset] 

    # By default concat has two input ports. Since HLS IP has only one interrupt,
    # set it to 1.
    if {$has_interrupt} {
        set_property -dict [list CONFIG.NUM_PORTS {1}] [get_bd_cells /${MB_INST}_xlconcat]
    }
    # }}}
}

############################################################
# set up hls ip for microblaze
############################################################
proc setup_hls_ip_for_microblaze {} {
    # {{{
    variable IP_INST
    variable MB_INST

    set freq [get_freq_for_microbaze]

    # interfaces
    foreach intf [get_bd_intf_pins /$IP_INST/*] {
        set vlnv [get_property VLNV $intf]
        set mode [get_property MODE $intf]
        set intf_name [lindex [split $vlnv ":"] 2]

        switch -- $intf_name {
            aximm_rtl {
                if {$mode == "Master"} {
                    # axi4 master
                    make_external_interface $intf $freq
                } else {
                    # axi4lite slave
                    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config [list \
                        Master "/$MB_INST (Periph)" \
                    ] $intf 
                }
            }
            default {
                make_external_interface $intf $freq
            }
        }
    }

    # pins
    foreach pin [get_bd_pins /$IP_INST/*] {
        set is_intf_pin [get_property INTF $pin]
        set net [get_bd_nets -quiet -of_objects $pin]

        if {$is_intf_pin || $net != ""} {
            continue
        }

        set name [get_property NAME $pin]
        set dir [get_property DIR $pin]
        set left [get_property LEFT $pin]
        set right [get_property RIGHT $pin]

        if {$name == "interrupt"} {
            connect_bd_net $pin [get_bd_pins /${MB_INST}_xlconcat/In0]
            continue
        } 

        if {$name == "ce"} {
            connect_to_vcc $pin
            continue
        } 

        if {$left == ""} {
            set net [create_bd_port -dir $dir -type data $name]
        } else {
            set net [create_bd_port -dir $dir -type data -from $left -to $right $name]
        }
        connect_bd_net $pin $net
    }
    # }}}
}

proc get_freq_for_microbaze {} {
    # {{{
    set clk_wiz_inst clk_wiz_1

    set clk_pin [get_bd_pins /$clk_wiz_inst/clk_out1]
    if {[llength $clk_pin] == 1} {
        return [get_property CONFIG.FREQ_HZ $clk_pin]
    } else {
        return ""
    }
    # }}}
}

############################################################
# set up arm
############################################################
proc setup_arm {} {
    # {{{
    variable PS_INST
    variable PS_VER

    set has_aximm_slave [hls_ip_has_aximm_slave]
    set has_aximm_master [hls_ip_has_aximm_master]
    if {!$has_aximm_slave && !$has_aximm_master} {
        return
    }

    set has_interrupt [hls_ip_has_interrupt]

    create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:$PS_VER $PS_INST
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" }  [get_bd_cells /$PS_INST]

    if {$has_interrupt} {
        set_property -dict [list \
            CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
            CONFIG.PCW_IRQ_F2P_INTR {1} \
        ] [get_bd_cells /$PS_INST]
    }

    if {!$has_aximm_slave} {
        set_property -dict [list \
            CONFIG.PCW_USE_M_AXI_GP0 {0} \
        ] [get_bd_cells /$PS_INST]
    }

    if {$has_aximm_master} {
        set_property -dict [list \
            CONFIG.PCW_USE_S_AXI_HP0 {1} \
        ] [get_bd_cells /$PS_INST]
    }
    # }}}
}

############################################################
# set up hls ip for arm
############################################################
proc setup_hls_ip_for_arm {} {
    # {{{
    variable IP_INST
    variable PS_INST

    set freq [get_freq_for_arm]

    # interfaces
    foreach intf [get_bd_intf_pins /$IP_INST/*] {
        set vlnv [get_property VLNV $intf]
        set mode [get_property MODE $intf]
        set intf_name [lindex [split $vlnv ":"] 2]

        switch -- $intf_name {
            aximm_rtl {
                if {$mode == "Master"} {
                    # axi4 master
                    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config [list \
                        Master $intf \
                    ] [get_bd_intf_pins /$PS_INST/S_AXI_HP0]
                } else {
                    # axi4lite slave
                    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config [list \
                        Master "/$PS_INST/M_AXI_GP0" \
                    ] $intf
                }
            }
            default {
                make_external_interface $intf $freq
            }
        }
    }

    # pins
    foreach pin [get_bd_pins /$IP_INST/*] {
        set is_intf_pin [get_property INTF $pin]
        set net [get_bd_nets -quiet -of_objects $pin]

        if {$is_intf_pin || $net != ""} {
            continue
        }

        set name [get_property NAME $pin]
        set dir [get_property DIR $pin]
        set left [get_property LEFT $pin]
        set right [get_property RIGHT $pin]

        if {$name == "interrupt"} {
            connect_bd_net $pin [get_bd_pins /$PS_INST/IRQ_F2P]
            continue
        } 

        if {$name == "ce"} {
            connect_to_vcc $pin
            continue
        } 

        if {$left == ""} {
            set net [create_bd_port -dir $dir -type data $name]
        } else {
            set net [create_bd_port -dir $dir -type data -from $left -to $right $name]
        }
        connect_bd_net $pin $net
    }
    # }}}
}

proc get_freq_for_arm {} {
    # {{{
    variable PS_INST

    set clk_pin [get_bd_pins /$PS_INST/FCLK_CLK0]
    if {[llength $clk_pin] == 1} {
        return [get_property CONFIG.FREQ_HZ $clk_pin]
    } else {
        return ""
    }
    # }}}
}

############################################################
# make external interface
############################################################
proc make_external_interface {intf {freq ""}} {
    # {{{
    set name [get_property NAME $intf]
    set vlnv [get_property VLNV $intf]
    set mode [get_property MODE $intf]

    set port [create_bd_intf_port -mode $mode -vlnv $vlnv $name]
    connect_bd_intf_net $intf $port

    # copy properties
    foreach property [list_property $intf CONFIG.*] {
        if {$property == "CONFIG.FREQ_HZ"} {
            set_property -quiet $property $freq $port
        } else {
            set_property -quiet $property [get_property $property $intf] $port
        }
    }
    # }}}
}

############################################################
# connect to vcc
############################################################
proc connect_to_vcc {pin} {
    # {{{
    set vcc [get_vcc_instance]
    connect_bd_net $pin [get_bd_pins /$vcc/dout]
    # }}}
}

############################################################
# get vcc instance (create a new one if it doesn't exist)
############################################################
proc get_vcc_instance {} {
    # {{{
    set VCC_INST VCC
    set vcc [get_bd_cell -quiet /$VCC_INST]
    if {$vcc == ""} {
        set vcc [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 $VCC_INST]
    }

    return $vcc
    # }}}
}

############################################################
# hls ip has aximm slave or not
############################################################
proc hls_ip_has_aximm_slave {} {
    # {{{
    variable IP_INST

    foreach intf [get_bd_intf_pins /$IP_INST/*] {
        set vlnv [get_property VLNV $intf]
        set mode [get_property MODE $intf]
        set intf_name [lindex [split $vlnv ":"] 2]

        if {$intf_name == "aximm_rtl" && $mode == "Slave"} {
            return 1
        }
    }

    return 0
    # }}}
}

############################################################
# hls ip has aximm master or not
############################################################
proc hls_ip_has_aximm_master {} {
    # {{{
    variable IP_INST

    foreach intf [get_bd_intf_pins /$IP_INST/*] {
        set vlnv [get_property VLNV $intf]
        set mode [get_property MODE $intf]
        set intf_name [lindex [split $vlnv ":"] 2]

        if {$intf_name == "aximm_rtl" && $mode == "Master"} {
            return 1
        }
    }

    return 0
    # }}}
}

############################################################
# hls ip has interrupt or not
############################################################
proc hls_ip_has_interrupt {} {
    # {{{
    variable IP_INST

    foreach pin [get_bd_pins /$IP_INST/*] {
        set name [get_property NAME $pin]
        if {$name == "interrupt"} {
            return 1
        } 
    }

    return 0
    # }}}
}

} ;# end of namespace eval HLS

if {$argc != 2} {
    puts "Usage:"
    puts "vivado  -notrace -source [file tail [info script]] -tclargs <part> <zipfile>"
    exit 1
}

lassign $argv part zipfile
HLS::create_ipi_example $part $zipfile

# vim:set ts=4 sw=4 et fdm=marker:
