.model small
.stack 100h
.data
    ballX       dw 1
    ballY       dw 31
    ballDirX    dw 1
    ballDirY    dw 1
    prevBallX   dw 1
    prevBallY   dw 1
    p1score     dw 0
    p2score     dw 0
    player1Pos  dw 10
    player2Pos  dw 310
    prevPlayer1Pos dw 0
    prevPlayer2Pos dw 0
    p1Up        dw 0
    p1Down      dw 0
    p2Up        dw 0
    p2Down      dw 0
    numStr      db 6 DUP ('$')
    modeStr     db "SinglePlayer(1) or MultiPlayer(2): $"
    mode        db 0

.code
PUBLIC _Input
PUBLIC _FrameUpdate
PUBLIC _Setup
PUBLIC _Exit
PUBLIC _Menu
PUBLIC _ModeSelect

_Setup proc FAR
    mov ax, 0A000h     ; Set ES to video memory segment (A000h)
    mov es, ax

    mov ax, 13h
    int 10h            ; Set video mode 13h (320x200, 256 colors)
    call playSound     ; Clear speaker stream
    retf
_Setup endp

_FrameUpdate PROC FAR
    push ds
    call gameCycle
    pop ds
    retf
_FrameUpdate ENDP

_Exit PROC FAR
    mov ax, 4C00h
    int 21h
    retf
_Exit ENDP

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

_ModeSelect PROC FAR
    push ax
    push bx
    push dx

    mov ax, @data
    mov ds, ax

    lea dx, modeStr
    mov ah, 9
    int 21h         ; print the string

    mov ah, 1
    int 21h         ; read key into AL

    sub al, '0'     ; convert to number (if key is '0'–'9')
    mov mode, al

    ; echo the mode value back
    mov dl, al
    add dl, '0'
    mov ah, 2
    int 21h

    pop dx
    pop bx
    pop ax
    retf
_ModeSelect ENDP

gameCycle proc
    call Input
    call drawPlayer1
    call drawPlayer2
    
    call updateBallPos
    call drawBall

    call updateP1Score
    call updateP2Score
    ret
gameCycle endp

num_to_str proc
    ; converts a 16-bit ax number to a string
    ; input: ax = number
    ; output: dx -> string buffer (numStr)
    
    push ax
    push bx
    push cx
    push dx

    mov cx, 0       ; digit count
    mov bx, 10      ; base 10 divisor

    convert_loop:
        mov dx, 0       ; clear dx before division
        div bx          ; ax / 10, remainder in dx
        add dl, '0'     ; convert remainder to ascii
        push dx         ; store digit on stack
        inc cx          ; increment digit count
        test ax, ax     ; check if ax == 0
        jnz convert_loop ; repeat until ax == 0

        ; store result in buffer
        mov di, offset numStr
    store_loop:
        pop dx
        mov [di], dl
        inc di
        loop store_loop

    mov byte ptr [di], '$' ; string terminator for dos int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
num_to_str endp

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
    cmp mode, 1        
    je next04

    cmp [p2Up], 1
    jne next03
    cmp [player2Pos], 310
    jbe next03

    mov ax, [player2Pos]
    mov [prevPlayer2Pos], ax
    sub [player2Pos], 320
    
    next03:
    cmp [p2Down], 1
    jne multiDone
    cmp [player2Pos], 320*175
    jae multiDone

    mov ax, [player2Pos]
    mov [prevPlayer2Pos], ax
    add [player2Pos], 320

    multiDone:
    ret

    ; Player 2 becomes the AI in Single Player
    next04: 
        mov ax, ballY
        mov bx, 320
        mul bx
        mov si, ax

        mov bx, [player2Pos]
        mov dx, bx
        add dx, 2240

        cmp dx, si
        ja AImoveUp

        cmp bx, 56000
        jae exitAI

        mov [prevPlayer2Pos], bx
        add bx, 320
        mov [player2Pos], bx
        jmp exitAI

    AImoveUp:
        cmp bx, 320
        jbe exitAI

        mov [prevPlayer2Pos], bx
        sub bx, 320
        mov [player2Pos], bx

    exitAI:
        ret
Input endp

drawPlayer1 proc
    mov ax, 0A000h
    mov es, ax         ; Set ES to video memory segment

    mov cx, 25         ; Number of rows (height of the screen)
    mov al, 0          ; Color (black) to clear

    mov di, prevPlayer1Pos          ; Load the player's current position
    clear_line:
        mov es:[di+10], al   
        mov es:[di+11], al
        add di, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)
        mov di, player1Pos          ; Load the player's current position

    draw_line:
        mov es:[di+10], al    
        mov es:[di+11], al 
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
        mov es:[si-10], al  
        mov es:[si-11], al  
        add si, 320        ; Move to the next row (320 bytes per row in mode 13h)
        loop clear_line2    ; Repeat for the entire line

        ; Draw vertical line at the new position
        mov cx, 25         ; Number of rows (height of the screen)
        mov al, 15         ; Color (white)

    draw_line2:
        mov es:[di-10], al  
        mov es:[di-11], al  
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

    mov es:[di-1], al
    mov es:[di], al
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
    mov al, 7
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

updateP1Score proc
    mov ax, [player2Pos]
    call num_to_str

    mov ah, 02h
    mov bh, 0         
    mov dh, 12  ; Row
    mov dl, 0  ; Column
    int 10h           ; Set cursor

    ; Print the number string in red
    lea si, numStr  ; Load string pointer

    print_loop1:
        mov al, [si]    ; Get character
        cmp al, '$'     ; End of string?
        je done1
        mov ah, 0Eh     ; BIOS teletype mode
        mov bl, 7       
        int 10H         ; Print character
        inc si          ; Next character
        jmp print_loop1  ; Repeat
    done1:
    ret
updateP1Score endp

updateP2Score proc
    mov ax, ballY
    call num_to_str

    mov ah, 02h
    mov bh, 0         
    mov dh, 12  ; Row
    mov dl, 30  ; Column
    int 10h           ; Set cursor

    ; Print the number string in red
    lea si, numStr  ; Load string pointer

    print_loop2:
        mov al, [si]    ; Get character
        cmp al, '$'     ; End of string?
        je done2
        mov ah, 0Eh     ; BIOS teletype mode
        mov bl, 7       
        int 10H         ; Print character
        inc si          ; Next character
        jmp print_loop2  ; Repeat
    done2:
    ret
updateP2Score endp

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
    je paddleHitP1
    
    mov bx, es:[di+1]
    cmp bx, 15
    je paddleHitP2

    ; Check for collision with left or right wall
    mov ax, [ballX]
    cmp ax, 1
    jl reverseXDir
    cmp ax, 319
    jg reverseXDir
    jmp checkY

    reverseXDir:
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
        neg [ballDirY]

    endUpdate:
        ret
    paddleHitP1:
        call playSound
        neg [ballDirX]
        inc p1Score
        ret
    paddleHitP2:
        call playSound
        neg [ballDirX]
        inc p2Score
        ret
updateBallPos endp

playSound proc
    mov al, 182    ; Set PIT channel 2 to square wave mode
    out 43h, al

    mov ax, 3500   ; Frequency (Higher number = Lower pitch)
    out 42h, al   
    mov al, ah
    out 42h, al   

    in al, 61h     
    or al, 3       ; Turn on speaker
    out 61h, al

    mov cx, 30000  ; Delay loop for sound duration
    delay_loop:
        loop delay_loop

        in al, 61h     
        and al, 0FCh   ; Turn off speaker
        out 61h, al

    ret
playSound endp

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