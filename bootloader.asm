use16           ; Use 16 bit (16 bit = 1 word) code only
org 07C00h		; Set bootsector to be at memory location hex 7C00h

;; DEFINED VARIABLES AFTER SCREEN MEMORY - 320*200 = 64000 or FA00h =========================
;; sprites (each sprite is 4 bytes)
sprites      equ 0FA00h
letter0      equ 0FA00h
letter1      equ 0FA04h
letter2      equ 0FA08h
letter3      equ 0FA0Ch
letter4      equ 0FA10h
letter5      equ 0FA14h
letter6      equ 0FA18h
letter7      equ 0FA1Ch
letter8      equ 0FA20h
letter9      equ 0FA24h
letter10     equ 0FA28h
letter11     equ 0FA2Ch
letter12     equ 0FA30h
letter13     equ 0FA34h

;; rotation
rotation     equ 0


;; CONSTANTS =====================================
SCREEN_WIDTH        equ 320     ; Width in pixels
SCREEN_HEIGHT       equ 200     ; Height in pixels
VIDEO_MEMORY        equ 0A000h
TIMER               equ 046Ch   ; # of timer ticks since midnight
SPRITE_SIZE_BYTE    equ 4       ; Size in bytes (2 words)
SPRITE_HEIGHT       equ 4
SPRITE_WIDTH        equ 4       ; Width in bits/data pixels
SPRITE_WIDTH_PIXELS equ 8      ; Width in screen pixels
NUM_LETTERS         equ 14
; Colors
LETTER_COLOR         equ 02h   ; Green



;; SETUP =========================================
;; Set up video mode - VGA mode 13h, 320x200, 256 colors, 8bpp, linear framebuffer at address A0000h
mov ax, 0013h
int 10h

;; Set up video memory
push VIDEO_MEMORY
pop es          ; ES -> A0000h

cld             ; Clear Direction Flag to ensure SI and DI are incremented

;; Move initial sprite data into memory
mov di, sprites
mov si, sprite_bitmaps + rotation*NUM_LETTERS*SPRITE_SIZE_BYTE
mov cl, NUM_LETTERS*SPRITE_SIZE_BYTE    ; Aqui solo copiamos sprites I G N A C I O   C A R L O S
rep movsb


push es
pop ds          ; DS = ES

;; GAME LOOP =====================================
game_loop:
    xor ax, ax      ; Clear screen to black first
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb       ; mov [ES:DI], al cx # of times

    ;; ES:DI now points to AFA00h
    ;; Draw letters ------------------------------------------------
    mov bl, LETTER_COLOR
    mov cl, 4


    draw_next_letter:
        pusha
        mov cl, 14             ; # of letter to write in row
        .check_next_letter:
            pusha
            dec cx


            mov si, di
            call draw_sprite

            .next_letter:
                popa
                add di, SPRITE_SIZE_BYTE    ;; ESTO SI FUNCIONO PORQUE?
                add ah, SPRITE_WIDTH+2

        loop .check_next_letter

        popa
    loop draw_next_letter



    ;; Delay timer - 1 tick delay (1 tick = 18.2/second)
    delay_timer:
        mov ax, [CS:TIMER]
        inc ax
        .wait:
            cmp [CS:TIMER], ax
            jl .wait
jmp game_loop

;; END GAME LOOP =====================================




;; Draw a sprite to the screen
draw_sprite:
    call get_screen_position    ; Get X/Y position in DI to draw at
    mov cl, SPRITE_HEIGHT
    .next_line:
        push cx
        lodsb                   ; AL = next byte of sprite data
        xchg ax, dx             ; save off sprite data
        mov cl, SPRITE_WIDTH    ; # of pixels to draw in sprite
        .next_pixel:
            xor ax, ax          ; If drawing blank/black pixel
            dec cx
            bt dx, cx           ; Is bit in sprite set? Copy to carry
            cmovc ax, bx        ; Yes bit is set, move BX into AX (BL = color)
            mov ah, al          ; Copy color to fill out AX
            mov [di+SCREEN_WIDTH], ax
            stosw
        jnz .next_pixel

        add di, SCREEN_WIDTH*3-SPRITE_WIDTH_PIXELS
        pop cx
    loop .next_line

    ret



;; Get X/Y screen position in DI
get_screen_position:
    mov dx, ax      ; Save Y/X values
    cbw             ; Convert byte to word - sign extend AL into AH, AH = 0 if AL < 128
    imul di, ax, SCREEN_WIDTH*2  ; DI = Y value
    mov al, dh      ; AX = X value
    shl ax, 1       ; X value * 2
    add di, ax      ; DI = Y value + X value or X/Y position

    ret



;; CODE SEGMENT DATA =================================
;; The size of the code are 32 bits (4 bytes) although we define only the last 
;; 4 bits of the letter the 4 MSB are 0 by default. Because the instruction
;; db only defines 1 bytes not nibbles, por eso los primeros 4 bits son 0.
sprite_bitmaps:
    ;; Rotation 0 ------------------------------------------------
        db 1111b    ; Letter 0 bitmap (I)
        db 0110b
        db 0110b
        db 1111b

        db 1111b    ; Letter 1 bitmap (G)
        db 1000b
        db 1111b
        db 1111b

        db 1001b    ; Letter 2 bitmap (N)
        db 1101b
        db 1011b
        db 1001b

        db 1111b    ; Letter 3 bitmap (A)
        db 1001b
        db 1111b
        db 1001b

        db 1111b    ; Letter 4 bitmap (C)
        db 1000b
        db 1000b
        db 1111b

        db 1111b    ; Letter 5 bitmap (I)
        db 0110b
        db 0110b
        db 1111b

        db 1111b    ; Letter 6 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 0000b    ; Letter 7 bitmap ( )
        db 0000b
        db 0000b
        db 0000b

        db 1111b    ; Letter 8 bitmap (C)
        db 1000b
        db 1000b
        db 1111b

        db 1111b    ; Letter 9 bitmap (A)
        db 1001b
        db 1111b
        db 1001b


        db 1110b    ; Letter 10 bitmap (R)
        db 1001b
        db 1110b
        db 1001b

        db 1000b    ; Letter 11 bitmap (L)
        db 1000b
        db 1000b
        db 1111b

        db 1111b    ; Letter 12 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 1111b    ; Letter 13 bitmap (S)
        db 1000b
        db 0110b
        db 1111b


    ;; Rotation 90 ------------------------------------------------
        db 1001b    ; Letter 0 bitmap (I)
        db 1111b
        db 1111b
        db 1001b

        db 1111b    ; Letter 1 bitmap (G)
        db 1101b
        db 1101b
        db 1101b

        db 1111b    ; Letter 2 bitmap (N)
        db 0010b
        db 0100b
        db 1111b

        db 1111b    ; Letter 3 bitmap (A)
        db 0101b
        db 0101b
        db 1111b

        db 1111b    ; Letter 4 bitmap (C)
        db 1001b
        db 1001b
        db 1001b

        db 1001b    ; Letter 5 bitmap (I)
        db 1111b
        db 1111b
        db 1001b

        db 1111b    ; Letter 6 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 0000b    ; Letter 7 bitmap ( )
        db 0000b
        db 0000b
        db 0000b

        db 1111b    ; Letter 8 bitmap (C)
        db 1001b
        db 1001b
        db 1001b

        db 1111b    ; Letter 9 bitmap (A)
        db 0101b
        db 0101b
        db 1111b


        db 1111b    ; Letter 10 bitmap (R)
        db 0101b
        db 0101b
        db 1010b
        

        db 1111b    ; Letter 11 bitmap (L)
        db 1000b
        db 1000b
        db 1000b

        db 1111b    ; Letter 12 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 1011b    ; Letter 13 bitmap (S)
        db 1101b
        db 1001b
        db 1001b


    ;; Rotation 180 ------------------------------------------------
        db 1111b    ; Letter 0 bitmap (I)
        db 0110b
        db 0110b
        db 1111b

        db 1111b    ; Letter 1 bitmap (G)
        db 1111b
        db 0001b
        db 1111b

        db 1001b    ; Letter 2 bitmap (N)
        db 1011b
        db 1101b
        db 1001b    

        db 1001b    ; Letter 3 bitmap (A)
        db 1111b
        db 1001b
        db 1111b    

        db 1111b    ; Letter 4 bitmap (C)
        db 0001b
        db 0001b
        db 1111b    

        db 1111b    ; Letter 5 bitmap (I)
        db 0110b
        db 0110b
        db 1111b

        db 1111b    ; Letter 6 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 0000b    ; Letter 7 bitmap ( )
        db 0000b
        db 0000b
        db 0000b

        db 1111b    ; Letter 8 bitmap (C)
        db 0001b
        db 0001b
        db 1111b    

        db 1001b    ; Letter 9 bitmap (A)
        db 1111b
        db 1001b
        db 1111b 


        db 1001b    ; Letter 10 bitmap (R)
        db 0111b
        db 1001b
        db 1110b    

        db 1111b    ; Letter 11 bitmap (L)
        db 0001b
        db 0001b
        db 0001b

        db 1111b    ; Letter 12 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 1111b    ; Letter 13 bitmap (S)
        db 0110b
        db 1000b
        db 1111b

    ;; Rotation 270 ------------------------------------------------
        db 1001b    ; Letter 0 bitmap (I)
        db 1111b
        db 1111b
        db 1001b

        db 1011b    ; Letter 1 bitmap (G)
        db 1011b
        db 1011b
        db 1111b

        db 1111b    ; Letter 2 bitmap (N)
        db 0100b
        db 0010b
        db 1111b

        db 1111b    ; Letter 3 bitmap (A)
        db 1010b
        db 1010b
        db 1111b

        db 1001b    ; Letter 4 bitmap (C)
        db 1001b
        db 1001b
        db 1111b

        db 1001b    ; Letter 5 bitmap (I)
        db 1111b
        db 1111b
        db 1001b

        db 1111b    ; Letter 6 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 0000b    ; Letter 7 bitmap ( )
        db 0000b
        db 0000b
        db 0000b

        db 1001b    ; Letter 8 bitmap (C)
        db 1001b
        db 1001b
        db 1111b

        db 1111b    ; Letter 9 bitmap (A)
        db 1010b
        db 1010b
        db 1111b


        db 1101b    ; Letter 10 bitmap (R)
        db 1010b
        db 1010b
        db 1111b
        

        db 0001b    ; Letter 11 bitmap (L)
        db 0001b
        db 0001b
        db 1111b

        db 1111b    ; Letter 12 bitmap (O)
        db 1001b
        db 1001b
        db 1111b

        db 1101b    ; Letter 13 bitmap (S)
        db 1011b
        db 1001b
        db 1001b



;; Boot signature ===================================
times 510-($-$$) db 0
dw 0AA55h

