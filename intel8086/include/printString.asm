PRINT_STR MACRO STRING
    PUSH AX                        ; SAVE TO STACK
    PUSH DX
    ;macro to print @STRING
    LEA DX,STRING                ; DS:DX ← PTR TO STRING TERMINATED WITH '$'
    MOV AH,9                    ; DISPLAY STRING
    INT 21H                        ; CALL DOS ROUTINE
    POP DX
    POP AX                        ; RESTORE FROM STACK
ENDM