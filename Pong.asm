.model small
.stack 100h
.data
    ballX       dw 1
    ballY       dw 31
    ballDirX    dw 1
    ballDirY    dw 1
    prevBallX   dw 1
    prevBallY   dw 1
    score       dw 0
    player1Pos  dw 0
    player2Pos  dw 0
.code
main proc
    mov ax, @data
    mov ds, ax
    mov ax, 0A000h     ; Set ES to video memory segment (A000h)
    mov es, ax

    mov ax, 13h
    int 10h            ; Set video mode 13h (320x200, 256 colors)
gameLoop:
    call drawGame
    call updateBallPos
    ; call keyPressTest

    call createPlayer2
    call createPlayer1
    call delay          ; crude delay to slow movement
    jmp gameLoop
main endp

;description
keyPressTest proc
    push ax 
    push bx
    push cx
    push dx
    push si
    push di

    mov ah, 01h
    int 16h
    
    jz asd
    ; Read key press
    mov ah, 00h
    int 16h

    cmp ah, 48h
    je green
    
    cmp ah, 50h
    je blue
    
    jmp white

    green:
        xor di, di              ; Start at the beginning of video memory
        mov cx, 320*200         ; Total pixels in Mode 13h
        mov al, 02h
        rep stosb               ; Fill entire screen with black
        jmp asd

    blue:
        xor di, di              ; Start at the beginning of video memory
        mov cx, 320*200        ; Total pixels in Mode 13h
        mov al, 04h
        rep stosb               ; Fill entire screen with black
        jmp asd

    white:
        xor di, di              ; Start at the beginning of video memory
        mov cx, 320*200         ; Total pixels in Mode 13h
        mov al, 0Fh
        rep stosb               ; Fill entire screen with black
        jmp asd
        
    asd:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
keyPressTest endp

createPlayer2 proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov di, [player2Pos]          ; Load the player's current position
    
    mov ah, 01h
    int 16h

    jz no_key_press2    ; If no key press, skip to drawing

    ; Read key press
    mov ah, 00h
    int 16h

    ; Check scan code
    cmp ah, 11h       ; Up arrow key scan code
    je up_arrow2

    cmp ah, 1Fh       ; Down arrow key scan code
    je down_arrow2

    jmp no_key_press2   ; If not up or down arrow, skip to drawing

    up_arrow2:
        cmp di, 319        ; Check if at the top edge
        jbe no_key_press2    ; If at the top, skip to drawing
        sub di, 320        ; Move up one row
        jmp no_key_press2

    down_arrow2:
        cmp di, 319*175  ; Check if at the bottom edge
        jae no_key_press2    ; If at the bottom, skip to drawing
        add di, 320        ; Move down one row
        jmp no_key_press2

    no_key_press2:
        mov ax, 0A000h
        mov es, ax         ; Set ES to video memory segment

        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 0          ; Color (black) to clear

        mov si, [player2Pos]
        mov [player2Pos], di  ; Save the new position
    clear_line2:
        mov es:[si+318], al    ; Clear pixel
        mov es:[si+319], al  ; Clear pixel
        add si, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line2    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)

    draw_line2:
        mov es:[di+318], al    ; Draw pixel
        mov es:[di+319], al  ; Draw pixel
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop draw_line2     ; Repeat for the entire line

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
createPlayer2 endp


createPlayer1 proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov di, [player1Pos]          ; Load the player's current position
    
    mov ah, 01h
    int 16h

    jz no_key_press    ; If no key press, skip to drawing

    ; Read key press
    mov ah, 00h
    int 16h

    ; Check scan code
    cmp ah, 48h        ; Up arrow key scan code
    je up_arrow

    cmp ah, 50h        ; Down arrow key scan code
    je down_arrow

    jmp no_key_press   ; If not up or down arrow, skip to drawing

    up_arrow:
        cmp di, 0        ; Check if at the top edge
        jbe no_key_press    ; If at the top, skip to drawing
        sub di, 320        ; Move up one row
        jmp no_key_press

    down_arrow:
        cmp di, 320*175  ; Check if at the bottom edge
        jae no_key_press    ; If at the bottom, skip to drawing
        add di, 320        ; Move down one row
        jmp no_key_press

    no_key_press:
        ; Clear the previous position
        
        mov ax, 0A000h
        mov es, ax         ; Set ES to video memory segment

        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 0          ; Color (black) to clear

        mov si, [player1Pos]
        mov [player1Pos], di  ; Save the new position

    clear_line:
        mov es:[si], al    ; Clear pixel
        mov es:[si+1], al  ; Clear pixel
        add si, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)

    draw_line:
        mov es:[di], al    ; Draw pixel
        mov es:[di+1], al  ; Draw pixel
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop draw_line     ; Repeat for the entire line

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
createPlayer1 endp

drawGame proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, [prevBallY]
    mov bx, 320
    mul bx
    add ax, [prevBallX]         
    mov di, ax              

    ; Set ES to video memory segment
    mov ax, 0A000h
    mov es, ax

    ; Clear the previous ball (color 0)
    mov al, 0
    mov es:[di], al
    mov es:[di+1], al
    mov es:[di+2], al
    mov es:[di+320], al
    mov es:[di+321], al
    mov es:[di+322], al
    mov es:[di+640], al
    mov es:[di+641], al
    mov es:[di+642], al

    ; Calculate the position in video memory
    mov ax, ballY
    mov bx, 320
    mul bx
    add ax, ballX
    mov di, ax

    ; Set ES to video memory segment
    mov ax, 0A000h
    mov es, ax

    ; Draw the ball (color 15)
    mov al, 15
    mov es:[di], al
    mov es:[di+1], al
    mov es:[di+2], al
    mov es:[di+320], al
    mov es:[di+321], al
    mov es:[di+322], al
    mov es:[di+640], al
    mov es:[di+641], al
    mov es:[di+642], al
    


    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawGame endp

updateBallPos proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Update X position
    mov ax, [ballX]
    mov [prevBallX], ax
    mov bx, [ballDirX]
    add ax, bx
    mov [ballX], ax

    ; Check for collision with left or right wall
    cmp ax, 1
    jl reverseXDir
    cmp ax, 316
    jg reverseXDir
    jmp checkY

    reverseXDir:
        inc [score]
        neg [ballDirX]

    checkY:
        ; Update Y position
        mov ax, [ballY]
        mov [prevBallY], ax
        mov bx, [ballDirY]
        add ax, bx
        mov [ballY], ax

        ; Check for collision with top or bottom wall
        cmp ax, 1
        jl reverseYDir
        cmp ax, 196
        jg reverseYDir
        jmp endUpdate

    reverseYDir:
        inc [score]
        neg [ballDirY]

    endUpdate:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
updateBallPos endp

ClearScreen proc
    push ax
    push cx
    push di
    push es

    mov ax, 0A000h          ; Set ES to video memory segment
    mov es, ax

    xor di, di              ; Start at the beginning of video memory
    mov cx, 320*200         ; Total pixels in Mode 13h
    xor al, al              ; Color 0 (black)
    rep stosb               ; Fill entire screen with black

    pop es
    pop di
    pop cx
    pop ax
    ret
ClearScreen endp

;------------------------------------------------------------
; Crude delay loop to slow down game speed.
; Adjust the value in CX as needed.
;------------------------------------------------------------
delay proc
    push cx
    mov cx, 02FFFh
    delay_loop:
        nop
        loop delay_loop
    pop cx
    ret
delay endp

end main