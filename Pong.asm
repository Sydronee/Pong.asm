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
    call drawPlayer1
    call drawPlayer2

    call updateBallPos
    call drawBall
    ret
gameCycle endp

_Input PROC FAR
    mov bp, sp       

    mov ax, [bp+4]   
    mov bx, [bp+6]   
    mov cx, [bp+8]   
    mov dx, [bp+10]   

    mov p1Up, ax
    mov p1Down, bx
    mov p2Up, cx
    mov p2Down, dx
        
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

drawPlayer1 proc
    mov ax, 0A000h
    mov es, ax         ; Set ES to video memory segment

    mov cx, 25         ; Number of rows (height of the screen)
    mov al, 0          ; Color (black) to clear

    mov di, prevPlayer1Pos          ; Load the player's current position
    clear_line:
        mov es:[di], al   
        mov es:[di+1], al 
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)
        mov di, player1Pos          ; Load the player's current position

    draw_line:
        mov es:[di], al    
        mov es:[di+1], al 
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop draw_line     ; Repeat for the entire line
    ret
drawPlayer1 endp

drawPlayer2 proc
    mov di, [player2Pos]          ; Load the player's current position
    
    mov ax, 0A000h
    mov es, ax         ; Set ES to video memory segment

    mov cx, 25         ; Number of rows (height of the screen)
    mov al, 0          ; Color (black) to clear

    mov si, [prevPlayer2Pos]

    clear_line2:
        mov es:[si+319], al  
        mov es:[si+320], al  
        add si, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line2    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)

    draw_line2:
        mov es:[di+319], al  
        mov es:[di+320], al  
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop draw_line2     ; Repeat for the entire line
    ret
drawPlayer2 endp

drawBall proc
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
    mov es:[di+319], al
    mov es:[di+320], al
    mov es:[di+321], al

    mov es:[di], al
    mov es:[di-1], al
    mov es:[di+1], al

    mov es:[di-319], al
    mov es:[di-320], al
    mov es:[di-321], al
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
    mov es:[di-319], al
    mov es:[di-320], al
    mov es:[di-321], al

    mov es:[di], al
    mov es:[di-1], al
    mov es:[di+1], al

    mov es:[di+319], al
    mov es:[di+320], al
    mov es:[di+321], al
    ret
drawBall endp

updateBallPos proc
    ; Update X position
    mov ax, [ballX]
    mov [prevBallX], ax
    mov bx, [ballDirX]
    add ax, bx
    mov [ballX], ax

    ; Calculate the position in video memory
    mov ax, ballY
    mov bx, 320
    mul bx
    add ax, ballX
    mov di, ax

    ; Check on the left and right for the player paddle
    mov bx, es:[di-2]
    cmp bx, 15
    je paddleHit
    
    mov bx, es:[di+1]
    cmp bx, 15
    je paddleHit

    ; Check for collision with left or right wall
    mov ax, [ballX]
    cmp ax, 1
    jl reverseXDir
    cmp ax, 319
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
        cmp ax, 199
        jg reverseYDir
        jmp endUpdate

    reverseYDir:
        inc [score]
        neg [ballDirY]

    endUpdate:
        ret
    paddleHit:
        neg [ballDirX]
        ret

updateBallPos endp

ClearScreen proc
    mov ax, 0A000h          ; Set ES to video memory segment
    mov es, ax

    xor di, di              ; Start at the beginning of video memory
    mov cx, 320*200         ; Total pixels in Mode 13h
    xor al, al              ; Color 0 (black)
    rep stosb               ; Fill entire screen with black
    ret
ClearScreen endp

end