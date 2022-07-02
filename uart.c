#include "lib.h"

void init_uart()
{
    // Disable the UART (write 0 to control register)
    out_word(UART0_CR, 0);

    // Baud rate divisor (BAUDDIV) = FUARTCLK/(16 * baud rate)
    // FUARTCLK (UART reference clock frequency) = 48MHz
    // Baud rate to aim for = 115,200.
    // BAUDDIV = 48,000,000 / (16 * 115,200) = 26.0416666...

    // Set lower 16 bits of IBRD to integer baud rate divisor (i.e. 26)
    // Set lower 6 bits of FBRD to fractional baud rate divisor (i.e. 0)
    out_word(UART0_IBRD, 26);
    out_word(UART0_FBRD, 0);

    // Line control register. Enable FIFO buffers and 8-bit data.
    // Bit 4 enables buffers if set. Bits 5 & 6 indicate 8-bit words if set.
    out_word(UART0_LCRH, 0x70);

    // Disable all interrupts (for now)
    // TODO: Should bits 4 & 5 be set to mask interrupts?
    out_word(UART0_IMSC, 0);

    // Enable the UART. Bit 0 is enabled. Bits 8 & 9 enable transmit & receive.
    out_word(UART0_CR, 0x0301);
}

void write_char(char cr)
{
    // If bit 5 of the flag register is set, then the transmit buffer is full
    // Wait for space before writing
    while (in_word(UART0_FR) & (1 << 5)) {}

    out_word(UART0_DR, cr);
}

char read_char()
{
    // If bit 4 of the flag register is set, then there is no data present
    // Wait until there is something to read
    while (in_word(UART0_FR) & (1 << 4)) {}
    
    return in_word(UART0_DR) & 0XFF;
}

void write_string(const char* str)
{
    while (*str) {
        write_char(*str);
        ++str;
    }
}
