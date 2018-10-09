READ_STRING      PROC    NEAR
	PUSH    AX
	PUSH    CX
	PUSH    DI
	PUSH    DX

	MOV     CX, 0                   ; char counter.
	CMP     DX, 1                   ; buffer too small?
	JBE     empty_buffer            ; 
	DEC     DX                      ; reserve space for null termination.

	; loop to get and processes key presses:

wait_for_key:
	MOV     AH, 0                   ; get pressed key.
	INT     16h

	CMP     AL, 13                  ; 'RETURN' pressed?
	JZ      exit

	CMP     AL, 8                   ; 'BACKSPACE' pressed?
	JNE     add_to_buffer
	JCXZ    wait_for_key            ; nothing to remove!
	DEC     CX
	DEC     DI
	PUTC    8                       ; backspace.
	PUTC    ' '                     ; clear position.
	PUTC    8                       ; backspace again.
	JMP     wait_for_key

add_to_buffer:
    CMP     CX, DX          ; buffer is full?
    JAE     wait_for_key    ; if so wait for 'BACKSPACE' or 'RETURN'...

    MOV     [DI], AL
    INC     DI
    INC     CX
    
    ; print the key:
    MOV     AH, 0Eh
	INT     10h

	JMP     wait_for_key

exit:
	; terminate by null:
	MOV     [DI], 0

empty_buffer:
	POP     DX
	POP     DI
	POP     CX
	POP     AX
	RET
GET_STRING      ENDP