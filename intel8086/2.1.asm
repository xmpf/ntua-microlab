include 'macros.asm'

data segment
	input		db 	"GIVE 4 OCTAL DIGITS: $"
	output 		db 	0AH,0DH,"DECIMAL: $"
	new_line		db	0AH,0DH,"$"
	array_flp		dw	0000h,1250h,2500h,3750h,5000h,6250h,7500h,8750h
ends
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

state1:
	mov ax,0
	mov bx,ax
	mov cx,bx

	print_str input
	;mov dl,al

	call in_oct
	cmp al,'D'
	je finish
	mov ah,al
	shr ah,2
	mov bh,ah
	shl al,3
	mov bl,al
	call in_oct
	cmp al,'D'
	je finish
	or al,bl
	shl al,3
	mov bl,al
	call in_oct
	cmp al,'D'
	je finish
	or al,bl
	mov bl,al
	print '.'
	call in_oct
	cmp al,'D'
	je finish
	mov cl,al
	mov ch,0

	print_str output
	mov ax,bx
	call print_dec
	print '.'
	
	mov bx,cx
    shl bx,1
	mov cx,array_flp[bx]
	
	mov al,ch
	call print_hex
	
	shr cl,4
	mov dl,cl
	call out_hex
	print_str new_line
	jmp state1

finish:
	exit
main endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ==IN_OCT==
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ

in_oct proc NEAR
_OIGNORE:
	READ		
	cmp AL, 'D'
	je _OQUIT
	cmp AL,'0'
	jl _OIGNORE
	cmp AL,'7'
	jg _OIGNORE
	PRINT AL
	sub AL, '0'
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