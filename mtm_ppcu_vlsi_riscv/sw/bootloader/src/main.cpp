#include <libdrivers/code_ram.hpp>
#include <libdrivers/gpio.hpp>
#include <libdrivers/uart.hpp>

int main()
{
    uart.write("INFO: bootloader started\n");

    if (gpio.get_pin(3)) {
        uart.write("INFO: codeload skipped\n");
    } else {
        uart.write("INFO: codeload started\n");

        for (uint32_t i = 0; i < code_ram.get_size(); i += 4) {
            union {
                uint8_t bytes[4];
                uint32_t word;
            } code_ram_word;

            for (int j = 0; j < 4; ++j) {
                while (!uart.is_receiver_ready()) { }
                code_ram_word.bytes[j] = uart.get_rdata();
            }
            code_ram.write(i, code_ram_word.word);
        }

        uart.write("INFO: codeload finished\n");
    }

    asm ("j 0x10000");
}
