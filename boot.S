    .section .text

    .global start
    .type start, %function
start:
    // The lower byte indicates the core id within the cluster
    mrs x0, mpidr_el1
    and x0, x0, #255
    cmp x0, #0
    # Only enter the kernel for core 0
    b.eq kernel_entry

end:
    b end

    .global kernel_entry
    .type kernel_entry, %function
kernel_entry:
    // Current exception level should be 2 on startup
    // Bits 2 & 3 indicate the level
    mrs x0, currentel
    lsr x0, x0, #2
    cmp x0, #2
    b.ne end

    // TODO: What does this do?
    msr sctlr_el1, xzr

    // Set execution state for EL1 to AArch64
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
    