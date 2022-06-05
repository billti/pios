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
