![ASIC](https://github.com/agh-riscv/mtm_ppcu_vlsi_riscv_teacher/actions/workflows/asic.yml/badge.svg)
![Sim](https://github.com/agh-riscv/mtm_ppcu_vlsi_riscv_teacher/actions/workflows/sim.yml/badge.svg)

# mtm_ppcu_vlsi_riscv

mtm_ppcu_vlsi_riscv is a repository used during MTM PPCU VLSI classes.

## Project cloning
```bash
git clone git@github.com:agh-riscv/mtm_ppcu_vlsi_riscv.git
```
or 
```bash
git clone https://github.com/agh-riscv/mtm_ppcu_vlsi_riscv.git
```

## Environment initialization
```bash
. env.sh
```

## Tools
### Software compilation
```bash
cmake -Ssw -Bsw/build
cmake --build sw/build/ -j $(nproc)
```

### Functional simulation
```bash
run_functional_sim.sh
```

### ASIC synthesis
```bash
run_asic_synth.sh
```

### ASIC implementation
```bash
run_asic_pr.sh
```

### Post-layout simulation
```bash
run_post_layout_sim.sh [-nt]
```

### Power analysis
```bash
run_power_analysis.sh
```

## Technology-related files

### IO cells
* DOC: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Documentation/documents/tpfn40lpgv2od3_120a
* LIB: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpfn40lpgv2od3_120a
* VERILOG: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/verilog/tpfn40lpgv2od3_120a

### Standard cell library
* DOC: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Documentation/documents/tcbn40lpbwp_200a
* LIB: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a
* VERILOG: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/verilog/tcbn40lpbwp_200a

### Analog IO cells
* DOC: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Documentation/documents/tpan40lpgv2od3_120a
* LIB: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/timing_power_noise/NLDM/tpan40lpgv2od3_120a
* VERILOG: /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/verilog/tpan40lpgv2od3_120a

### Application notes
* /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Documentation/application_notes


## Post-layout sim README.md
Recommended simulation strategy:

1. Simulations without timing checks and with debug (for simulation debug, the
fastest):
```bash
./run_post_layout_sim.sh -n -d
```

2. Simulations with timing checks (for implementation verfication) for minimum
and maximum delays
```bash
./run_post_layout_sim.sh -y MAX
./run_post_layout_sim.sh -y MIN
```

3. Simulations without timing checks and with TCF dump (very slow).
```bash
./run_post_layout_sim.sh -n -t
```
