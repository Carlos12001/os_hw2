use16           ; (Not needed) Use 16 bit code only
org 07C00h		; Set bootsector to be at memory location hex 7C00h (UNCOMMENT IF USING AS BOOTSECTOR)

;; DEFINED VARIABLES AFTER SCREEN MEMORY - 320*200 = 64000 or FA00h =========================
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

letterY       equ 0FA2Dh ;
letterX       equ 0FA2Eh ;

changeLetter equ 00000h  ; Choose Letter Rotation

;; CONSTANTS =====================================
SCREEN_WIDTH        equ 320     ; Width in pixels
SCREEN_HEIGHT       equ 200     ; Height in pixels
VIDEO_MEMORY        equ 0A000h
TIMER               equ 046Ch   ; # of timer ticks since midnight
SPRITE_HEIGHT       equ 4
SPRITE_WIDTH        equ 4       ; Width in bits/data pixels
SPRITE_WIDTH_PIXELS equ 8      ; Width in screen pixels

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
mov si, sprite_bitmaps
mov cl, 14
rep movsw


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
    mov di, 100 ; Set starting Y coordinate
    mov bx, 50  ; Set starting X coordinate
    mov cx, 14  ; Number of letters

    draw_letters:
        push cx
        mov si, sprites
        add si, cx
        shl si, 2   ; Multiply by 4 (size of each sprite)
        
        ;; Draw sprite
        push di     ; Save DI
        mov dx, SPRITE_HEIGHT ; Set number of rows
        draw_sprite_row:
            push dx
            push si
            push di
            mov dx, SPRITE_WIDTH_PIXELS ; Set width in pixels
            draw_sprite_pixel:
                mov al, [si] ; Get sprite pixel data
                test al, 1
                jz next_pixel
                mov [es:di], LETTER_COLOR ; Draw pixel
            next_pixel:
                inc di
                shr al, 1
                dec dx
                jnz draw_sprite_pixel
            pop di
            pop si
            pop dx
            add di, SCREEN_WIDTH ; Move to next row on screen
            dec dx
            jnz draw_sprite_row
        pop di
        add di, SPRITE_WIDTH_PIXELS ; Move to next sprite position
        pop cx
        loop draw_letters


    ;; Delay timer - 1 tick delay (1 tick = 18.2/second)
    delay_timer:
        mov ax, [CS:TIMER]
        inc ax
        .wait:
            cmp [CS:TIMER], ax
            jl .wait
jmp game_loop

;; END GAME LOOP =====================================


;; CODE SEGMENT DATA =================================
;; The size of the code are 32 bits (4 bytes) although we define only the last 
;; 4 bits of the letter the 4 MSB are 0 by default. Because the instruction
;; db only defines 1 bytes not nibbles, por eso los primeros 4 bits son 0.
sprite_bitmaps:
;; 0 degree rotation
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
    db 1111b
    db 1111b

    ;; 90 degree rotation
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
    db 1111b
    db 1111b

;; 180 degree rotation
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
    db 1111b
    db 1111b


;; 270 degree rotation
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
    db 1111b
    db 1111b
;; Boot signature ===================================
times 510-($-$$) db 0
dw 0AA55h

