#!/usr/bin/env python3

import os
import sys
import shutil
import subprocess

SRC = ["boot.S", "lib.S", "uart.c", "kernel.c"]

# All this utilities must be installed with LLVM and on the system PATH.
# Note: Trying to run "ld.lld" without the .exe on Windows fails, but locating the binary with shutil.which works.
CC = shutil.which("clang")
LD = shutil.which("ld.lld")
OC = shutil.which("llvm-objcopy")

if not CC or not LD or not OC:
    raise EnvironmentError("Could not locate llvm binaries")

# Note: llvm-objdump works on the elf file ("llvm-objdump -d kernel8.elf"), but 
# not the binary image. If you want to dump that you'll need the platform-specific
# GCC objdump, e.g.: "aarch64-none-elf-objdump -m aarch64 -b binary -D kernel8.img"

OBJ = [os.path.join("obj", os.path.splitext(file)[0] + ".o") for file in SRC]

CCARGS = [CC, "-c", "--target=aarch64-elf", "-Wall", "-ffreestanding", "-g", "-nostdlib", "-mcpu=cortex-a53"]
LDARGS = [LD, "-nostdlib", "-T", "link.lds", "-o", "kernel8.elf"] + OBJ
OCARGS = [OC, "-O", "binary", "kernel8.elf", "kernel8.img"]

if "raspi3b" in sys.argv:
    CCARGS += ["-D", "RASPI3B"]
else:
    CCARGS += ["-D", "RASPI4B"]

# Ensure the project dir is the working dir.
# Note: Need to use samefile to ignore casing difference on Windows
if not os.path.samefile(os.path.dirname(os.path.abspath(__file__)), os.getcwd()):
    raise EnvironmentError("Current working directory must be the project directory")

def build():
    if not os.path.isdir("obj"):
        os.makedirs("obj")

    # Compile each source file
    for unit in zip(SRC, OBJ):
        args = CCARGS + ["-o", unit[1], unit[0]]
        print(*args)
        subprocess.run(args, check=True)

    # Link all the objects into the ELF image
    print(*LDARGS)
    subprocess.run(LDARGS, check=True)

    # Create the binary file from the ELF image
    print(*OCARGS)
    subprocess.run(OCARGS, check=True)

def clean():
    if os.path.isfile("kernel8.img"):
        os.remove("kernel8.img")

    if os.path.isfile("kernel8.elf"):
        os.remove("kernel8.elf")

    if os.path.isdir("obj"):
        shutil.rmtree("obj")

if len(sys.argv) > 1 and sys.argv[1] == "clean":
    clean()
else:
    build()
