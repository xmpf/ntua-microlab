#include <avr/io.h>
#include <util/delay.h>

// MACRO => SET LEDS ON FOR 4sec
#define BLINK_YES do {\
	PORTA = 0xFF;\
	_delay_ms(4000);\
} while (0)

// MACRO => BLINK LEDS ON . OFF FOR 250ms EACH
#define BLINK_NO do {\
	PORTA = 0xFF;\
	_delay_ms(250);\
	PORTA = 0x00;\
	_delay_ms(250);\
} while (0)

// GLOBAL VARIABLES
unsigned char	ram[2],
				keypad[2],
				x,y;		// x: 1st key, y: 2nd key

// SCAN ROW(x)
unsigned char scan_row(int i) {
	unsigned char a = ( 1 << 3 );
	a = (a << i);
	PORTC = a;				// WE SELECT ROW BY SETTING CORRESPONDING BIT TO 1 
	_delay_ms(30);
	return PINC & 0x0F;		// WE READ THE BUTTON FROM THAT ROW, BY READING PINC
}

/* FUNCTION TO SWAP LO WITH HO BITS */
unsigned char swap_nibbles(unsigned char x) {
	return ((x & 0x0F) << 4 | (x & 0xF0) >> 4);
}

// SCAN ROWS(1..4)
void scan_keypad() {
	unsigned char i;
	
	// check row 1, 0b0001 
	i = scan_row(1);
	keypad[1] = swap_nibbles(i);
	
	// check row 2, 0b0010
	i = scan_row(2);
	keypad[1] += i;
	
	// check row 3, 0b0100
	i = scan_row(3);
	keypad[0] = swap_nibbles(i);
	
	// check row 4, 0b1000
	i = scan_row(4);
	keypad[0] += i;
}

// SCAN KEYPAD => SPINTHIRISMOS SAFE
int scan_keypad_rising_edge() {
	// CHECK KEYPAD
	scan_keypad();
	// ADD TEMPORARY VARIABLES
	unsigned char tmp_keypad[2];
	tmp_keypad[0] = keypad[0];
	tmp_keypad[1] = keypad[1];
	
	// FOR A SPECIFIC EASYAVR6 PLATFORM 0xBC WAS WORKING
	_delay_ms(0x15);
	
	// APOFYGH SPINTHIRISMOU
	scan_keypad();
	keypad[0] &= tmp_keypad[0];
	keypad[1] &= tmp_keypad[1];
	
	tmp_keypad[0] = ram[0];
	tmp_keypad[1] = ram[1];
	
	ram[0] = keypad[0];
	ram[1] = keypad[1];
	
	
	keypad[0] &= ~tmp_keypad[0];
	keypad[1] &= ~tmp_keypad[1];
	
	return (keypad[0] || keypad[1])
}

// CONVERT VALUE TO ASCII CODE
unsigned char keypad_to_ascii() {
	if (keypad[0] & 0x01)
	return '*';
	
	if (keypad[0] & 0x02)
	return '0';
	
	if (keypad[0] & 0x04)
	return '#';
	
	if (keypad[0] & 0x08)
	return 'D';
	
	if (keypad[0] & 0x10)
	return '7';
	
	if (keypad[0] & 0x20)
	return '8';
	
	if (keypad[0] & 0x40)
	return '9';
	
	if (keypad[0] & 0x80)
	return 'C';
	
	if (keypad[1] & 0x01)
	return '4';
	
	if (keypad[1] & 0x02)
	return '5';
	
	if (keypad[1] & 0x04)
	return '6';
	
	if (keypad[1] & 0x08)
	return 'B';
	
	if (keypad[1] & 0x10)
	return '1';
	
	if (keypad[1] & 0x20)
	return '2';
	
	if (keypad[1] & 0x40)
	return '3';
	
	if (keypad[1] & 0x80)
	return 'A';
	
	// Nothing Found
	return 0;
}

int main(void) {
	
	DDRA = 0xFF;        // PORTA => OUTPUT
	DDRC = 0xF0;        // KEYPAD: PORTC[7:4] => OUTPUT, PORTC[3:0] => INPUT
	
	while (1) {
	MAIN_L:
	
		ram[0] = 0;
		ram[1] = 0;
		PORTA = 0;
		
		while (1) {
			
			// GET INPUT
			if (scan_keypad_rising_edge()) {
				x = keypad_to_ascii();
				break;
			}
		}
		
		// IF INPUT NOT EQUAL WITH EXPECTED KEY ABORT
		if (x != '1') { goto B_NO; }
		
		while (1) {
			if (scan_keypad_rising_edge()) {
				y = keypad_to_ascii();
				break;
			}
		}
		
		// IF INPUT NOT EQUAL WITH EXPECTED KEY ABORT
		if (y != '5') { goto B_NO; }					
		
		// SUCCESSFUL
		BLINK_YES;
		goto MAIN_L;

B_NO:
		BLINK_NO;
		BLINK_NO;
		BLINK_NO;
		BLINK_NO;
		
		BLINK_NO;
		BLINK_NO;
		BLINK_NO;
		BLINK_NO;
	}
	return 0;
}
