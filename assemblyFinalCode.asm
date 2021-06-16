; multi-segment executable file template.

data segment
    ; add your data here!
    white equ 0
    black equ 15
    wordsFile db "words.txt"
    FileHandle dw 0
    buffer db 255 dup (0)
    randomNumber db 0
    word db 20 dup (0)  
    word_len db 0 
    fail_label_message db "fails:$"
    succeed db 0
    fail_place db 6 
    
    head_circle db 0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
                db 0,0,0,0,0,15,15,0,15,15,0,0,0,0,0
                db 0,0,0,0,15,0,0,0,0,0,15,0,0,0,0
                db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0
                db 0,0,15,0,0,0,0,0,0,0,0,0,15,0,0
                db 0,15,0,0,0,0,0,0,0,0,0,0,0,15,0
                db 0,15,0,0,0,0,0,0,0,0,0,0,0,15,0
                db 15,0,0,0,0,0,0,0,0,0,0,0,0,0,15
                db 0,15,0,0,0,0,0,0,0,0,0,0,0,15,0      
                db 0,15,0,0,0,0,0,0,0,0,0,0,0,15,0
                db 0,0,15,0,0,0,0,0,0,0,0,0,15,0,0
                db 0,0,0,15,0,0,0,0,0,0,0,15,0,0,0
                db 0,0,0,0,15,0,0,0,0,0,15,0,0,0,0
                db 0,0,0,0,0,15,15,0,15,15,0,0,0,0,0
                db 0,0,0,0,0,0,0,15,0,0,0,0,0,0,0
    head_length equ 15
    fail_number db 0    
    correct db 20 dup (0)
    did_win db 0
    
ends

stack segment
    dw   128  dup(0)
ends

code segment   
proc init_screen
    push ax
    mov ax, 13H
    int 10H  
    pop ax
    ret
endp





proc draw_lines
    pusha
    lea si, word_len
    mov bx, [si]
    
    
    mov ah, 0ch
    mov al, 15
    mov cx, 27     
    mov dx, 170
    
   lines:
     
    call draw_line
    dec bx
    add cx, 12
    cmp bl, 0
    jne lines
     
    
    popa
    ret

proc draw_line
    push bx
    xor bx, bx
   making_line: 
    int 10h
    inc cx
    inc bx
    cmp bx, 20    
    jne making_line 

    pop bx
    ret    
    
proc write_letter
    mov bp, sp
    pusha
    
    lea si, succeed
    mov [si], 1
    
    mov cx, [bp+2]
    mov ax, 4
    mul cx
    
   
    mov  dl, al   ;Column start at al location
    mov  dh, 20   ;Row 
    xor  bh, bh   ;Display page set to 0
    mov  ah, 02h  ;SetCursorPosition in int 10h
    int  10h
    
    mov ax, [bp+4]
    ;mov  al, '3'
    mov bl, 15
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h
    popa
    ret 4    


proc get_fail  ;work on progres
    
    
    mov bp, sp
    pusha
    
    lea si, succeed
    cmp [si], 1
    je exit_get_fail
    
    
    lea si, fail_place
    mov dl, [si]
    ;mov dl, 6 ;column = 6
    mov ah, 02h
    xor bh, bh ;page = 0
    mov dh, 24 ;row = 24
    int 10h
    
    mov ah, 08h
    int 10h
    
    inc dl
    mov [si], dl
    

    
    mov al, [bp +2]
    mov ah, 09h
    mov bl, 0ch
    mov cx, 1
    int 10h
    
    lea si, fail_number
    inc [si]
    
    
    
   exit_get_fail:
    lea si, succeed
    mov [si], 0   
    popa
    ret 2 

proc get_letter
    pusha
    mov ah, 7h
    int 21h
    
    lea si, correct
    
    mov cl, 1
    
    lea bx, word
    cmp [bx], al
    je call_write_letter
    
   check_for_letter:
    inc cl
    inc bx
    inc si
    cmp [bx], "$"
    je call_get_fail
    cmp [bx], al
    je call_write_letter
    
    jne check_for_letter
   
   call_get_fail:
    push ax
    call get_fail
    jmp exit
   call_write_letter:
    mov [si], al
    push ax
    push cx
    call write_letter
    jmp check_for_letter

    
   exit:
    popa 
    ret        
            
proc openAndReadFile
    pusha
    ;opens file
    mov ah, 3Dh
    lea dx, wordsFile
    xor al, al
    int 21h 
    mov offset fileHandle, ax ;handler
    
    ;reads from file
    mov ah, 3Fh
    mov bx, [fileHandle]
    mov cx, 255
    lea dx, buffer
    int 21h
    popa
    ret

proc randomNumb
    pusha
    mov ah, 2ch    
    int 21h
    mov ax, dx
    add ah, al
    xor dx, dx
    mov bx, 10
    div bx
    lea bx, randomNumber
    mov [bx], ah
    popa 
    ret
    
proc randomWord
    pusha
    lea bx, randomNumber
    mov cx, [bx]
    lea bx, buffer
   loop_until_found:   ;0A
    inc bx
    mov ax, [bx]
    cmp al, 0Ah
    jne loop_until_found
    dec cx
    cmp cx,0
    jne loop_until_found
    
    inc bx 
    

    lea di, word
   collect_word:
    mov si, [bx]
    mov [di], si
    inc bx
    inc di
    cmp si, 0A0Dh  ; 0A0D 0D62
    jne collect_word
    
    dec di
    mov [di], "$"
    
    popa 
    ret

proc word_length
    pusha
    
    lea bx, word
    xor cx, cx
   count:
    inc cx
    inc bx
    cmp [bx], "$"
    jne count
    
    lea bx, word_len
    mov [bx], cl
    
    
    popa
    ret



    
    
proc fail_label
    
    lea si, fail_label_message
    mov dl, 0
    xor cl, cl
   write_label: 
    ;mov  dl, cl   ;Column start at 3
    mov  dh, 24   ;Row 
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    
    mov al, [si]
    inc si
    ;mov  al, '3'
    mov  bl, 0Ch  ;Color is red
    xor  bh, bh    ;Display page
    mov  ah, 0Eh  ;Teletype
    int  10h
    inc dl
    cmp [si], "$"
    jne write_label
    ret     

proc base       
    mov ah, 0Ch
    mov al, 15
    xor bh, bh
    mov cx, 240
    mov dx, 120 
   p1:         
    int 10h
    inc cx 
    cmp cx, 270
    jne p1
    
    
    mov cx, 255
   p2:
    int 10h
    dec dx
    cmp dx, 45
    jne p2 
   
   p3:    
    int 10h
    dec cx 
    cmp cx, 220
    jne p3
    
   p4:
    int 10h
    inc dx
    cmp dx, 55 
    jne p4
    
    
    ret
    
proc draw_head
    pusha
    lea si, head_circle
    
    mov ah, 0Ch
    
    mov cx, 213
    mov dx, 55
   head_loop:
    cmp dx, 55 + head_length
    je head_draw_exit
    mov al, [si]
    int 10h
    inc cx
    inc si
    cmp cx, 213+head_length
    je next_layer
    jmp head_loop
   
   next_layer:
    mov cx, 213
    inc dx 
    jmp head_loop
    
   head_draw_exit:
    popa
    ret

proc write_all_word
    pusha
    
     lea si, word
     mov dl, 4
    write_loop:
     
     mov  dh, 20   ;Row 
     xor  bh, bh   ;Display page set to 0
     mov  ah, 02h  ;SetCursorPosition in int 10h
     int  10h
     add dl, 4
    
    
     mov ah, 09h
     mov cx, 1
     mov al, [si]
     inc si
     mov bl, 4h
     int 10h
     cmp [si], "$"
     jne write_loop 
    
     
   exit_write_all_word:    
    popa    
    ret                  
    
    
proc main_game   
    pusha
    
    ;setup
    call openAndReadFile
    call randomNumb     
    call randomWord
    call word_length
    call init_screen 
    call base
    call fail_label
    call draw_lines      
    
    ;game        
   main_game_loop:     
    call get_letter
    call check_win
    cmp [did_win], 1
    je exit_game 
    lea bx, fail_number
    cmp [fail_number], 1
    je call_draw_head
    cmp [fail_number], 2
    je draw_belly
    cmp [fail_number], 3
    je draw_hand1
    cmp [fail_number], 4
    je draw_hand2
    cmp [fail_number], 5
    je draw_leg1
    cmp [fail_number], 6
    je draw_leg2
    cmp [fail_number], 7
    je call_write_all_word        
    jmp main_game_loop
   
   
   
   
   call_draw_head:
    call draw_head
    jmp main_game_loop
   
   
   draw_belly:
    mov cx, 220
    mov dx, 70
    mov ah, 0Ch
    mov al, 15
   belly_loop:
    int 10h  
    inc dx
    cmp dx, 90
    jne belly_loop
    jmp main_game_loop
   
   
   draw_hand1:
    mov cx, 220
    mov dx, 70
    mov ah, 0Ch
    mov al, 15
   hand1_loop:
    int 10h
    inc dx
    inc cx
    cmp dx, 80
    jne hand1_loop
    jmp main_game_loop
    
    
   draw_hand2:
    mov cx, 220
    mov dx, 70
    mov ah, 0Ch
    mov al, 15
   hand2_loop:
    int 10h
    inc dx
    dec cx
    cmp dx, 80
    jne hand2_loop
    jmp main_game_loop  
     
    
   draw_leg1:
    mov cx, 220
    mov dx, 90
    mov ah, 0Ch
    mov al, 15
   leg1_loop:
    int 10h
    inc dx
    inc cx
    cmp dx, 100
    jne leg1_loop
    jmp main_game_loop
    
                         
   draw_leg2:
    mov cx, 220
    mov dx, 90
    mov ah, 0Ch
    mov al, 15
   leg2_loop:
    int 10h
    inc dx
    dec cx
    cmp dx, 100
    jne leg2_loop
    jmp main_game_loop
    
   call_write_all_word:
    call write_all_word
    
    
   exit_game:   
    
    popa        
    ret
proc check_win
    pusha 
    
    lea si, correct
    lea bx, word  
    cmp [bx], "$"
    je call_win 
    mov al, [si]
    mov dl, [bx]
    cmp al, dl
    je check_loop
    
    
   check_loop:
    inc si
    inc bx
    cmp [bx], "$"
    je call_win
    mov al, [si]
    mov dl, [bx]
    cmp al, dl
    je check_loop   
    
   exit_check: 
    popa
    ret        
    
   call_win:
    lea si, did_win
    mov [si], 1
    call win
    jmp exit_check

proc win
    pusha
    
     lea si, word
     mov dl, 4
    write_win:
     
     mov  dh, 20   ;Row 
     xor  bh, bh   ;Display page set to 0
     mov  ah, 02h  ;SetCursorPosition in int 10h
     int  10h
     add dl, 4
    
    
     mov ah, 09h
     mov cx, 1
     mov al, [si]
     inc si
     mov bl, 2h
     int 10h
     cmp [si], "$"
     jne write_win 
    
     
   exit_write_win:    
    popa    
    ret
    
                   
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    
    call main_game
    ;call draw_head
     
    
    
   ; mov cx, 10
   ;est:
   ; call get_letter
   ; loop est
   ; mov ax, 4c00h ; exit to operating system.
   ; int 21h    
ends

end start ; set entry point and stop the assembler.
