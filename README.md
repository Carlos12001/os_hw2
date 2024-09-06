# Bootloader Project

## Description

This project involves creating a simple bootloader for x86 architecture. The bootloader is designed to be run in a QEMU emulation environment. It initializes in 16-bit real mode and sets the video mode to display pixels directly to the screen. 

## Requirements

- NASM (Netwide Assembler) for assembling the bootloader code.
- QEMU for emulating an x86 system and testing the bootloader.
- A Unix-like environment (Linux, macOS, or WSL on Windows) for the development tools.

## Installation

### Installing NASM

For Debian/Ubuntu-based systems, use:
```bash
sudo apt update
sudo apt install nasm
```

For Arch Linux systems, use:
```bash
sudo pacman -Sy nasm
```

### Installing QEMU

For Debian/Ubuntu-based systems, use:
```bash
sudo apt update
sudo apt install qemu-system-x86
```

For Arch Linux systems, use:
```bash
sudo pacman -Sy qemu
```

## Run

To run the bootloader, you first need to assemble the bootloader code using NASM and then use QEMU to emulate the system. Here are the steps:

1. Assemble the bootloader:
```bash
nasm -f bin -o bootloader.bin bootloader.asm
```

2. Create a floppy disk image:
```bash
dd if=/dev/zero of=floppy.img bs=1024 count=1440
dd if=bootloader.bin of=floppy.img conv=notrunc
```

3. Run the bootloader using QEMU:
```bash
qemu-system-x86_64 -drive file=floppy.img,format=raw,index=0,if=floppy
```

Replace `bootloader.asm` with the path to your assembly file if it's located in a different directory.

## Additional Information

Feel free to modify the bootloader code to test different functionalities or to enhance the graphical output. This project is a great starting point for learning more about low-level programming and operating system development.

