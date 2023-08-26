# ####################################################################

#  Created by Genus(TM) Synthesis Solution 19.11-s087_1 on Fri Aug 25 20:14:29 CEST 2023

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design mtm_riscv_chip

create_clock -name "clk1" -period 20.0 -waveform {0.0 10.0} [get_pins u_pads_in/u_clk/C]
set_clock_transition 0.1 [get_clocks clk1]
set_load -pin_load 30.0 [get_ports {gpio_dout[3]}]
set_load -pin_load 30.0 [get_ports {gpio_dout[2]}]
set_load -pin_load 30.0 [get_ports {gpio_dout[1]}]
set_load -pin_load 30.0 [get_ports {gpio_dout[0]}]
set_load -pin_load 30.0 [get_ports uart_sout]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports clk]
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports rst_n]
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_din[3]}]
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_din[2]}]
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_din[1]}]
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_din[0]}]
set_input_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports uart_sin]
set_output_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_dout[3]}]
set_output_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_dout[2]}]
set_output_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_dout[1]}]
set_output_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports {gpio_dout[0]}]
set_output_delay -clock [get_clocks clk1] -add_delay 5.0 [get_ports uart_sout]
set_max_fanout 4.000 [get_ports clk]
set_max_fanout 4.000 [get_ports rst_n]
set_max_fanout 4.000 [get_ports {gpio_din[3]}]
set_max_fanout 4.000 [get_ports {gpio_din[2]}]
set_max_fanout 4.000 [get_ports {gpio_din[1]}]
set_max_fanout 4.000 [get_ports {gpio_din[0]}]
set_max_fanout 4.000 [get_ports uart_sin]
set_max_transition 4.0 [get_ports {gpio_dout[3]}]
set_max_transition 4.0 [get_ports {gpio_dout[2]}]
set_max_transition 4.0 [get_ports {gpio_dout[1]}]
set_max_transition 4.0 [get_ports {gpio_dout[0]}]
set_max_transition 4.0 [get_ports uart_sout]
set_input_transition 0.5 [get_ports clk]
set_input_transition 0.5 [get_ports rst_n]
set_input_transition 0.5 [get_ports {gpio_din[3]}]
set_input_transition 0.5 [get_ports {gpio_din[2]}]
set_input_transition 0.5 [get_ports {gpio_din[1]}]
set_input_transition 0.5 [get_ports {gpio_din[0]}]
set_input_transition 0.5 [get_ports uart_sin]
set_wire_load_selection_group "WireAreaForZero" -library "tcbn40lpbwpwc"
set_wire_load_selection_group "WireAreaForZero" -library "tcbn40lpbwpwcl"
set_wire_load_selection_group "WireAreaForZero" -library "tcbn40lpbwpwcz"
set_wire_load_selection_group "WireAreaForZero" -library "tcbn40lpbwpml"
set_wire_load_selection_group "WireAreaForZero" -library "tcbn40lpbwplt"
set_clock_uncertainty -setup 2.0 [get_clocks clk1]
set_clock_uncertainty -hold 0.05 [get_clocks clk1]
