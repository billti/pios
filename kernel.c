#include "uart.h"

void KMain(void)
{
    write_string("Hello, world\n");
    
    while (1) {
        ;
    }
}

int add(int a, int b)
{
    return a + b;
}
