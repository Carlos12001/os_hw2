;;;
;;; Space Invaders-ish game in 510 bytes (or less!) of qemu bootable real mode x86 asm
;;;

;; NOTE: Assuming direction flag is clear, SP initialized to 6EF0h, BP = 0

use16           ; (Not needed) Use 16 bit code only
org 07C00h		; Set bootsector to be at memory location hex 7C00h (UNCOMMENT IF USING AS BOOTSECTOR)

;; DEFINED VARIABLES AFTER SCREEN MEMORY - 320*200 = 64000 or FA00h =========================
sprites      equ 0FA00h
letter1      equ 0FA00h
letter2      equ 0FA02h
letter3      equ 0FA04h
letter4      equ 0FA06h
letter5      equ 0FA08h
letter6      equ 0FA0Ah
;barrierArr   equ 0FA0Ch
alienArr     equ 0FA20h  ; 2 words (1 dblword) - 32bits/aliens
;playerX      equ 0FA24h
;shotsArr     equ 0FA25h  ; 4 Y/X shot values - 8 bytes, 1st shot is player
alienY       equ 0FA2Dh
alienX       equ 0FA2Eh
;num_aliens   equ 0FA2Fh  ; # of aliens still alive
;direction    equ 0FA30h  ; # pixels that aliens move in X direction
;move_timer   equ 0FA31h  ; 2 bytes (using BP) - # of game loops/timer ticks to wait before aliens move
change_alien equ 0FA33h  ; Use alternate sprite yes/no

;; CONSTANTS =====================================
SCREEN_WIDTH        equ 320     ; Width in pixels
SCREEN_HEIGHT       equ 200     ; Height in pixels
VIDEO_MEMORY        equ 0A000h
TIMER               equ 046Ch   ; # of timer ticks since midnight
PLAYERY             equ 93
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

;; Move initial sprite data into memory
mov di, sprites
mov si, sprite_bitmaps
mov cl, 6
rep movsw

lodsd           ; Store 5 barriers in memory for barrierArr
mov cl, 5
rep stosd

;; Set initial variables
mov cl, 5       ; Alien array & playerX
rep movsb

xor ax, ax      ; Shots array - 8 bytes Y/X values
mov cl, 4
rep stosw

mov cl, 5       ; AlienY/X, # of aliens, direction, move_timer, change_alien
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
    ;; Draw aliens ------------------------------------------------
    mov si, alienArr
    mov bl, LETTER_COLOR
    mov ax, [si+13]       ; AL = alienY, AH = alienX
    mov cl, 4
    mov dl, byte[si+19]
    ;cmp byte [si+19], cl  ; Change alien? CL = 0 from above
    ;mov cl, 4

    ;jg draw_next_alien_row    ; Nope, use normal sprite
    ;add di, cx                ; Yes, use alternate sprite  (CX = 4)

    ;cmp byte [si+19], 0
    ;je draw_next_alien_row
    ;cmp byte [si+19], 1
    ;je second_sprite

    cmp dl, 0
    je draw_next_alien_row

    cmp dl, 1
    je sprite_1

    cmp dl, 2
    je sprite_2

    cmp dl, 3
    je sprite_3

    ;add di, cx
    jmp draw_next_alien_row

    sprite_1:
        add di, cx
        jmp draw_next_alien_row

    sprite_2:
        add di, cx
        add di, cx
        jmp draw_next_alien_row

    sprite_3:
        add di, cx
        add di, cx
        add di, cx
        jmp draw_next_alien_row

    sprite_4:
        add di, cx
        add di, cx
        add di, cx
        add di, cx
        jmp draw_next_alien_row

    sprite_5:
        add di, cx
        add di, cx
        add di, cx
        add di, cx
        add di, cx
        jmp draw_next_alien_row

draw_next_alien_row:
        pusha
        mov cl, 13             ; # of aliens to check per row
        check_next_alien:
            pusha
            dec cx
            ;bt [si], cx     ; Bit test - copy bit to carry flag
            ;jnc .next_alien ; Not set, skip

            mov si, di      ; SI = alien sprite to draw
            call draw_sprite

            .next_alien:
                popa
                add ah, SPRITE_WIDTH+2

        loop check_next_alien

        popa
    loop draw_next_alien_row

    ;; Draw player ship -------------------------------------------
    ;; SI currently poins to playerX
    ;lodsb       ; AL = playerX
    ;push si
    ;mov si, ship
    ;mov ah, PLAYERY
    ;xchg ah, al ; Swap playerX and playerY values
    ;mov bl, PLAYER_COLOR
    ;call draw_sprite


    ;; Move aliens ------------------------------------------------
    ;; TODO: Try to change to use leftmost/rightmost aliens for comparisons,
    ;;   don't just check the top left alien
    move_aliens:
        ;; Using BP for move_timer, Push/pop only affects SP, BP is unaffected
        mov di, alienX

        ;; Yes, move aliens
        neg byte [change_alien]     ; Toggle change_alien byte between 1 & -1, use next sprite
	    mov al, byte [change_alien]
	    inc al
	    cmp al, 6

	    jl continue
        mov al, 0
	
	    continue:
	        mov byte [change_alien], al
        



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
;; Input parameters:
;;   SI = address of sprite to draw
;;   AL = Y value of sprite
;;   AH = X value of sprite
;;   BL = color
;; Clobbers:
;;   DX
;;   DI
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
;; Input parameters:
;;   AL = Y value
;;   AH = X value
;; Clobbers: 
;;   DX
;;   DI
get_screen_position:
    mov dx, ax      ; Save Y/X values
    cbw             ; Convert byte to word - sign extend AL into AH, AH = 0 if AL < 128
    imul di, ax, SCREEN_WIDTH*2  ; DI = Y value
    mov al, dh      ; AX = X value
    shl ax, 1       ; X value * 2
    add di, ax      ; DI = Y value + X value or X/Y position

    ret

;; CODE SEGMENT DATA =================================
sprite_bitmaps:
    db 1111b    ; Letter 0 bitmap
    db 0110b
    db 0110b
    db 1111b

    db 1111b    ; Letter 1 bitmap
    db 1000b
    db 1111b
    db 1111b

    db 1001b    ; Letter 2 bitmap
    db 1101b
    db 1011b
    db 1001b

    db 1111b    ; Letter 3 bitmap
    db 1001b
    db 1111b
    db 1001b

    db 1111b    ; Letter 4 bitmap
    db 1001b
    db 1000b
    db 1111b

    db 1111b    ; Letter 5 bitmap
    db 0110b
    db 0110b
    db 1111b

    ;;; Rotate izq 90
    db 1001b    ; Letter 0 bitmap
    db 1111b
    db 1111b
    db 1001b




    db 11000011b    ; Player ship bitmap
    db 11100011b
    db 11011011b
    db 11100111b

    db 00111100b    ; Barrier bitmap
    db 01111110b
    db 11100111b
    db 11100111b

    ;; Initial variable values
    dw 0FFFFh       ; Alien array
    dw 0FFFFh
    ;db 70           ; PlayerX
    ;; times 8 db 0 ; Shots array
    dw 230Ah        ; alienY & alien X | 10 = Y, 35 = X
    db 20h          ; # of aliens = 32 TODO: Remove & check if alienArr = 0, 
                    ;   This is probably not needed, can save some bytes
    db 0FBh         ; Direction -5
    dw 18           ; Move timer
    db 1            ; Change alien - toggle between 1 & -1

;; Boot signature ===================================
times 510-($-$$) db 0
dw 0AA55h

