#------------------------------------------------------------------------------
# TODO: check the place&route results directory
RESULTS_DIR=../../asic/pr/results_pr
DESIGN=mtm_riscv_chip
DUT_HINST=tb_mtm_riscv_soc.u_mtm_riscv_chip
#------------------------------------------------------------------------------
# TODO: check the netlist path
NETLIST=${RESULTS_DIR}/${DESIGN}.noPower.v.gz
# TODO: check the SDF file name
SDF=${DESIGN}.sdf.gz
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# SDF compilation and command file generation

THIS_DIR=`pwd`

# SDF files
SDF_SOURCE=$SDF
SDF_COMPILED=${SDF}.X
SDF_COMMAND=${DESIGN}.sdfcmd

#------------------------------------------------------------------------------
if [[ ! -e $NETLIST ]] ; then
  echo "ERROR: netlist does not exists ($NETLIST)"
  exit -1
fi
#------------------------------------------------------------------------------
if [[ ! -e $RESULTS_DIR/$SDF_SOURCE ]] ; then
  echo "ERROR: SDF file does not exists ($RESULTS_DIR/$SDF_SOURCE)."
  exit -1
fi


#------------------------------------------------------------------------------
# compile SDF file - DO IT ONLY ONCE and MODIFY THE .sdfcmd file to change the SCOPE
if [[ -e $THIS_DIR/$SDF_COMPILED && $THIS_DIR/$SDF_COMPILED -nt $RESULTS_DIR/$SDF_SOURCE ]]; then
  echo "SDF is already compiled." >> /dev/null
else
  ncsdfc $RESULTS_DIR/$SDF_SOURCE -output $THIS_DIR/$SDF_COMPILED -update
fi
#------------------------------------------------------------------------------
# generate SDF command (*.sdfcmd) file
echo -e \
COMPILED_SDF_FILE = \"$SDF_COMPILED\",\\n\
LOG_FILE = \"${DESIGN}_sdf.log\", \\n\
MTM_CONTROL = \"TOOL_CONTROL\",\\n\
SCOPE = ${DUT_HINST} \;  \
> $SDF_COMMAND


export XRUN_NETLIST_ARGS="\
+neg_check \
+sdf_file+$THIS_DIR/$SDF_COMPILED \
+xmsdf_cmd_file+$THIS_DIR/$SDF_COMMAND \
$NETLIST"
