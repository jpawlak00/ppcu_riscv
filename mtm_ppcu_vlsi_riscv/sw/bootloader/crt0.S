.section .text
.org 0x00

/* set all registers to zero (x0 is hardwired to zero) */
    mv      x1,     x0
    mv      x2,     x0
    mv      x3,     x0
    mv      x4,     x0
    mv      x5,     x0
    mv      x6,     x0
    mv      x7,     x0
    mv      x8,     x0
    mv      x9,     x0
    mv      x10,    x0
    mv      x11,    x0
    mv      x12,    x0
    mv      x13,    x0
    mv      x14,    x0
    mv      x15,    x0
    mv      x16,    x0
    mv      x17,    x0
    mv      x18,    x0
    mv      x19,    x0
    mv      x20,    x0
    mv      x21,    x0
    mv      x22,    x0
    mv      x23,    x0
    mv      x24,    x0
    mv      x25,    x0
    mv      x26,    x0
    mv      x27,    x0
    mv      x28,    x0
    mv      x29,    x0
    mv      x30,    x0
    mv      x31,    x0

/* stack initilization */
    la      sp,     _stack_start

/* BSS clearing */
    la      t0,     _bss_start
    la      t1,     _bss_end

    bge     t0,     t1,     bss_clear_loop_end
bss_clear_loop:
    sw      x0,     0(t0)
    addi    t0,     t0,     4
    ble     t0,     t1,     bss_clear_loop
bss_clear_loop_end:

/* data initilization */
    la      t0,     _sidata
    la      t1,     _sdata
    la      t2,     _edata

    bge     t1,     t2,     data_init_loop_end
data_init_loop:
    lw      t3,     0(t0)
    sw      t3,     0(t1)
    addi    t0,     t0,     4
    addi    t1,     t1,     4
    blt     t1,     t2,     data_init_loop
data_init_loop_end:

/* objects construction */
    la      t0,     _init_array_start
    la      t1,     _init_array_end

    bge     t0,     t1,     objects_construction_loop_end
objects_construction_loop:
    lw      a5,     0(t0)
    jalr    a5
    addi    t0,     t0,     4
    blt     t0,     t1,     objects_construction_loop
objects_construction_loop_end:

/* jump to main program entry point (argc = argv = 0) */
main_entry:
    addi    a0,     x0,     0
    addi    a1,     x0,     0
    jal     x1,     main
