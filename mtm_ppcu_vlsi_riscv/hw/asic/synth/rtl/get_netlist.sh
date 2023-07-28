#!/bin/bash
# This script generates one netlist file from all the sources
# based on the xrun log file.

#source xcelium to get xrun
source /cad/env/cadence_path.XCELIUM1909
PERL=/usr/bin/perl

# go to the script directory (if called from different dir)
cd "$(dirname "$0")"
source ../../../../env.sh
echo $PATH

#------------------------------------------------------------------------------
# read-only memeries generation
#------------------------------------------------------------------------------
function compile_program {
      cmake -S ../../../../sw -B ../../../../sw/build && \
      cmake --build ../../../../sw/build -j "$(nproc)"
}

function generate_boot_mem {
    boot_mem_generator.py ../../../../sw/build/bootloader/bootloader.bin ../../../rtl/soc/memories/boot_mem.sv
}

compile_program || { echo "error: programs compilation failed"; exit 1; }
generate_boot_mem || { echo "error: boot_mem generation failed"; exit 1; }

#------------------------------------------------------------------------------
# input data
#------------------------------------------------------------------------------
f1=../../../rtl/core/core.f
f2=../../../rtl/soc/soc.f
f3=../../../asic/rtl/_asic.f
top=mtm_riscv_chip
define=KMIE_IMPLEMENT_ASIC
netlist=netlist.sv

#------------------------------------------------------------------------------
# clean previous data
#------------------------------------------------------------------------------

rm -f $netlist src_file_list.txt

#------------------------------------------------------------------------------
# generate the file list from the xrun simulation log
#------------------------------------------------------------------------------

# compile
xrun \
  -clean \
  -compile \
  -F $f1 \
  -F $f2 \
  -F $f3 \
  -top $top \
  -define $define \
  # >> /dev/null

# check status
if [[ "$?" != "0" ]]; then
  echo COMPILATION ERROR!
  exit -1
fi

# File list preparing (include files + .v files)

$PERL -lane 'print $1 if /file: (.*)/' xrun.log >> src_file_list.txt

#------------------------------------------------------------------------------
# create single file netlist
#------------------------------------------------------------------------------

echo "\`define $define" > $netlist
cat src_file_list.txt | xargs cat >> $netlist

echo "Netlist created ($netlist)"

#------------------------------------------------------------------------------
# verify the netlist (elaborate)
#------------------------------------------------------------------------------

echo "------------------------------------------------------------------------------"
echo " Starting netlist verification ..."
TSMC_PARAMS=""
TSMC_PARAMS+=" -v /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/VERILOG/ts1n40lpb4096x32m4m_250a_tt1p1v25c.v"
TSMC_PARAMS+=" -v /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/verilog/tpfn40lpgv2od3_120a/tpfn40lpgv2od3.v"
TSMC_PARAMS+=" -timescale 1ns/1ps"

xrun \
  -elaborate $netlist $TSMC_PARAMS +nowarnTRNNOP \
  -clean \
  -top $top \
  #>> /dev/null

if [[ "$?" != "0" ]]; then
  echo "Netlist compilation failed."
  exit -1
fi

rm -rf xcelium.d
rm -f xrun.history

echo "------------------------------------------------------------------------------"
echo "-- FILES IN THE NETLIST ------------------------------------------------------"
echo "------------------------------------------------------------------------------"
cat src_file_list.txt
echo "------------------------------------------------------------------------------"
echo "-- Netlist verification successful"
echo "------------------------------------------------------------------------------"

exit 0
