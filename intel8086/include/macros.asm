;________________________
IS_ODD macro 
LOCAL:
	CLC 
	TEST AX,01H
	JZ MY_EXIT
	STC
MY_EXIT:
ENDM


SAFE_CALL macro THE_PROC
	pushf		; store the flags
	push AX
	push BX
	push CX
	push DX

	call THE_PROC

	pop DX
	pop CX
	pop BX
	popf
endm


IS_HEX macro CHAR
LOCAL _HEX, _MYEXIT
	CLC 
	CMP CHAR, '0'
	JB, _MYEXIT
	CMP CHAR, '9'
	JBE _HEX
	CMP CHAR, 'A'
	JB, _MYEXIT
	CMP CHAR, 'F'
	JBE _HEX
	CMP CHAR, 'a'
	JB, _MYEXIT
	CMP CHAR, 'f'
	JG _MYEXIT
_HEX:
	STC
_MYEXIT:
ENDM

;__________________________
;______I/O_________________
;__________________________

BACKSP macro
	PUSH AX
	PUSH DX
	MOV DL, 0x08
	MOV AH, 0x02
	INT 0x21
	POP DX
	POP AX
ENDM


READ macro
	mov ah,8
	int 21h
endm


READ_ECHO macro
	mov ah,01
	int 21h
endm

PRINT macro CHAR
	push ax
	push dx
	mov dl,CHAR
	mov ah,2
	int 21h
	pop dx
	pop ax
endm

PRINT_STR macro STRING
	push ax
	push dx
	push ax
	mov dx, offset STRING
	mov ah,9
	int 21h
	pop ax
	pop dx
	pop ax
endm

EXIT macro
	mov ax,4c00h
	int 21h
endm

RESETREG macro
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0

	mov di,0
	mov si,0
endm