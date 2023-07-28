SHELL=/bin/bash

NETLIST=netlist.sv

# disabling defaults suffixes
.SUFFIXES:

${NETLIST} : get_netlist.sh \
../../../rtl/core/alu.sv \
../../../rtl/core/core.sv \
../../../rtl/core/core_pkg.sv \
../../../rtl/core/cu.sv \
../../../rtl/core/data_bus.sv \
../../../rtl/core/idu.sv \
../../../rtl/core/ifu.sv \
../../../rtl/core/instr_bus.sv \
../../../rtl/core/lsu.sv \
../../../rtl/core/rf.sv \
../../../rtl/soc/gpio/gpio.sv \
../../../rtl/soc/gpio/gpio_csr.sv \
../../../rtl/soc/memories/asic/ram.sv \
../../../rtl/soc/memories/boot_rom.sv \
../../../rtl/soc/memories/code_ram.sv \
../../../rtl/soc/memories/data_ram.sv \
../../../rtl/soc/uart/uart.sv \
../../../rtl/soc/uart/uart_clock_generator.sv \
../../../rtl/soc/uart/uart_csr.sv \
../../../rtl/soc/uart/uart_receiver.sv \
../../../rtl/soc/uart/uart_transmitter.sv \
../../../rtl/soc/data_bus_arbiter.sv \
../../../rtl/soc/instr_bus_arbiter.sv \
../../../rtl/soc/memory_map.sv \
../../../rtl/soc/soc.sv
	./get_netlist.sh

clean:
	rm -f ${NETLIST} src_file_list.txt xrun.log
	rm -rf xcelium.d
