#include <gpio.hpp>
#include <common.hpp>
#include <memory_map.hpp>

static constexpr uint32_t odr_offset        {0x000};
static constexpr uint32_t idr_offset        {0x004};

Gpio gpio{gpio_base_address};

Gpio::Gpio(uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)}
{ }

void Gpio::set_odr(uint32_t val) const
{
    regs[odr_offset >> 2] = val;
}

uint32_t Gpio::get_idr() const
{
    return regs[idr_offset >> 2];
}

void Gpio::set_pin(uint8_t pin, bool val) const
{
    set_reg_bits(regs, odr_offset, pin, 0x01, val);
}

bool Gpio::get_pin(uint8_t pin) const
{
    return get_reg_bits(regs, idr_offset, pin, 0x01);
}

void Gpio::toggle_pin(uint8_t pin) const
{
    toggle_reg_bits(regs, odr_offset, pin, 0x01);
}
