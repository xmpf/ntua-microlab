INCLUDE "./include/MACROS_PRINTFINAL.ASM"
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
	    PRINT_STR MSG1           ;Prints a string starting in memory address MSG1
	    CALL READ_PRINT_DEC      ;Reads a 3 digit dec number and returns it in reg DX andalso it prints in dec form the inputed number in stdout
	    PRINT_STR MSG2
	    PRINTX_HEX				 ;Prints hex number in reg DX in HEX form 
        JMP SRT
	MAIN    ENDP
    
    ;Read dec digits from keyboard and store them in an array , if you get 'Q' quit the program
    ;Ignore any other character other than 0-9, enter or Q
    ;If you get enter check if you got at least 3 numbers get those 3 last numbers from the array,
    ;save them in registers in order to print them at the correct order and save the 3 digit number in DX
    READ_PRINT_DEC    PROC NEAR
        MOV CX,00H                ;number of input digits
        MOV DX,00H                ;inputed number will be saved here
      IGNORE:
        MOV AH,08H
        INT 21H
        CMP AL,0DH                ;In = 'enter' ?
        JL IGNORE
        JE CHECK							
        CMP AL,30H				  ;In = (0-9) ?
        JL IGNORE
        CMP AL,39H
        JLE ISNUM
        CMP AL,51H                ;if in = 'Q' then exit
        JNE IGNORE
        MOV AX,4C00H
        INT 21H
      ISNUM:
        INC CL   
        SUB AX,30H
        MOV [BX],AL
        INC BX
        JMP IGNORE
      CHECK:
        CMP CL,03H                 ;got enter so check if i got at least 3 non hex numbers
        JL IGNORE   
        MOV CX,100
        DEC BX                     ;BX is pointning now in the last position of the array
        MOV DL,[BX-2]              ;Get ms digit and print it then do 100xmsb and store to AX
        PRINT_DEC                  ; Repeat this for all the digits
        MOV AH,0
        MOV AL,DL                  
        MUL CX
        MOV DL,[BX-1]
        PRINT_DEC
        MOV DH,[BX]              ;get least significant digits in order to free BX 
        MOV BX,AX
        MOV CL,10
        MOV AH,0
        MOV AL,DL
        MUL CL
        ADD AX,BX
        MOV DL,DH                   ;print ls digit
        PRINT_DEC
        MOV DH,0
        ADD DX,AX
        RET
    READ_PRINT_DEC    ENDP
CODE_SEG ENDS 
	END MAIN