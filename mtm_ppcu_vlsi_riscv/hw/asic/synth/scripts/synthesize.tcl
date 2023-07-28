# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Copyright 2020 AGH University of Science and Technology
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
set DESIGN mtm_riscv_chip
set REPORT_DIR reports
set RESULT_DIR results

source scripts/flow_config.tcl

# Read the Multi-Mode, Multi-Corner view definition file and populate the MMMC-related attributes
read_mmmc "constraints/mmode.tcl"

# List of global Power nets
set_db init_power_nets  {VDD VDDPST}
set_db init_ground_nets {VSS}

# Read the physical design information from the specified LEF files
read_physical -lefs {
    /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tcbn40lpbwp_120c/lef/HVH_0d5_0/tcbn40lpbwp_8lm5X2ZRDL.lef
    /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tpfn40lpgv2od3_120a/mt_2/8lm/lef/tpfn40lpgv2od3_8lm.lef
    /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tpfn40lpgv2od3_120a/mt_2/8lm/lef/antenna_8lm.lef
    /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tpbn45v_ds_150a/wb/8m/8M_5X2Z/lef/tpbn45v_ds_8lm.lef
    /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/LEF/ts1n40lpb4096x32m4m_250a_4m.lef
}

puts "--------------------------------------------------------------------------------"
puts "-- HDL READ --------------------------------------------------------------------"
puts "--------------------------------------------------------------------------------"
# TODO: read netlist file rtl/netlist.sv
# Note that this is a systemVerilog netlist.
# Use command: read_hdl

read_hdl -sv rtl/netlist.sv

#------------------------------------------------------------------------------
# merge and analyse the input files
puts "--------------------------------------------------------------------------------"
puts "-- ELABORATION -----------------------------------------------------------------"
puts "--------------------------------------------------------------------------------"
elaborate $DESIGN
timestat ELABORATE
# TODO: check if there are any errors or warnings during elaboration. There should be
# no errors, warnings can be accepted only if they are well understood and justified.
# Ignore the warnings from:
#       - standard cell library,
#       - io pads library,
#       - ibex core.

# Initialize the database and ensure that the tool is ready for full execution
puts "--------------------------------------------------------------------------------"
puts "-- INIT DESIGN -----------------------------------------------------------------"
puts "--------------------------------------------------------------------------------"
init_design -top $DESIGN

# TODO: Check if there are any errors/warnings.
#
# The correct lines in the log should show no errors, e.g.:
#
# Statistics for commands executed by read_sdc:
#  "all_inputs"               - successful      4 , failed      0 (runtime  0.00)
#  "all_outputs"              - successful      2 , failed      0 (runtime  0.00)
#  "create_clock"             - successful      1 , failed      0 (runtime  0.00)
#  "get_ports"                - successful      1 , failed      0 (runtime  0.00)
#  "set_clock_uncertainty"    - successful      2 , failed      0 (runtime  0.00)
#  "set_dont_use"             - successful      8 , failed      0 (runtime  0.00)
#  "set_driving_cell"         - successful      1 , failed      0 (runtime  0.00)
#  "set_input_delay"          - successful      1 , failed      0 (runtime  0.00)
#  "set_input_transition"     - successful      1 , failed      0 (runtime  0.00)
#  "set_load"                 - successful      1 , failed      0 (runtime  0.00)
#  "set_load_unit"            - successful      1 , failed      0 (runtime  0.00)
#  "set_max_fanout"           - successful      1 , failed      0 (runtime  0.00)
#  "set_output_delay"         - successful      1 , failed      0 (runtime  0.00)
#  "set_time_unit"            - successful      1 , failed      0 (runtime  0.00)
#  "set_units"                - successful      2 , failed      0 (runtime  0.00)
# Total runtime 0


# Check the SDC quality and timing attributes placed on the current design and
# print timing lint report
puts "--------------------------------------------------------------------------------"
puts "-- CHECK TIMING CONSTRATINTS ---------------------------------------------------"
puts "--------------------------------------------------------------------------------"
check_timing_intent -verbose > ${REPORT_DIR}/check_timing_intent.rpt
#
# TODO: the report should show no errors and no warnings
#
# The correct report is similiar to:
#
# Lint summary
#  Unconnected/logic driven clocks                                  0
#  Sequential data pins driven by a clock signal                    0
#  Sequential clock pins without clock waveform                     0
#  Sequential clock pins with multiple clock waveforms              0
#  Generated clocks without clock waveform                          0
#  Generated clocks with incompatible options                       0
#  Generated clocks with multi-master clock                         0
#  Paths constrained with different clocks                          0
#  Loop-breaking cells for combinational feedback                   0
#  Nets with multiple drivers                                       0
#  Timing exceptions with no effect                                 0
#  Suspicious multi_cycle exceptions                                0
#  Pins/ports with conflicting case constants                       0
#  Inputs without clocked external delays                           0
#  Outputs without clocked external delays                          0
#  Inputs without external driver/transition                        0
#  Outputs without external load                                    0
#  Exceptions with invalid timing start-/endpoints                  0
#
#                                                   Total:          0


# Provide information on unresolved references
check_design -unresolved  > ${REPORT_DIR}/check_design.rpt
# TODO: check if the report contains the following info:
#
# The correct results is similiar to:
#
# No unresolved references in design 'mtm_riscv_chip'
# No empty modules in design 'mtm_riscv_chip'


# Take an elaborated and fully constrained design as input and synthesize it into a netlist
# of generic gates by doing high-level RTL and datapath optimizations
syn_generic $DESIGN
timestat GENERIC

# Map a design from generic gates to a technology library while optimizing for best performance,
# power and area
syn_map $DESIGN
timestat MAPPED

# Take a mapped design as input and incrementally optimize timing, area and power
syn_opt $DESIGN
timestat OPT

#------------------------------------------------------------------------------
# TODO: put your report commands below.
# Report:
# - quality of results (QOR); save to the file:  ${REPORT_DIR}/qor.log
# - worst timing paths (to check, if the timing was met); save to the file:
#    ${REPORT_DIR}/timing.log

# TODO: Report the critical path slack, total negative slack (TNS), number of gates
# on the critical path and number of violating paths for each cost group
report_qor $DESIGN > ${REPORT_DIR}/qor.log

# Generate a timing report of the current design
report_timing > ${REPORT_DIR}/timing.log

# TODO: Check the logs and make sure that the timing was met and no errors are reported.

#------------------------------------------------------------------------------
# Generate all the files needed to reload the session in Genus or Innovus (-innovus option)
write_design -innovus -basename ${RESULT_DIR}/$DESIGN
