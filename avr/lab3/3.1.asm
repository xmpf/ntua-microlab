;
; 3.1.asm
;
; Created: 10/30/2018 10:03:01 AM
; Author : Nick Maritsas
;

.include "m16def.inc"
;.include "wait.asm"

;-------------------
; REGISTER ALIASING
.def cnt=r20
.def input=r22

;-------------------
; PROGRAM CODE
;-------------------

;-------------------
.MACRO CHECK
LOOP:
	in input,PINB
	andi input,0x01
	cpi input,0x01
	breq LOOP
	rjmp @0
.ENDMACRO
;-------------------

;-------------------
; INITIALIZING STACK
SETUP_STACK:
	ldi r24,low(RAMEND)
	ldi r25,high(RAMEND)
	out SPL,r24
	out SPH,r25
;-------------------

INIT:
	ser cnt			; cnt = 1..1
	out DDRA,cnt	; initialize PORTA as OUTPUT 
	clr cnt 		; cnt = 0
	out DDRB,cnt 	; initialize PORTB as INPUT

MAIN:
	in input,PINB 	; read INPUT
	andi input,0x01 ; get LSB
	sbrc input,0 	; skip if input[0] (bit) is reset (=0)
	rjmp MAIN 		; if input[0] (bit) == 0 then goto MAIN

	inc cnt 		; cnt = 1
	jmp LSB_2_MSB

CHANGE_FROM_MSB_2_LSB:
	lsl cnt		 	; start from the second bit

LSB_2_MSB:
	out PORTA,cnt 	;
	rcall WAIT 		; wait for 500ms
	cpi cnt,0x80 	; if 0b1000 0000 => last bit
	breq CHANGE_FROM_LSB_2_MSB 	; change direction
	lsl cnt 		; else, cntt << 1

	CHECK LSB_2_MSB

CHANGE_FROM_LSB_2_MSB:
	lsr cnt 		; start from the sixth bit

MSB_2_LSB:
	out PORTA,cnt 	;
	rcall WAIT 		; 500 ms
	cpi cnt,0x01 	; first bit => change direction
	breq CHANGE_FROM_MSB_2_LSB
	lsr cnt
	
	CHECK MSB_2_LSB 

;------------------- 
WAIT:
	ldi r24,low(500)
	ldi r25,high(500)
	rcall wait_msec
	ret
;------------------- 

wait_usec:
	sbiw r24,1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret

wait_msec:
	push r24
	push r25
	ldi r24,low(998)
	ldi r25,high(998)
	rcall wait_usec
	pop r25
	pop r24
	sbiw r24,1
	brne wait_msec
	ret