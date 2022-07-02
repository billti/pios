ENTRY(start)
SECTIONS
{
    .text 0x80000 : {
        boot.o(.text)
        *(.text)
    }

    .rodata : {
        *(.rodata)
        *(.rodata.*)
        /* 
        Without the second line above, constant literals were getting their own
        .rodata.str1.1 section (or similarly named) which would get given an earlier
        address (e.g. 0x00000000) and mess up the binary image export.
        */
    }

    . = ALIGN(16);
    .data : {
        *(.data)
    }

    .bss : {
        bss_start = .;
        *(.bss)
        bss_end = .;
    }
}