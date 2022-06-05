# https://www.gnu.org/software/make/manual/

# Use the cross-compiler, not the standard GCC tools
TOOLCHAIN = aarch64-none-elf
CC = $(TOOLCHAIN)-gcc
LD = $(TOOLCHAIN)-ld
OBJCOPY = $(TOOLCHAIN)-objcopy

# See CPU options at https://gcc.gnu.org/onlinedocs/gcc/AArch64-Options.html#AArch64-Options
# Raspberry Pi 3b uses a Cortex-A53. Raspberry Pi 4b uses a Cortex-A72.
CFLAGS = -mcpu=cortex-a53 -fpic -ffreestanding -g -std=c99
LFLAGS = -nostdlib

IMG_NAME = kernel8
OBJ_DIR = obj

$(IMG_NAME).img: $(IMG_NAME).elf
	$(OBJCOPY) -O binary $< $@

$(IMG_NAME).elf: $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o
	$(LD) $(LFLAGS) -T link.lds -o $@ $+

$(OBJ_DIR)/boot.o: boot.S
	mkdir -p $(@D)
	$(CC) -c $< -o $@

$(OBJ_DIR)/kernel.o: kernel.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	-rm $(IMG_NAME).img
	-rm $(IMG_NAME).elf
	-rm -rf $(OBJ_DIR)

.PHONY: clean
