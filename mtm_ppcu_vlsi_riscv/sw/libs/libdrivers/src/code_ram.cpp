#include <code_ram.hpp>
#include <memory_map.hpp>

static constexpr int code_ram_depth         {4096};
static constexpr int code_ram_word_length   {4};

Code_ram code_ram{code_ram_base_address, code_ram_depth * code_ram_word_length};

Code_ram::Code_ram(uint32_t base_address, uint32_t size)
    :   mem{reinterpret_cast<volatile uint32_t *>(base_address)}, size{size}
{ }

uint32_t Code_ram::read(uint32_t offset) const
{
    return mem[offset >> 2];
}

void Code_ram::write(uint32_t offset, uint32_t val) const
{
     mem[offset >> 2] = val;
}

uint32_t Code_ram::get_size() const
{
    return size;
}
