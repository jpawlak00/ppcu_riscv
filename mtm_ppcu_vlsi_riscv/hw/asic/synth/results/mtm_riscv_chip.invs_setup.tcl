################################################################################
#
# Innovus setup file
# Created by Genus(TM) Synthesis Solution 19.11-s087_1
#   on 09/12/2023 20:28:35
#
################################################################################
#
# Genus(TM) Synthesis Solution setup file
# This file can only be run in Innovus Common UI mode.
#
################################################################################

      set _t0 [clock seconds]
      puts [format  {%%%s Begin Genus to Innovus Setup (%s)} \# [clock format $_t0 -format {%m/%d %H:%M:%S}]]
    
if {[is_attribute -obj_type root read_physical_allow_multiple_port_pin_without_must_join]} {
  set_db read_physical_allow_multiple_port_pin_without_must_join true
} else {
  set read_physical_allow_multiple_port_pin_without_must_join 1
}


# Design Import
################################################################################
set_library_unit -cap 1pf -time 1ns
## Reading FlowKit settings file
source results/mtm_riscv_chip.flowkit_settings.tcl

source results/mtm_riscv_chip.invs_init.tcl

# Reading metrics file
################################################################################
read_metric -id current results/mtm_riscv_chip.metrics.json

## Reading common preserve file for dont_touch and dont_use preserve settings
source results/mtm_riscv_chip.preserve.tcl



# Mode Setup
################################################################################
source results/mtm_riscv_chip.mode

# Source cell padding from Genus
################################################################################
source results/mtm_riscv_chip.cell_pad.tcl 


# Reading write_name_mapping file
################################################################################
if {[is_attribute -obj_type port original_name] && [is_attribute -obj_type pin original_name] && [is_attribute -obj_type pin is_phase_inverted]} {
  source results/mtm_riscv_chip.wnm_attrs.tcl
}

eval_legacy { set edi_pe::pegConsiderMacroLayersUnblocked 1 }
eval_legacy { set edi_pe::pegPreRouteWireWidthBasedDensityCalModel 1 }

      set _t1 [clock seconds]
      puts [format  {%%%s End Genus to Innovus Setup (%s, real=%s)} \# [clock format $_t1 -format {%m/%d %H:%M:%S}] [clock format [expr {28800 + $_t1 - $_t0}] -format {%H:%M:%S}]]
    
