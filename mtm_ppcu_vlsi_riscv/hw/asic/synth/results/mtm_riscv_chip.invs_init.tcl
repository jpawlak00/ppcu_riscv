################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 09/12/2023 20:28:35
#
################################################################################

      if { ![is_common_ui_mode] } {
        error "This script must be loaded into an 'innovus -stylus' session."
      }
    


read_mmmc results/mtm_riscv_chip.mmmc.tcl

read_physical -lef {/cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tcbn40lpbwp_120c/lef/HVH_0d5_0/tcbn40lpbwp_8lm5X2ZRDL.lef /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tpfn40lpgv2od3_120a/mt_2/8lm/lef/tpfn40lpgv2od3_8lm.lef /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tpfn40lpgv2od3_120a/mt_2/8lm/lef/antenna_8lm.lef /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Back_End/lef/tpbn45v_ds_150a/wb/8m/8M_5X2Z/lef/tpbn45v_ds_8lm.lef /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/LEF/ts1n40lpb4096x32m4m_250a_4m.lef}

read_netlist results/mtm_riscv_chip.v

init_design
