mkdir ./obj
clang --target=aarch64-elf -Wall -ffreestanding -g -nostdinc -nostdlib -mcpu=cortex-a53 -c boot.S   -o obj/boot.o
clang --target=aarch64-elf -Wall -ffreestanding -g -nostdinc -nostdlib -mcpu=cortex-a53 -c kernel.c -o obj/kernel.o
ld.lld -nostdlib --discard-none -T link.lds -o kernel8.elf obj/boot.o obj/kernel.o
llvm-objcopy -O binary kernel8.elf kernel8.img
