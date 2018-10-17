READ_AND_PRINT_CHAR MACRO 
   PUSH CX
   PUSH DX
READ:    
   MOV AH,8     ;read char
   INT 21H 
   CMP AL,30H
   JL  ENTER
   CMP AL,39H
   MOV CL,0          ;If char is number carry = 0 else =1
   JLE PCHAR
   CMP AL,41H
   JL READ
   CMP AL,5AH                                       
   MOV CL,1
   JG READ 
   JMP PCHAR
ENTER:
    CMP AL,0DH
    JNZ READ
    MOV AX,4C00H
    INT 21H   

PCHAR:
    MOV DL,AL
    MOV AH,2H   ;print char
    INT 21H
    CMP CL,0
    CLC
    JZ LEAVE
    STC
LEAVE:
    POP DX
    POP CX    
ENDM
   
    


READ macro
	mov ah,8
	int 21h
endm     

PRINT_DEC MACRO
    PUSH DX
    PUSH AX
    ADD DL,30H
    MOV AH,2
    INT 21H
    POP AX
    POP DX
ENDM 



PRINT macro CHAR
	push ax
	push dx
	mov dl,CHAR
	mov ah,2
	int 21h
	pop dx
	pop ax
endm
    
PRINT_REG macro cl
	push ax
	push dx
	mov dl,cl
	mov ah,2
	int 21h
	pop dx
	pop ax
endm


PRINT_STR macro STRING
	push ax
	push dx
	mov dx, offset STRING
	mov ah,9
	int 21h
	pop dx
	pop ax
endm 
  

;Printing hex with two digits
PRINT_HEX_MAC macro DL
    PUSH DX     ;saving previous values
    PUSH CX 
    PUSH AX
    
    MOV AL,DL
    MOV CH,2
SRT0:
    MOV CL,4
    ROL DL,CL
    AND DL,00001111B
    CMP DL,09H
    JG  IS_LET
    ADD DL,30H
    JMP OUT1
IS_LET:
    ADD DL,37H
    
OUT1:
    MOV AH,02H
    INT 21H    
    MOV DL,AL
    ROL DL,CL   ;prepare 4 lsbs
    DEC CH
    JNZ SRT0   ;Do the procedure two times first with msbs then with
                ;lsbs
 
    POP AX
    POP CX
    POP DX
ENDM                                   

PRINTX_HEX macro 
    PUSH AX
    PUSH DX
    PUSH CX
    PUSH BX
    
    MOV BL,00H ;initial zeros flag
    MOV BH,00H ;flag that checks if both DH,DL has been printed
    MOV AL,DL  ;most significant reg needs to be printed first
    MOV DL,DH
    MOV DH,AL
BEGIN:    
    MOV AL,DL
    MOV CH,2
SRT0:
    MOV CL,4
    ROL DL,CL
    AND DL,00001111B
    CMP DL,09H
    JG  IS_LET
    CMP DL,00H  ;if 0 is to be printed check if another number has
    JNZ CONT    ;been printed before it
    CMP BL,00H
    JNZ CONT
    JMP SKIP0
CONT:
    ADD DL,30H
    JMP OUT1
IS_LET:
    ADD DL,37H
    
OUT1:
    MOV BL,01H  ;a non 0 number has been printed
    MOV AH,02H                                   
    PUSH AX     ;AFTER THE INTR AL <-DL?????????????
    INT 21H
    POP AX
SKIP0:    
    MOV DL,AL
    ROL DL,CL   ;prepare 4 lsbs
    DEC CH
    JNZ SRT0
    INC BH
    CMP BH,02H
    JZ LEAVE
    MOV DL,DH
    JMP BEGIN 
LEAVE:
    CMP BL,00H
    JNZ DOL
    PRINT '0'
DOL:    
    POP BX
    POP CX
    POP DX
    POP AX
ENDM    


IS_ODD macro 
LOCAL:
	CLC 
	TEST CL,01H
	JZ MY_EXIT
	STC
MY_EXIT:
ENDM     

EXIT macro
    mov ax,4C00H
    int 21H
endm