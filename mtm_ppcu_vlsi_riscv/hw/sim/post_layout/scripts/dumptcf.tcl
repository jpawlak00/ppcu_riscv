# dump net switching activity into a file
# (to be used for dynamic power estimation)
dumptcf \
  -scope u_mtm_riscv_chip \
  -compress \
  -inctoggle \
  -overwrite \
  -dumpwireasnet \
  -output mtm_riscv_chip.tcf

# run simulation
run

# finish
exit
