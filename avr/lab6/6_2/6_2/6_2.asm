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

; constants / EEPROM segment
.eseg
NODEVMSG : .db "NO DEVICE\000"
KEYPADSELECT : .db 0x1

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
	ori r18,0x0F	; r18 = 1111 1111
	out DDRD,r18    ; PORTD: OUTPUT
	out DDRA,r18	; PORTA: OUTPUT


main:
	; we can make this to change on runtime 
	; by checking a specific register (eg: PINAx)
	; preload device select option
	ldi r20,KEYPADSELECT

	; initialize lcd screen
	rcall lcd_init

	; KEYPADSELECT => READ FROM KEYPAD OR SENSOR
	cpi r20,0x1
	breq USE_KEYPAD

USE_SENSOR:	
	; use sensor
	rcall sensor_temp
	rjmp SKIP_KEYPAD

USE_KEYPAD:
	; use keypad
	rcall keypad_temp

SKIP_KEYPAD:
	; wait 100ms
	ldi r24,low(100)
	ldi r25,high(100)
	rcall wait_msec
	
	; while (1)
	rjmp main
	ret
;; [/main]

; print temperature
print_temp:
	; check if temperature is 0 => therefore no sign is needed
	cpi r24,0x0 
	breq TEMP0		; positive 0 (+0)
	cpi r24,0xff
	breq TEMP0		; negative 0 (-0)

	; keep a backup of temp
	mov r19,r24
PROSIMO:
	sbrs r24,7		; if r24[7] = 1 => NEGATIVE
	rjmp POSITIVE	; so skip POSITIVE
	rjmp NEGATIVE	; else goto POSITIVE

POSITIVE:
	ldi r24,'+'
	rcall lcd_data	; print '+'
	rjmp SKIP_NEGATIVE

NEGATIVE:
	ldi r24,'-'
	rcall lcd_data	; print '-'
	com r19			; One\'s complement => make temp positive

SKIP_NEGATIVE:
	clr r18			; r18 will hold number of decades
	ldi r17,0x30	; convert to ASCII

	; maximal temp = +125 = 0x7C
	; therefore we mask everything with 0x7F = 0b 0111 xxx
	andi r19,0x7F
	; check if we have a hundred
	cpi r19,0x64
	brlo decades
	ldi r24,'1'
	rcall lcd_data
	; subtract 100 = 0x64 from r19
	subi r19,0x64	; now r19 < 27
decades:
	cpi r19,0x0A	; while (r19 > 10)
	brlo print_decades
	inc r18			; incr counter
	subi r19,0x0A	; r19 -= 10
	rjmp decades

print_decades:
	cpi r18,0x0
	breq print_units	; if there are no decades move on to units
	mov r24,r18			; decades counter
	add r24,r17			; convert to ASCII (+48)
	rcall lcd_data

	; at this point r19 < 10
print_units:
	add r19,r17
	rcall lcd_data
	; print Celsius
	ldi r24,0xB2
	rcall lcd_data
	ldi r24,'C'
	rcall lcd_data
	
	rjmp EXIT0
TEMP0:
	ldi r24,'0'
	rcall lcd_data
EXIT0:
	ret
;; [/print_temp]

; read temperature from keypad
; aux function
keypad_read:
	ldi r24,0xA5	; spinthirismos
	rcall scan_keypad_rising_edge
	rcall keypad_to_hex
	cpi r24,0x0		; got any input?
	breq keypad_read
	ret
;; [/keypad_read]

keypad_temp:
	; first byte
	rcall keypad_read
	mov r21,r24
	swap r21		; swap HO/LO bits
	rcall keypad_read
	or r21,r24

	; second byte
	rcall keypad_read
	mov r20,r24
	swap r20		; swap HO/LO bits
	rcall keypad_read
	or r20,r24

	; output temperature
	mov r25,r21
	mov r24,r20
	rcall print_temp
	ret
;; [/keypad_temp]

; SENSOR NOT FOUND ROUTINE
; load into r0 the error message
; and print it to lcd screen
sensor_error:
	; preload init base location
	ldi ZL,low(NODEVMSG << 1)
	ldi ZH,high(NODEVMSG << 1)

	; clear lcd screen
	ldi r24,0x01
	rcall lcd_command

	; print first character
	lpm r24,Z
	rcall lcd_data
	ldi r18,0x01
L1:
	; load and post-increment Z
	lpm r24,Z
	rcall lcd_data
	lsl r18			; r18 <<= 1
	sbrs r18,7		; when r18=0b1000 0000 whole message has been printed
	rjmp L1			; therefore break loop and return
	ret
;; [/sensor_error]

; read temperature from sensor
sensor_temp:
	rcall one_wire_reset	; returns r24=0x0 if no sensor is found
	cpi r24,0x0
	breq sensor_error		; goto missing sensor routine

	; we only have one sensor
	ldi r24,0xCC
	rcall one_wire_transmit_byte
	; request temperature
	ldi r24,0x44
	rcall one_wire_transmit_byte

	; print temperature
	rcall print_temp
	ret
;; [/sensor_temp]