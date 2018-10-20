include './include/macros.asm'

data segment
	input		db 	"GIVE 4 OCTAL DIGITS: $"
	output 		db 	0AH,0DH,"DECIMAL: $"
	new_line		db	0AH,0DH,"$"
	array_flp		dw	0000h,1250h,2500h,3750h,5000h,6250h,7500h,8750h
ends                                                                      

;array_flp contains the results of 0/8,1/8,2/8,3/8 etc in hex form but with the right decimal numeric value

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stack segment
	dw 128 dup(0)
ends
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
code segment

main proc FAR
	mov ax,data
	mov ds,ax
	mov es,ax   
	
;knowing that each octal digit is up to three bits
;for each one we take as input we are gonna shift it 3 times left in order to
;prepare it to merge with the next one
;however,since we are gonna take 3 octal sto akeraio meros the msb of the first octal
;is gonna overflow and disappear
;so we deal with this problem by saving the first octal also
;in BH and shift it 2 times right to only keep its msb	

start:
	mov ax,0            ;reset all regesters
	mov bx,ax
	mov cx,bx

	print_str input     ;print message input

	call in_oct         ;AL = first octal or 'D'
	cmp al,'D'          ;if user enters 'D' in in_oct proc 
	je finish           ;go to finish
	mov ah,al           ;move first octal to AH
	shr ah,2            ;and shift right 2 times in order to keep its msb
	mov bh,ah           ;move AH to BH
	shl al,3            ;shift first octal 3 times left in order to prepare it
	mov bl,al           ;for the next octal and store it to BL
	
	call in_oct         ;AL = second octal or 'D'
	cmp al,'D'          ;if user enters 'D' in in_oct proc
	je finish           ;go to finish
	or al,bl            ;merge first and second octal to AL
	shl al,3            ;and then shift the new AL 3 times 
	                    ;in order to prepare it for the next
	mov bl,al           ;move AL to BL
	
	call in_oct         ;al = third octal or 'D'
	cmp al,'D'          ;if user enters 'D' in in_oct proc
	je finish           ;go to finish
	or al,bl            ;merge them all and put them in BL
	mov bl,al           
	                    ;now BX has the first three octals 
	print '.'
	
	call in_oct         ;al = forth octal or 'D'
	cmp al,'D'          ;if user enters 'D' in in_oct proc
	je finish           ;go to finish
	mov cl,al           ;move AL to CL
	mov ch,0            

	print_str output    ;print output message
	
	mov ax,bx
	call print_dec      ;print first three octals as decimal
	print '.'
	
	mov bx,cx           ;double the value of the final octal
    shl bx,1            ;in order to point at the right address of the 
	mov cx,array_flp[bx];look up table which contains every case scenario in hex form
	
	mov al,ch
	call print_hex      ;print the first two hex digits which however are made to
	                    ;have the right decimal numeric value :P
	
	shr cl,4            ;shift right 4 times in order to isolate the third hex digit
	mov dl,cl           ;move CL to DL
	call out_hex        ;and print it as hex digit
	print_str new_line
	print_str new_line  ;go to next line
	jmp start           ;go to start label and start over

finish:
	exit                ;invoke DOS software interrupt
main endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ==In_Oct== 
; Repeatedly requests a character from keyboard until user
; enters an octal digit. The octal digit is echoed on the screen
; The value of the digit is returned in AL.
; Routine is terminated if user enters 'D'
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ

in_oct proc NEAR
_OIGNORE:
	READ		 ;read a character from keyboard   
	cmp AL, 'D'  ;if user enters 'D' 
	je _OQUIT    ;terminate program
	cmp AL,'0'
	jl _OIGNORE  ;if chr(AL)<'0' or chr(AL)>'9' 
	cmp AL,'7'   ;get new input
	jg _OIGNORE
	PRINT AL     ;else print number on screen and
	sub AL, '0'  ;get numeric value
_OQUIT:
	ret
endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; == out_hex ==
; Prints DL as a hex digit.
; ASSUMES: 0x00 <= DL <= 0x0f
; MODIFIES: FLAGS
; REQUIRES: <iolib.asm>: PRINT
out_hex proc NEAR
    push dx
    cmp DL, 9       ; DL <= 9?
    jle _DEC        ; yes: jump to appropriate fixing code.
    add DL, 0x37    ; no : Prepare DL by adding chr(A) - 10 = 0x37.
    jmp _HEX_OUT    ; ... and go to output stage.
_DEC:  
    add DL, '0'     ; Prepare DL by adding chr(0) = 0x30.
_HEX_OUT:
    PRINT DL        ; Print char to screen.
    pop dx    
    ret             ; Terminate routine.
endp
             
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; == out_hex_byte ==
; Prints AL as 2 hex digits.
; MODIFIES: 
; REQUIRES: <numlib.asm>: out_hex
PRINT_HEX proc NEAR
    push ax    
    push cx
    push dx
    mov CH, AL      ; Save AL in CH.
    mov CL, 4       ; Set rotation counter.
    shr AL, CL      ; Swap high & low nibble of AL, to print MSH first.
    and AL, 0x0f    ; Mask out high nibble (low nibble is single hex digit).
    mov DL, AL      ; Copy AL to DL.
    call out_hex    ; ... and print as hex.
    mov AL, CH      ; Recover unswapped AL from CH.
    and AL, 0x0f    ; Mask out high nibble (already printed).
    mov DL, AL      ; Copy AL to DL.
    call out_hex    ; ... and print as hex.
    pop dx
    pop cx    
    pop ax    
    ret             ; Terminate routine.
endp 

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; == PRINT_DEC ==
; Prints number in AX as sequence of decimal digits.
; MODIFIES: FLAGS, AX, BX, CX, DX
; REQUIRES: <iolib.asm>: PRINT_UNSAFE

PRINT_DEC proc NEAR
   pusha
   ;mov AX,BX   
    mov CX, 0       ; CX will be used as counter for decimal digits.
_DCALC:             ; Digit-calculation loop.
    mov DX, 0       ; Zero DX.    
    mov BX, 10      ; Divide DX:AX by 10 to find next decimal digit.
    div BX          ; Quotient in AX, remainder in DX.
    push DX         ; Store decimal digit.
    inc CX          ; Increase digit counter. 
    cmp AX, 0       ; Repeat until there are no more digits (AX = 0).
    jnz _DCALC
_DOUT:              ; Digit-printing loop (from MSD to LSD).
    pop DX          ; Pop a decimal digit.
    add DX, '0'     ; Generate ASCII code
    PRINT DL ; ... and print as char.
    loop _DOUT      ; Loop until no decimal digits left (CX = 0).
    popa
    ret             ; Terminate routine.
endp   

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~