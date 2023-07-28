#!/bin/python3
#
# Copyright (C) 2022  AGH University of Science and Technology
#

import sys

depth = 4096

def read_bin_file(filename):
    file_content = []
    with open(filename, 'rb') as file:
        for _ in range(depth):
            file_content.append(int.from_bytes(file.read(4), "little"))
    return file_content

def generate_mem_file(filename, bin_file_content):
    with open(filename, 'w') as file:
        irom_init_file_content = ''
        for i in range(len(bin_file_content)):
            irom_init_file_content += '{:08x}\n'.format(bin_file_content[i])
        file.write(irom_init_file_content)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print('usage: {} <bin_file> <mem_file>'.format(sys.argv[0]))
        sys.exit()

    generate_mem_file(sys.argv[2], read_bin_file(sys.argv[1]))
