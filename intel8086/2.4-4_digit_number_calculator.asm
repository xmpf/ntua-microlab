INCLUDE ".include/MACROS_PRINT.ASM"

DATA    SEGMENT  
    NEWL    DB  0AH,0DH,'$'
DATA	ENDS
               
CODE    SEGMENT
        ASSUME DS:DATA,CS:CODE,SS:DATA
    MAIN 			PROC FAR
        
        MOV AX,DATA
        MOV DS,AX
     START: 
     	MOV AX,00H
     	MOV CX,00H
        MOV BX,0FFFFH                     ;checks if a number has been imput before +, - or =
        CALL READ_DIGITS       		      ;Reads up to a 4 digit decimal number from keyboard, stores it in register DX. 
        MOV AX,DX                         ;Also it reads an operand '+' or '-' and stores it to CL (the first time that is called)
        MOV BX,0FFFEH 
        CALL READ_DIGITS                                 
        CALL CALC_AND_OUTPUT              ;It calculates the result of the operation AX (+ or -) DX and outputs the
                                          ;result in both hex and decimal forms
        JMP START                         ;The function is continuous and terminates when the letter 'M' is read as input                             
    MAIN ENDP 
    
    READ_DIGITS PROC NEAR
        PUSH AX
        MOV DX,0
        MOV CH,04H										;input number counter
     SRT:   
        MOV AH,08H            ;Read input number 
        INT 21H 
        CMP AL,2BH            ;Check to see if input is between 0-9 or is '+', '-','=' or 'M ....here in = '+' ?
        JL SRT
        JG NXT                ;Else its equal with 2Bh 
        CMP CL,'+'            ;if input= '+' and CL='+' or '-' then its the second time the routine is called 
        JZ SRT                ;the only acceptable operand is '='
        CMP CL,'-'
        JZ SRT
        CMP BX,0FFFFH										;If BX hasnt changed then no number has been input as the first value but in ='+'
        JZ SRT
        MOV CL,AL
        PRINT CL
        JMP RETURN
     NXT:                      
        CMP AL,2DH            ;in = '-' ?
        JL SRT
        JG NUM
        CMP CL,'+'            ;if input= '-' and CL='+' or '-' then its the second time the routine is called 
        JZ SRT                ;the only acceptable operand is '='
        CMP CL,'-'
        JZ SRT
        CMP BX,0FFFFH									;If BX hasnt change then no number has been input as the first value but in ='+'
        JZ SRT 
        MOV CL,AL
        PRINT CL
        JMP RETURN
     NUM:            
        CMP AL,30H            ;in = [0,9] ? 
        JL SRT
        CMP AL,39H
        JLE ISNUM 
        CMP AL,3DH            ;in = '='?
        JG CHECK_EXT
        JL SRT
        CMP CL,0              ;if in = '=' and its the first time this routine is called (CL=0) its not a valid operand
        JZ SRT
        CMP BX,0FFFEH									;Also if no valid value hasbeen input its incorrect
        JZ SRT
        PRINT '='
        JMP RETURN
     CHECK_EXT:               ;if in = 'M' then exit the program
        CMP AL,4DH
        JNZ SRT
        MOV AX,4C00H
        INT 21H
     ISNUM: 
     	CMP CH,00H            ;if 4 numbers have been read ,wait for a char tobe input
     	JZ SRT				  ;If we have a new number then multiply the number that we have x10 and then add the new number and store 
        MOV AH,0              ;it to DX
        PRINT AL
        SUB AL,30H
        MOV BX,AX
        MOV AX,DX
        MOV DX,10
        MUL DX
        ADD AX,BX
        MOV DX,AX
        DEC CH
        JMP SRT        
      RETURN:
        POP AX  
        RET
    READ_DIGITS ENDP
    
    CALC_AND_OUTPUT PROC NEAR
    	MOV CH,00H							;Negative sub flag
    	CMP CL,'+'
    	JNZ MNS
    	ADD AX,DX
    	JMP OUTP
      MNS:
    	SUB AX,DX
    	JNC OUTP
    	MOV CH,01				    ;if AX-DX <0
    	NEG AX						;complete of 2 of the reg AX
      OUTP:
        CMP CH,00H
        JZ NO_PR
        PRINT '-'
      NO_PR:   
        MOV DX,AX
    	PRINTX_HEX
    	PRINT '='
    	CMP CH,00
    	JZ PRDEC
    	PRINT '-'
   	  PRDEC:
    	MOV DX,0
  		MOV BX,10
    	MOV CX,0
   	  PUSH_NUM:
    	INC CX
    	DIV BX
    	PUSH DX
    	CMP AX,0
    	JZ DO_PRINT
    	MOV DX,0
    	JMP PUSH_NUM
      DO_PRINT:
    	POP DX 
    	PRINT_DEC
    	LOOP DO_PRINT
    	PRINT_STR NEWL
    	RET
	CALC_AND_OUTPUT ENDP
CODE ENDS
    END MAIN