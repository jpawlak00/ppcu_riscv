cmake_minimum_required(VERSION 3.19)

string(REGEX MATCH "[^\/]+$" app "${CMAKE_CURRENT_LIST_DIR}")

add_executable(${app})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
    -Wl,-Map=${app}.map \
")

target_link_options(${app} PRIVATE
    -T ${CMAKE_CURRENT_SOURCE_DIR}/link.ld
)

target_link_libraries(${app} PRIVATE
    libs
)

target_sources(${app} PRIVATE
    crt0.S
    src/main.cpp
)

add_custom_command(TARGET ${app} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -SD ${app} > ${app}.dis
    COMMAND ${CMAKE_OBJCOPY} -O binary ${app} ${app}.bin
    COMMAND bin_mem_converter.py ${app}.bin ${app}.mem
)
