#------------------------------------------------------------------------------
# (#03) CREATE FLOORPLAN
#------------------------------------------------------------------------------
# This is usefull if you run the script many times
delete_all_floorplan_objs
#kubo

# TODO: initialize floorplan to the required size
# Menu: Floorplan -> Specify Floorplan...
# Function: create_floorplan
create_floorplan -site core -box_size 0.0 0.0 1182.02 1182.02 189.98 189.98 992.04 992.04 291.06 291.06 890.96 890.96

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
read_io_file mtm_riscv_chip.io


# TODO: Add 12um placement halo around blocks to reserve the place for the power ring
# Menu: Floorplan -> Edit Flooplan -> Edit Halo...
# Function: create_place_halo
create_place_halo -halo_deltas {12 12 12 12} -cell TS1N40LPB4096X32M4M


# TODO: Set the desired location of the instruction RAM
#set myram0 [get_cells u_mtm_riscv_soc/u_peripherals_unit/u_memory_unit_u_instr_ram_u_ram/u_TS1N40LPB4096X32M4M]
set myram0 [get_cells u_soc/u_code_ram_u_ram/u_TS1N40LPB4096X32M4M]
set_db $myram0 .location {412.9825 362.465}

#set_obj_floorplan_box Instance u_soc/u_code_ram_u_ram/u_TS1N40LPB4096X32M4M 596.7515 640.424 731.1865 1132.919


# TODO: Set the desired location of the data RAM
set myram1 [get_cells u_soc/u_data_ram/u_ram/u_TS1N40LPB4096X32M4M]
set_db $myram1 .location {634.6715 362.465}


# TODO: Cut core rows to placement halo
# Menu: makes problems. Run this command:
split_row


# Core rings
# TODO: Create core rings for VDD and VSS. Use maximum width possible. Use several wires.
#       Use M6,M7,M8. M8 will cover M6
# Menu: Power -> Power Planning -> Add Ring …
# Functions: set_db, add_rings
set_db add_rings_target default ; set_db add_rings_extend_over_row 0 ; set_db add_rings_ignore_rows 0 ; set_db add_rings_avoid_short 0 ; set_db add_rings_skip_shared_inner_ring none ; set_db add_rings_stacked_via_top_layer AP ; set_db add_rings_stacked_via_bottom_layer M1 ; set_db add_rings_via_using_exact_crossover_size 1 ; set_db add_rings_orthogonal_only true ; set_db add_rings_skip_via_on_pin {  standardcell } ; set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VDD VDD VDD VDD VDD} -type core_rings -follow core -layer {top M7 bottom M7 left M6 right M6} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 10 bottom 10 left 10 right 10} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

set_db add_rings_target default ; set_db add_rings_extend_over_row 0 ; set_db add_rings_ignore_rows 0 ; set_db add_rings_avoid_short 0 ; set_db add_rings_skip_shared_inner_ring none ; set_db add_rings_stacked_via_top_layer AP ; set_db add_rings_stacked_via_bottom_layer M1 ; set_db add_rings_via_using_exact_crossover_size 1 ; set_db add_rings_orthogonal_only true ; set_db add_rings_skip_via_on_pin {  standardcell } ; set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VSS VSS VSS VSS VSS} -type core_rings -follow core -layer {top M7 bottom M7 left M6 right M6} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 50 bottom 50 left 50 right 50} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

set_db add_rings_target default ; set_db add_rings_extend_over_row 0 ; set_db add_rings_ignore_rows 0 ; set_db add_rings_avoid_short 0 ; set_db add_rings_skip_shared_inner_ring none ; set_db add_rings_stacked_via_top_layer AP ; set_db add_rings_stacked_via_bottom_layer M1 ; set_db add_rings_via_using_exact_crossover_size 1 ; set_db add_rings_orthogonal_only true ; set_db add_rings_skip_via_on_pin {  standardcell } ; set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VDD VDD VDD VDD VDD} -type core_rings -follow core -layer {top M7 bottom M7 left M8 right M8} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 10 bottom 10 left 10 right 10} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

set_db add_rings_target default ; set_db add_rings_extend_over_row 0 ; set_db add_rings_ignore_rows 0 ; set_db add_rings_avoid_short 0 ; set_db add_rings_skip_shared_inner_ring none ; set_db add_rings_stacked_via_top_layer AP ; set_db add_rings_stacked_via_bottom_layer M1 ; set_db add_rings_via_using_exact_crossover_size 1 ; set_db add_rings_orthogonal_only true ; set_db add_rings_skip_via_on_pin {  standardcell } ; set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VSS VSS VSS VSS VSS} -type core_rings -follow core -layer {top M7 bottom M7 left M8 right M8} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 50 bottom 50 left 50 right 50} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

# Add vertical stripes
# TODO: add vertical strips of width 3, with spacing 5 for VDD and VSS nets.
# Use M6.
# Keep the stripe pitch below 100 um.
# Note that the standard cells will also be connected to the core ring.
# Do not route the stripes over the blocks.
# Menu: Power -> Power planning -> Add stripe...
# Function: set_db, add_stripes
set_db add_stripes_break_at block_ring
add_stripes -direction vertical -layer M6 -nets {VDD VSS} -set_to_set_distance 50 -spacing 5 -start_offset 10 -start_from {left} -width 3 


add_stripes -direction horizontal -layer M7 -nets {VDD VSS} -set_to_set_distance 50 -spacing 5 -start_offset 15 -start_from {bottom} -width 3
