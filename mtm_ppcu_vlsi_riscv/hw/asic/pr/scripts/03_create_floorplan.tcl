#------------------------------------------------------------------------------
# (#03) CREATE FLOORPLAN
#------------------------------------------------------------------------------
# This is usefull if you run the script many times
delete_all_floorplan_objs


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
set_db $myram0 .location {431.755 362.465}

#CLEAN #set_obj_floorplan_box Instance u_soc/u_code_ram_u_ram/u_TS1N40LPB4096X32M4M 596.7515 640.424 731.1865 1132.919

# TODO: Set the desired location of the data RAM
set myram1 [get_cells u_soc/u_data_ram/u_ram/u_TS1N40LPB4096X32M4M]
set_db $myram1 .location {634.670 362.465}


# TODO: Cut core rows to placement halo
# Menu: makes problems. Run this command:
split_row


# Core rings
# TODO: Create core rings for VDD and VSS. Use maximum width possible. Use several wires.
#       Use M6,M7,M8. M8 will cover M6
# Menu: Power -> Power Planning -> Add Ring …
# Functions: set_db, add_rings

# internal VDD ring M6-M7
set_db add_rings_target default ; set_db add_rings_extend_over_row 0 ; set_db add_rings_ignore_rows 0 ; set_db add_rings_avoid_short 0 ; set_db add_rings_skip_shared_inner_ring none ; set_db add_rings_stacked_via_top_layer AP ; set_db add_rings_stacked_via_bottom_layer M1 ; set_db add_rings_via_using_exact_crossover_size 1 ; set_db add_rings_orthogonal_only true ; set_db add_rings_skip_via_on_pin {  standardcell } ; set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets VDD -type core_rings -follow core -layer {top M7 bottom M7 left M6 right M6} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 10 bottom 10 left 10 right 10} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none -use_wire_group 1 -use_wire_group_bits 5

# internal VDD overlapping ring M8 (M7-M8)
add_rings -nets VDD -type core_rings -follow core -layer {top M7 bottom M7 left M8 right M8} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 10 bottom 10 left 10 right 10} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none -use_wire_group 1 -use_wire_group_bits 5

# external VSS ring M6-M7
add_rings -nets VSS -type core_rings -follow core -layer {top M7 bottom M7 left M6 right M6} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 50 bottom 50 left 50 right 50} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none -use_wire_group 1 -use_wire_group_bits 5

# internal VSS overlapping ring M8 (M7-M8)
add_rings -nets VSS -type core_rings -follow core -layer {top M7 bottom M7 left M8 right M8} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 3 bottom 3 left 3 right 3} -offset {top 50 bottom 50 left 50 right 50} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none -use_wire_group 1 -use_wire_group_bits 5

# RAM rings
# TODO: Create rings of 4.5um width around the RAM blocks. Extend the vertical
# connections upwards and downwords to the core ring. Use M6 and M7
# Menu: Power -> Power Planning -> Add Ring …
# Functions: set_db, add_rings
set_db add_rings_target default ; set_db add_rings_extend_over_row 0 ; set_db add_rings_ignore_rows 0 ; set_db add_rings_avoid_short 0 ; set_db add_rings_skip_shared_inner_ring none ; set_db add_rings_stacked_via_top_layer AP ; set_db add_rings_stacked_via_bottom_layer M1 ; set_db add_rings_via_using_exact_crossover_size 1 ; set_db add_rings_orthogonal_only true ; set_db add_rings_skip_via_on_pin {  standardcell } ; set_db add_rings_skip_via_on_wire_shape {  noshape }
add_rings -nets {VDD VSS} -type block_rings -around each_block -layer {top M7 bottom M7 left M6 right M6} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 1.5 bottom 1.5 left 1.5 right 1.5} -offset {top 1.5 bottom 1.5 left 1.5 right 1.5} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

#add_rings -nets VSS -type block_rings -around each_block -layer {top M7 bottom M7 left M6 right M6} -width {top 4.5 bottom 4.5 left 4.5 right 4.5} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 6.3 bottom 6.3 left 6.3 right 6.3} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none


# Add vertical stripes
# TODO: add vertical strips of width 3, with spacing 5 for VDD and VSS nets.
# Use M6.
# Keep the stripe pitch below 100 um.
# Note that the standard cells will also be connected to the core ring.
# Do not route the stripes over the blocks.
# Menu: Power -> Power planning -> Add stripe...
# Function: set_db, add_stripes

set_db add_stripes_ignore_block_check false ; set_db add_stripes_break_at block_ring ; set_db add_stripes_route_over_rows_only false ; set_db add_stripes_rows_without_stripes_only false ; set_db add_stripes_extend_to_closest_target none ; set_db add_stripes_stop_at_last_wire_for_area false ; set_db add_stripes_partial_set_through_domain false ; set_db add_stripes_ignore_non_default_domains false ; set_db add_stripes_trim_antenna_back_to_shape none ; set_db add_stripes_spacing_type edge_to_edge ; set_db add_stripes_spacing_from_block 0 ; set_db add_stripes_stripe_min_length stripe_width ; set_db add_stripes_stacked_via_top_layer AP ; set_db add_stripes_stacked_via_bottom_layer M1 ; set_db add_stripes_via_using_exact_crossover_size false ; set_db add_stripes_split_vias false ; set_db add_stripes_orthogonal_only true ; set_db add_stripes_allow_jog { padcore_ring  block_ring } ; set_db add_stripes_skip_via_on_pin {  standardcell } ; set_db add_stripes_skip_via_on_wire_shape {  noshape   }
#add_stripes -nets {VDD VSS} -layer M6 -direction vertical -width 3 -spacing 5 -set_to_set_distance 100 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit AP -pad_core_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid none
# CLEAN set_db add_stripes_break_at block_ring
add_stripes -direction vertical -layer M6 -nets {VDD VSS} -set_to_set_distance 50 -spacing 5 -start_offset 5 -start_from {left} -width 3 

# Add stripes horizontal
# TODO: add horizontal strips of width 3, with spacing 5 for VDD and VSS nets.
# Use M7.
# Keep the stripe pitch below 100 um.
# Do not route the stripes over the blocks.
# Function: set_db, add_stripes
add_stripes -direction horizontal -layer M7 -nets {VDD VSS} -set_to_set_distance 50 -spacing 5 -start_offset 30 -start_from {bottom} -width 3


# TODO: Connect pads to ring
# Menu: Route -> Special route...
# Basic -> SRoute = Pad Pins
# Basic -> Allow Layer Change = Off
# Advanced -> Pad Pins -> Number of connections to Multiple Geometries = All
# Function: route_special
set_db route_special_via_connect_to_shape { noshape }
route_special -connect {pad_pin} -layer_change_range { M1(1) AP(9) } -block_pin_target {nearest_target} -pad_pin_port_connect {all_port all_geom} -pad_pin_target {nearest_target} -allow_jogging 1 -crossover_via_layer_range { M1(1) AP(9) } -nets { VSS VDD } -allow_layer_change 0 -target_via_layer_range { M1(1) AP(9) }

# TODO: Connect RAM block powers
# Menu: Route -> Special route...
# Basic -> SRoute = Block Pins
# Basic -> Allow Layer Change = Off
# Advanced -> Block Pins -> Pin selection = All Pins
# Function: route_special
#set_db route_special_via_connect_to_shape { noshape }
route_special -connect {block_pin} -layer_change_range { M1(1) AP(9) } -block_pin_target {nearest_target} -allow_jogging 1 -crossover_via_layer_range { M1(1) AP(9) } -nets { VDD VSS } -allow_layer_change 0 -block_pin all -target_via_layer_range { M1(1) AP(9) }



# TODO: Connect standard cell power
# Menu: Route -> Special route...
# Basic -> SRoute = Follow Pins
# Basic -> Allow Layer Change = Off
# Via Generation -> Make Via Connection to: = Core Ring, Stripe
# Functions: set_db, route_special
set_db route_special_via_connect_to_shape { ring stripe }
route_special -connect {core_pin} -layer_change_range { M1(1) AP(9) } -block_pin_target {nearest_target} -core_pin_target {first_after_row_end} -allow_jogging 1 -crossover_via_layer_range { M1(1) AP(9) } -nets { VSS VDD } -allow_layer_change 0 -target_via_layer_range { M1(1) AP(9) }

# save database
write_db $saveDir/${DESIGN}_03_floorplan.db

