READ_OCTAL MACRO
READ_AGAIN:
    MOV AH,8            ; READ ROUTINE
    INT 21H             ; CALL DOS
    CMP AL,'0'             ; AL < '0'
    JL  READ_AGAIN         ; READ_AGAIN
    CMP AL,'7'             ; AL > '7'
    JG  READ_AGAIN        ; READ_AGAIN
VALID_OCTAL:            ; INPUT IS BETWEEN '0' .. '7'
    MOV DL,AL
    MOV AH,2             ; PRINT
    INT 21H
EXIT:
ENDM