INCLUDE "MACROS_PRINT.ASM"
DATA_SEG SEGMENT 
			MSG1 DB 0AH, 0DH, 'GIVE 3 DEC DIGITS: $'
			MSG2 DB 0AH, 0DH, 'HEX= $'
			BUF  DW 50 DUP (?)
DATA_SEG ENDS

CODE_SEG SEGMENT
			ASSUME DS:DATA_SEG, CS:CODE_SEG, SS:DATA_SEG
    MAIN    PROC FAR
	    MOV AX,DATA_SEG
	    MOV DS,AX
	  SRT:
	    MOV BX,offset BUF
	    PRINT_STR MSG1     ;Prints a string starting in memory address MSG1
	    CALL READ_PRINT_DEC      ;Reads a 3 digit dec number and returns it in reg DX andalso it prints in dec form the inputed number in stdout
	    PRINT_STR MSG2
	    PRINTX_HEX							;Prints hex number in reg DX in HEX form 
        JMP SRT
	MAIN    ENDP
    
    ;Read dec digits from keyboard and store them in an array , if you get 'Q' quit the program
    ;Ignore any other character other than 0-9, enter or Q
    ;If you get enter check if you got at least 3 numbers get those 3 last numbers from the array,
    ;save them in registers in order to print them at the correct order and save the 3 digit number in DX
    READ_PRINT_DEC    PROC NEAR
        MOV CX,00H    ;number of input digits
        MOV DX,00H    ;inputed number
      IGNORE:
        MOV AH,08H
        INT 21H
        CMP AL,0DH     ;In = 'enter' ?
        JL IGNORE
        JE CHECK							
        CMP AL,30H				;In = (0-9) ?
        JL IGNORE
        CMP AL,39H
        JLE ISNUM
        CMP AL,51H    ;if in = 'Q' then exit
        JNE IGNORE
        MOV AX,4C00H
        INT 21H
      ISNUM:
        MOV AH,00H
        INC CL   
        SUB AX,30H
        MOV [BX],AL
        INC BX
        JMP IGNORE
      CHECK:
        CMP CL,03H
        JL IGNORE
        MOV AH,00H	        ;get the last number that was inputed
        MOV AL,[BX-1]       ;BX is pointing to 
        MOV DX,AX      ;save it in DX and then add the other more significant digits to it
        MOV CL,AL					;save least significant number in order to print it later
        MOV AL,[BX-2]
        MOV CH,AL
        PUSH BX
        MOV BL,10
        MUL BL 
        POP BX
        ADD DX,AX
        MOV AL,[BX-3] 
        PUSH DX
        MOV DL,AL
        PRINT_DEC
        MOV DL,CH
        PRINT_DEC
        MOV DL,CL
        PRINT_DEC
        MOV BX,100
        MUL BX 
        POP DX
        ADD DX,AX
        RET
    READ_PRINT_DEC    ENDP
CODE_SEG ENDS 
	END MAIN