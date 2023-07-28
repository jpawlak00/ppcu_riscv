# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Copyright 2020 AGH University of Science and Technology
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

set memTimingLibDir /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM
set stdcellTimingLibDir /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a
set iocellTimingLibDir  /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a


# Associate a TCL list of timing and cdB/UDN libraries with a specified library set name
# +--------+--------------------------+---------+---------+---------+-----+
# | Corner |        Condition         |  PMOS   |  NMOS   |    V    |  T  |
# +--------+--------------------------+---------+---------+---------+-----+
# | TC     | typical                  | typical | typical | VDD     |  25 |
# | WC     | worst                    | slow    | slow    | 0.9 VDD | 125 |
# | BC     | best                     | fast    | fast    | 1.1 VDD |   0 |
# | LT     | low temperature          | fast    | fast    | 1.1 VDD | -40 |
# | WCL    | worst at low temperature | slow    | slow    | 0.9 VDD | -40 |
# | ML     | maximum leakage          | fast    | fast    | 1.1 VDD | 125 |
# | WCZ    | worst at 0               | slow    | slow    | 0.9 VDD |   0 |
# +--------+--------------------------+---------+---------+---------+-----+
create_library_set -name TC_stdcell_libs  -timing [ list $stdcellTimingLibDir/tcbn40lpbwptc.lib ]
create_library_set -name WC_stdcell_libs  -timing [ list $stdcellTimingLibDir/tcbn40lpbwpwc.lib ]
create_library_set -name BC_stdcell_libs  -timing [ list $stdcellTimingLibDir/tcbn40lpbwpbc.lib ]
create_library_set -name LT_stdcell_libs  -timing [ list $stdcellTimingLibDir/tcbn40lpbwplt.lib ]
create_library_set -name WCL_stdcell_libs -timing [ list $stdcellTimingLibDir/tcbn40lpbwpwcl.lib ]
create_library_set -name ML_stdcell_libs  -timing [ list $stdcellTimingLibDir/tcbn40lpbwpml.lib ]
create_library_set -name WCZ_stdcell_libs -timing [ list $stdcellTimingLibDir/tcbn40lpbwpwcz.lib ]

create_library_set -name TC_mem_libs  -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_tt1p1v25c.lib ]
create_library_set -name WC_mem_libs  -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_ss0p99v125c.lib ]
create_library_set -name BC_mem_libs  -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_ff1p21v0c.lib ]
create_library_set -name LT_mem_libs  -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_ff1p21vm40c.lib ]
create_library_set -name WCL_mem_libs -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_ss0p99vm40c.lib ]
create_library_set -name ML_mem_libs  -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_ff1p21v125c.lib ]
create_library_set -name WCZ_mem_libs -timing [ list $memTimingLibDir/ts1n40lpb4096x32m4m_250a_ss0p99v0c.lib ]

create_library_set -name TC_iocell_libs  -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3tc1.lib ]
create_library_set -name WC_iocell_libs  -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3wc1.lib ]
create_library_set -name BC_iocell_libs  -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3bc1.lib ]
create_library_set -name LT_iocell_libs  -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3lt1.lib ]
create_library_set -name WCL_iocell_libs -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3wcl1.lib ]
create_library_set -name ML_iocell_libs  -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3ml1.lib ]
create_library_set -name WCZ_iocell_libs -timing [ list $iocellTimingLibDir/tpfn40lpgv2od3wcz1.lib ]

# Create a set of virtual operating conditions in the specified library without modifying the library
create_opcond -name TC_op_cond  -process 1 -voltage 0.99 -temperature 25
create_opcond -name WC_op_cond  -process 1 -voltage 0.99 -temperature 125
create_opcond -name BC_op_cond  -process 1 -voltage 1.21 -temperature 0
create_opcond -name LT_op_cond  -process 1 -voltage 1.21 -temperature -40
create_opcond -name WCL_op_cond -process 1 -voltage 0.99 -temperature -40
create_opcond -name ML_op_cond  -process 1 -voltage 1.21 -temperature 125
create_opcond -name WCZ_op_cond -process 1 -voltage 0.99 -temperature 0

create_timing_condition -name TC_tc  -opcond TC_op_cond  -library_sets "TC_stdcell_libs  TC_mem_libs  TC_iocell_libs"
create_timing_condition -name WC_tc  -opcond WC_op_cond  -library_sets "WC_stdcell_libs  WC_mem_libs  WC_iocell_libs"
create_timing_condition -name BC_tc  -opcond BC_op_cond  -library_sets "BC_stdcell_libs  BC_mem_libs  BC_iocell_libs"
create_timing_condition -name LT_tc  -opcond LT_op_cond  -library_sets "LT_stdcell_libs  LT_mem_libs  LT_iocell_libs"
create_timing_condition -name WCL_tc -opcond WCL_op_cond -library_sets "WCL_stdcell_libs WCL_mem_libs WCL_iocell_libs"
create_timing_condition -name ML_tc  -opcond ML_op_cond  -library_sets "ML_stdcell_libs  ML_mem_libs  ML_iocell_libs"
create_timing_condition -name WCZ_tc -opcond WCZ_op_cond -library_sets "WCZ_stdcell_libs WCZ_mem_libs WCZ_iocell_libs"


set qrcTechDir /cad/dk/PDK_CRN45GS_DGO_11_25/digital/QRC/8m_5x2z_alrdl

# Create a named RC corner that can be referenced later when creating a delay calculation corner
create_rc_corner -name RCcorner_typical -qrc_tech $qrcTechDir/typical/qrcTechFile
create_rc_corner -name RCcorner_cworst  -qrc_tech $qrcTechDir/cworst/qrcTechFile
create_rc_corner -name RCcorner_cbest   -qrc_tech $qrcTechDir/cbest/qrcTechFile
create_rc_corner -name RCcorner_rcworst -qrc_tech $qrcTechDir/rcworst/qrcTechFile
create_rc_corner -name RCcorner_rcbest  -qrc_tech $qrcTechDir/rcbest/qrcTechFile

# Define a delay calculation corner that can be referenced when creating an analysis view.
# From the documentation: for N40 and below processes, three different RC corners are used:
# - typical RC: TT related corners,
# - C-Worst:    SS related corners,
# - C-Best:     FF related corners
create_delay_corner -name TC_dc  -timing_condition TC_tc  -rc_corner RCcorner_typical
create_delay_corner -name WC_dc  -timing_condition WC_tc  -rc_corner RCcorner_cworst
create_delay_corner -name BC_dc  -timing_condition BC_tc  -rc_corner RCcorner_cbest
create_delay_corner -name LT_dc  -timing_condition LT_tc  -rc_corner RCcorner_cbest
create_delay_corner -name WCL_dc -timing_condition WCL_tc -rc_corner RCcorner_cworst
create_delay_corner -name ML_dc  -timing_condition ML_tc  -rc_corner RCcorner_cbest
create_delay_corner -name WCZ_dc -timing_condition WCZ_tc -rc_corner RCcorner_cworst


# Define a constraint mode and associate the specified SDC files with the constraint mode
create_constraint_mode -name standard_cm -sdc_files [ list ./constraints/design.sdc ]

# Create an analysis view (associate a list of operating corners with a given mode)
create_analysis_view -name TC_av  -delay_corner TC_dc  -constraint_mode standard_cm
create_analysis_view -name WC_av  -delay_corner WC_dc  -constraint_mode standard_cm
create_analysis_view -name BC_av  -delay_corner BC_dc  -constraint_mode standard_cm
create_analysis_view -name LT_av  -delay_corner LT_dc  -constraint_mode standard_cm
create_analysis_view -name WCL_av -delay_corner WCL_dc -constraint_mode standard_cm
create_analysis_view -name ML_av  -delay_corner ML_dc  -constraint_mode standard_cm
create_analysis_view -name WCZ_av -delay_corner WCZ_dc -constraint_mode standard_cm

# Define the analysis views to use for setup and hold analysis and optimization
set_analysis_view \
  -setup [ list WC_av WCL_av WCZ_av ] \
  -hold  [ list BC_av LT_av ML_av ] \
  -leakage ML_av \
  -dynamic LT_av
