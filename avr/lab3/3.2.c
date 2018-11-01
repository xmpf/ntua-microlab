/*
 * 3.2.c.c
 *
 * Created: 10/30/2018 1:43:16 PM
 * Author : Nick Maritsas
 */ 

#include <avr/io.h>

unsigned char x, A, B, C, D, E, f0, f1, f2;
int main()
{
	DDRA = 0xFF;	//output
	DDRC = 0x00;	//input
	while(1)
	{
		x = PINC & 0x1F;
		A = x & 0x01;
		B = (x & 0x02) >> 1;
		C = (x & 0x04) >> 2;
		D = (x & 0x08) >> 3;
		E = (x & 0x10) >> 4;
		f0 =  !( (A & B) | (B & C) | (C & D) | (D & E) );
		f1 = ( (A & B & C & D) | ((!D) & (!E)) ) ;
		f2 = f0 | f1;
		f2 = f2 << 2;
		f1 = f1 << 1;
		PORTA = (f2 | f1 | f0) & 0x7;
	};
	return 0;
}