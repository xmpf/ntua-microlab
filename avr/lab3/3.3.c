/*
 * 3.3.c
 * Created: 10/25/2018 7:15:45 PM
 * Author : Nick Maritsas
 */ 

#include <avr/io.h>

int checkBit(unsigned char byte, int offset)				//check if a bit is set or not
{
	byte = byte >> offset;									
	return (byte && 0x01);									//return the value of the bit
}

unsigned char resetBit(unsigned char byte, int offset)
{
	if (offset == 4){										//if there is no input, do nothing
		return byte;
	}
	unsigned char mask = 0x01;								//reset the bit that is about to serve its purpose
	mask = mask << offset;
	mask = !mask;
	byte = byte & mask;
	return byte;
}

int rotateLeft(unsigned char byte) 					
{
	if(byte == 0x80)										//if you are on the left edge, return 0x01 (the right edge)
	return 0x01;
	else
	return (byte << 1);										//otherwise shift left once
}

int rotateRight(unsigned char byte) 					
{
	if(byte == 0x01)										//if you are on the right edge, return 0x80 (the left edge)
	return 0x80;
	else
	return (byte >>1); 										//otherwise shift left once
}

int main(void)
{
	DDRB = 0xFF;											//PORT B : output
	DDRD = 0x00;											//PORT D : input
	
	unsigned char input, output, input_rec, flag;

	PORTB = output = 0x01;									//set PB0

	input_rec = 0x00;										//set input_rec = 0x00 cause no input has been recorded yet

	while(1)
	{
		input = PIND;										//input from portD
		input_rec = input_rec | input;						//input_rec variable holds each input given in real time
		flag = 4;											//there are only SW0,SW1,SW2,SW3 so if flag = 4 no input has been given
		for(int i = 3; i >= 0; i--)							//for loop start from 3 cause SW3 has higher priority
		{
			if(checkBit(input_rec, i))						//check if input bit is 1
			{
				flag = i;									//if it is 1 indeed, flag holds its position and then break 
				break;
			}
		}

		//(input has been given) && (input_rec bit is set) && (input bit is reset)
		//**only when push button is unpushed changes take place
		
		if(flag != 4 && checkBit(input_rec, flag) && checkBit(input, flag) == 0)
		{
			input_rec = resetBit(input_rec, flag);			//reset input_rec bit which is about to serve its purpose
			switch (flag)
			{
				case 3:	output = 0x01;						//set PB0
				break;
				case 2:	output = 0x80;						//set PB7
				break;
				case 1:	output = rotateRight(output);		
				break;
				case 0:	output = rotateLeft(output);		
				break;
			}
			PORTB = output;
		}
	}
	return 0;
}
