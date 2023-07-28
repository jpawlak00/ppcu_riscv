#include <uart.hpp>
#include <common.hpp>
#include <memory_map.hpp>

static constexpr uint32_t cr_offset                 {0x000};
static constexpr uint32_t sr_offset                 {0x004};
static constexpr uint32_t tdr_offset                {0x008};
static constexpr uint32_t rdr_offset                {0x00c};
static constexpr uint32_t cdr_offset                {0x010};

static constexpr uint32_t cr_en_shift               {0};
static constexpr uint32_t cr_en_mask                {0x01};

static constexpr uint32_t sr_rxne_shift             {0};
static constexpr uint32_t sr_rxne_mask              {0x01};
static constexpr uint32_t sr_txact_shift            {1};
static constexpr uint32_t sr_txact_mask             {0x01};
static constexpr uint32_t sr_rxerr_shift            {2};
static constexpr uint32_t sr_rxerr_mask             {0x01};

static constexpr uint32_t tdr_data_shift            {0};
static constexpr uint32_t tdr_data_mask             {0xff};

static constexpr uint32_t rdr_data_shift            {0};
static constexpr uint32_t rdr_data_mask             {0xff};

static constexpr uint32_t cdr_div_shift             {0};
static constexpr uint32_t cdr_div_mask              {0xff};

Uart uart{uart_base_address};

Uart::Uart(uint32_t base_address)
    :   regs{reinterpret_cast<volatile uint32_t *>(base_address)}
{
    set_reg_bits(regs, cdr_offset, cdr_div_shift, cdr_div_mask, 12);
    set_reg_bits(regs, cr_offset, cr_en_shift, cr_en_mask, 1);
}

uint8_t Uart::read() const
{
    while (!is_receiver_ready()) { }
    return get_rdata();
}

int Uart::read(char *dest, int len) const
{
    for (int i = 0; i < len; ++i) {
        dest[i] = read();
        if (dest[i] == '\n') {
            dest[i] = '\0';
            return 0;
        } else if (dest[i] == '\b') {
            if (i)
                i -= 2;
            else
                i -= 1;
        }
    }
    return 1;
}

void Uart::write(uint8_t val) const
{
    while (is_transmitter_busy()) { }
    set_wdata(val);
}

void Uart::write(const char *src) const
{
    while (*src)
        write(*src++);
}

bool Uart::is_receiver_ready() const
{
    return get_reg_bits(regs, sr_offset, sr_rxne_shift, sr_rxne_mask);
}

uint8_t Uart::get_rdata() const
{
    return get_reg_bits(regs, rdr_offset, rdr_data_shift, rdr_data_mask);
}

bool Uart::is_transmitter_busy() const
{
    return get_reg_bits(regs, sr_offset, sr_txact_shift, sr_txact_mask);
}

void Uart::set_wdata(uint8_t val) const
{
    set_reg_bits(regs, tdr_offset, tdr_data_shift, tdr_data_mask, val);
}
