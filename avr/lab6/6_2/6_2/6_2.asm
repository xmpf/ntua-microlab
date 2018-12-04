; Author: Michalis Papadopoullos
; AM: 03114702
; Lab 6 (AVR) Exercise 2

; TODO:
;	- Implement print_temp function
;	- Test solution in lab
;	- Error message routine -> uses lpm => 

; ***********************************************************
; 0x8000 => Error Code: No Device Found (Sensor not connected)
; ***********************************************************


; header file
.include "m16def.inc"

; data segment
.dseg
_tmp_ : .byte 2

; code segment
.cseg

; ------ RESET -------
.org 0x0
rjmp reset
; --------------------

; custom libraries
.include "include/keypad_hex.asm"	; keypad_to_hex, scan_keypad_rising_edge
.include "include/wait.asm"			; wait_msec (r25:r24)
.include "include/lcd.asm"			; lcd_data, lcd_command, lcd_init
.include "include/one_wire.asm"		; one_wire_receive_byte, one_wire_transmit_byte, one_wire_reset

reset:
	; initialize stack
	ldi r24,low(RAMEND)
	ldi r25,high(RAMEND)
	out SPL,r24
	out SPH,r25
	
	; SETUP KEYPAD
	ldi r18,0xf0 	; r18 = 1111 0000
	out DDRC,r18 	; PORTC[7:4] OUTPUT, PORTC[3:0] INPUT

	; SETUP LCD
	ser r18			; r18 = 1111 1111
	out DDRD,r18    ; PORTD: OUTPUT
	out DDRA,r18	; PORTA: OUTPUT


main:
	; we can make this to change on runtime 
	; by checking a specific register (eg: PINAx)
	; preload device select option
	ldi r20,0x00

	; initialize lcd screen
	rcall lcd_init

	; KEYPADSELECT => READ FROM KEYPAD OR SENSOR
	cpi r20,0x1
	breq USE_KEYPAD

; if r20 = 0x00 => Sensor will be used
USE_SENSOR:	
	; use sensor
	rcall sensor_temp
	rcall printw
	rjmp SKIP_KEYPAD

; if r20 = 0x01 => keypad will be used
USE_KEYPAD:
	; use keypad
	rcall keypad_temp

SKIP_KEYPAD:
	; wait 250ms
	ldi r24,low(250)
	ldi r25,high(250)
	rcall wait_msec
	
	; while (1)
	rjmp main
	ret
;; [/main]

; print temperature
print_temp:
	; keep backup of HO & LO byte
	mov r19,r24

	; POSITIVE OR NEGATIVE
	sbrc r25,7
	rjmp NEGATIVE	; prints '-'
					; and complements r19
	cpi r25,0x00
	breq POSITIVE	; prints '+'


NEGATIVE:
	ldi r24,'-'
	rcall lcd_data	; print '-'
	com r19			; One\'s complement of LO byte
	inc r19
;	cpi r19,0x37
;	brlo PROCESSING_R19
;	lsr r19
	rjmp PROCESSING_R19

POSITIVE:
	ldi r24,'+'
	rcall lcd_data	; print '+'
	; maximal temp = +125 = 0x7C
	; therefore we mask everything with 0x7F = 0b 0111 xxx
	andi r19,0x7F
	
	
	; -55 <= TEMPERATURE <= +125
	; therefore TEMPERATURE is contained only
	; in 1 byte \r19\

PROCESSING_R19:
	lsr r19
	clr r25
	clr r21			; flag
	clr r18			; r18 will hold number of decades
	ldi r17,'0'		; ASCII code of 0


	
	; check if we have a hundred
	cpi r19,0x64
	brlo decades

	; print 1 in the first position
	ldi r24,'1'
	rcall lcd_data

	; flag
	ser r21

	; subtract 100 = 0x64 from r19
	subi r19,0x64	; r19 holds decades

decades:
	cpi r19,0x0A	; while (r19 > 10)
	brlo print_decades
	inc r18			; incr counter
	subi r19,0x0A	; r19 -= 10
	rjmp decades

print_decades:
	cpi r18,0x00
	breq print_units	; if there are no decades move on to units
	
	clr r21				; set flag off
	mov r24,r18			; decades counter
	add r24,r17			; convert to ASCII (+'0')
	rcall lcd_data		; print decades

	; at this point r19 < 10
print_units:
	; if flag set then print a leading 0
	; in case of we had no decades but the number
	; was in range [100..109]
	cpi r21,0xff
	brne CONTINUE1
	ldi r24,'0'
	rcall lcd_data
	
CONTINUE1:
	add r24,r19			; r19 holds units
	add r24,r17			; convert value to ASCII (+ '0')
	rcall lcd_data		; print units

	; print Celsius
	ldi r24,0xB2
	rcall lcd_data
	ldi r24,'C'
	rcall lcd_data

EXIT0:
	; add delay for the temperature
	; to remain on screen for 200msec
	ldi r24,low(200)
	ldi r25,high(200)
	rcall wait_msec
	ret
;; [/print_temp]

; Print Temperature Wrapper
printw:
	cpi r25,0x80
	brne no_error
	cpi r24,0x00
	brne no_error
	rcall sensor_error_msg	; got 0x8000 => ERROR
	ret
no_error:					; r25:r24 != 0x8000 => NO ERROR
	; if its 0x0000 or 0xffff
	; then just print 0 without sign
	; actually this is redundant as we should only check value of \r24\
CHECK_ZERO:
	cpi r24,0xff
	breq ZERO
	cpi r24,0x00
	breq ZERO

CONTINUE:
	; r25:r24 hold temperature
	rcall print_temp
	ret

ZERO:
	ldi r24,'0'
	rcall lcd_data
	ret
;; [/tempw]

; read temperature from keypad
; aux function
keypad_read:
	ldi r24,low(25)	; spinthirismos
	ldi r25,high(25)
	rcall scan_keypad_rising_edge
	rcall keypad_to_hex
	
	cpi r24,0x0		; got any input?
	breq keypad_read

	subi r24,'0'
	cpi r24,0x0A
	brlo EXIT1
	subi r24,0x07
EXIT1:
	ret
;; [/keypad_read]

keypad_temp:
	; first byte (HO)
	clr r21
	rcall keypad_read
	mov r21,r24
	swap r21		; swap HO/LO bits
	rcall keypad_read
	or r21,r24

	; second byte (LO)
	clr r20
	rcall keypad_read
	mov r20,r24
	swap r20		; swap HO/LO bits
	rcall keypad_read
	or r20,r24

	; output temperature
	mov r25,r21
	mov r24,r20
	rcall printw
	
	; add delay of 500msec
	ldi r24,low(500)
	ldi r25,high(500)
	rcall wait_msec

	ret
;; [/keypad_temp]

; SENSOR NOT FOUND ROUTINE
; print error message to lcd screen
sensor_error_msg:
	ldi r24, 0x01
	rcall lcd_command
	ldi r24, low(1530)
	ldi r25, high(1530)
	rcall wait_usec
	ldi r24, 'N'
	rcall lcd_data
	ldi r24, 'O'
	rcall lcd_data
	ldi r24, ' '
	rcall lcd_data
	ldi r24, 'D'
	rcall lcd_data
	ldi r24, 'e'
	rcall lcd_data
	ldi r24, 'v'
	rcall lcd_data
	ldi r24, 'i'
	rcall lcd_data
	ldi r24, 'c'
	rcall lcd_data
	ldi r24, 'e'
	rcall lcd_data
	ret
;; [/sensor_error_msg]

; read temperature from sensor
sensor_temp:
	rcall one_wire_reset	; returns r24=0x0 if no sensor is found
	sbrs r24,0
	breq sensor_error		; goto missing sensor routine

	; we only have one sensor
	ldi r24,0xCC
	rcall one_wire_transmit_byte
	; request temperature
	ldi r24,0x44
	rcall one_wire_transmit_byte

isTxFinished:
	rcall one_wire_receive_bit
	sbrs r24,0
	rjmp isTxFinished
	
	; reset sensor
	rcall one_wire_reset	
	sbrs r24,0
	rjmp sensor_error

	ldi r24,0xCC
	rcall one_wire_transmit_byte
	ldi r24,0xBE
	rcall one_wire_transmit_byte

	; r25:r24 = temperature
	rcall one_wire_receive_byte
	push r24
	rcall one_wire_receive_byte
	mov r25,r24
	pop r24
 
	sbrs r25,0
	rjmp done
	dec r24

done:
	push r24
	lsr r24
	out PORTA,r24
	pop r24
	ret

sensor_error:
	ldi r24,low(8000)
	ldi r25,high(8000)
	ret
;; [/sensor_temp]
