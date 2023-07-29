#include <libdrivers/gpio.hpp>
#include <libdrivers/uart.hpp>
#include <libmisc/delay.hpp>

// jan      .--- .- -.
// pawlak   .--. .- .-- .-.. .- -.-

#define MAX_SOS_LVL 30
#define MAX_NAME_LVL 30
#define MAX_SURNAME_LVL 64

char name[] = ".--- .- -.";
char surname[] = ".--. .- .-- .-.. .- -.-";
char sos[] = "... --- ...";

char sos_lvl[MAX_SOS_LVL];
char name_lvl[MAX_NAME_LVL];
char surname_lvl[MAX_SURNAME_LVL];

static constexpr uint32_t led_mask{0xf};
int pins = 0;  

void get_levels(char*, char*);

int main()
{
    uart.write("INFO: application started\n");
    get_levels(sos, sos_lvl);
    get_levels(name, name_lvl);
    get_levels(surname, surname_lvl);

    while (true)
    {
        mdelay(1);
        //gpio.set_pin(0, 1);                         //sending
        for (int i = 0; i < MAX_SURNAME_LVL; i++)
        {
            pins = 0b0001;
            
            if (i < MAX_SOS_LVL)
            {
                if (sos_lvl[i] == '1') pins += 0b0010;
            }

            if (i < MAX_NAME_LVL)
            {
                if (name_lvl[i] == '1') pins += 0b0100;
            }

            if (surname_lvl[i] == '1') pins += 0b1000;
            
            gpio.set_odr(pins & led_mask);
            mdelay(1);
        }
        
        gpio.set_odr(0b0000 & led_mask); // not sending
        return 0;
    }
}

void get_levels(char* name, char* name_levels)
{
    int ctr = 0;
    for (int i = 0; *(name + i) != 0; i++)
    {
        if (name[i] == '.')
        {
            *(name_levels + ctr) = '1';
            *(name_levels + ++ctr) = '0';
            ctr++;
        }
        else if (name[i] == '-')
        {
            *(name_levels + ctr) = '1';
            *(name_levels + ++ctr) = '1';
            *(name_levels + ++ctr) = '1';
            *(name_levels + ++ctr) = '0';
            ctr++;
        }
        else if (name[i] == ' ')
        {
            *(name_levels + ctr) = '0';
            *(name_levels + ++ctr) = '0';
            ctr++;
        }
    }
}

