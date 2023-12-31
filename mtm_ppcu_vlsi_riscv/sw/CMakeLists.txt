cmake_minimum_required(VERSION 3.19)

set(CMAKE_CXX_COMPILER /opt/riscv/bin/riscv32-unknown-elf-g++)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")

project(hpsd VERSION 1.0.0 LANGUAGES CXX ASM)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
    -fno-common \
    -fno-exceptions \
    -fno-non-call-exceptions \
    -fno-rtti \
    -fno-use-cxa-atexit \
    -fvisibility=hidden \
    -march=rv32i \
    -mabi=ilp32 \
    -mcmodel=medany \
    -nostdlib \
    -Os \
    -Wall \
    -Wextra \
    -Werror \
")

add_subdirectory(app)
add_subdirectory(bootloader)
add_subdirectory(libs)
