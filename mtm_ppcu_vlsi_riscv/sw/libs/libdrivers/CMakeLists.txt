cmake_minimum_required(VERSION 3.19)

add_library(libdrivers)

target_include_directories(libdrivers PUBLIC
    include
)

target_include_directories(libdrivers PRIVATE
    include/libdrivers
)

target_sources(libdrivers PRIVATE
    src/common.cpp
    src/code_ram.cpp
    src/gpio.cpp
    src/uart.cpp
)
