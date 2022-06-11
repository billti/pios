# https://www.gnu.org/software/make/manual/

# To build for Raspberry Pi 3, run with: make RASPI_MODEL=3
ifeq ($(RASPI_MODEL), 3)
	CPU = cortex-a53
	DIRECTIVES = -D RASPI_MODEL=3
else
	CPU = cortex-a72
	DIRECTIVES = -D RASPI_MODEL=4
endif

# Use the cross-compiler, not the standard GCC tools
TOOLCHAIN = aarch64-none-elf

# Default variable names: https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
CC = $(TOOLCHAIN)-gcc
LD = $(TOOLCHAIN)-ld

# See CPU options at https://gcc.gnu.org/onlinedocs/gcc/AArch64-Options.html#AArch64-Options
# Raspberry Pi 3b uses a Cortex-A53. Raspberry Pi 4b uses a Cortex-A72.
CFLAGS = -mcpu=$(CPU) -fpic -ffreestanding -g -std=c99 $(DIRECTIVES) -Wall -Wextra
LFLAGS = -nostdlib

# makefile syntax
#   $<    = the first prerequisite
#   $+    = all prerequisites
#   $?    = all prerequisites newer than the target
#   $@    = the target
#   $(@D) = the directory part of the target

kernel8.img: kernel8.elf
	$(TOOLCHAIN)-objcopy -O binary $< $@

kernel8.elf: obj/boot.o obj/kernel.o
	$(LD) $(LFLAGS) -T link.lds -o $@ $+

obj/boot.o: boot.S
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

obj/kernel.o: kernel.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# QEMU support for raspberry pi: https://qemu.readthedocs.io/en/latest/system/arm/raspi.html
run: kernel8.elf
	qemu-system-aarch64 -M raspi3b -serial stdio -kernel kernel8.elf

debug: kernel8.elf
	qemu-system-aarch64 -s -S -M raspi3b -serial stdio -kernel kernel8.elf

attach:
	$(TOOLCHAIN)-gdb -ex "target remote localhost:1234" -ex "b start" -ex "cont" kernel8.elf

clean:
	-rm kernel8.img
	-rm kernel8.elf
	-rm -rf obj

.PHONY: run debug clean attach
