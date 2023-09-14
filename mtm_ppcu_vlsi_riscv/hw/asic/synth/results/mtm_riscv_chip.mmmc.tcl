#################################################################################
#
# Created by Genus(TM) Synthesis Solution 19.11-s087_1 on Tue Sep 12 20:28:33 CEST 2023
#
#################################################################################

## library_sets
create_library_set -name TC_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwptc.lib }
create_library_set -name WC_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwpwc.lib }
create_library_set -name BC_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwpbc.lib }
create_library_set -name LT_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwplt.lib }
create_library_set -name WCL_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwpwcl.lib }
create_library_set -name ML_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwpml.lib }
create_library_set -name WCZ_stdcell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a/tcbn40lpbwpwcz.lib }
create_library_set -name TC_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_tt1p1v25c.lib }
create_library_set -name WC_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_ss0p99v125c.lib }
create_library_set -name BC_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_ff1p21v0c.lib }
create_library_set -name LT_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_ff1p21vm40c.lib }
create_library_set -name WCL_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_ss0p99vm40c.lib }
create_library_set -name ML_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_ff1p21v125c.lib }
create_library_set -name WCZ_mem_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/NLDM/ts1n40lpb4096x32m4m_250a_ss0p99v0c.lib }
create_library_set -name TC_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3tc1.lib }
create_library_set -name WC_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3wc1.lib }
create_library_set -name BC_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3bc1.lib }
create_library_set -name LT_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3lt1.lib }
create_library_set -name WCL_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3wcl1.lib }
create_library_set -name ML_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3ml1.lib }
create_library_set -name WCZ_iocell_libs \
    -timing { /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a/tpfn40lpgv2od3wcz1.lib }

## opcond
create_opcond -name TC_op_cond -process 1.0 -voltage 0.99 -temperature 25.0
create_opcond -name WC_op_cond -process 1.0 -voltage 0.99 -temperature 125.0
create_opcond -name BC_op_cond -process 1.0 -voltage 1.21 -temperature 0.0
create_opcond -name LT_op_cond -process 1.0 -voltage 1.21 -temperature -40.0
create_opcond -name WCL_op_cond -process 1.0 -voltage 0.99 -temperature -40.0
create_opcond -name ML_op_cond -process 1.0 -voltage 1.21 -temperature 125.0
create_opcond -name WCZ_op_cond -process 1.0 -voltage 0.99 -temperature 0.0

## timing_condition
create_timing_condition -name TC_tc \
    -opcond TC_op_cond \
    -library_sets { TC_stdcell_libs \
               TC_mem_libs \
               TC_iocell_libs }
create_timing_condition -name WC_tc \
    -opcond WC_op_cond \
    -library_sets { WC_stdcell_libs \
               WC_mem_libs \
               WC_iocell_libs }
create_timing_condition -name BC_tc \
    -opcond BC_op_cond \
    -library_sets { BC_stdcell_libs \
               BC_mem_libs \
               BC_iocell_libs }
create_timing_condition -name LT_tc \
    -opcond LT_op_cond \
    -library_sets { LT_stdcell_libs \
               LT_mem_libs \
               LT_iocell_libs }
create_timing_condition -name WCL_tc \
    -opcond WCL_op_cond \
    -library_sets { WCL_stdcell_libs \
               WCL_mem_libs \
               WCL_iocell_libs }
create_timing_condition -name ML_tc \
    -opcond ML_op_cond \
    -library_sets { ML_stdcell_libs \
               ML_mem_libs \
               ML_iocell_libs }
create_timing_condition -name WCZ_tc \
    -opcond WCZ_op_cond \
    -library_sets { WCZ_stdcell_libs \
               WCZ_mem_libs \
               WCZ_iocell_libs }

## rc_corner
create_rc_corner -name RCcorner_typical \
    -qrc_tech /cad/dk/PDK_CRN45GS_DGO_11_25/digital/QRC/8m_5x2z_alrdl/typical/qrcTechFile \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}
create_rc_corner -name RCcorner_cworst \
    -qrc_tech /cad/dk/PDK_CRN45GS_DGO_11_25/digital/QRC/8m_5x2z_alrdl/cworst/qrcTechFile \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}
create_rc_corner -name RCcorner_cbest \
    -qrc_tech /cad/dk/PDK_CRN45GS_DGO_11_25/digital/QRC/8m_5x2z_alrdl/cbest/qrcTechFile \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}
create_rc_corner -name RCcorner_rcworst \
    -qrc_tech /cad/dk/PDK_CRN45GS_DGO_11_25/digital/QRC/8m_5x2z_alrdl/rcworst/qrcTechFile \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}
create_rc_corner -name RCcorner_rcbest \
    -qrc_tech /cad/dk/PDK_CRN45GS_DGO_11_25/digital/QRC/8m_5x2z_alrdl/rcbest/qrcTechFile \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name TC_dc \
    -early_timing_condition { TC_tc } \
    -late_timing_condition { TC_tc } \
    -early_rc_corner RCcorner_typical \
    -late_rc_corner RCcorner_typical
create_delay_corner -name WC_dc \
    -early_timing_condition { WC_tc } \
    -late_timing_condition { WC_tc } \
    -early_rc_corner RCcorner_cworst \
    -late_rc_corner RCcorner_cworst
create_delay_corner -name BC_dc \
    -early_timing_condition { BC_tc } \
    -late_timing_condition { BC_tc } \
    -early_rc_corner RCcorner_cbest \
    -late_rc_corner RCcorner_cbest
create_delay_corner -name LT_dc \
    -early_timing_condition { LT_tc } \
    -late_timing_condition { LT_tc } \
    -early_rc_corner RCcorner_cbest \
    -late_rc_corner RCcorner_cbest
create_delay_corner -name WCL_dc \
    -early_timing_condition { WCL_tc } \
    -late_timing_condition { WCL_tc } \
    -early_rc_corner RCcorner_cworst \
    -late_rc_corner RCcorner_cworst
create_delay_corner -name ML_dc \
    -early_timing_condition { ML_tc } \
    -late_timing_condition { ML_tc } \
    -early_rc_corner RCcorner_cbest \
    -late_rc_corner RCcorner_cbest
create_delay_corner -name WCZ_dc \
    -early_timing_condition { WCZ_tc } \
    -late_timing_condition { WCZ_tc } \
    -early_rc_corner RCcorner_cworst \
    -late_rc_corner RCcorner_cworst

## constraint_mode
create_constraint_mode -name standard_cm \
    -sdc_files { results/mtm_riscv_chip.standard_cm.sdc }

## analysis_view
create_analysis_view -name TC_av \
    -constraint_mode standard_cm \
    -delay_corner TC_dc
create_analysis_view -name WC_av \
    -constraint_mode standard_cm \
    -delay_corner WC_dc
create_analysis_view -name BC_av \
    -constraint_mode standard_cm \
    -delay_corner BC_dc
create_analysis_view -name LT_av \
    -constraint_mode standard_cm \
    -delay_corner LT_dc
create_analysis_view -name WCL_av \
    -constraint_mode standard_cm \
    -delay_corner WCL_dc
create_analysis_view -name ML_av \
    -constraint_mode standard_cm \
    -delay_corner ML_dc
create_analysis_view -name WCZ_av \
    -constraint_mode standard_cm \
    -delay_corner WCZ_dc

## set_analysis_view
set_analysis_view -setup { WC_av WCL_av WCZ_av } \
                  -hold { BC_av LT_av ML_av } \
                  -leakage ML_av \
                  -dynamic LT_av
