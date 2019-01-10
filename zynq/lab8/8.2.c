/*
 * 8.2.c
 *
 *  Created on: 20 Δεκ 2018
 *      Author: mlab
 */


#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"

#define LEDS_DEV           XPAR_LEDS_DEVICE_ID
#define BUTTONS_DEV   XPAR_BUTTONS_DEVICE_ID
#define SWITCHES_DEV  XPAR_SWITCHES_DEVICE_ID
#define LED_DELAY     10000000*5

XGpio leds_inst;         // leds gpio driver instance
XGpio buttons_inst;    // buttons gpio driver instance
XGpio switches_inst;  // switches gpio driver instance

unsigned char x, A, B, C, D, E, f0, f1, f2;

int main()
{
	int statusCodes = 0;
	uint32_t led_value = 0;
	uint32_t switches_value = 0;
	uint32_t delay = 0;
	init_platform();

	/* Initialize the GPIO driver for the leds */
	statusCodes = XGpio_Initialize(&leds_inst, LEDS_DEV);
	if (statusCodes != XST_SUCCESS) {
	xil_printf("ERROR: failed to init LEDS. Aborting\r\n");
	return XST_FAILURE;
	}

	/* Initialize the GPIO driver for the switches */
	statusCodes = XGpio_Initialize(&switches_inst, SWITCHES_DEV);
	if (statusCodes != XST_SUCCESS) {
	xil_printf("ERROR: failed to init SWITCHES. Aborting\r\n");
	return XST_FAILURE;
	}

	/* Set the direction for all led signals as outputs */
	XGpio_SetDataDirection(&leds_inst, 1, 0);

	/* Set the direction for all switches signals as inputs */
	XGpio_SetDataDirection(&switches_inst, 1, 1);

	while(1){
		switches_value = XGpio_DiscreteRead(&switches_inst,1);

		A = switches_value & 0x01;
		B = (switches_value & 0x02) >> 1;
		C = (switches_value & 0x04) >> 2;
		D = (switches_value & 0x08) >> 3;

		f0 = !( (A & B) | (B & C) | (C & D) | (D & A) );
		f1 = ( (A & B & C & D) | ((!D) & (!A)) );
		f2 = f0 | f1;

		led_value = (f2 << 2) | (f1 << 1) | f0;

		XGpio_DiscreteWrite(&leds_inst, 1, led_value);
	}
	cleanup_platform();
	return 0;
}
