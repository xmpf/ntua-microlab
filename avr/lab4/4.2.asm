;
; 4.2.asm
; Created: 11/1/2018 1:35:05 PM
; Author : Nick Maritsas
;

.include "m16def.inc"
.org 0x0									;arxi kwdika panta 0x0
rjmp reset
.org 0x4									;h eksipiretisi tis INT1 einai sth 0x4
rjmp ISR1


reset:	ldi r26, HIGH(RAMEND)				;initialize stack pointer 
		out SPH, r26
		ldi r26, LOW(RAMEND)
		out SPL, r26

		ser r26   
		out DDRA, r26						;PORTA gia output		
		
		ldi r24, (1<<ISC11) | (1<<ISC10)	;gia diakopi stin anerxomenh akmh
		out MCUCR, r24						;perase to sto MCUCR
		ldi r24, (1<<INT1)					;energopoihsh INT1
		out GICR, r24						;perase to sto GICR
					 
		clr r26								;arxikopoihsh metriti

loop5:	sei									;energopoihsh diakopwn
		out PORTA, r26						;deikse timi tou metriti sto PORTA 
		ldi r24, low(200)					;fortwse to low tou 200
		ldi r25, high(200)					;fortwse to high toy 200
		rcall wait_msec						;kalese gia kathisterisi
		inc r26								;afksise metriti
		rjmp loop5							;repeat


 ISR1:
	push r26								
	in r26 , SREG							
	push r26
	loop1:									;ayto gia thn anapidisi
			ldi r24 ,(1 << INTF0)
			out GIFR ,r24
			ldi r24,0x05
			ldi r25,0x00
			rcall wait_msec
			in r24,GIFR
			sbrc r24,6
			rjmp loop1
			
			clr r27
			out DDRB,r27					;eisodos PORTB
			ser r27
			out DDRC,r27					;exodos PORTC
			ldi r24,0x08					;8bits o diakoptis
			ldi r25,0x00					;metritis asswn (dld diakoptwn pou einai on)
			in r28,PINB						;diavazw tous diakoptes
	loop2:
			ror r28
			brcc next
			inc r25
	next:
			dec r24
			cpi r24,0
			brne loop2

			out PORTC,r25

	telos:
			pop r26							;pop kataxoritwn poy eginan store
			out SREG, r26		
			pop r26
			reti



wait_usec: sbiw r24,1						;2 cycles
			nop								;1 cycle
			nop								;1 cycle
			nop								;1 cycle
			nop								;1 cycle
			brne wait_usec
			ret

wait_msec:  push r24						;2 cycles
			push r25						;2 cycles
			ldi r24, low(998)				;load registers r25:r24 using 998
			ldi r25, high(998)				;1 cycles
			rcall wait_usec					;3 cycles
			pop r25							;2 cycles
			pop r24							;2 cycless
			sbiw r24,1						;2 cycless
			brne wait_msec					;1 or 2 cycles
			ret								;4 cycles
