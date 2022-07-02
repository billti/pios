#pragma once

#include <stdint.h>

// The base address for perihperals changed in the Raspberry Pi 3b (BCM2837) from
// those documents for the earlier models (e.g. using the BCM2835 & BCM2836). 
// Updated doc is at https://github.com/raspberrypi/documentation/files/1888662/BCM2837-ARM-Peripherals.-.Revised.-.V2-1.pdf
// Original BCM2835 doc is at https://datasheets.raspberrypi.com/bcm2835/bcm2835-peripherals.pdf
//
// As the BCM2837 doc states in section 1.2.3:
//
//    Physical addresses range from 0x3F000000 to 0x3FFFFFFF for peripherals. The 
//    bus addresses for peripherals are set up to map onto the peripheral bus address
//    range starting at 0x7E000000. Thus a peripheral advertised here at bus 
//    address 0x7Ennnnnn is available at physical address 0x3Fnnnnnn.
//
// i.e. Page 177 states, "The PL011 UART is mapped on base adderss 0x7E201000", so:
#define RASPI3B_PERIPHERAL_BASE 0x3f000000


// Per the BCM2711 spec at https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf
//
//    So a peripheral described in this document as being at legacy address 
//    0x7Enn_nnnn is available in the 35-bit address space at 0x4_7Enn_nnnn, and 
//    visible to the ARM at 0x0_FEnn_nnnn if Low Peripheral mode is enabled.
//
// i.e. add 0x8000_0000 to the addresses in that doc (which is 0x7e201000 for UART0):
#define RASPI4B_PERIPHERAL_BASE 0xfe000000

#ifdef RASPI3B 
#define PERIPHERAL_BASE   RASPI3B_PERIPHERAL_BASE
#else
#define PERIPHERAL_BASE   RASPI4B_PERIPHERAL_BASE
#endif

#define UART0_BASE        PERIPHERAL_BASE + 0x201000

#define UART0_DR          UART0_BASE + 0x00
#define UART0_FR          UART0_BASE + 0x18
#define UART0_IBRD        UART0_BASE + 0x24
#define UART0_FBRD        UART0_BASE + 0x28
#define UART0_LCRH        UART0_BASE + 0x2c
#define UART0_CR          UART0_BASE + 0x30
#define UART0_IMSC        UART0_BASE + 0x38
#define UART0_MIS         UART0_BASE + 0x40
#define UART0_ICR         UART0_BASE + 0x44

void delay(uint64_t count);
void out_word(uint64_t address, int value);
int in_word(uint64_t address);
