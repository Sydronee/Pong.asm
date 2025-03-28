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
    player1Pos  dw 10
    player2Pos  dw 310
    prevPlayer1Pos dw 0
    prevPlayer2Pos dw 0
    p1Up        dw 0
    p1Down      dw 0
    p2Up        dw 0
    p2Down      dw 0

.code
PUBLIC _Input
PUBLIC _FrameUpdate
PUBLIC _Setup
PUBLIC _Exit

;description
_Setup proc
    mov ax, @data
    mov ds, ax
    mov ax, 0A000h     ; Set ES to video memory segment (A000h)
    mov es, ax

    mov ax, 13h
    int 10h            ; Set video mode 13h (320x200, 256 colors)
    retf
_Setup endp
_FrameUpdate PROC FAR
    push ds
    call gameCycle
    pop ds
    retf
_FrameUpdate ENDP
_Exit PROC
    MOV AH, 00
    MOV AL, 03h    
    INT 10h        
    retf
_Exit ENDP

gameCycle proc
    call Input
    call createPlayer1
    call createPlayer2

    call updateBallPos
    call drawGame
    ret
gameCycle endp

_Input PROC FAR
    push bp          
    mov bp, sp       

    mov ax, [bp+6]   
    mov bx, [bp+8]   
    mov cx, [bp+10]   
    mov dx, [bp+12]   

    mov p1Up, ax
    mov p1Down, bx
    mov p2Up, cx
    mov p2Down, dx

    pop bp         
    retf
_Input ENDP

Input proc
    cmp [p1Up], 1
    jne next01
    cmp [player1Pos], 10
    jbe next01
    mov ax, [player1Pos]
    mov [prevPlayer1Pos], ax
    sub [player1Pos], 320
    
    next01:
    cmp [p1Down], 1
    jne next02
    cmp [player1Pos], 320*175
    jae next02
    mov ax, [player1Pos]
    mov [prevPlayer1Pos], ax
    add [player1Pos], 320
    
    next02:
    cmp [p2Up], 1
    jne next03
    cmp [player2Pos], 310
    jbe next03
    mov ax, [player2Pos]
    mov [prevPlayer2Pos], ax
    sub [player2Pos], 320
    
    next03:
    cmp [p2Down], 1
    jne next04
    cmp [player2Pos], 320*175
    jae next04
    mov ax, [player2Pos]
    mov [prevPlayer2Pos], ax
    add [player2Pos], 320
    
    next04:
    ret
Input endp

createPlayer1 proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, 0A000h
    mov es, ax         ; Set ES to video memory segment

    mov cx, 25         ; Number of rows (height of the screen)
    mov al, 0          ; Color (black) to clear

    mov di, prevPlayer1Pos          ; Load the player's current position
    clear_line:
        mov es:[di], al    ; Clear pixel
        mov es:[di+1], al  ; Clear pixel
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)
        mov di, player1Pos          ; Load the player's current position

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
createPlayer2 proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov di, [player2Pos]          ; Load the player's current position
    
    mov ax, 0A000h
    mov es, ax         ; Set ES to video memory segment

    mov cx, 25         ; Number of rows (height of the screen)
    mov al, 0          ; Color (black) to clear

    mov si, [prevPlayer2Pos]

    clear_line2:
        mov es:[si+319], al    ; Clear pixel
        mov es:[si+320], al  ; Clear pixel
        add si, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line2    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)

    draw_line2:
        mov es:[di+319], al    ; Draw pixel
        mov es:[di+320], al  ; Draw pixel
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

end