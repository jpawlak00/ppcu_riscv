#!/bin/bash

cd $(dirname $(readlink -e "$0"))/../hw/power_analysis

#update nfs (if any)
ls -laR . >> /dev/null

# link timing database from place&route
if [[ ! -e ecoTimingDB ]] ; then
  ln -sf ../asic/pr/ecoTimingDB .
fi

#------------------------------------------------------------------------------
# Set paths.
source ../asic/env.sh


#------------------------------------------------------------------------------
# Batch run (use it to automatize the flow)
innovus -stylus -abort_on_error -no_gui -files ./scripts/run_power.tcl -log innovus_mtm -overwrite

#------------------------------------------------------------------------------
# Interactive run with automatic starting of the scripts.
# The script execution can be stopped with "suspend" command in the script, and
# resumed with "resume" command.
# The GUI is open with "gui_show", and closed with "gui_hide" commands.

# innovus -stylus -abort_on_error -files ./scripts/run_power.tcl -log innovus_mtm -overwrite


#------------------------------------------------------------------------------
# Just start innovus

# innovus -stylus -log innovus_mtm -overwrite
