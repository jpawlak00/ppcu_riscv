#pragma once

#include <cstdint>

uint32_t get_reg_bits(volatile uint32_t *regs, uint32_t offset, uint8_t shift, uint32_t mask);
void set_reg_bits(volatile uint32_t *regs, uint32_t offset, uint8_t shift, uint32_t mask, uint32_t val);
void toggle_reg_bits(volatile uint32_t *regs, uint32_t offset, uint8_t shift, uint32_t mask);
