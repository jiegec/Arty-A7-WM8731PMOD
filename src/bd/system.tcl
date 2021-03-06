
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# top

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35ticsg324-1L
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:ila:6.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
top\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set i2c [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 i2c ]


  # Create ports
  set clk_in [ create_bd_port -dir I -type clk clk_in ]
  set i2s_adcdat [ create_bd_port -dir I i2s_adcdat ]
  set i2s_bclk [ create_bd_port -dir O i2s_bclk ]
  set i2s_dacdat [ create_bd_port -dir O i2s_dacdat ]
  set i2s_lrclk [ create_bd_port -dir O i2s_lrclk ]
  set mclk [ create_bd_port -dir O mclk ]
  set resetn [ create_bd_port -dir I -type rst resetn ]
  set speaker_mute [ create_bd_port -dir O speaker_mute ]
  set spi_cs [ create_bd_port -dir O spi_cs ]
  set spi_dq0 [ create_bd_port -dir O spi_dq0 ]
  set spi_dq1 [ create_bd_port -dir I spi_dq1 ]
  set spi_dq2 [ create_bd_port -dir O spi_dq2 ]
  set spi_dq3 [ create_bd_port -dir O spi_dq3 ]
  set spi_sck [ create_bd_port -dir O spi_sck ]
  set switches [ create_bd_port -dir I -from 3 -to 0 switches ]
  set uart_rx [ create_bd_port -dir I uart_rx ]
  set uart_tx [ create_bd_port -dir O uart_tx ]

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Byte_Size {8} \
   CONFIG.Coe_File {../../../../../../../src/other/music.coe} \
   CONFIG.EN_SAFETY_CKT {true} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Load_Init_File {true} \
   CONFIG.Memory_Type {Single_Port_ROM} \
   CONFIG.Port_A_Write_Rate {0} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {true} \
   CONFIG.Write_Depth_A {32768} \
   CONFIG.Write_Width_A {32} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_0

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {328.461} \
   CONFIG.CLKOUT1_PHASE_ERROR {378.726} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {73.728} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {50.875} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {11.500} \
   CONFIG.MMCM_DIVCLK_DIVIDE {6} \
 ] $clk_wiz

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {6} \
 ] $ila_0

  # Create instance: rst_clk_wiz_100M, and set properties
  set rst_clk_wiz_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_100M ]

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [ list \
   CONFIG.C_BRAM_CNT {6} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:iic_rtl:1.0} \
 ] $system_ila_0

  # Create instance: top_0, and set properties
  set block_name top
  set block_cell_name top_0
  if { [catch {set top_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $top_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net top_0_BRAM [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins top_0/BRAM]
  connect_bd_intf_net -intf_net top_0_IIC [get_bd_intf_ports i2c] [get_bd_intf_pins top_0/IIC]
connect_bd_intf_net -intf_net [get_bd_intf_nets top_0_IIC] [get_bd_intf_ports i2c] [get_bd_intf_pins system_ila_0/SLOT_0_IIC]

  # Create port connections
  connect_bd_net -net clk_in1_0_1 [get_bd_ports clk_in] [get_bd_pins clk_wiz/clk_in1]
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins clk_wiz/clk_out1] [get_bd_pins ila_0/clk] [get_bd_pins rst_clk_wiz_100M/slowest_sync_clk] [get_bd_pins system_ila_0/clk] [get_bd_pins top_0/clk]
  connect_bd_net -net clk_wiz_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rst_clk_wiz_100M/dcm_locked]
  connect_bd_net -net ext_reset_in_0_1 [get_bd_ports resetn] [get_bd_pins rst_clk_wiz_100M/ext_reset_in]
  connect_bd_net -net i2s_adcdat_0_1 [get_bd_ports i2s_adcdat] [get_bd_pins ila_0/probe2] [get_bd_pins top_0/i2s_adcdat]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_aresetn [get_bd_pins rst_clk_wiz_100M/peripheral_aresetn] [get_bd_pins top_0/rstn]
  connect_bd_net -net spi_dq1_0_1 [get_bd_ports spi_dq1] [get_bd_pins top_0/spi_dq1]
  connect_bd_net -net switches_0_1 [get_bd_ports switches] [get_bd_pins top_0/switches]
  connect_bd_net -net top_0_i2s_bclk [get_bd_ports i2s_bclk] [get_bd_pins ila_0/probe5] [get_bd_pins top_0/i2s_bclk]
  connect_bd_net -net top_0_i2s_dacdat [get_bd_ports i2s_dacdat] [get_bd_pins ila_0/probe4] [get_bd_pins top_0/i2s_dacdat]
  connect_bd_net -net top_0_i2s_lrclk [get_bd_ports i2s_lrclk] [get_bd_pins ila_0/probe3] [get_bd_pins top_0/i2s_lrclk]
  connect_bd_net -net top_0_mclk [get_bd_ports mclk] [get_bd_pins top_0/mclk]
  connect_bd_net -net top_0_speaker_mute [get_bd_ports speaker_mute] [get_bd_pins top_0/speaker_mute]
  connect_bd_net -net top_0_spi_cs [get_bd_ports spi_cs] [get_bd_pins top_0/spi_cs]
  connect_bd_net -net top_0_spi_dq0 [get_bd_ports spi_dq0] [get_bd_pins top_0/spi_dq0]
  connect_bd_net -net top_0_spi_dq2 [get_bd_ports spi_dq2] [get_bd_pins top_0/spi_dq2]
  connect_bd_net -net top_0_spi_dq3 [get_bd_ports spi_dq3] [get_bd_pins top_0/spi_dq3]
  connect_bd_net -net top_0_spi_sck [get_bd_ports spi_sck] [get_bd_pins top_0/spi_sck]
  connect_bd_net -net top_0_uart_tx [get_bd_ports uart_tx] [get_bd_pins ila_0/probe1] [get_bd_pins top_0/uart_tx]
  connect_bd_net -net uart_rx_0_1 [get_bd_ports uart_rx] [get_bd_pins ila_0/probe0] [get_bd_pins top_0/uart_rx]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins clk_wiz/reset] [get_bd_pins xlconstant_0/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


