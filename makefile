.PHONY: all

all:
	nasm -f bin -o bootloader.bin bootloader.asm

run:
	qemu-system-x86_64 -drive file=bootloader.bin,format=raw,index=0
