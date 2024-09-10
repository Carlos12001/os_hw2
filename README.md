# Bootloader Project

## Description

This project involves creating a simple bootloader for x86 architecture. The bootloader is designed to be run in a QEMU emulation environment. It initializes in 16-bit real mode and sets the video mode to display pixels directly to the screen.

## Arquitectura x86

La arquitectura x86 es un conjunto de instrucciones basado en la microarquitectura de los procesadores desarrollados por Intel. Empezó con el Intel 8086 en 1978, un procesador de 16 bits, y ha evolucionado hasta incluir las modernas variantes de 32 bits (IA-32) y 64 bits (x86-64 o AMD64). La arquitectura x86 es predominantemente usada en computadoras personales, servidores, y estaciones de trabajo.

### Tamaños de las Unidades de Datos en x86

En el ensamblador x86, los datos se pueden manejar en diferentes tamaños, lo que permite a los programas ser más específicos sobre la cantidad de memoria que se manipula en una operación. Los tamaños de las unidades de datos son los siguientes:

- **Byte:**

  - 8 bits.
  - Es la unidad de dato más pequeña y se usa comúnmente para manipular caracteres y otros tipos de datos que requieren poco espacio.

- **Word:**

  - 16 bits.
  - Originalmente el tamaño de las palabras en el primer procesador x86, el 8086. Se usa para operaciones que necesitan más precisión que un byte, como el manejo de enteros más grandes y operaciones de hardware.

- **Dword (Double Word):**

  - 32 bits.
  - Introducido con la extensión de 32 bits de la arquitectura x86. Permite operaciones y cálculos más complejos, y es el tamaño estándar para la manipulación de enteros en las aplicaciones de 32 bits.

- **Qword (Quad Word):**
  - 64 bits.
  - Utilizado en las extensiones de 64 bits de la arquitectura para permitir el manejo de grandes cantidades de datos y direcciones de memoria, esencial para aplicaciones que requieren trabajar con grandes conjuntos de datos o realizar cálculos de alta precisión.

Estos tamaños permiten que la arquitectura x86 maneje una amplia gama de aplicaciones, desde simples manipulaciones de texto hasta complejas operaciones científicas y de manejo de bases de datos.

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
