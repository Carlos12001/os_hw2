.PHONY: all

all:
	nasm -f bin bootloader.asm -o bootloader.bin
run:
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=bootloader.bin of=floppy.img conv=notrunc
	qemu-system-x86_64 -drive file=floppy.img,format=raw,index=0,if=floppy
