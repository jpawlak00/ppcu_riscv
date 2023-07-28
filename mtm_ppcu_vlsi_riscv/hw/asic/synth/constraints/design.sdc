# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Copyright 2021 AGH University of Science and Technology
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
set sdc_version 2.0

# Specify units used in SDC file
set_units -capacitance 1.0pF
set_units -time 1.0ns
set_time_unit -nanoseconds
set_load_unit -picofarads

# TODO: Create a clock object and define its waveform (freq = 50 MHz)
# You can get the source clock tree pin with the command: [get_pins u_pads_in/u_clk/C]
create_clock

# TODO: Specify the uncertainty on the clock network (setup: 0.1 Tclk,
# hold: 4-5x or T_hold_dff, e.g. 50ps)
set_clock_uncertainty
set_clock_uncertainty

# TODO: Specify the clock transition (slew) on the specified clock (100 ps for TSMC 40n)
set_clock_transition

# TODO: Specify the rise/fall time of 0.5 ns for all the input signals except the clock
set_input_transitio

# TODO: Constrain input ports within the desing relative to the clock edge (try 1/4 of Tclk)
set_input_delay

# TODO: Constrain output ports within the design relative to a clock edge (try 1/4 of Tclk)
set_output_delay 

# TODO: Constrain the output rise time to 1/5 of the clock period
set_max_transition

# TODO: Set the maximum fanout load limit to 4 for all the input ports
set_max_fanout

# TODO: Set the output capacitance connected to all the output ports to 30pF
set_load 

# Do not modify power pads (they are not connected during the synthesis).
set_dont_touch [get_cells u_pads_pwr]
