.global delay
.global out_word
.global in_word

delay:
    subs x0, x0, 1
    bne delay
    ret

// Store the 32-bits in the w1 register to the address in the first argument
out_word:
    str w1, [x0]
    ret

// Return the word (32-bits) from the address provided
in_word:
    ldr w0, [x0]
    ret
