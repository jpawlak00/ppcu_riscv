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

int main()
{
    uart.write("INFO: application started\n");
    get_levels(sos, sos_lvl);
    get_levels(name, name_lvl);
    get_levels(surname, surname_lvl);

    while (true)
    {
        mdelay(1);
        gpio.set_pin(0, 1);                         //sending
        for (int i = 0; i < MAX_SURNAME_LVL; i++)
        {
            if (i < MAX_SOS_LVL)
            {
                sos_lvl[i] == '1' ? gpio.set_pin(1, 1) : gpio.set_pin(1, 0);
            }
            else
            {
                gpio.set_pin(1, 0);
            }

            if (i < MAX_NAME_LVL)
            {
                name_lvl[i] == '1' ? gpio.set_pin(2, 1) : gpio.set_pin(2, 0);
            }
            else
            {
                gpio.set_pin(2, 0);
            }

            surname_lvl[i] == '1' ? gpio.set_pin(3, 1) : gpio.set_pin(3, 0);

            mdelay(1);
        }
        gpio.set_pin(0, 0);                         // not sending
        return 0;
    }
}

// void send_morse(uint8_t pin, char name[])
// {
//     gpio.set_pin(0, 1);                     //sending
//     for (int i = 0; name[i] != 0; i++)
//     {
//         if (name[i] == '.')
//         {
//             gpio.set_pin(pin, 1);
//             mdelay(1);
//             gpio.set_pin(pin, 0);
//             mdelay(1);
//         }
//         else if (name[i] == '-')
//         {
//             gpio.set_pin(pin, 1);
//             mdelay(3);
//             gpio.set_pin(pin, 0);
//             mdelay(1);
//         }
//         else if (name[i] == ' ')
//         {
//             mdelay(2);
//         }
//     }
//     gpio.set_pin(0, 0);
// }

// int main()
// {

//     uart.write("INFO: application started 2\n");
//     mdelay(1);
//     send_morse(1, sos);
//     send_morse(2, name);
//     send_morse(3, surname);
//     mdelay(1);
//     return 0;
// }
/*static constexpr uint32_t led_mask{0xf};

int main()
{

    uart.write("INFO: application started\n");
    udelay(100);

    while (true) {
        for (int i = 0; i < 16; ++i) {
            gpio.set_odr(i & led_mask);
            udelay(20);
        }
  
    }
}*/

