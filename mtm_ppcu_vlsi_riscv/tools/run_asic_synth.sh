#!/bin/bash
u Runs genus synthesis of the design. Default is batch mode.

# Commmand arguments:
# -g          - starts genus with gui
# -h          - display help

BATCH="-abort_on_error -no_gui -batch -files scripts/synthesize.tcl"

while getopts gh option
  do case "${option}" in
    g) BATCH="-gui";;
    *) echo -e "Valid option are: \n  -g - for GUI \n  -h - display this help"; 
       echo -e "Without options genus runs in batch mode."
       exit -1 ;;
  esac
done


cd $(dirname $(readlink -e "$0"))/../hw/asic/synth

# regenerate the netlist, if necessary
make -C rtl || { echo "error: netlist generation failed"; exit 1; }

source ../env.sh

#update nfs (if any)
ls -laR . >> /dev/null

# run synthesis in batch mode (exit after synthesis)
genus $BATCH -log genus_synth -overwrite

