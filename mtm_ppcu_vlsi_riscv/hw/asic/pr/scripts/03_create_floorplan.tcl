#------------------------------------------------------------------------------
# (#03) CREATE FLOORPLAN
#------------------------------------------------------------------------------
# This is usefull if you run the script many times
delete_all_floorplan_objs


# TODO: initialize floorplan to the required size
# Menu: Floorplan -> Specify Floorplan...
# Function: create_floorplan


# TODO: Generate template for IO placement:
# Menu: File -> Save -> IO File... , check the boxes: sequence, Generate template IO File"
#
# TODO: copy the generated IO template to the file: mtm_riscv_chip.io
# TODO: Edit the file.
#       Add 'offset = 190' option to each first pad in the io row (after place_status=).
#       Add 'space = N' option to each second pad in the io row. N is the
#       distance to the previous pad in the row.


# TODO: Read created IO configuration. You can do this many times
# Menu: File -> Load -> I/O File...
# Function: read_io_file


# TODO: Add 12um placement halo around blocks to reserve the place for the power ring
# Menu: Floorplan -> Edit Flooplan -> Edit Halo...
# Function: create_place_halo


# TODO: Set the desired location of the instruction RAM
set myram0 [get_cells u_mtm_riscv_soc/u_peripherals_unit/u_memory_unit_u_instr_ram_u_ram/u_TS1N40LPB4096X32M4M]
set_db $myram0 .location {0 0}

# TODO: Set the desired location of the data RAM
set myram1 [get_cells u_mtm_riscv_soc/u_peripherals_unit/u_memory_unit_u_data_ram/u_ram/u_TS1N40LPB4096X32M4M]
set_db $myram1 .location {0 0}


# TODO: Cut core rows to placement halo
# Menu: makes problems. Run this command:
split_row


# Core rings
# TODO: Create core rings for VDD and VSS. Use maximum width possible. Use several wires.
#       Use M6,M7,M8. M8 will cover M6
# Menu: Power -> Power Planning -> Add Ring …
# Functions: set_db, add_rings


# RAM rings
# TODO: Create rings of 4.5um width around the RAM blocks. Extend the vertical
# connections upwards and downwords to the core ring. Use M6 and M7
# Menu: Power -> Power Planning -> Add Ring …
# Functions: set_db, add_rings


# Add vertical stripes
# TODO: add vertical strips of width 3, with spacing 5 for VDD and VSS nets.
# Use M6.
# Keep the stripe pitch below 100 um.
# Note that the standard cells will also be connected to the core ring.
# Do not route the stripes over the blocks.
# Menu: Power -> Power planning -> Add stripe...
# Function: set_db, add_stripes


# Add stripes horizontal
# TODO: add horizontal strips of width 3, with spacing 5 for VDD and VSS nets.
# Use M7.
# Keep the stripe pitch below 100 um.
# Do not route the stripes over the blocks.
# Function: set_db, add_stripes


# TODO: Connect pads to ring
# Menu: Route -> Special route...
# Basic -> SRoute = Pad Pins
# Basic -> Allow Layer Change = Off
# Advanced -> Pad Pins -> Number of connections to Multiple Geometries = All
# Function: route_special


# TODO: Connect RAM block powers
# Menu: Route -> Special route...
# Basic -> SRoute = Block Pins
# Basic -> Allow Layer Change = Off
# Advanced -> Block Pins -> Pin selection = All Pins
# Function: route_special


# TODO: Connect standard cell power
# Menu: Route -> Special route...
# Basic -> SRoute = Follow Pins
# Basic -> Allow Layer Change = Off
# Via Generation -> Make Via Connection to: = Core Ring, Stripe
# Functions: set_db, route_special

# save database
write_db $saveDir/${DESIGN}_03_floorplan.db
