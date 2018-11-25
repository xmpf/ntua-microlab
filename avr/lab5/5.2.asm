; Functionality:
;  - Read a 2 digit and signed hex number from keyboard
;  - Convert number to 3 digit Dec number
;  - Output number to the LED screen
;  - Repeat


			; ---- ���� �������� ���������
.DSEG
_tmp_: .byte 2
			; ---- ����� �������� ���������

.CSEG
.include "m16def.inc"

.def temp=r20

.org 0x00
rjmp init

.macro Bit_to_Ascii
	cpi r24,10
	brge let	;if it's 0-9 add 30h else add 37h
	mov r25,0x30
	add r24,r25
	rjmp exit
let:
	mov r25,0x37
	add r24,r25
exit:
.endm

;_____________________________________________________________ MAIN_____________________________________________________________________

init:
	clr temp

	ldi r24, low(RAMEND)
	out SPL, r24
	
	ldi r24, high(RAMEND)
	out SPH, r24

	ser r24
	out DDRD, r24
out DDRA,r24					; r25: [A|3|2|1]|[B|6|5|4]
								; r24: [C|9|8|7]|[D|#|0|*]
	ldi temp,0xf0 	; r18 = 1111 0000
	out DDRC,temp 	; PORTC[7:4] OUTPUT, PORTC[3:0] INPUT

	rcall lcd_init			;initiallize lcd values

	clr r25
start:
	ldi r24,20
	rcall scan_keypad_rising_edge		;r17-18 has most significant hex number bit, r24-25 has least significant number bit
	sbiw r24,0
	breq start

	movw r16,r24

	ldi r24 ,0x01			;reset screen for new numbers
	rcall lcd_command
	
	ldi r24 ,low(1530)
	ldi r25 ,high(1530)
	rcall wait_usec

digit2:
	ldi r24,20
	rcall scan_keypad_rising_edge
	sbiw r24,0
	breq digit2

	rcall keypad_to_num				;lsn (least significant number) in hex number in r19 and msn in r24
	mov r19,r24
	movw r24,r16
	
	rcall keypad_to_num
	mov temp,r24						;temp has 2 digit full number
	swap temp
	add temp,r19
out PORTA,temp

	bit_to_ascii						;gets r24 and converts it to ascii code
	rcall lcd_data						;print msn
	
	mov r24,r19
	bit_to_ascii
	rcall lcd_data						;print lsn

	ldi r24,'='
	rcall lcd_data
	
	sbrc temp,7							;if last bit is 1 then number is negative
	ldi r24,'-'
	sbrs temp,7
	ldi r24,'+'	
	rcall lcd_data						;operation print
	
	sbrc temp,7							;get temp to its correct form
	neg temp
	rcall print_dec
	rjmp start



print_dec:
	ser r16
	subi temp,100		;if num >100 print 1 and then continue with printing next digits
	brcs below			; else add 100 back and continue with next digits
	ldi r24,'1'
	rcall lcd_data		;print ekatodades
	rjmp noadd

below:
	ldi r24,100
	add temp,r24

noadd:
	inc r16
	subi temp,10
	brcc noadd

	ldi r24,10
	add temp,r24		;reset last num

	mov r24,r16			;print decades
	bit_to_ascii
	rcall lcd_data

	mov r24,temp		;print monades
	bit_to_ascii
	rcall lcd_data
	ret



;_______________________________________________________ LCD_routines_____________________________________________________________________________

write_2_nibbles:
	push r24			; ������� �� 4 MSB
	in r25 ,PIND		; ����������� �� 4 LSB ��� �� �������������
	andi r25 ,0x0f		; ��� �� ��� ��������� ��� ����� ����������� ���������
	andi r24 ,0xf0		; ������������� �� 4 MSB ���
	add r24 ,r25		; ������������ �� �� ������������ 4 LSB
	out PORTD ,r24		; ��� �������� ���� �����
	sbi PORTD ,PD3		; ������������� ������ Enable ���� ��������� PD3
	cbi PORTD ,PD3		; PD3=1 ��� ���� PD3=0
	pop r24				; ������� �� 4 LSB. ��������� �� byte.
	swap r24			; ������������� �� 4 MSB �� �� 4 LSB
	andi r24 ,0xf0		; ��� �� ��� ����� ���� �������������
	add r24 ,r25
	out PORTD ,r24
	sbi PORTD ,PD3		; ���� ������ Enable
	cbi PORTD ,PD3
	ret

lcd_data:
	sbi PORTD ,PD2		; ������� ��� ���������� ��������� (PD2=1)
	rcall write_2_nibbles ; �������� ��� byte

	ldi r24 ,43			; ������� 43�sec ����� �� ����������� � ����
	ldi r25 ,0			; ��� ��������� ��� ��� ������� ��� lcd
	rcall wait_usec

	ret

lcd_command:
	cbi PORTD ,PD2			; ������� ��� ���������� ������� (PD2=0)
	rcall write_2_nibbles	; �������� ��� ������� ��� ������� 39�sec
	
	ldi r24 ,39				; ��� ��� ���������� ��� ��������� ��� ��� ��� ������� ��� lcd.
	ldi r25 ,0				; ���.: �������� ��� �������, �� clear display ��� return home,
	rcall wait_usec			; ��� �������� ��������� ���������� ������� ��������.
	ret

lcd_init:
	ldi r24 ,40				; ���� � �������� ��� lcd ������������� ��
	ldi r25 ,0				; ����� ������� ��� ���� ��� ������������.
	rcall wait_msec			; ������� 40 msec ����� ���� �� �����������.
	ldi r24 ,0x30			; ������ ��������� �� 8 bit mode
	out PORTD ,r24			; ������ ��� �������� �� ������� �������
	sbi PORTD ,PD3			; ��� �� ���������� ������� ��� �������
	cbi PORTD ,PD3			; ��� ������, � ������ ������������ ��� �����
	ldi r24 ,39
	ldi r25 ,0				; ��� � �������� ��� ������ ��������� �� 8-bit mode
	rcall wait_usec			; ��� �� ������ ������, ���� �� � �������� ���� ����������
							; ������� 4 bit �� ������� �� ���������� 8 bit
	ldi r24 ,0x30
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec

	ldi r24 ,0x20			; ������ �� 4-bit mode
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec

	ldi r24 ,0x28			; ������� ���������� �������� 5x8 ��������
	rcall lcd_command		; ��� �������� ��� ������� ���� �����
	
	ldi r24 ,0x0c			; ������������ ��� ������, �������� ��� �������
	rcall lcd_command
	
	ldi r24 ,0x01			; ���������� ��� ������
	rcall lcd_command
	
	ldi r24 ,low(1530)
	ldi r25 ,high(1530)
	rcall wait_usec
	
	ldi r24 ,0x06			; ������������ ��������� ������� ���� 1 ��� ����������
	rcall lcd_command		; ��� ����� ������������ ���� ������� ����������� ���
							; �������������� ��� ��������� ��������� ��� ������
	ret



;_______________________________________________________ Keypad_Routines ____________________________________________________________________________________


scan_row:
	ldi r25 , 0x08		; ������������ �� �0000 1000�
back_: 
	lsl r25			; �������� �������� ��� �1� ����� ������
	dec r24			; ���� ����� � ������� ��� �������
	brne back_
	out PORTC , r25 ; � ���������� ������ ������� ��� ������ �1�
	nop
	nop				; ����������� ��� �� �������� �� ����� � ������ ����������
	in r24 , PINC	; ����������� �� ������ (������) ��� ��������� ��� ����� ���������
	andi r24 ,0x0f	; ������������� �� 4 LSB ���� �� �1� �������� ��� ����� ���������
	ret				; �� ���������.


scan_keypad:
	ldi r24 , 0x01		; ������ ��� ����� ������ ��� �������������
	rcall scan_row
	swap r24			; ���������� �� ����������
	mov r27 , r24		; ��� 4 msb ��� r27
	ldi r24 ,0x02		; ������ �� ������� ������ ��� �������������
	rcall scan_row
	add r27 , r24		; ���������� �� ���������� ��� 4 lsb ��� r27
	ldi r24 , 0x03		; ������ ��� ����� ������ ��� �������������
	rcall scan_row
	swap r24			; ���������� �� ����������
	mov r26 , r24		; ��� 4 msb ��� r26
	ldi r24 ,0x04		; ������ ��� ������� ������ ��� �������������
	rcall scan_row
	add r26 , r24		; ���������� �� ���������� ��� 4 lsb ��� r26
	movw r24 , r26		; �������� �� ���������� ����� ����������� r25:r24
	ret



scan_keypad_rising_edge:
	mov r22 ,r24		; ���������� �� ����� ������������ ���� r22
	rcall scan_keypad	; ������ �� ������������ ��� ���������� ���������
	push r24			; ��� ���������� �� ����������
	push r25
	mov r24 ,r22		; ����������� r22 ms (������� ����� 10-20 msec ��� ����������� ��� ���
	ldi r25 ,0			; ������������ ��� ������������� � ������������� ������������)
	rcall wait_msec
	rcall scan_keypad	; ������ �� ������������ ���� ��� ��������
	pop r23				; ��� ������� ���������� �����������
	pop r22
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_) ; ������� ��� ��������� ��� ��������� ����
	ldi r27 ,high(_tmp_) ; ����������� ����� ��� �������� ����� r27:r26
	ld r23 ,X+
	ld r22 ,X
	st X ,r24			; ���������� ��� RAM �� ��� ���������
	st -X ,r25			; ��� ���������
	com r23
	com r22				; ���� ���� ��������� ��� ����� ������ �������
	and r24 ,r22
	and r25 ,r23
	ret


keypad_to_num:	; ������ �1� ���� ������ ��� ���������� r26 ��������
	movw r26 ,r24	; �� �������� ������� ��� ��������
	ldi r24 ,0x0E	;originally was '*'
	sbrc r26 ,0
	ret
	ldi r24 ,0
	sbrc r26 ,1
	ret
	ldi r24 ,0x0F	;originally was '#'
	sbrc r26 ,2
	ret
	ldi r24 ,0x0D
	sbrc r26 ,3		; �� ��� ����� �1������������ ��� ret, ������ (�� ����� �1�)
	ret				; ���������� �� ��� ���������� r24 ��� ASCII ���� ��� D.
	ldi r24 ,7
	sbrc r26 ,4
	ret
	ldi r24 ,8
	sbrc r26 ,5
	ret
	ldi r24 ,9
	sbrc r26 ,6
	ret
	ldi r24 ,0x0C
	sbrc r26 ,7
	ret
	ldi r24 ,4	; ������ �1� ���� ������ ��� ���������� r27 ��������
	sbrc r27 ,0		; �� �������� ������� ��� ��������
	ret
	ldi r24 ,5
	sbrc r27 ,1
	ret
	ldi r24 ,6
	sbrc r27 ,2
	ret
	ldi r24 ,0x0B
	sbrc r27 ,3
	ret
	ldi r24 ,1
	sbrc r27 ,4
	ret
	ldi r24 ,2
	sbrc r27 ,5
	ret
	ldi r24 ,3
	sbrc r27 ,6
	ret
	ldi r24 ,0x0A
	sbrc r27 ,7
	ret
	clr r24
	ret


;_____________________ Delay_routines______________________
wait_msec:
	push r24				; 2 ������ (0.250 �sec)
	push r25				; 2 ������
	ldi r24 , low(998)		; ������� ��� �����. r25:r24 �� 998 (1 ������ - 0.125 �sec)
	ldi r25 , high(998)		; 1 ������ (0.125 �sec)
	rcall wait_usec			; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec
	pop r25					; 2 ������ (0.250 �sec)
	pop r24					; 2 ������
	sbiw r24 , 1			; 2 ������
	brne wait_msec			; 1 � 2 ������ (0.125 � 0.250 �sec)
	ret						; 4 ������ (0.500 �sec)

wait_usec:
	sbiw r24 ,1			; 2 ������ (0.250 �sec)
	nop					; 1 ������ (0.125 �sec)
	nop					; 1 ������ (0.125 �sec)
	nop					; 1 ������ (0.125 �sec)
	nop					; 1 ������ (0.125 �sec)
	brne wait_usec		; 1 � 2 ������ (0.125 � 0.250 �sec)
	ret					; 4 ������ (0.500 �sec)
