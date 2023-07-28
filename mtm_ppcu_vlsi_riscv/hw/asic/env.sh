source /cad/etc/lm_license_file

# this was necessary for innovus 17. Not checked if needed for 19
export LD_LIBRARY_PATH=/cad/INNOVUS191/tools/lib/64bit

export PATH=\
/cad/INNOVUS191/tools/bin:\
/cad/GENUS191/tools/bin:\
/cad/EXT191/tools/bin:\
/cad/CONFRML191/tools/bin:\
/cad/SSV191/tools/bin:\
/cad/MODUS191/tools/bin:\
/cad/XCELIUM1909/tools/bin:\
$PATH

export FE_TMPDIR=/tmp
