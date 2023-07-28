cmake_minimum_required(VERSION 3.19)

add_library(libmisc)

target_link_libraries(libmisc PRIVATE
    libdrivers
)

target_include_directories(libmisc PUBLIC
    include
)

target_include_directories(libmisc PRIVATE
    include/libmisc
)

target_sources(libmisc PRIVATE
    src/delay.cpp
)
