; multi-segment executable file template.

data segment
    board           db 2000 dup(0)
    
    sep_str         db "********************************************************************************", 0
    maintTitle_str  db "*******************************    SNAKE GAME    *******************************", 0
    OpMenu1         db "Introduzir identificacao do jogador", 0  
    OpMenu2         db "Consultar Top Five", 0
    OpMenu3         db "Iniciar jogo", 0
    OpMenuQuit      db "Sair", 0  
    top5Title_str   db "*******************************      TOP 5       *******************************", 0

    gameHeader_str  db "Jogador:                          Nivel:                           Pontos:      ", 0

    gameOver_str    db "GAME OVER!  Prima a tecla enter.", 0
    scoreEnd_str    db ", a sua pontuacao e: ", 0   
    
    
    top5_names      db 35 dup(0), 24h
    top5_points     dw 5 dup(0), 24h   
    
    ;pathnew         db "C:\Users\Aluno\Desktop\snake", 0
    ;pathTop5        db "C:\Users\Aluno\Desktop\snake\top5.bin", 0
    ;pathResultados  db "C:\Users\Aluno\Desktop\snake\resultados.txt", 0
    
    pathnew         db "C:\snake", 0       
    pathTop5        db "C:\snake\top5.bin", 0                               
    pathResultados  db "C:\snake\resultados.txt", 0
    
    order1 db "1o", 0Ah, 0Dh, 0
    order2 db "2o", 0Ah, 0Dh, 0  
    order3 db "3o", 0Ah, 0Dh, 0
    order4 db "4o", 0Ah, 0Dh, 0
    order5 db "5o", 0Ah, 0Dh, 0
    
    playerRes   db 27 dup(0)  
              
    snake_pos   db 6 dup(0) 
    
    char_snake  db 219
    gameScore   dw 0 

    level       dw 1 
    delaytime   dw 11
    ;char        db 0
    pname       db 0
    cont        db 0         
    quociente   dw 0
    resto       dw 0 
    ctop5       db 0
    endgame     db 0 
    constant    db 0   
    handlerTop5 dw 0
    handlerRes  dw 0

    tmp        db 50 dup(0)
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    call files          ; opens / creates, reads necessary files
    call setvideo       ; sets the graphical mode (text)
    call startMenu
    call caseBin
 
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
ends

;*****************************************************************
; files
; description: creates necessary files (resultados, top5)  
; input - pathResultados, pathTop5, top5_names
; output - handlerRes, handlerTop5
; destroys - ax, bx, cx, dx 
;*****************************************************************      
files proc
    
    call setCurrentDirectory    ; fetches the current working directory
    jc needs_new_dir
     
    mov dx, offset pathResultados
    mov al, 2  
    call fopen          ; attempts to open existing resultados.txt file 
    jnc ready
    jmp dir_exists
    
    needs_new_dir:      ; creates a new directory
    call makeDirectory
    
    dir_exists:
    mov dx, offset pathResultados
    mov cx, 00h          
    call fcreate        ; creates resultados.txt file
     
    ready:
    mov handlerRes, ax   ; ax contains the handler
    mov bx, handlerRes
    xor cx, cx
    xor dx, dx
    mov ah, 42h
    mov al, 02h
    int 21h
    
    mov dx, offset pathTop5
    mov al, 0 
    call fopen          ; attempts to open existing top5.bin file                   
    jnc top5_exists
    mov dx, offset pathTop5
    push cx
    mov cx, 00h          
    call fcreate        ; creates top5.bin file
    mov handlerTop5, ax
    pop cx
    ret
    
    top5_exists:
    mov handlerTop5, ax
    mov cx, 45
    mov dx, offset top5_names
    mov bx,handlerTop5
    call fread          ; reads existing top5.bin file
    call fclose 
    
    ret
    
files endp

;*****************************************************************
; caseBin
; description: writes top5 to disk in binary form 
; input - pathTop5, handlerTop5, top5_names
; output - outputs file (top5.bin)
; destroys - ax, bx, cx, dx  
;*****************************************************************         
caseBin proc
        
    mov dx, offset pathTop5
    push cx
    mov cx, 00h          
    call fcreate        ; creates a new top5.bin file
    mov handlerTop5, ax  ; ax contains the handler
    pop cx
    mov bx, handlerTop5 ; moves to bx the handler of top5.bin
    mov cx, 45
    mov dx, offset top5_names
    call fwrite         ; writes contents to top5.bin
    call fclose         ; closes top5.bin
    
    ret
caseBin endp

;****************************************************************************************
; printMenu 
; description: prints the main menu 
; input - sep_str, maintTitle_str, OpMenu1, OpMenu2, OpMenu3, OpMenuQuit
; output - 
; destroys - ax, bx, cx, dx
;****************************************************************************************
printMenu proc
    
    call hideTextCursor     ; hides the standard text cursor
    call clearScreen        ; clears the screen
    call initMouse          ; initializes mouse
    call showMousePointer   ; shows mouse on screen
    
    ;*** printing of menu strings ***;
    
    mov bp, offset sep_str
    mov cx, 80
    mov dl, 0
    mov dh, 0
    call str_output
                      
    mov bp, offset maintTitle_str
    mov cx, 80
    mov dl, 0
    mov dh, 1
    call str_output
    
    mov bp, offset sep_str
    mov cx, 80
    mov dl, 0
    mov dh, 2
    call str_output
    
    
    mov bp, offset OpMenu1
    mov cx, 35
    mov dl, 22
    mov dh, 6
    call str_output
    
    mov bp, offset OpMenu2
    mov cx, 18
    mov dl, 22
    mov dh, 8
    call str_output
    
    mov bp, offset OpMenu3
    mov cx, 12
    mov dl, 22
    mov dh, 10
    call str_output
    
    mov bp, offset OpMenuQuit
    mov cx, 4
    mov dl, 22
    mov dh, 12
    call str_output
    
    ret
printMenu endp

;*****************************************************************
; startMenu
; description: Presents the start menu of the game and chooses
; option using the mouse
; input - playerRes, sep_str,   
; output - delayTime
; destroys - ax, bx, cx, dx 
;*****************************************************************
startMenu proc
    
    call printMenu
    OPClick1:
     
    cmp cx, 179
    jb polling
    cmp cx, 454  
    ja polling 
    
    cmp dx, 2Fh
    jbe polling 
    
    cmp cx, 179
    jb polling
    cmp cx, 457 
    ja polling            
    cmp dx, 37h 
    jbe player_name 
    cmp dx, 3Fh
    jbe polling 
    
    cmp cx, 179
    jb polling
    cmp cx, 321  
    ja polling 
    cmp dx, 47h
    jbe top
    cmp dx, 4Fh
    jbe polling 
     
    cmp cx, 179
    jb polling
    cmp cx, 273  
    ja polling  
    cmp dx , 57h 
    jbe  start1 
    cmp dx, 5Fh
    jbe polling
    
    cmp cx, 179
    jb polling
    cmp cx, 208  
    ja polling 
    cmp dx , 67h
    jbe exit_startMenu
    
    polling: 
    call getMousePos
    cmp bx, 1  
    je  OPClick1          
    jmp polling
            
    player_name:  
    call insertPlayerName   ; insert the player name option
    call printMenu 
    jmp OPClick1
    
    start1:                 ; checks if name string is empty  
    cmp pname, 0
    je polling
    push si 
    mov si,offset playerRes
    mov al, byte ptr[si]
    pop si
    cmp al,";"
    je polling
    
    call game           ; start snake game option
    call printMenu
    jmp OPClick1
    
    top:                ; print top 5 option
    call printTop5
    call printMenu
    jmp OPClick1
     
    exit_startMenu:
    ret    
startMenu endp    

;*****************************************************************
; retNextDir - return next direction
; description: returns the next direction of the snake
; input - snake_pos
; output - bl (w,a,s,d)
; destroys - bx
;*****************************************************************                   
retNextDir proc
    push si
    mov si,offset snake_pos
    add si, 5
    mov bl, byte ptr[si]
    pop si
    
    ret
retNextDir endp

;*****************************************************************
; retCurrentDir - return current direction 
; description: returns the current direction of the snake
; input - snake_pos
; output - al (w,a,s,d)
; destroys - ax 
;*****************************************************************
retCurrentDir proc
    push si
    mov si,offset snake_pos
    add si, 4
    mov al, byte ptr[si]
    pop si
    
    ret  
retCurrentDir endp

;*****************************************************************
; retPosition - return position of snake 
; description: returns the coordinates of the snake
; input - snake_pos
; output - dh: y coordinate; dl: x coordinate
; destroys - dx
;*****************************************************************
retPosition proc
    push si
    mov si,offset snake_pos 
    mov dx, word ptr[si]
    pop si
    
    ret  
retPosition endp 

;*****************************************************************
; printTop5 - print top 5
; description: prints top 5 strings (names and points)
; input - sep_str, top5Title_str, order(1,2,3,4,5)
; output - [nothing]
; destroys - ax, bx, cx, dx
;*****************************************************************
printTop5 proc 
    
    push di
    
    call hideMousePointer  
    call clearScreen
    
    mov ctop5, 0
    mov cont, 0
    
    ;*** printing of top 5 option strings ***;
             
    mov bp, offset sep_str
    mov cx, 80
    mov dl, 0
    mov dh, 0
    call str_output
                      
    mov bp, offset top5Title_str
    mov cx, 80
    mov dl, 0
    mov dh, 1
    call str_output
    
    mov bp, offset sep_str
    mov cx, 80
    mov dl, 0
    mov dh, 2
    call str_output
     
    zeroPoints:
    mov bp, offset order1
    mov dh, 4
    mov dl, 1
    mov cx, 2 
    call setCursorPosition
    call str_output  
    mov bp, offset order2 
    mov dh, 6
    mov dl, 1 
    mov cx, 2
    call setCursorPosition 
    call str_output
    mov bp, offset order3
    mov dh, 8 
    mov dl, 1
    mov cx, 2
    call setCursorPosition 
    call str_output
    mov bp, offset order4
    mov dh, 10
    mov dl, 1 
    mov cx, 2
    call setCursorPosition
    call str_output
    mov bp, offset order5
    mov dh, 12
    mov dl, 1 
    mov cx, 2 
    call setCursorPosition
    call str_output
    
    mov si,offset top5_names        ; si contains the pointer to top5_names
    mov di,offset top5_points       ; di contains the pointer to top5_points
     
    cmp byte ptr[si], 0
    je exit_printTop5
           
    mov ctop5, 4
    nn: 
    mov ax, word ptr[di]
    cmp ax, 0
    je exit_printTop5 
    call printNP            ; print names and points

    gg: 
    add ctop5, 2 
    ;inc cont
    ;cmp cont, 5
    cmp byte ptr [si],"$"
    je exit_printTop5 
    jne nn 

    exit_printTop5:
    call checkKey
    jz exit_printTop5
    call readKeystroke
    cmp al, 0Dh
    jne exit_printTop5
   ; mov cont, 0
    
    pop si
    
    ret     
printTop5 endp    

;*****************************************************************
; printNP
; description: prints name and points (pointed by si)
; input - ctop5,  
; output - [nothing]
; destroys - ax, bx, cx, dx, si, di 
;*****************************************************************
printNP proc
  
    mov dl, 4
    mov dh, ctop5
    print: 
    mov al, byte ptr[si]
    call setCursorPosition
    call printChar
    no_print:
    inc dl
    inc si 
    cmp byte ptr[si],"$"
    je  points
    cmp byte ptr[si], 0
    je no_print
    cmp byte ptr[si],";"
    jne print 
    
    points:
    add dl, 3
    add si, 1
    
    call setCursorPosition
    mov ax,word ptr[di]
    call writeUns
    inc dl
    add di, 2
    
    exit_printnp: 
    ret  
printNP endp  

;*****************************************************************
; printPlayerName 
; description: prints the player name 
; input - playerRes
; output - [nothing]
; destroys - ax, si, di  
;***************************************************************** 
printPlayerName proc
    push si
    mov si, offset playerRes
    cycle:  
    mov al, byte ptr[si]   
    cmp al, ";"
    je exit_printPlayerName
    call setCursorPosition
    call printchar
    inc si 
    inc dl
    jmp cycle  
    
    exit_printPlayerName:
    pop si
    ret
printPlayerName endp

;*****************************************************************
; game 
; description: prepares and updates memory before the game,
; starts game, selects movements of the snake  
; input - gameHeader_str, constant, gameScore, endgame,
; snake_pos, gameOver_str, scoreEnd_str
; output - level, ctop5, gameScore, pname 
; destroys - ax, bx, cx, dx
;***************************************************************** 
game proc
    
    call hideMousePointer            
    call clearScreen
    call clearKeyBuffer
    
    cmp constant, 255
    jne no_reset 
    call resetConst 
    no_reset:
    
    mov delayTime, 11
    mov level, 1
    mov ctop5, 0
    mov gameScore, 0
    mov cont, 0         
    mov quociente, 0
    mov resto, 0     
    mov endgame, 0    
     
    mov bp, offset gameHeader_str
    mov dh, 0
    mov dl, 0
    mov cx, 80  
    call str_output
     
    mov dh, 0
    mov dl, 10        
    call printPlayerName
    
    mov bp, offset sep_str
    mov cx, 80
    mov dl, 0
    mov dh, 1
    call str_output

    call updateLevel  
    call updateScore
    
    xor cx, cx
    inc constant

    ; ******** Randomize Direction *********      

    mov cl, constant
    call rand
    jp horiz
    
    vert:
    call rand
    jp upward
    jmp downward
    horiz:
    call rand
    jp right2
    jmp left2

    ; **************************************
        
    move1: 
    call moveSnake
    cmp endgame, 1
    je end_msg
    jmp waitWASD 
    
    upward:
    push si
    mov  si,offset snake_pos 
    add si, 4
    mov byte ptr[si],'w'
    pop si
    jmp move1  
    
    downward:
    push si
    mov  si,offset snake_pos 
    add si, 4
    mov byte ptr[si],'s'
    pop si
    jmp move1                 
    
    right2:
    push si
    mov  si,offset snake_pos 
    add si, 4
    mov byte ptr[si],'d'
    pop si               
    jmp move1
    
    left2:
    push si
    mov  si,offset snake_pos 
    add si, 4
    mov byte ptr[si],'a'
    pop si    
    jmp move1
            
    waitWASD: 
    call checkKey 
    jnz isKey
    jmp move1
    
    isKey:
    call readKeystroke 
    cmp al,'w'
    je label4
    cmp al,'s'
    je label4
    cmp al,'a'
    je  label4
    cmp al,'d' 
    je  label4
    jmp waitWASD
    
    label4: 
    push si
    mov si,offset snake_pos
    add si, 5
    mov byte ptr[si], al
    pop si
    
    call moveSnake 
    cmp endgame, 1
    je end_msg 
    jmp waitWASD  
     
    end_msg:
    call clearScreen   
    mov bp, offset gameOver_str
    mov cx, 41
    mov dh, 12
    mov dl, 12 
    call str_output 
    mov dh, 13
    mov dl, 12
    call printPlayerName
    mov bp, offset scoreEnd_str
    mov cx, 21
    mov dh, 13                        
    call str_output
    mov ax, gameScore     
    call writeUns
    mov pname, 0
    
    label5:
    call checkKey
    jz label5
    call readKeystroke
    cmp al, 0Dh
    jne label5 
    
    ret        
game endp
            
;*****************************************************************
; moveSnake 
; description: prints the snake and updates structures in memory
; input - gameScore, snake_pos
; output - [nothing]
; destroys - ax, bx, cx, dx, si, di
;*****************************************************************
moveSnake proc 
     
    call retNextDir     
    cmp bl, 0
    je start_move1
    
    cmp bl,'w'
    je up
    cmp bl,'s'
    je down
    cmp bl,'d'                              
    je right
    cmp bl,'a'                   
    je left
    
    up:
    call retPosition
    dec dh      
    cmp dh, 0 
    jbe game_over 
    dec si
    cmp byte ptr[si], cl
    je game_over
    jmp start_move2
    
    down:
    call retPosition
    inc dh 
    cmp dh, 25
    jae game_over
    inc si
    cmp byte ptr[si], cl
    je game_over
    jmp start_move2
    
    right:
    call retPosition
    inc dl
    cmp dl, 80
    je game_over
    add si, 25
    cmp byte ptr[si], cl
    je game_over
    jmp start_move2
    
    left:
    call retPosition
    dec dl
    cmp dl,-1
    je game_over
    sub si, 25
    cmp byte ptr[si], cl
    je game_over
    
    start_move2:
    call timer
    xor bh, bh
    call setCursorPosition
    call print_snake
    mov ax, level 
    add gameScore, ax
    call checkLevel
    mov byte ptr[si], cl
    call updateScore  
    push si
    mov si,offset snake_pos  ;atualizar a posicao da cobra para o proximo move
    mov word ptr[si], dx
    pop si      
    ret
    
    start_move1:
    mov dl, 40
    mov dh, 13   
    mov si, 1013
   
    mov byte ptr[si], cl         
    push si
    mov si,offset snake_pos
    mov word ptr[si], dx
    add si, 5                     
    call retCurrentDir
    mov byte ptr[si], al 
    pop si
    xor bh, bh
    
    call setCursorPosition
    call print_snake
    inc gameScore
    call updateScore
    ret
    
    game_over: 
    call GameOver
    ret          
moveSnake endp    

;*****************************************************************
; GameOver
; description: updates necessary structures and exists game 
; input - gameScore, endGame, snake_pos
; output - [updated memory and temporary variables]
; destroys - ax, bx, cx, dx, si, di
;*****************************************************************
GameOver proc
      
    push si
    push di     
    call updateTop5 
    pop di              
    pop si
    
    inc di 
    mov ax,gameScore
    call ASCII2dec
    mov byte ptr[di],";"
    inc di
    call regTime
    inc endgame
    call writeRes
     
    push si
    mov si,offset snake_pos
    add si, 5
    mov byte ptr[si], 0
    pop si
    
    ret
    
GameOver endp     
  
;*****************************************************************
; checkLevel 
; description: checks the score, updates the level if necessary 
; input - gameScore, delayTime
; output - gameScore 
; destroys - [nothing]
;***************************************************************** 
checkLevel proc
    
    comp:
    cmp gameScore, 50
    je lvlup
    cmp gameScore, 200
    je lvlup
    cmp gameScore, 500
    je lvlup
    jmp exit_checkLevel
    
    lvlup:
    inc level
    sub delayTime, 3
    
    call updateLevel 
    call beep
    
    exit_checkLevel:
    ret
checkLevel endp 

;*****************************************************************
; updateLevel 
; description: prints level on screen (used during the game) 
; input - level
; output - [nothing] 
; destroys - [nothing]
;***************************************************************** 
updateLevel proc 
    push ax
    push dx
    
    mov ax, level
    add al, 30h
    mov dh, 0
    mov dl, 41 
    call setCursorPosition
    call printChar
    pop dx
    pop ax
    
    ret
updateLevel endp
     
;*****************************************************************
; updateTop5
; description: updates and organizes top 5 (points and names)
;              in descending score order.
;              Used at the end of every snake game
; input - top5_points, top5_names, gameScore, playerRes, tmp
; output - [ordered structure]
; destroys - ax, bx, cx, dx, si, di
;***************************************************************** 
updateTop5 proc
     
     mov si,offset top5_points
     mov di,offset top5_names     
     looop:
     mov ax, word ptr[si] ; score
     cmp ax, 0
     je if_free 
     cmp ax,"$"
     je exit_updateTop5
     cmp  gameScore, ax
     ja if_above 
     jb if_below
     je equal_score
     
     
     equal_score:
     push si
     mov si,offset playerRes       
     call moveString 
     pop si  
     ret
          
     if_free:
     mov bx, gameScore 
     mov word ptr[si], bx  
     push si
     mov si,offset playerRes       
     call moveString 
     pop si
     ret    
     
     if_above:
     push ax
     mov bx, gameScore
     mov word ptr[si], bx 
     add si, 2
     ; mov ax, word ptr[si] 
     
     pushdownPoints:   
     pop bx 
     mov ax, word ptr[si] 
     cmp ax, 0 
     je if_free3
     push ax
     mov word ptr[si], bx
     add si, 2
     mov ax, word ptr[si]
     cmp ax,"$" 
     je endpushdown_points
     jmp pushdownPoints
      
     if_free3:
     mov word ptr[si], bx
     jmp pushdownOffsets
     
     endpushdown_points: 
     mov dx,offset top5_points
     sub dx, 8
     pop bx 
     pushdownOffsets:
     cmp ctop5, 5
     je fifthPlace
     mov si,offset tmp
     call copyTop5 
     mov si,offset playerRes
     call moveString
     ;add di, 7
     inc di
     mov si,offset tmp
     copy2:
     cmp byte ptr[si],"$"
     je exit_updateTop5
     mov bl, byte ptr[si]  
     mov byte ptr[di], bl 
     inc si
     inc di
     jmp copy2
     
     fifthPlace:
     push si
     mov si,offset playerRes       
     call moveString 
     pop si
     jmp exit_updateTop5 
      
     if_below:
     add si, 2
     add di, 7
     inc ctop5
     jmp looop
     
     exit_updateTop5:
     ret
updateTop5 endp    

;*****************************************************************
; copyTop5
; description: copy top5 structure 
; input - bx, di, si
; output - [nothing] 
; destroys - si 
;*****************************************************************
copyTop5 proc
    
   push bx
   push di
   copy:
   cmp byte ptr[di],";"
   je verify
   end_verify:
   cmp di, dx
   je exit_copyTop5
   mov bl, byte ptr[di]  
   mov byte ptr[si], bl 
   inc si
   inc di
   jmp copy
   
   
   verify:
   cmp byte ptr[di+1], 0
   jne end_verify
   mov bl, byte ptr[di]  
   mov byte ptr[si], bl 
   inc si
   inc di
   
   exit_copyTop5:
 
   mov byte ptr[si],"$"
   pop di 
   pop bx
   
   ret
copyTop5 endp

;*****************************************************************
; moveString
; description: move string from one position in memory to another
;              (uses si and di) 
; input - cont
; output - [nothing] 
; destroys - cont, si, di 
;*****************************************************************
moveString proc
   
    push ax
    push bx
    mov cont, 0

    move_string1:
    mov al, byte ptr[si]
    cmp al,";"
    je move_string2
    cmp cont, 6
    je move_string3
    mov byte ptr[di], al
    inc cont
    inc si
    inc di
    jmp move_string1
    
    
    move_string2:
    cmp cont, 6
    je move_string3            
    xor ax, ax
    mov byte ptr[di], al
    inc cont
    inc di
    jmp move_string2
    
    move_string3:               
    mov byte ptr[di],";" 
    pop bx
    pop ax
    
    ret
moveString endp    
        
;*****************************************************************
; writeRes - write results
; description: writes playerRes structure
; input - playerRes, handlerRes
; output - written file
; destroys - bx, cx, dx
;***************************************************************** 
writeRes proc
   
    mov dx, offset playerRes 
    mov cx, di
    sub cx, dx
    inc cx
    mov bx,handlerRes          
    call fwrite
     
    ret         
writeRes endp

;*****************************************************************
; regTime - register time
; description: fetches system system date and time, registers to
;              data structure pointed by di (in character form)     
; input - [nothing]
; output - structure pointed by di
; destroys - ax, di
;*****************************************************************
regTime proc 
    
    push dx
    push cx
    call getSystemDate      ; fetches system date
    mov ax, cx              ; year
    call ASCII2dec 
    mov byte ptr[di],"-" 
    inc di
    xor ax, ax
    mov al, dh              ;month  
    call ASCII2dec
    mov byte ptr[di],"-" 
    inc di
    mov al, dl              ;day
    call ASCII2dec
    mov byte ptr[di]," " 
    inc di
    call getSystemTime 
    xor ax, ax 
    mov al, ch              ;hour
    call ASCII2dec
    mov byte ptr[di],":" 
    inc di 
    mov al, cl              ;minute
    call ASCII2dec 
    mov byte ptr[di], 13 
    inc di
    mov byte ptr[di], 10 
  
    pop cx
    pop dx
     
    ret   
regTime endp

;*****************************************************************
; timer
; description: temporarily stops the system for a specified time
; input - delaytime
; output - [nothing]
; destroys - ax
;*****************************************************************
timer proc 

    push cx 
    push dx
    push bx
    mov ah, 0
    int 1Ah         ; get system time (in clock ticks since midnight)
    mov bx, dx

    jmp_delay:
    int 1Ah
    sub dx, bx
    cmp dx, delaytime
    jl jmp_delay
    pop bx
    pop dx 
    pop cx 
    
    ret
timer endp    

;*****************************************************************
; insertPlayerName
; description: waits for a maximum of 6 characters from
;              the keyboard (or ENTER) and stores playername
; input - pname, playerRes
; output - PlayerRes contains inserted name
; destroys - ax, bx, cx
;***************************************************************** 
insertPlayerName proc
    
    call hideMousePointer
    call clearScreen
    call showTextCursor 

    mov di, offset playerRes
    xor dx, dx
    xor bx, bx
    call setCursorPosition
    call clearKeyBuffer
    xor cx, cx
    name1:  
    cmp cx, 6
    je wait_enter
    call readKeystroke
    cmp al, 0Dh
    je exit_insertPlayerName
    cmp al, 08h
    je backspace 
         
   	cmp al, 65 
	jae upper_case	
	cmp al, 97
	jae lower_case
    jmp name1

	upper_case:
	cmp al, 90
	jbe isUpperCase 	
	cmp al, 97
	jae lower_case
	jmp name1
	
	lower_case:
	cmp al, 122
	jbe is_small
    jmp name1
	
	isUpperCase: 
	call co
	inc cx 
	mov byte ptr[di], al ; stores read character in the data structure
	inc di
	jmp name1 
	
	is_small: 
	call co
	inc cx
	mov byte ptr[di], al ; stores read character in the data structure
	inc di
	jmp name1
    
    backspace: 
    cmp cx, 0
    je name1
    call co 
    dec di
    mov byte ptr[di], 0 ; stores read character in the data structure
    mov al, 20h
    call co
    mov al, 08h
    call co 
    dec cx
    jmp name1
      
    wait_enter:
    call readKeystroke
    cmp al, 0Dh
    je exit_insertPlayerName
    cmp al, 08h
    je backspace
    jmp wait_enter
    
    exit_insertPlayerName:
    push di
    dec di
    mov al, byte ptr[di] 
    pop di
    cmp al, 0
    je  exit
    mov pname, 1
    
    exit: 
    mov byte ptr[di],";"
    
    ret
insertPlayerName endp    
   
;*****************************************************************
; ASCII2dec
; description: conversts ascii to decimal 
; input - quociente, resto, cont, ax, cx, dx
; output - ax (decimal value)
; destroys - bx
;*****************************************************************   
ASCII2dec proc
            
    mov quociente, 0
    mov resto, 0 
    mov cont, 0
    push ax
    push cx 
    push dx
    label10:
    cmp ax, 10
    jb only1dig  
    mov bx, 10
    call division
    push ax 
    add cont, 1
    mov ax, cx
    jmp label10
                
    only1dig:
    add al, 30h
    mov byte ptr[di], al
    inc di      
    cmp cont, 0
    je exitASCII2dec
    
    digitosprox:
    pop ax 
    sub cont, 1
    add al, 30h
    mov byte ptr[di], al
    inc di
    cmp cont, 0
    je exitASCII2dec
    jmp digitosprox
    
    
    exitASCII2dec: 
    pop dx
    pop cx
    pop ax
    
    ret  
ASCII2dec endp

;*****************************************************************
; updateScore
; description: prints new game score during snake movements
; input - gameScore
; output - [nothing]
; destroys - ax
;*****************************************************************             
updateScore proc

    push dx
    mov ax, gameScore
    mov dh, 0
    mov dl, 75 
    call setCursorPosition
    call writeUns   
    pop dx
     
    ret     
updateScore endp

;*****************************************************************
; resetConst - reset constant (used in game 255)
; description: sets intermediary game constant (# of the game)
;              and the game board to 0
; input - [nothing] 
; output - constant = 0, 
; destroys - ax, constant
;*****************************************************************       
resetConst proc
    
    push di
    
    xor constant, 255
    xor ax, ax
    mov cx, 2000
    
    lea di, board
    repne stosb
    
    pop di
      
    ret      
resetConst endp

;*****************************************************************
; print_snake
; description: prints new char_snake at cursor position,
; input:
;   char_snake (character that will be printed)                       
;
; output - [nothing]
; destroys - ax
;*****************************************************************
print_snake proc 
 
    push cx 
    mov cx, 1         ; number of times char_snake will be printed
    mov al, char_snake
    mov ah, 0Ah
    int 10h 
    pop cx
    
    ret
print_snake endp

;*****************************************************************
; fcreate
; description: create a file
; input:
;   CX = file attributes 
;   DS:DX -> ASCIZ filename
;
; output:
;   CF clear if successful, AX = file handle
;   CF set on error AX = error code
; destroys - ax
;*****************************************************************
fcreate proc    
    mov ah, 3ch
    int 21h
    jc err1 
    ret
    
    err1:  
    ret
fcreate endp 

;*****************************************************************
; fopen
; description: open existing file
; input:
;   DS:DX -> ASCIZ filename
;       
; output:
;   CF clear if successful, AX = file handle
;   CF set on error AX = error code
; 
; destroys - ax 
;*****************************************************************    
fopen proc   
    mov ah, 3dh
    int 21h
    jc err2

    ret
        
    err2:
    ret    
fopen endp

;*****************************************************************
; fclose
; description: close file 
; input:
;   bx = file handler
; 
; output: 
;   CF clear if successful, AX destroyed. 
;   CF set on error, AX = error code (06h)
; destroys - ax
;*****************************************************************    
fclose proc

    mov ah, 3eh
    int 21h   
    jc err3 
   
    ret
        
    err3:    
    ret
fclose endp

;*****************************************************************
; fread
; description: read from file 
; input:
;   BX = file handler
;   CX = number of bytes to write
;   DS:DX -> buffer for data
;  
; output:
;   CF is clear if successful - AX = number of bytes actually read;
;   0 if at EOF (end of file) before call. 
;   CF set on error; AX = error code 
; destroys - ax 
;*****************************************************************
fread proc
    mov ah, 3fh
    int 21h  
    jc err4 
    ret
    
    err4:
    ret 
fread endp

;*****************************************************************
; fwrite
; description: write to file
; input:
;   BX = file handler
;   CX = number of bytes to write
;   DS:DX -> data to write
;  
; output:
;   CF clear if successful; AX = number of bytes actually written
;   CF set on error; AX = error code 
; destroys - ax 
;*****************************************************************            
fwrite proc
     
     mov ah, 40h
     int 21h
     jc err5
     ret
     
     err5:    
     ret  
fwrite endp


;*****************************************************************
; readkey (with echo)
; description: reads character from standard input,
; result is stored in AL
; input - [nothing]
; output:
;   al 
; destroys - ax
;*****************************************************************
readkey proc 
          
    mov ah, 01h
    int 21h 
    
    ret         
readkey endp

;*****************************************************************
; readKeystroke (no echo)
; description: get keystroke from keyboard (no echo)
; input - [nothing]
; output:
;   AH = BIOS scan code
;   AL = ASCII character
;
; destroys - ax
;*****************************************************************
readKeystroke proc
    mov ah, 00h
    int 16h
   
    ret
readKeystroke endp

;*****************************************************************
; checkKey
; description: check for keystroke in the keyboard buffer 
; input - [nothing] 
; output:
;   ah = BIOS scan code.
;   al = ASCII character.
; 
; destroys - [nothing]
;*****************************************************************
checkKey proc
    push ax 
    mov ah, 01h
    int 16h
    pop ax
    
    ret
checkKey endp

;*****************************************************************
; str_output - string output
; input:
;   AL = write mode:
;    bit 0: update cursor after writing;
;    bit 1: string contains attributes.
;   BH = page number.
;   BL = attribute if string contains only characters (bit 1 of AL is zero).
;   CX = number of characters in string (attributes are not counted).
;   DL,DH = column, row at which to start writing.
;   ES:BP points to string to be printed. 
;
; output - 
; destroys - cx 
;*****************************************************************
str_output proc
    
    push ax
    push bx
    xor bh, bh
    mov al, 1 
    mov bl, 1111b
    mov ah, 13h
    int 10h  
    pop bx
    pop ax
    
    ret
str_output endp

;*****************************************************************
; printChar - print character
; description: print character (at cursor position)
; input:
;   al = character to display
;   bl = page number
;   cx = number of times to write character 
;
; output - [nothing]
; destroys - [nothing]
;*****************************************************************
printChar proc
     
   push cx  
   mov cx, 1
   mov ah, 0Ah
   int 10h  
   pop cx
   
   ret 
printChar endp    


;*****************************************************************
; co - caracter output
; description: rotina que faz o output de um caracter para o ecra
; input - al=caracter a escrever
; destroys - [nothing]
;*****************************************************************
co proc
    push ax
    push dx
    mov ah, 02h
    mov dl, al
    int 21h
    pop dx
    pop ax
    
    ret
co endp 
         
;*****************************************************************
; writeUns - write unsigned numbers 
; descricao: writes unsigned number
; input:
;   ax=number to write
;
; output - [nothing]
; destroys - ax, bx, cx, dx
;****************************************************************
writeUns proc
    
    mov cont, 0 
    push dx
    push ax
    push cx
    label6:
    cmp ax, 10
    jb somente1dig  
    mov bx, 10
    call division
    push ax 
    add cont, 1
    mov ax, cx
    jmp label6
                
    somente1dig:
    mov ah, 2
    add al, 30h
    mov dl, al
    int 21h      
    cmp cont, 0
    je exit_writeUns
    
    digitosseg:
    pop ax
    sub cont, 1
    add al, 30h
    mov dl, al
    call co
    cmp cont, 0
    je exit_writeUns
    jmp digitosseg
    
    exit_writeUns:
    pop cx
    pop ax
    pop dx
    ret      
writeUns endp

;*****************************************************************
; division
; input:
;   ax=divisor
; output:
;   ax=resto, quociente
;
; destroys - ax, cx 
;*****************************************************************       
division proc
      
    mov cx, 0 ; counter of valid subtractions
                  
    l1:
    call subt    
                 
    cmp ax, 0
    jz zero  
    cmp ax, 10
    jb zero
    add cx, 1
    jmp l1
          
    zero:
    add cx, 1
           
    exit_division: 
    mov quociente, cx
    mov resto, dx
    mov ax, resto
    
    ret           
division endp
	  
;*****************************************************************
; subt
; description: subtraction 
; input - ax, bx
; output: 
;   dx = resut of subtraction
;   
; destroys - ax
;*****************************************************************	  
subt proc
    sub ax, bx
    mov dx, ax
    
    ret 
subt endp    
   
;*****************************************************************
; rand
; description: returns psudo-random number from system miliseconds 
; output - ch = hour. cl = minute. dh = second. dl = 1/100 seconds.
; destroys - ah, dh
;*****************************************************************
rand proc
    push cx
    call getSystemTime
    cmp dx, 0fh
    pop cx
    
    ret
rand endp
 
;*****************************************************************
; getSystemTime
; description: returns system time
; output - ch = hour. cl = minute. dh = second. dl = 1/100 seconds.
; destroys - ah, dx
;*****************************************************************
getSystemTime proc
    
    mov ah, 2Ch
    int 21h
    
    ret     
getSystemTime endp 

;*****************************************************************
; getSystemDate
; description: return system date
; output - cx = year (1980-2099). dh = month. dl = day
; destroys - ax, cx, dx
;*****************************************************************    
getSystemDate proc
    mov ah, 2Ah
    int 21h
    
    ret
getSystemDate endp

;*****************************************************************
; initMouse 
; description: initializes the mouse
; input - [nothing]
; output:
;   if successful, ax=0FFFFh and bx=number of mouse buttons.
;   if failed, ax=0
; destroys - [nothing]
;*****************************************************************
initMouse proc
    push ax
    mov ax, 00
    int 33h
    pop ax
    
    ret
initMouse endp

;*****************************************************************
; setCursorPosition 
; description: set the cursor position
; input:
;   dh = row.
;   dl = column.
;   bh = page number (0..7)
; 
; output - [nothing]
; destroys - bx, dx
;*****************************************************************
setCursorPosition proc
    push ax
    xor bh, bh
    mov ah, 2
    int 10h
    pop ax
    ret
setCursorPosition endp

;*****************************************************************
; getMousePos - get mouse position 
; description: fetches the current mouse position 
; and status of its buttons
; input - 
; output:
;   if left button is down: bx=1
;   if right button is down: bx=2
;   if both buttons are down: bx=3 
; 
; destroys - bx
;*****************************************************************
getMousePos proc
    push ax
    mov ax, 03h
    int 33h
    pop ax
    
    ret
getMousePos endp  

;*****************************************************************
; showMousePointer
; description: show the default mouse pointer
; input - [nothing]
; output - [nothing] 
; destroys - [nothing] 
;*****************************************************************
showMousePointer proc
    push ax
    mov ax, 1
    int 33h
    pop ax

    ret
showMousePointer endp

;*****************************************************************
; hideMousePointer 
; description: hides the mouse pointer
; input - [nothing]
; output - [nothing] 
; destroys - [nothing] 
;*****************************************************************
hideMousePointer proc
    push ax
    mov ax, 02
    int 33h
    pop ax
    
    ret
hideMousePointer endp

;*****************************************************************
; hideTextCursor 
; description: hides the text cursor
; input - [nothing]
; output - [nothing] 
; destroys - [nothing] 
;*****************************************************************
hideTextCursor proc
    push ax
    push cx
    mov ch, 32
    mov ah, 1
    int 10h
    pop cx
    pop ax
        
    ret
hideTextCursor endp 

;*****************************************************************
; showTextCursor 
; description: shows the text cursor
; input - [nothing]
; output - [nothing] 
; destroys - [nothing]
;*****************************************************************
showTextCursor proc
    push ax
    push cx
    mov ch, 6
    mov cl, 7
    mov ah, 1
    int 10h
    pop cx
    pop ax
    
    ret
showTextCursor endp

;*****************************************************************
; clearScreen 
; input - [nothing]
; output - [nothing]
; destroys - bx
;*****************************************************************
clearScreen proc
    push ax
    push cx
    mov ah, 06
    mov al, 00
    mov bh, 07  ; attributes to be used on blanked lines
    mov cx, 0   ; ch,cl = row,column of upper left corner of window to scroll
    mov dh, 25  ; row,column of lower right corner of window
    mov dl, 80
    int 10h
    pop cx
    pop ax
    
    ret
clearScreen endp 

;*****************************************************************
; setVideo 
; description: sets the video mode
; input - [nothing]
; output - [nothing] 
; destroys - ax 
;*****************************************************************
setVideo proc
    mov ah, 0    
    mov al, 03h
    int 10h
    
    ret
setVideo endp

;*****************************************************************
; beep 
; description: write beep character to standard outut (no echo)  
; input - [nothing]
; output - [nothing]
; destroys - ax 
;*****************************************************************
beep proc 
    
    push dx
    mov ah, 2
	mov dl, 07h
	int 21h
    pop dx
    
    ret
beep endp

;*****************************************************************
; clearKeyBuffer 
; description: clears the keyboard buffer
; input - [nothing]
; output - [nothing]
; destroys - [nothing]
;*****************************************************************
clearKeyBuffer proc
    push ax 
    
    clearKeys:
    call checkKey
    jz exit_clear
    mov ah, 00h
    int 16h
    jmp clearKeys
    
    exit_clear:
    pop ax
    ret
clearKeyBuffer endp

;*****************************************************************
; makeDirectory 
; description: 
; input - pathnew (name of the new directory)
; output - [new directory]
; destroys - ax
;*****************************************************************
makeDirectory proc
    
    push dx 
    mov dx, offset pathnew
    mov ah, 39h
    int 21h
    pop dx
     
    ret
makeDirectory endp  

;*****************************************************************
; setCurrentDirectory 
; description: 
; input - pathnew
; output - pathnew
; destroys - [nothing]
;*****************************************************************
setCurrentDirectory proc
    
    push ax
    push dx
    mov dx, offset pathnew
    mov ah, 3Bh
    int 21h 
    pop dx
    pop ax 

    ret 
setCurrentDirectory endp

end start ; set entry point and stop the assembler.