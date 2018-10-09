PRINT MACRO CHAR
    ;macro to print char
    PUSH AX                ; SAVE TO STACK    
    PUSH DX
    MOV DL,CHAR         ; CHAR MUST BE IN DL REGISTER
    MOV AH,2             ; PRINTS 8-BIT ASCII (FROM DL)
    INT 21H                ; CALL DOS ROUTINE (21/02)
    POP DX
    POP AX                 ; RESTORE FROM STACK
ENDM