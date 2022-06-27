#!/usr/bin/env python3

import os
import sys
import shutil
import subprocess

# Set to the correct path for the local install
LLVM_DIR = "/usr/local/bin/clang14/bin"

SRC = ["boot.S", "kernel.c"]

CC = os.path.join(LLVM_DIR, "clang")
LD = os.path.join(LLVM_DIR, "ld.lld")
OC = os.path.join(LLVM_DIR, "llvm-objcopy")

if shutil.which(OC) == None:
    raise EnvironmentError("Could not locate llvm binaries")

# Note: llvm-objdump works on the elf file ("llvm-objdump -d kernel8.elf"), but 
# not the binary image. If you want to dump that you'll need the platform-specific
# GCC objdump, e.g.: "aarch64-none-elf-objdump -m aarch64 -b binary -D kernel8.img"

OBJ = [os.path.join("obj", os.path.splitext(file)[0] + ".o") for file in SRC]

CCARGS = [CC, "-c", "--target=aarch64-elf", "-Wall", "-ffreestanding", "-g", "-nostdinc", "-nostdlib", "-mcpu=cortex-a53"]
LDARGS = [LD, "-nostdlib", "--discard-none", "-T", "link.lds", "-o", "kernel8.elf"] + OBJ
OCARGS = [OC, "-O", "binary", "kernel8.elf", "kernel8.img"]

# Ensure the project dir is the working dir
if os.path.dirname(os.path.abspath(__file__)) != os.getcwd():
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
