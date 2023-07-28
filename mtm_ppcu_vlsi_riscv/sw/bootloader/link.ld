OUTPUT_ARCH(riscv)
SEARCH_DIR(.)

MEMORY
{
    boot_rom    : org = 0x00000000, len = 16k
    data_ram    : org = 0x40000000, len = 16k
}

_stack_start = ORIGIN(data_ram) + LENGTH(data_ram);

/* required to correctly link newlib */
GROUP( -lc -lgloss -lgcc -lsupc++ )

/* sections should be word-algined */
SECTIONS
{
    .vectors :
    {
        . = ORIGIN(boot_rom);
        KEEP(*(.vectors))
    } > boot_rom

    .text : {
        . = ALIGN(4);
        _stext = .;
        *(.text)
        *(.text.*)
        _etext  =  .;
        __CTOR_LIST__ = .;
        LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
        *(.ctors)
        LONG(0)
        __CTOR_END__ = .;
        __DTOR_LIST__ = .;
        LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2)
        *(.dtors)
        LONG(0)
        __DTOR_END__ = .;
        *(.lit)
        *(.shdata)
        . = ALIGN(4);
        _endtext = .;
    } > boot_rom

    .init_array :
    {
        . = ALIGN(4);
        _init_array_start = .;
        KEEP (*(.init_array*))
        . = ALIGN(4);
        _init_array_end = .;
    } > boot_rom

    .rodata : {
        . = ALIGN(4);
        *(.rodata);
        *(.rodata.*)
        . = ALIGN(4);
    } > boot_rom

     _sidata = LOADADDR(.data);

    .data : {
        . = ALIGN(4);
        sdata  =  .;
        _sdata  =  .;
        *(.data);
        *(.data.*)
        *(.sdata);
        *(.sdata.*)
        . = ALIGN(4);
        edata  =  .;
        _edata  =  .;
    } > data_ram AT > boot_rom

    .shbss :
    {
        . = ALIGN(4);
        *(.shbss)
        . = ALIGN(4);
    } > data_ram

    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > data_ram

    .stab  0 (NOLOAD) :
    {
        [ .stab ]
    }

    .stabstr  0 (NOLOAD) :
    {
        [ .stabstr ]
    }
}
