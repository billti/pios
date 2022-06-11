.section .text
.global start

start:
    mrs x0, mpidr_el1
    and x0, x0, #3
// Below is just to test the preprocessor is working.
#if RASPI_MODEL == 3
    and x1, x1, #3
#else
    and x1, x1, #4
#endif
    cmp x0, #0
    beq kernel_entry

end:
    b end

kernel_entry:
    // Current exception level should be 2 on startup.
    mrs x0, currentel
    lsr x0, x0, #2
    cmp x0, #2
    bne end

    msr sctlr_el1, xzr
    mov x0, #(1 << 31)
    msr hcr_el2, x0

    // Mask all interrupts. Return to AArch64 (bit 4). Use EL1h SP (bits 0 - 3)
    //         DAIF-4...0
    mov x0, #0b1111000101
    msr spsr_el2, x0

    adr x0, el1_entry
    msr elr_el2, x0

    eret

el1_entry:
    mov sp, #0x80000

    ldr x0, =bss_start
    ldr x1, =bss_end
    sub x2, x1, x0
    mov x1, #0
    // bl memset

    // ldr x0, =vector_table
    msr vbar_el1, x0
    
    bl KMain
    
    mov x0, #0
    msr spsr_el1, x0
    adr x0, el0_entry
    msr elr_el1, x0
    eret

el0_entry:
    b end
    