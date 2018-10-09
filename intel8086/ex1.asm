; @Input: 4 digits (octal representation)
; @Output: Octal & Decimal representation

include "include/printString.asm" 	; PRINT_STR [STRING]
include "include/readOctal.asm" 	; READ_OCTAL

.CODE
ASSUME CS:.CODE, SS:.STACK, DS:.DATA

MAIN PROC FAR
	PRINT_STR MSG1
LOOP_READ:					; LOOP 4 -- READ 4 DIGITS
	READ_OCTAL
	; SAVE INTO MEMORY 
	; INC MEMORY POINTER
	; GOTO LOOP
	PRINT_STR MSG2
	PRINT_STR OCTAL_MEM
	PRINT_STR MSG3
	PRINT_STR DECIMAL_MEM


.DATA
	MSG1	DB	 "GIVE 4 OCTAL DIGITS: $"
	MSG2	DB	 0AH,0DH,"Octal: $"
	MSG3	DB 	 0AH,0DH,"Decimal: $"
	NEWLN	DB 	 0AH,0DH,'$'



