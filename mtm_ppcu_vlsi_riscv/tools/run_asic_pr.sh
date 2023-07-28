#!/bin/bash
# Runs innovus p&r for the design. Default is batch mode.

# Commmand arguments:
# -g          - starts innovus with gui
# -h          - display help

BATCH="-abort_on_error -files ./scripts/run_pr.tcl"

while getopts gh option
  do case "${option}" in
    g) BATCH="";;
    *) echo -e "Valid option are: \n  -g - for GUI \n  -h - display this help"; 
       echo -e "Without options innovus runs in batch mode.";
       exit -1 ;;
  esac
done


cd $(dirname $(readlink -e "$0"))/../hw/asic/pr

source ../env.sh

#update nfs (if any)
ls -laR . >> /dev/null

innovus -stylus $BATCH -log innovus_riscv -overwrite

