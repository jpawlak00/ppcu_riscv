#pragma once

#include <cstdint>

class Uart final {
public:
    Uart(uint32_t base_address);
    Uart(const Uart &) = delete;
    Uart(Uart &&) = delete;
    Uart &operator=(const Uart &) = delete;
    Uart &operator=(Uart &&) = delete;

    uint8_t read() const;
    int read(char *dest, int len) const;
    void write(uint8_t val) const;
    void write(const char *src) const;

    bool is_receiver_ready() const;
    uint8_t get_rdata() const;
    bool is_transmitter_busy() const;
    void set_wdata(uint8_t val) const;

private:
    volatile uint32_t * const regs;
};

extern Uart uart;
