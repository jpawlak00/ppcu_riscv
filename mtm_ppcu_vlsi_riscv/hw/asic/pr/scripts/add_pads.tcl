set mtm_io_pad PAD70N_DS
set mtm_io_lib tpfn40lpgv2od3wc
set mtm_bond_pad_suffix _bondpad

delete_inst -inst *$mtm_bond_pad_suffix

# creating temporary bond pad instance to get the size
set bond_pad_cell MY_TMP_BONDPAD_12345
create_inst -cell $mtm_io_pad -inst $bond_pad_cell -location {500 500} -orient R0
set bond_pad_bbox_l [split [get_db [get_cells $bond_pad_cell] .bbox] " {}"]
set bond_pad_height [expr [lindex $bond_pad_bbox_l 4] - [lindex $bond_pad_bbox_l 2] ]
delete_inst -inst $bond_pad_cell

# io cells are located based on the lib name
set io_cell_names_l [get_db [get_lib_cells $mtm_io_lib/*] .base_name]

# search all the design to find the io cells by the name
foreach io_cell_name $io_cell_names_l {
  set design_io_cells_c [get_cells -hier -filter "@ref_lib_cell_name == $io_cell_name"]

  foreach_in_collection io_cell $design_io_cells_c {
      set io_cell_name [get_object_name $io_cell]
      puts $io_cell_name

      set io_location [get_db $io_cell .location]
      set io_location_l [split $io_location " {}"]
      set io_location_x [lindex $io_location_l 1]
      set io_location_y [lindex $io_location_l 2]
      set io_orient [string toupper [get_db $io_cell .orient] ]
      set pad_inst \\${io_cell_name}${mtm_bond_pad_suffix}\

      # Innovus sets the location to lower-left corner always.
      # Need to correct.
      set io_cell_bbox_l [split [get_db $io_cell .bbox] " {}"]

      if {[string equal $io_orient R0] || [string equal $io_orient R180]} {
        set io_height [expr [lindex $io_cell_bbox_l 4] - [lindex $io_cell_bbox_l 2] ]
        puts $io_height
      }
      if {[string equal $io_orient R90] || [string equal $io_orient R270]} {
        set io_height [expr [lindex $io_cell_bbox_l 3] - [lindex $io_cell_bbox_l 1] ]
        puts $io_height
      }

      switch $io_orient {
        R0 {
          set io_location_y [expr $io_location_y - $bond_pad_height]
        }
        R90 {
          set io_location_x [expr $io_location_x + $io_height]
        }
        R180 {
          set io_location_y [expr $io_location_y + $io_height]
        }
        R270 {
          set io_location_x [expr $io_location_x - $bond_pad_height]
        }
      }

      puts "Adding bond pad to: $io_cell_name"
      puts "     location: $io_location"
      puts "     orient  : $io_orient"
      puts "     pad_inst: $pad_inst"

      create_inst \
          -cell $mtm_io_pad \
          -inst $pad_inst \
          -location [list $io_location_x $io_location_y] \
          -orient $io_orient \
          -physical \
          -status fixed

  }
}
