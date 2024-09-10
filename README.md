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

## Additional Information

Feel free to modify the bootloader code to test different functionalities or to enhance the graphical output. This project is a great starting point for learning more about low-level programming and operating system development.

## Examples of x86 Assembly

### Moving Data in x86 Assembly

#### Example 1: MOVSB

```assembly
; Example 1: MOVSB
section .data
source db 'Hello, world!', 0
destination db 20 dup(0)

section .text
global _start
_start:
    ; Initialize registers
    mov si, source
    mov di, destination
    mov cx, 13       ; Length of the string including null terminator

    cld              ; Ensure increment
    rep movsb        ; Move the string byte by byte

    ; Termination code could go here

```

#### Example 2: MOVSW

```assembly
; Example 2: MOVSW
section .data
source dw 'H', 'e', 'l', 'l', 'o', 0
destination dw 10 dup(0)

section .text
global _start
_start:
    ; Initialize registers
    mov si, source
    mov di, destination
    mov cx, 5        ; Number of words

    cld              ; Ensure increment
    rep movsw        ; Move the string word by word
```

#### Example 3: MOVSD

```assembly
; Example 3: MOVSD
section .data
source dd 'Hell', 'o, w', 'orld', '!', 0
destination dd 5 dup(0)

section .text
global _start
_start:
    ; Initialize registers
    mov si, source
    mov di, destination
    mov cx, 4        ; Number of double words

    cld              ; Ensure increment
    rep movsd        ; Move the string double word by double word
```

### Compare x86 Assembly

#### Example 4: CMPSB

```assembly
; Example 4: CMPSB
section .data
str1 db 'abc', 0
str2 db 'abc', 0

section .text
global _start
_start:
    mov si, str1
    mov di, str2
    mov cx, 3        ; Length of strings to compare

    cld
    repe cmpsb       ; Compare until a difference is found or CX = 0

    ; Termination code could go here
```

#### Example 5: CMPSW

```assembly
; Example 5: CMPSW
section .data
str1 dw 'ab', 'cd', 0
str2 dw 'ab', 'cd', 0

section .text
global _start
_start:
    mov si, str1
    mov di, str2
    mov cx, 2        ; Number of words to compare

    cld
    repe cmpsw

```

#### Example 6: CMPSD

```assembly
; Example 5: CMPSW
section .data
str1 dw 'ab', 'cd', 0
str2 dw 'ab', 'cd', 0

section .text
global _start
_start:
    mov si, str1
    mov di, str2
    mov cx, 2        ; Number of words to compare

    cld
    repe cmpsw

```

### Search x86 Assembly

#### Example 7: SCASB

```assembly
; Example 7: SCASB
section .data
data db 'hello', 0

section .text
global _start
_start:
    mov di, data     ; DI points to the string
    mov al, 'o'      ; AL contains the byte to search for
    mov cx, 5        ; Length of the string

    cld
    repne scasb      ; Search for 'o' in the string

    ; Termination code could go here
```

#### Example 8: SCASW

```assembly
; Example 8: SCASW
section .data
data dw 'he', 'll', 'o', 0

section .text
global _start
_start:
    mov di, data     ; DI points to the string
    mov ax, 'll'     ; AX contains the word to search for
    mov cx, 3        ; Number of words

    cld
    repne scasw      ; Search for 'll' in the string

```

#### Example 9: SCASD

```assembly
; Example 9: SCASD
section .data
data dd 'hell', 'o', 0

section .text
global _start
_start:
    mov di, data     ; DI points to the string
    mov eax, 'o'     ; EAX contains the double word to search for
    mov cx, 2        ; Number of double words

    cld
    repne scasd      ; Search for 'o' in the string

```

### Load x86 Assembly

#### Example 10: LODSB

```assembly
; Example 10: LODSB
section .data
source db 'Hello, world!', 0

section .text
global _start
_start:
    mov si, source   ; SI points to the source
    mov cx, 13       ; Number of bytes to load

    cld
    lodsb            ; Load the first byte into AL
```

#### Example 11: LODSW

```assembly
; Example 11: LODSW
section .data
source dw 'He', 'll', 'o,', ' wo', 'rld', '!', 0

section .text
global _start
_start:
    mov si, source   ; SI points to the source
    mov cx, 6        ; Number of words to load

    cld
    lodsw            ; Load the first word into AX

```

#### Example 12: LODSD

```assembly
; Example 12: LODSD
section .data
source dd 'Hell', 'o, w', 'orld', '!', 0

section .text
global _start
_start:
    mov si, source   ; SI points to the source
    mov cx, 4        ; Number of double words to load

    cld
    lodsd            ; Load the first double word into EAX

```

### Store x86 Assembly

#### Example 13: STOSB

```assembly
; Example 13: STOSB
section .data
destination db 20 dup(0)

section .text
global _start
_start:
    mov di, destination  ; DI points to the destination
    mov al, 'A'          ; AL contains the byte to store
    mov cx, 1            ; Number of times to store

    cld
    stosb                ; Store the byte at the address pointed by DI
```

#### Example 14: STOSW

```assembly
; Example 14: STOSW
section .data
destination dw 10 dup(0)

section .text
global _start
_start:
    mov di, destination  ; DI points to the destination
    mov ax, 'AB'         ; AX contains the word to store
    mov cx, 1            ; Number of times to store

    cld
    stosw                ; Store the word at the address pointed by DI
```

#### Example 15: STOSD

```assembly
; Example 15: STOSD
section .data
destination dd 5 dup(0)

section .text
global _start
_start:
    mov di, destination  ; DI points to the destination
    mov eax, 'ABCD'      ; EAX contains the double word to store
    mov cx, 1            ; Number of times to store

    cld
    stosd                ; Store the double word at the address pointed by DI

```
