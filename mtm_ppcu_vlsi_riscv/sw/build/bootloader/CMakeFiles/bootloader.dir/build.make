# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.23

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/cmake-3.23.0-rc2-linux-x86_64/bin/cmake

# The command to remove a file.
RM = /usr/local/cmake-3.23.0-rc2-linux-x86_64/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build

# Include any dependencies generated for this target.
include bootloader/CMakeFiles/bootloader.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include bootloader/CMakeFiles/bootloader.dir/compiler_depend.make

# Include the progress variables for this target.
include bootloader/CMakeFiles/bootloader.dir/progress.make

# Include the compile flags for this target's objects.
include bootloader/CMakeFiles/bootloader.dir/flags.make

bootloader/CMakeFiles/bootloader.dir/crt0.S.o: bootloader/CMakeFiles/bootloader.dir/flags.make
bootloader/CMakeFiles/bootloader.dir/crt0.S.o: ../bootloader/crt0.S
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building ASM object bootloader/CMakeFiles/bootloader.dir/crt0.S.o"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-g++ $(ASM_DEFINES) $(ASM_INCLUDES) $(ASM_FLAGS) -o CMakeFiles/bootloader.dir/crt0.S.o -c /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader/crt0.S

bootloader/CMakeFiles/bootloader.dir/crt0.S.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing ASM source to CMakeFiles/bootloader.dir/crt0.S.i"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-g++ $(ASM_DEFINES) $(ASM_INCLUDES) $(ASM_FLAGS) -E /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader/crt0.S > CMakeFiles/bootloader.dir/crt0.S.i

bootloader/CMakeFiles/bootloader.dir/crt0.S.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling ASM source to assembly CMakeFiles/bootloader.dir/crt0.S.s"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-g++ $(ASM_DEFINES) $(ASM_INCLUDES) $(ASM_FLAGS) -S /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader/crt0.S -o CMakeFiles/bootloader.dir/crt0.S.s

bootloader/CMakeFiles/bootloader.dir/src/main.cpp.o: bootloader/CMakeFiles/bootloader.dir/flags.make
bootloader/CMakeFiles/bootloader.dir/src/main.cpp.o: ../bootloader/src/main.cpp
bootloader/CMakeFiles/bootloader.dir/src/main.cpp.o: bootloader/CMakeFiles/bootloader.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object bootloader/CMakeFiles/bootloader.dir/src/main.cpp.o"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT bootloader/CMakeFiles/bootloader.dir/src/main.cpp.o -MF CMakeFiles/bootloader.dir/src/main.cpp.o.d -o CMakeFiles/bootloader.dir/src/main.cpp.o -c /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader/src/main.cpp

bootloader/CMakeFiles/bootloader.dir/src/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/bootloader.dir/src/main.cpp.i"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader/src/main.cpp > CMakeFiles/bootloader.dir/src/main.cpp.i

bootloader/CMakeFiles/bootloader.dir/src/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/bootloader.dir/src/main.cpp.s"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader/src/main.cpp -o CMakeFiles/bootloader.dir/src/main.cpp.s

# Object files for target bootloader
bootloader_OBJECTS = \
"CMakeFiles/bootloader.dir/crt0.S.o" \
"CMakeFiles/bootloader.dir/src/main.cpp.o"

# External object files for target bootloader
bootloader_EXTERNAL_OBJECTS =

bootloader/bootloader: bootloader/CMakeFiles/bootloader.dir/crt0.S.o
bootloader/bootloader: bootloader/CMakeFiles/bootloader.dir/src/main.cpp.o
bootloader/bootloader: bootloader/CMakeFiles/bootloader.dir/build.make
bootloader/bootloader: libs/libmisc/liblibmisc.a
bootloader/bootloader: libs/libdrivers/liblibdrivers.a
bootloader/bootloader: bootloader/CMakeFiles/bootloader.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking CXX executable bootloader"
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/bootloader.dir/link.txt --verbose=$(VERBOSE)
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-objdump -SD bootloader > bootloader.dis
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && /opt/riscv/bin/riscv32-unknown-elf-objcopy -O binary bootloader bootloader.bin
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && bin_mem_converter.py bootloader.bin bootloader.mem

# Rule to build all files generated by this target.
bootloader/CMakeFiles/bootloader.dir/build: bootloader/bootloader
.PHONY : bootloader/CMakeFiles/bootloader.dir/build

bootloader/CMakeFiles/bootloader.dir/clean:
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader && $(CMAKE_COMMAND) -P CMakeFiles/bootloader.dir/cmake_clean.cmake
.PHONY : bootloader/CMakeFiles/bootloader.dir/clean

bootloader/CMakeFiles/bootloader.dir/depend:
	cd /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/bootloader /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader /home/student/jpawlak/PROJEKT_JP_2023/ppcu_riscv/mtm_ppcu_vlsi_riscv/sw/build/bootloader/CMakeFiles/bootloader.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : bootloader/CMakeFiles/bootloader.dir/depend

