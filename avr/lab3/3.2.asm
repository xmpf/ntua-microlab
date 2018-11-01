;
; AssemblerApplication2.asm
;
; Created: 24/10/2018 11:56:31 ??
; Author : gmitis
;



.include "m16def.inc"
.def scan=r20
.def num=r19			;has input number
.def temp=r18
.def f0=r17
.def f1=r16
.def f2=r15


	ser temp			;set PORTA as output and PORTC as input
	out DDRA,temp
	clr temp
	out DDRC,temp
	
	clr f0
	clr f1
	clr f2
	ldi scan,0b00000011
	in num,PINC		;get number from PortC	
	mov temp,num	;save number to temp
			
					;With the use of variable scan each loop we isolate pair AB,BC etc check if it equals to 11
					;and if yes then f0 is 0 so continue with f1.
					;if no scan is rotated left to check the next pair and if bit 5 of scan is 0 then every pair is 0 so f0 = 1
main:
	and num,scan
	cp num,scan
	breq check_f1
	lsl scan
	mov num,temp	;get the input number to num
	sbrs scan,0x05	;if scan out of bounds f0 = 1
	rjmp main
	ldi f0,0x01
check_f1:
	mov num,temp
	andi num,0b00001111		;same as f0 checking if ABCD = 1111 or B'E' = 00
	cpi num,0b00001111
	breq set_f1
	andi temp,0b0011000
	cpi temp,0b00000000
	brne check_f2
set_f1:
	ldi f1,0x01
check_f2:
	or f2,f1			;if f0 or f1 = 0x01 then f2 = 0x01
	or f2,f0
	lsl f2				;slide f2 once to the left and put f1 or f0 to the lsb respectively
	or f2,f1
	lsl f2
	or f2,f0
	out PORTA,f2		;output to PORTA

	
	
				