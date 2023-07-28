#include <delay.hpp>

static void execute_10_cycles_loop(uint32_t iterations)
{
    int out;  /* only to notify compiler of modifications to |loops| */
    asm volatile (
        "1: nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   nop             \n"
        "   addi %1, %1, -1 \n"
        "   bnez %1, 1b     \n"
        : "=&r" (out)
        : "0" (iterations)
    );
}

void mdelay(uint32_t msec)
{
    execute_10_cycles_loop(msec * 5000);
}

void udelay(uint32_t usec)
{
    execute_10_cycles_loop(usec * 5);
}
