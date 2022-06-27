# A minimal OS for Raspberry Pi

This project targets both Qemu emulating the Raspberry Pi 3b board, and a
physical Raspberry Pi 4 board.

## Build tools
For building on Windows, use WSL (so instructions should be similar for Ubuntu)

TODO: Correct below package names

    sudo apt-get install build-essential gcc-aarch64-linux-gnu gdb-multiarch

This results in the build tools (gcc, as, ld, etc.) having the prefix `aarch64-linux-gnu-`

For building on Mac I installed the `MacOS bare metal` .pkg bundle from
https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads
and then added the below to `~/.zshrc`

    export PATH=$PATH:/Applications/ARM/bin

Installed into the above directory are the various build tools (as, gcc, ld,
objcopy, gdb, etc.) with a `aarch64-none-elf-` prefix.

## Running in QEMU

To install QEMU on MacOS using Homebrew run `brew install qemu`, which will put
(links to) the variou emulators in `/usr/loca/bin` (which should already be on
your path).

Run QEMU emulatoring a Raspberry 3b board (the latest supported at the time of
writing with:

    qemu-system-aarch64 -M raspi3b -serial stdio -kernel kernel8.img

To debug, run with the `-s -S` flags. The first tells QEMU to listen for a GDB
connection on port 1234, the second tells QEMU not to start the guest until told.

The makefile has targets for these, so run `make run` to launch in the QEMU
emulator. To debug run `make debug` to launch QEMU with the `-s -S` flags, and
then in a separate terminal run `make attach` to attach GDB to it.

## Running on the Raspberry Pi 4

After building, you should have a binary kernel file named `kernel8.img`. If you
plug an SD Card formatted with a Raspberry Pi image into a Mac, you should see
the files at something like `/Volumes/boot`. To copy the kernel image to the
card simply run a command such as:

    cp ./kernel8.img /Volumes/boot/

For debugging (without special hardware) the OS will write to a UART, and you
can connect a USB serial cable to the right GPIO pins to send and receive data.
On MacOS, you can use the `screen` utility to connect a terminal emulator to the
serial connection. Find the device name via `ls /dev/tty.usb*`, and then run with
the right device and baud rate, e.g.

    screen /dev/tty.usbserial-0001 115200

Use `Ctrl-A Ctrl-/` to exit the `screen` application.

## Building

Just run `make` to build the kernel image (the default target) in the `makefile`

By default this will build for Raspberry Pi 3. To build for Raspberry Pi 4, run
`make RASPI_MODEL=4`. If changing model across builds, run `make clean` inbetween.

## Coding

The code is compiled with GNU using the C99 standard for the C code, and using
the GNU assembler (GAS) with C preprocessing for the assembly code. (Done by using
an uppercase '.S' extension and running through the C compiler). By using the
preprocessor on the assembly code this allows for things such as `#define` and
`#ifdef` style directives in the assembly code.

# TODO
Still can't figure out how to get assembly functions to show up in the GNU
debugger. Tried the directives at https://developer.arm.com/documentation/100748/0618/Assembling-Assembly-Code/How-to-get-a-backtrace-through-assembler-functions?lang=en
with no luck. (See also stackoverflow posts on topic). May be able to remove the
`.cfi_*` directives in the assembly if they're not doing anything useful.

Still haven't managed to get VS Code to attach the GDB debugger. Try the extension
listed at https://marketplace.visualstudio.com/items?itemName=webfreak.debug and
the docs at https://code.visualstudio.com/docs/cpp/launch-json-reference (also 
see https://stackoverflow.com/q/54039083/1674945)

# Windows

Install LLVM from the GitHub releases package (e.g. something like 
<https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.5/LLVM-14.0.5-win64.exe>) which
should put the necessary binaries (e.g. clang.exe, ld.lld.exe, llvm-objcopy.exe, lldb.exe) on your PATH.

Ensure that Python3 is installed and the directory containing python310.dll is on your path, else LLDB
will fail to launch.

Run build.bat to compile. To debug, launch QEMU with:

    qemu-system-aarch64 -s -S -M raspi3b -serial stdio -kernel kernel8.img

From a separate command window start a debug session via the below (which sets a breakpoint at 
`kernel_entry` and runs to it).

    lldb.exe
    (lldb) file kernel8.elf
    (lldb) gdb-remote 1234
    (lldb) b kernel_entry
    (lldb) c

