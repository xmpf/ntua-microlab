/*
; Author: Michalis Papadopoullos
; Exercise: 7.2 (ii)
*/
#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

#define USART_BAUDRATE 9600
#define BAUD_PRESCALE (((F_CPU / (USART_BAUDRATE * 16UL))) - 1)

void USART_init(void)
{	
	UCSRA = 0;
	UCSRB = (1<<RXEN) | (1<<TXEN);
	UBRRH = 0;
	UBRRL = 51;
	UCSRC = (1 << URSEL) | (3 << UCSZ0);
}

unsigned char USART_receive(void)
{	
	while((UCSRA & 0x80) == 0 ){}
	return UDR;	
}

void USART_transmit(char input)
{
	while((UCSRA & 0x20) == 0){}
	UDR = input;
}

void ADC_init ()
{
	ADMUX = (1 << REFS0);
	ADCSRA = (1 << ADEN) | (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2);
}

int main (void)
{
	/*
	   ADCSRA [ADEN|ADSC|ADATE|ADIF|ADIE|*|*|*]
	*/
	
	// Left Adjust Result: No
	// ADLAR = 0;
	
	// Initialize USART
	USART_init();

	// Initialize ADC
	ADC_init();

	while (1) {
        // To start ADC conversion ADSC=1
		ADCSRA = ADCSRA | 0x40;

		while ( !(ADCSRA & 0x40) ) { /* WAIT UNTIL CONVERSION IS DONE */ }
		
		_delay_ms(100);
	
		int res = ADC;
		USART_transmit ( (res * 5) / 1024 + '0' );
		
		int dig = (res % 10) + '0';
		
		USART_transmit ( ',' );
		USART_transmit ( ( (res * 50) / 1024) % 10 + '0' );
		
		
		USART_transmit('\n');
		
		_delay_ms(100);
		
    }
}
