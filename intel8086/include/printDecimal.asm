;O ARITHMOS DINETAI STON AX
PRINT_DEC PROC NEAR 
    MOV CX,0
    MOV BX,10
    
A1: MOV DX,0         ;
    DIV BX             ;
    PUSH DX          ;
    
    INC CX             ; CX HOLDS # OF DIGITS
    CMP AX,0         ; WHILE AX != 0 REPEAT
    JNE A1
    
A2: POP DX
    ADD DX,30H
    MOV AH,2         ; PRINT CHAR
    INT 21H
    LOOP A2         ; LOOP UNTIL CX == 0
    RET
PRINT_DEC ENDP