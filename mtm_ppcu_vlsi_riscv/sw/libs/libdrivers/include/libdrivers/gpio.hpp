#pragma once

#include <cstdint>

class Gpio final {
public:
    Gpio(uint32_t base_address);
    Gpio(const Gpio &) = delete;
    Gpio(Gpio &&) = delete;
    Gpio &operator=(const Gpio &) = delete;
    Gpio &operator=(Gpio &&) = delete;

    void set_odr(uint32_t val) const;
    uint32_t get_idr() const;

    void set_pin(uint8_t pin, bool val) const;
    bool get_pin(uint8_t pin) const;
    void toggle_pin(uint8_t pin) const;

private:
    volatile uint32_t * const regs;
};

extern Gpio gpio;
