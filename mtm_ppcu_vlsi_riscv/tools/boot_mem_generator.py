#!/bin/python3
#
# Copyright (C) 2023  AGH University of Science and Technology
#

import sys

depth = 4096

def read_bin_file(filename):
    file_content = []
    with open(filename, 'rb') as file:
        for _ in range(depth):
            file_content.append(int.from_bytes(file.read(4), "little"))
    return file_content

def get_file_header():
    header = '''\
/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

'''
    return header

def get_module_prologue():
    module_definition = f'''\
module boot_mem (
    output logic [31:0] rdata,
    input logic [31:0]  addr
);


'''
    return module_definition

def get_module_internal_logic(bin_file_content):
    module_internal_logic = f'''\
/**
 * Module internal logic
 */

always_comb begin
    case (addr[13:2])
'''

    for i in range(len(bin_file_content)):
        module_internal_logic += f'        {i:4}:    rdata = 32\'h{bin_file_content[i]:08x};\n'

    module_internal_logic += '''\
        default: rdata = 32'h00000000;
    endcase
end

'''
    return module_internal_logic

def get_module_epilogue():
    module_epilogue = '''\
endmodule
'''
    return module_epilogue

def generate_mem_file(filename, bin_file_content):
    with open(filename, 'w') as file:
        irom_init_file_content = ''
        for i in range(len(bin_file_content)):
            irom_init_file_content += '{:08x}\n'.format(bin_file_content[i])
        file.write(irom_init_file_content)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print('usage: {} <bootloader_bin_file> <boot_mem_filepath>'.format(sys.argv[0]))
        sys.exit()

    bin_file_content = read_bin_file(sys.argv[1])
    boot_mem_file_content = get_file_header()
    boot_mem_file_content += get_module_prologue()
    boot_mem_file_content += get_module_internal_logic(bin_file_content)
    boot_mem_file_content += get_module_epilogue()

    with open(sys.argv[2], 'w') as boot_mem_file:
        boot_mem_file.write(boot_mem_file_content)
