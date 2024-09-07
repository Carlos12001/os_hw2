[BITS 16]            ; Code for 16-bit mode
[ORG 0x7C00]         ; Bootloader load address

;; CONSTANTS ===================================================
SCREEN_WIDTH       equ 320  ; Width in pixels
SCREEN_HEIGHT      equ 200  ; Height in pixels

BLUE_COLOR         equ 0x01 ; Color blue


start:
    ;; SETUP ===================================================
    mov ax, 0x0013   ; Set video mode to 320x200 with 256 colors
    int 0x10         ; Call video interrupt for video services
    ;; =========================================================

    mov ah, 0x0C     ; Function to set a pixel
    mov al, BLUE_COLOR     ; Blue color (commonly in default palette)
    xor cx, cx       ; X coordinate = 0
    xor dx, dx       ; Y coordinate = 0
    int 0x10         ; Call video interrupt to set the pixel

    ; Paint the entire screen blue
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT  ; Total pixels to paint
    mov bx, 0         ; Initial pixel position 
    loop_segment:
        mov es, ax   ; Set video segment (0xA000 for mode 13h)
        mov di, bx   ; Initial pixel address in video memory
        mov al, 0x01 ; Blue color
        stosb        ; Paint a pixel and advance offset
        inc bx       ; Increment offset for the next pixel
        dec cx       ; Decrement pixel counter
        jnz loop_segment ; Continue until all pixels are painted

    hang:
    jmp hang         ; Infinite loop to stop the bootloader

    times 510 - ($ - start) db 0   ; Fill the rest of the sector zeros 
    dw 0xAA55                      ; Boot sector signature

