; multi-segment executable file template.

data segment
    tabuleiro db 2000 dup(0) 
    tituloMenu db "******SNAKE GAME******",0
    OpMenu1 db "Introduzir identificacao do jogador",0  
    OpMenu2 db "Consultar Top Five",0
    OpMenu3 db "Iniciar jogo",0
    OpMenuQuit db "Sair",0  
    tituloTop5 db "******TOP 5******",0
    newline db  12 dup(0)
    
    
    erroCriar db "Erro ao criar o ficheiro", 0
    erroAbrir db "Erro ao abrir o ficheiro", 0
    erroFechar db "Erro ao fechar o ficheiro", 0
    erroLer db "Erro na leitura do ficheiro", 0
    erroEscrever db "Erro na escrita do ficheiro", 0   
    
    end db "GAME OVER! Ja foste! #rekt Prima a tecla enter.",0
    pontuacao_end db "a sua pontuacao e: ",0   
    
    sepPoints db "********************************************************************************", 0
    
    

    top5_names dw 5 dup(" "),24h
    top5_points dw 5 dup(" "),24h   
       
    pathTop5 db "C:\top5.bin", 0                               
 
    order1 db  "1o",0Ah, 0Dh,0
    order2 db "2o",0Ah, 0Dh, 0  
    order3  db "3o",0Ah, 0Dh,0
    order4  db  "4o",0Ah, 0Dh,0
    order5  db  "5o",0Ah, 0Dh,0
    playerRes db 27 dup(0)         
    pathResultados db "C:\resultados.txt", 0
                  
    snake_pos db 6 dup(0) 
    
    char_snake db 0DBh
    gameScore dw 0 
    
    cont db 0         
    quociente dw 0
    resto dw 0 
    ctop5 db 0
    count db 0
    endgame db 0 
    constant db 0   
    handlerTop5 dw 0
    handlerRes dw 0
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

    
    call menu
    mov bx,handlerRes  
    call fclose
    mov ax, 4c00h ; exit to operating system.
    int 21h 
;---------------------------------------------

     

       
menu proc         
    
    call clearScreen
    call initMouse 
    call showMouse 
    
    mov al, 2  
    mov dx, offset pathResultados
    call fopen
    mov handlerRes, ax  
    
    mov dx, offset pathTop5
    mov al, 2 
    call fopen 
    mov ax,7
    je alreadyExists
    mov dx, offset pathTop5
    push cx
    mov cx, 00h          
    call fcreate
    pop cx
    
    alreadyExists:
    mov cx,20
    mov dx, offset top5_names
    mov bx,ax
    call fread
    call fclose 
    

   
    call printMenu
    call OPclick
    ret
    
menu endp



printMenu proc
                      
    mov bp, offset tituloMenu
    mov cx, 22
    mov dl, 17
    mov dh, 0
    call str_output
    
    mov bp, offset OpMenu1
    mov cx, 35
    mov dl, 0
    mov dh, 4
    call str_output
    
    mov bp, offset OpMenu2
    mov cx, 18
    mov dl, 0
    mov dh, 6
    call str_output
    
    mov bp, offset OpMenu3
    mov cx, 12
    mov dl, 0
    mov dh, 8
    call str_output
    
    mov bp, offset OpMenuQuit
    mov cx, 4
    mov dl, 0
    mov dh, 10
    call str_output
    
    ret
printMenu endp

OPclick proc
    
    OPClick1: 
    cmp cx,0
    jb polling
    cmp cx ,280  
    ja polling 
               
    cmp dx,29h 
    jbe player 
    cmp dx,2Eh
    jbe polling
    cmp dx, 38h
    jbe top
    cmp dx,3Eh
    jbe polling  
    cmp dx , 48h 
    jbe  start1 
    cmp dx,4Eh
    jbe polling
    cmp dx , 59h
    jbe sair
    
    polling: 
    call getMousePos
    cmp bx, 1  
    je  OPClick1          
    jmp polling
            
    player: 
    call hideMouse 
    call clearScreen 
    call player_name
    call clearScreen
    call showMouse
    call printMenu 
    jmp OPClick1
    
    start1: 
    call hideMouse            
    call clearScreen   
    mov bp, offset sepPoints
    mov cx, 80
    mov dl, 0
    mov dh, 1
    call str_output
    call start_game 
    call clearScreen 
    call showMouse
    call printMenu
    jmp OPClick1
    
    top:
    call hideMouse  
    call clearScreen 
    mov bp, offset tituloTop5
    mov cx,17
    mov dl, 17
    mov dh, 0
    call str_output
    call printTop5 
    call clearScreen
    call showMouse
    call printMenu
    jmp OPClick1
     
    sair:
    ret    
OPclick endp   
    
 
                   
proc retNextDir ;retorna a direcao seguinte
    push si
    mov si,offset snake_pos
    add si, 5
    mov bl, byte ptr[si]
    pop si
    ret
endp

proc retCurrentDir ;retorna a direcao atual
    push si
    mov si,offset snake_pos
    add si, 4
    mov al, byte ptr[si]
    pop si
    ret  
endp

proc retPosition
    push si
    mov si,offset snake_pos 
    mov dx, word ptr[si]
    pop si
    ret  
endp 


printTop5 proc 
    
    push cx
    push si
    mov si,offset top5_points
    mov ax,word ptr[si]
    cmp ax," "
    je zeroPoints 
    
    mov si,offset top5_names
    mov bx,handlerRes
    nn: 
    xor cx,cx
    mov dx, -1
    mov al,1
    call fseek
    push ax
    xor cx,cx
    mov dx, word ptr[si]
    mov al,0
    call fseek
    mov cx,12
    mov bx,handlerRes
    mov dx, offset newline
    call fread 
    mov bx,handlerRes
    xor cx,cx
    pop ax
    mov dx, ax
    mov al,0
    call fseek
     
    pop si
    pop cx
    ret 
    
    zeroPoints:
    mov bp, offset order1
    mov dh,3
    mov dl,0
    mov cx,2
    call str_output
    mov bp, offset order2 
    mov dh,4
    mov dl,1 
    mov cx,2 
    call str_output
    mov bp, offset order3
    mov dh,5 
    mov dl,1
    mov cx,2 
    call str_output
    mov bp, offset order4
    mov cx,2
    mov dh,6 
    mov dl,1
    call str_output
    mov bp, offset order5
    mov dh,7
    mov dl,1 
    mov cx,2 
    call str_output
    nope:
    
    jne nope
    pop cx
    ret  
printTop5 endp    


moveSnake proc
      
    call retNextDir     
    cmp bl,0
    je start_move1
    
    ;call retCurrentDir
    cmp bl,'w'
    je up
    cmp bl,'s'
    je down
    cmp bl,'d'                              
    je right
    cmp bl,'a'                   
    je left
    
    up:
    ;call retPosition
    dec dh      
    cmp dh,1 
    je game_over 
    ;call calcPos
    dec si
    cmp byte ptr[si], cl
    je game_over
    jmp start_move2
    
    down:
    ;call retPosition
    inc dh 
    cmp dh,25
    je game_over
    ;call calcPos
    inc si
    cmp byte ptr[si], cl
    je game_over
    jmp start_move2
    
    right:
    ;call retPosition
    inc dl
    cmp dl,81
    je game_over
    ;call calcPos
    add si,25
    cmp byte ptr[si], cl
    je game_over
    jmp start_move2
    
    left:
    ;call retPosition
    dec dl
    cmp dl,-1
    je game_over
    ;call calcPos
    sub si,25
    cmp byte ptr[si], cl
    je game_over
    
    start_move2:
    call timer
    call print_snake 
    inc gameScore
    mov byte ptr[si], cl 
    push si
    mov si,offset snake_pos  ;atualizar a posicao da cobra para o proximo move
    mov word ptr[si],dx
    pop si      
    ret
    
    start_move1:
    mov dl,40
    mov dh,13   
    mov si, 1013
   
    mov byte ptr[si], cl
    push si
    mov si,offset snake_pos
    mov word ptr[si],dx
    add si,5
    call retCurrentDir
    mov byte ptr[si],al 
    pop si
    call timer
    call print_snake
    ret
    
    game_over: 
    push si
    push di
    mov si,offset top5_points
    mov di,offset top5_names 
    call atualizaTop5 
    pop di              
    pop si
    mov byte ptr[di],";"
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
    mov byte ptr[si],0
    pop si
    
    ret 
   
    exit_move:
    ret 
moveSnake endp  
 
 
 
atualizaTop5 proc 
     
  
   
     
     looop:
     mov ax, word ptr[si] ;pontos
     cmp ax, " "
     je if_free 
     cmp  gameScore,ax
     ja if_above 
     jb if_below
    
                
     if_free:
     mov bx, gameScore 
     mov word ptr[si], bx  
     mov al,1
     mov bx,handlerRes
     mov cx,0
     mov dx,0
     call fseek
     mov word ptr[di],ax
     ret    
     
     
     if_above:
     push ax
     inc ctop5
     mov bx, gameScore
     mov word ptr[si], bx 
     add si, 2 
     mov ax, word ptr[di]  ;offset no ficheiro
     push ax
     inc ctop5
     mov al,1
     mov bx,handlerRes
     mov cx,0
     mov dx,0
     call fseek
     mov word ptr[di], ax 
     add di, 2
     mov ax, word ptr[di] 
     cmp ax,"$"
     je exit_looop
     
     
     
     pushdownOffsets:
     pop bx 
     dec ctop5
     mov ax, word ptr[di] 
     cmp ax, " "
     je if_free2 
     push ax
     inc ctop5
     mov word ptr[di], bx
     cmp ctop5,0
     je  pushdownPoints 
     add di,2  
     jmp pushdownOffsets
     
     
     if_free2:
     mov word ptr[di], bx 
     
    
      
      
      
     pushdownPoints:   
     pop bx 
     dec ctop5
     mov ax, word ptr[si] 
     cmp ax, " "
     je if_free3
     push ax
     inc ctop5
     mov word ptr[si], bx
     cmp ctop5,0
     je exit_looop
     add si,2
     jmp pushdownPoints
   
      
     if_free3:
     mov word ptr[si], bx 
     ret
     
     
    
    
      
     if_below:
     add si,2
     add di,2
     jmp looop
     
 
     exit_looop: 
     pop ax 
     pop ax
     ret
     
         
atualizaTop5 endp 


   


COMMENT@
proc
    add si,2
    mov count,0
    
    looop:
    mov ax,word ptr[si]
    cmp ax," "
    je is_free
    cmp ax,gameScore
    jb too_low 
    jae too_high
    
    
    
    is_free: 
    mov ax,gameScore
    mov word ptr[si],ax 
    mov al,1
    ;push bx
    mov bx,handlerRes
    mov cx,0
    mov dx,0
    call fseek
    sub si,2
    mov word ptr[si],ax
    ;pop bx
    ret
    
    too_high:
    mov ax,gameScore
    mov word ptr[si],ax 
    mov al,1
    ;push bx
    mov bx,handlerRes
    mov cx,0
    mov dx,1
    call fseek
    sub si,2
    mov word ptr[si],ax
    ;pop bx
    ret
    
    too_low:
    mov ax,gameScore
    mov word ptr[si],ax 
    mov al,1
    ;push bx
    mov bx,handlerRes
    mov cx,0
    mov dx,1
    call fseek
    sub si,2
    mov word ptr[si],ax
    ;pop bx
    ret
    ret
    
endp
COMMENT@



 
writeRes proc
          
    mov dx, offset playerRes 
    mov cx,di
    sub cx,dx
    inc cx
    mov bx,handlerRes          
    call fwrite 
    ret         
   
writeRes endp



regTime proc 
    
    push dx
    push cx
    call getSystemDate
    ;mov ax,cx
    ;call ASCII2dec
    xor ax,ax
    mov al, dh ;month  
    call ASCII2dec
    mov byte ptr[di],"-" 
    inc di
    mov al,dl  ;day
    call ASCII2dec
    mov byte ptr[di]," " 
    inc di
    call getSystemTime 
    xor ax,ax 
    mov al, ch ;hour
    call ASCII2dec
    mov byte ptr[di],":" 
    inc di 
    mov al, cl ;minute
    call ASCII2dec 
    mov byte ptr[di],13 
    inc di
    mov byte ptr[di],10 
  
    pop cx
    pop dx 
    ret 
      
regTime endp


timer proc 
    push cx 
    push dx
    push bx
    
    
    COMMENT@
    push dx
    push bx
    to:
    mov ah,2Ch
    int 21h
    mov bh,dh  ; DH has current second 
    
    getsec:      ; Loops until the current second is not equal to the last, in BH
    mov ah,2Ch
    int 21h
    cmp bh,dh ; Here is the comparison to exit the loop
    jne exit_timer
    jmp getsec
    
    exit_timer:
    pop bx
    pop dx
    COMMENT@
    
    
    mov cx,0
    mov dx,650
    mov ah,86h 
    int 15h
      
    pop bx
    pop dx
    pop cx
    ret 
    
timer endp    
 
 
player_name proc 
    call hideMouse 
    mov di, offset playerRes
    xor dx,dx
    xor bx,bx
    call setCursorPosition
    
    ;push si
    xor cx,cx
    name1:  
    cmp cx,12
    je wait_enter
    call readKeystroke
    cmp al,0Dh
    je exit
    cmp al,08h
    je backspace
    
    
    
    cmp al,48
	jae number     
   	cmp al,65 
	jae capital_case	
	cmp al,97
	jae small_case
    jmp name1
	       
    
    number:
    cmp al,57
	jbe is_number
	cmp al,65 
	jae capital_case	
	cmp al,97
	jae small_case
	jmp name1
    
    
	capital_case:
	cmp al,90
	jbe is_capital 	
	cmp al,97
	jae small_case
	jmp name1
	
	small_case:
	cmp al,122
	jbe is_small
    jmp name1
	
	
	
	is_capital:
	;sub al,32           
	;armazenar  na estrutura resultados
	;incrementar o apontador 
	call co
	
	inc cx 
	mov byte ptr[di],al ;armazenar o caracter lido na estrututa resultados
	inc di
	jmp name1 
	
	is_number:
	call co
	
	inc cx ;numero de caracteres
	mov byte ptr[di],al ;armazenar o caracter lido na estrututa resultados
	inc di
	jmp name1
	
	is_small: 
	call co
	
	inc cx
	mov byte ptr[di],al ;armazenar o caracter lido na estrutura resultados
	inc di
	jmp name1
    
    backspace:
    cmp cx,0
    je name1
    call co
    dec di
    mov byte ptr[di],0 ;armazenar o caracter lido na estrututa resultados	 
    mov al,20h
    call co
    mov al,08h
    call co 
    dec cx
    jmp name1
      
    wait_enter:
    call readKeystroke
    cmp al,0Dh
    je exit
    cmp al,08h
    je backspace
    jmp wait_enter
    
    erro:
    ret	
    
    exit:
    ret
    
 
player_name endp    
   

   
ASCII2dec proc
            
    mov quociente,0
    mov resto,0 
    mov cont,0
    push ax
    push cx 
    push dx
    label10:
    cmp ax, 10
    jb only1dig  
    mov bx, 10
    call divisao
    push ax 
    add cont,1
    mov ax, cx
    jmp label10
                
    only1dig:
    add al, 30h
    mov byte ptr[di],al
    inc di      
    cmp cont, 0
    je exitASCII2dec
    
    digitosprox:
    pop ax 
    sub cont, 1
    add al, 30h
    mov byte ptr[di],al
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
 
 
 
 
start_game proc
    
    
    mov ctop5,0
    mov gameScore,0
    mov cont, 0         
    mov quociente,0
    mov resto,0     
    mov endgame, 0
    cmp constant,255
    je reset
    inc constant
   
    Psudo:
    mov cl,constant
    call psudoRand
    jp horiz
    
    vert:
    call psudoRand
    jp upward
    jmp downward
    horiz:
    call psudoRand
    jp right2
    jmp left2
    
    move1: 
    call moveSnake
    cmp endgame, 1
    je end_msg
    jmp waitWASD 
    
    upward:
    push si
    mov  si,offset snake_pos 
    add si,4
    mov byte ptr[si],'w'
    pop si
    jmp move1  
    
    downward:
    push si
    mov  si,offset snake_pos 
    add si,4
    mov byte ptr[si],'s'
    pop si
    jmp move1                 
    
    right2:
    push si
    mov  si,offset snake_pos 
    add si,4
    mov byte ptr[si],'d'
    pop si               
    jmp move1
    
    left2:
    push si
    mov  si,offset snake_pos 
    add si,4
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
    add si,5
    mov byte ptr[si],al
    pop si
    call moveSnake 
    cmp endgame, 1
    je end_msg 
    jmp waitWASD  
    
    reset:
    call resetConst
    
    
    end_msg:
    call clearScreen
    mov bp, offset end
    mov cx, 47
    mov dh, 12
    mov dl, 12 
    call str_output 
    mov bp, offset pontuacao_end
    mov cx, 19
    mov dh, 13
    mov dl, 12                         
    call str_output
    mov ax, gameScore     
    call writeUns
    
    
    label5:
    call checkKey
    jz label5
    call readKeystroke
    cmp al,0Dh
    jne label5 
    ret
    
    
     
start_game endp
            
            
;FOR EXTRAS            
actualizaScore proc
    
     mov ax, gameScore
     call writeUns     
          
actualizaScore endp
       
resetConst proc
    xor constant,255 
    ret      
endp


print_snake proc
    push cx
    push bp
    mov bp, offset char_snake
    ;call retPosition
    mov cx,1
    call str_output
    pop bp
    pop cx
    ret
print_snake endp

;************************************************
;************************************************
;************************************************
fcreate proc    
    mov ah, 3ch
    int 21h
    jc err1 
    ret
    
    err1:
    ;mov si, offset erroCriar
    ;call printStr
    
    ret
fcreate endp 
    
fopen proc   
    mov ah, 3dh
    int 21h
    jc err2

    ret
        
    err2:
    mov dx, offset pathResultados
    push cx
    mov cx, 00h          
    call fcreate
    pop cx  
    ret    
fopen endp
    
fclose proc

    mov ah, 3eh
    int 21h   
    jc err3 
   
    ret
        
    err3: 
    ;mov si, offset erroFechar
    ;call printStr
    
    ret
fclose endp

fread proc
    mov ah, 3fh
    int 21h  
    jc err4 
  
    ret
    
    err4:
    ;mov si, offset erroLer
    ;call printStr
   
    ret 
fread endp

            
fwrite proc
     
     mov ah,40h
     int 21h
     jc err5
     ret
     
     err5:
     ret
       
fwrite endp


fseek proc
    mov ah,42h
    int 21h
    ret
fseek endp


readkey proc 
          
    mov ah,01h
    int 21h 
    ret 
            
readkey endp

readKeystroke proc
    mov ah,00h
    int 16h
   
    ret
readKeystroke endp



checkKey proc
    push ax 
    mov ah,01h
    int 16h
    pop ax
    
    ret
checkKey endp


str_output proc
    
    push ax
    push bx
    xor bh,bh
    mov al,1 
    mov bl,1111b
    mov ah,13h
    int 10h  
    pop bx
    pop ax
    
    ret
str_output endp

;*****************************************************************
; printStr - print string
; description: rotina que faz o output de uma string para o ecra
; input - si=endereco da string a escrever
; destroys - al, si
;*****************************************************************
printStr proc
    
    L1: mov al, byte ptr [si]
    or al, 0
    jz fimprtstr
    push si
    call co
    pop si	
    inc si
    jmp L1
    fimprtstr: ret
    
printStr endp

;*****************************************************************
; co - caracter output
; description: rotina que faz o output de um caracter para o ecra
; input - al=caracter a escrever
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
; descricao: rotina que escreve um numero sem sinal
; input - ax= numero a escrever
; output - nenhum
; destroi - ax, bx, cx, dx
;****************************************************************
    
writeUns proc 
        mov cont, 0 
        push ax
        push cx
        label6:
        cmp ax, 10
        jb somente1dig  
        mov bx, 10
        call divisao
        push ax 
        add cont,1
        mov ax, cx
        jmp label6
                    
        somente1dig:
        mov ah, 2
        add al, 30h
        mov dl, al
        int 21h      
        cmp cont, 0
        je exitWRITEUNS
        
        digitosseg:
        pop ax
        sub cont, 1
        add al, 30h
        mov dl, al
        call co
        cmp cont, 0
        je exitWRITEUNS
        jmp digitosseg
        
        exitWRITEUNS:
        pop cx
        pop ax
        ret 
              
writeUns endp
    
    
divisao proc
      
    mov cx, 0 ; contador de subtracoes validas
                  
    label:
    call subt    
                 
    label2:
    cmp ax,0
    jz zero  
    cmp ax,10
    jb zero
    add cx,1
    jmp label
          
    zero:
    add cx,1
           
    sairDIVISAO: 
    mov quociente, cx
    mov resto, dx
    mov ax,resto
    ret  
               
divisao endp
	  
	  
subt proc
    sub ax, bx
    mov dx,ax
    ret 
subt endp    


     
;*****************************************************************
; psudoRand
; description: returns psudo-random number from system miliseconds 
; output - CH = hour. CL = minute. DH = second. DL = 1/100 seconds.
; destroys - AH, DH
;*****************************************************************
psudoRand proc
    push cx
    call getSystemTime
    cmp dx, 0fh
    pop cx
    ret
psudoRand endp
 
;*****************************************************************
; getSystemTime
; description: returns system time
; output - CH = hour. CL = minute. DH = second. DL = 1/100 seconds.
; destroys - AH, DX
;*****************************************************************
getSystemTime proc
    ;push cx
    mov ah, 2Ch
    int 21h
   ; pop cx
    ret
           
getSystemTime endp 

;*****************************************************************
; getSystemDate
; description: return system date
; output - CX = year (1980-2099). DH = month. DL = day. AL = day of week (00h=Sunday) 
; destroys - AH, CX, DX
;*****************************************************************    
getSystemDate proc
    mov ah, 2Ah
    int 21h
    ret
getSystemDate endp


initMouse proc
    push ax
    mov ax,00
    int 33h
    pop ax
    ret
initMouse endp


ShowStandardCursor proc
    push cx
    mov ch, 6
    mov cl, 7
    mov ah, 1
    int 10h
    pop cx
    ret
endp

; *************************************
; Set Cursor Position
;
; Input:
; DH = row.
; DL = column.
; BH = page number (0..7).
; Output:Nothing
; Detroys: Nothing
;**************************************
setCursorPosition proc
    xor bh,bh
    
    mov ah,2
    Int 10h
    ret
endp


getMousePos proc
    push ax
    mov ax, 03h
    int 33h
    pop ax
    ret
getMousePos endp  

; ****************************************************
; Show Mouse Pointer
;
; Input: Nothing
;
; Output: Nothing
;
showMouse proc
    push ax
    mov ax,01
    int 33h
    pop ax
    ret
endp

; ****************************************************
; Hide Mouse Pointer
;
; Input: Nothing
; Output: Nothing
;
hideMouse proc
    push ax
    mov ax,02
    int 33h
    pop ax
    ret
endp

clearScreen proc
    push ax
    push cx
    mov ah,06
    mov al,00
    mov BH,07 ; attributes to be used on blanked lines
    mov cx,0 ; CH,CL = row,column of upper left corner of window to scroll
    mov DH,25 ;= row,column of lower right corner of window
    mov DL,80
    int 10h
    pop cx
    pop ax
    ret
endp 


COMMENT@    
label: 
    mov al, 0
    mov dx, offset pathTop5
    call fopen
    
    mov dx, offset top5
    mov bx, handler 
    mov cx, 64
    call fread 
    
    call fclose     
COMMENT@    
ends

end start ; set entry point and stop the assembler.