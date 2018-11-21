; Author: Michalis Papadopoullos (031 14702)

; DESCRIPTION:
; 	Read INPUT from KEYPAD (4x4) PORTC
;	if INPUT == 15 then BLINK_YES (LEDS PA[7:0] ON FOR 4 SECONDS)
;	else BLINK_NO (LEDS PA[7:0] ON FOR 8 ROUNDS OF ON/OFF = 0.25 + 0.25 SECONDS)

.include "m16def.inc"

; data segment
.dseg
	_tmp_ : .byte 2

; code segment
.cseg

.def cnt=r16

; ------------------------------------------------
; =============== [MACROS] =============== 
; ------------------------------------------------
.macro SET_LEDS_ON
	; MACRO: SET ALL LEDS OF PORTA TO ON
	; AFFECTED REGISTER: 
	ser r18
	out PORTA,r18
.endm
; ------------------------------------------------
.macro SET_LEDS_OFF
	; MACRO: SET ALL LEDS OF PORTA TO ON
	; AFFECTED REGISTER: r20
	clr r20
	out PORTA,r20
.endm
; ------------------------------------------------
.macro BLINK_NO
	; LEDS PA[7:0] BLINK ON/OF FOR 4 SECONDS
	ldi cnt,0x08 		; iterate 8 times 
L1:
	SET_LEDS_ON 		; set leds on (MACRO)
	ldi r24,low(250)
	ldi r25,high(250)
	rcall wait_msec			; delay 0.25msec (MACRO)
	
	SET_LEDS_OFF 		; set leds off (MACRO)
	ldi r24,low(250)
	ldi r25,high(250)
	rcall wait_msec
	
	dec cnt 			; cnt--
	cpi cnt, 0x0 		; (cnt == 0) ?
	brne L1 			; if cnt != 0 goto L1
.endm
; ------------------------------------------------
.macro BLINK_YES
	; LEDS PA[7:0] OPEN FOR 4 SECONDS
	SET_LEDS_ON 		; ALL LEDS ON (MACRO)
	
	ldi r24,low(4000)
	ldi r25,high(4000)
	rcall wait_msec			; DELAY 4 SECONDS (MACRO)
.endm

.org 0x0
rjmp INIT		; ON RESET JUMP TO INIT

INIT:
	; INIT STACK
	ldi r24,low(RAMEND)
	ldi r25,high(RAMEND)
	out SPL,r24
	out SPH,r25

	; SET PORTA AS OUTPUT
	ser r18			; r18 = 1111 1111
	out DDRA, r18

	; SETUP KEYPAD
	andi r18,0xf0 	; r18 = 1111 0000
	out DDRC,r18 	; PORTC[7:4] OUTPUT, PORTC[3:0] INPUT

MAIN:
	; START WITH LEDS OFF
	clr r18
	out PORTA,r18

; =========== [SCAN KEYPAD] ===========
SCAN_FST:
	; r24 xronos spinthirismou (*tha doume stin pra3i poio value volevei*)
	ldi r24,0x15
	
	; r25: [A|3|2|1]|[B|6|5|4]
	; r24: [C|9|8|7]|[D|#|0|*]
	; r25:r25 holds input
	rcall scan_keypad_rising_edge 
	adiw r24,0x0000			; if r24 == 0 then 
	breq SCAN_FST			; goto SCAN_FST
; =============================================
	; EPISTREFEI r24=0 AN DEN PATITHIKE KNAS DIAKOPTIS
	rcall keypad_to_ascii 	
	cpi r24,0x31			; check if '1' pressed
	brne B_NO  				; if YES then continue else goto BLINK_NO (jumps to MAIN)
; =============================================

SCAN_SND:
	; delay value (spinthirismos)
	ldi r24,0x15
	
	; r25: [A|3|2|1][B|6|5|4]
	; r24: [C|9|8|7][D|#|0|*]
	; r25:r25 holds input
	rcall scan_keypad_rising_edge
	adiw r24,0x0000
	breq SCAN_SND
; =============================================

	; CONVERT TO ASCII
	rcall keypad_to_ascii 	; EPISTREFEI r24=0 AN DEN PATITHIKE KNAS DIAKOPTIS
	cpi r24,0x35 			; if r24 == 5 then
	brne B_NO				; goto SCAN_SND
; =============================================
	
B_YES:
	BLINK_YES  		 ; 	 BLINK BLINK_YES (jumps to MAIN)
	rjmp MAIN

B_NO:
	BLINK_NO 	 	 ; 	 BLINK BLINK_NO (jumps to MAIN
	rjmp MAIN 		 ; PROGRAMMA SYNEXOUS LEITOURGIAS

; ------------------------------------------------
; =============== [PROCEDURES] =============== 
; ------------------------------------------------
wait_usec:
	sbiw r24,1			;2 cycles (0,250 ?sec)
	nop					;1 (0,125 ?sec)
	nop		
	nop
	nop
	brne wait_usec		;1 or 2 cycles
	ret					;4 cycles (0,5 ?sec)
; ------------------------------------------------
wait_msec:
	push r24				;2
	push r25				;2
	ldi r24,low(998)		;fortwse ton r25:r24 me 998 ( 1 cc - 0,125 ?sec)
	ldi r25,high(998)		;1
	rcall wait_usec			;3 cycles (0,375?sec), kathisterhsh 998,375
	pop r25					;2
	pop r24					;2
	sbiw r24,1				;2
	brne wait_msec			;1 or 2
	ret						;4
; ------------------------------------------------
scan_row:
	ldi r25 , 0x08
back_:
	lsl r25
	dec r24
	brne back_
	out PORTC , r25
	nop
	nop
	in r24 , PINC
	andi r24 ,0x0f
	ret
; ------------------------------------------------
scan_keypad:
	ldi r24 , 0x01
	rcall scan_row
	swap r24
	mov r27 , r24
	ldi r24 ,0x02
	rcall scan_row
	add r27 , r24
	ldi r24 , 0x03
	rcall scan_row
	swap r24
	mov r26 , r24
	ldi r24 ,0x04
	rcall scan_row
	add r26 , r24
	movw r24 , r26
	ret
; ------------------------------------------------
scan_keypad_rising_edge:
	mov r22 ,r24
	rcall scan_keypad
	push r24
	push r25
	mov r24 ,r22
	ldi r25 ,0
	rcall wait_msec
	rcall scan_keypad
	pop r23
	pop r22
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_)
	ldi r27 ,high(_tmp_)
	ld r23 ,X+
	ld r22 ,X
	st X ,r24
	ret
; ------------------------------------------------
keypad_to_ascii:	
	movw r26 ,r24 	
	ldi r24 ,'*'
	sbrc r26 ,0
	ret
	ldi r24 ,'0'
	sbrc r26 ,1
	ret
	ldi r24 ,'#'
	sbrc r26 ,2
	ret
	ldi r24 ,'D'
	sbrc r26 ,3		
	ret			
	ldi r24 ,'7'
	sbrc r26 ,4
	ret
	ldi r24 ,'8'
	sbrc r26 ,5
	ret
	ldi r24 ,'9'
	sbrc r26 ,6
	ret
	ldi r24 ,'C'
	sbrc r26 ,7
	 ret
	ldi r24 ,'4'	
	sbrc r27 ,0	
	ret
	ldi r24 ,'5'
	sbrc r27 ,1
	ret
	ldi r24 ,'6'
	sbrc r27 ,2
	ret
	ldi r24 ,'B'
	sbrc r27 ,3
	ret
	ldi r24 ,'1'
	sbrc r27 ,4
	ret
	ldi r24 ,'2'
	sbrc r27 ,5
	ret
	ldi r24 ,'3'
	sbrc r27 ,6
	ret
	ldi r24 ,'A'
	sbrc r27 ,7
	ret
	clr r24
	ret