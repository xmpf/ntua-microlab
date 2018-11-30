write_2_nibbles:
	push r24				; ??????? ?? 4 MSB
	in r25, PIND			; ??????????? ?? 4 LSB ??? ?? ?????????????
	andi r25, 0x0f			; ??? ?? ??? ????????? ??? ????? ??????????? ?????????
	andi r24, 0xf0			; ????????????? ?? 4 MSB ???
	add r24, r25			; ???????????? ?? ?? ???????????? 4 LSB
	out PORTD, r24			; ??? ???????? ???? ?????
	sbi PORTD, PD3			; ????????????? ?????? ?nable ???? ????????? PD3
	cbi PORTD, PD3			; PD3=1 ??? ???? PD3=0
	pop r24					; ??????? ?? 4 LSB. ????????? ?? byte.
	swap r24				; ????????????? ?? 4 MSB ?? ?? 4 LSB
	andi r24, 0xf0			; ??? ?? ??? ????? ???? ?????????????
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3			; ???? ?????? ?nable
	cbi PORTD, PD3
	ret

lcd_data:
	sbi PORTD, PD2			; ??????? ??? ?????????? ????????? (PD2=1)
	rcall write_2_nibbles	; ???????? ??? byte
	ldi r24, 43				; ??????? 43?sec ????? ?? ??????????? ? ????
	ldi r25, 0				; ??? ????????? ??? ??? ??????? ??? lcd
	rcall wait_usec
	ret

lcd_command:
	cbi PORTD, PD2			; ??????? ??? ?????????? ??????? (PD2=0)
	rcall write_2_nibbles	; ???????? ??? ??????? ??? ??????? 39?sec
	ldi r24, 39				; ??? ??? ?????????? ??? ????????? ??? ??? ??? ??????? ??? lcd.
	ldi r25, 0				; ???.: ???????? ??? ???????, ?? clear display ??? return home,
	rcall wait_usec			; ??? ???????? ????????? ?????????? ??????? ????????.
	ret

lcd_init:
	ldi r24, 40				; ???? ? ???????? ??? lcd ????????????? ??
	ldi r25, 0				; ????? ??????? ??? ???? ??? ????????????.
	rcall wait_msec			; ??????? 40 msec ????? ???? ?? ???????????.
	ldi r24, 0x30			; ?????? ????????? ?? 8 bit mode
	out PORTD, r24			; ?????? ??? ???????? ?? ??????? ???????
	sbi PORTD, PD3			; ??? ?? ?????????? ??????? ??? ???????
	cbi PORTD, PD3			; ??? ??????, ? ?????? ???????????? ??? ?????
	ldi r24, 39
	ldi r25, 0				; ??? ? ???????? ??? ?????? ????????? ?? 8-bit mode
	rcall wait_usec			; ??? ?? ?????? ??????, ???? ?? ? ???????? ???? ??????????
							; ??????? 4 bit ?? ??????? ?? ?????????? 8 bit
	ldi r24, 0x30
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24, 39
	ldi r25, 0
	rcall wait_usec
	ldi r24, 0x20			; ?????? ?? 4-bit mode
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24, 39
	ldi r25, 0
	rcall wait_usec
	ldi r24, 0x28			; ??????? ?????????? ???????? 5x8 ????????
	rcall lcd_command		; ??? ???????? ??? ??????? ???? ?????
	ldi r24, 0x0e			; ???????????? ??? ??????, ???????? ??? ???????
	rcall lcd_command
	ldi r24, 0x01			; ?????????? ??? ??????
	rcall lcd_command
	ldi r24, low(1530)
	ldi r25, high(1530)
	rcall wait_usec
	ldi r24, 0x06			; ???????????? ????????? ??????? ???? 1 ??? ??????????
	rcall lcd_command		; ??? ????? ???????????? ???? ??????? ??????????? ???
							; ?????????????? ??? ????????? ????????? ??? ??????
	ret
