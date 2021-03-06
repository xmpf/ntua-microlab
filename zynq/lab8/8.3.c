{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil Courier New;}{\f1\fswiss\fcharset161{\*\fname Arial;}Arial Greek;}}
{\colortbl ;\red127\green0\blue85;\red0\green0\blue0;\red42\green0\blue255;\red0\green80\blue50;\red63\green127\blue95;}
{\*\generator Msftedit 5.41.15.1515;}\viewkind4\uc1\pard\cf1\lang1032\b\f0\fs20 #include\cf2\b0  \cf3 <stdio.h>\cf0\par
\cf1\b #include\cf2\b0  \cf3 "platform.h"\cf0\par
\cf1\b #include\cf2\b0  \cf3 "xil_printf.h"\cf0\par
\cf1\b #include\cf2\b0  \cf3 "xparameters.h"\cf0\par
\cf1\b #include\cf2\b0  \cf3 "xgpio.h"\cf0\par
\par
\cf1\b #define\cf2\b0  LEDS_DEV XPAR_LEDS_DEVICE_ID\cf0\par
\cf1\b #define\cf2\b0  BUTTONS_DEV XPAR_BUTTONS_DEVICE_ID\cf0\par
\cf1\b #define\cf2\b0  SWITCHES_DEV XPAR_SWITCHES_DEVICE_ID\cf0\par
\par
\cf1\b #define\cf2\b0  LED_DELAY 10000000*5\cf0\par
\par
\cf4 XGpio\cf2  leds_inst; \cf5 // \ul leds\ulnone  \ul gpio\ulnone  driver instance\cf0\par
\cf4 XGpio\cf2  buttons_inst; \cf5 // buttons \ul gpio\ulnone  driver instance\cf0\par
\cf4 XGpio\cf2  switches_inst; \cf5 // switches \ul gpio\ulnone  driver instance\cf0\par
\par
\cf1\b int\cf2\b0  \b checkBit\b0 (\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  byte, \cf1\b int\cf2\b0  offset)\cf0\par
\cf5 //check if a bit is set or not\cf0\par
\cf2\{\cf0\par
\cf2\tab byte = byte >> offset;\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf1\b return\cf2\b0  (byte && 0x01);\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //return the value of the bit\cf0\par
\cf2\}\cf0\par
\par
\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  \b resetBit\b0 (\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  byte, \cf1\b int\cf2\b0  offset)\cf0\par
\cf2\{\cf0\par
\cf2\tab\cf1\b if\cf2\b0  (offset == 4)\{\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //if there is no input, do nothing\cf0\par
\cf2\tab\tab\cf1\b return\cf2\b0  byte;\cf0\par
\cf2\tab\}\cf0\par
\cf2\tab\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  mask = 0x01;\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //reset the bit that is about to serve its purpose\cf0\par
\cf2\tab mask = mask << offset;\cf0\par
\cf2\tab mask = !mask;\cf0\par
\cf2\tab byte = byte & mask;\cf0\par
\cf2\tab\cf1\b return\cf2\b0  byte;\cf0\par
\cf2\}\cf0\par
\par
\cf1\b int\cf2\b0  \b rotateLeft\b0 (\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  byte)\cf0\par
\cf2\{\cf0\par
\cf2\tab\cf1\b if\cf2\b0 (byte == 0x08)\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //if you are on the left edge, return 0x01 (the right edge)\cf0\par
\cf2\tab\cf1\b return\cf2\b0  0x01;\cf0\par
\cf2\tab\cf1\b else\cf0\b0\par
\cf2\tab\cf1\b return\cf2\b0  (byte << 1);\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //otherwise shift left once\cf0\par
\cf2\}\cf0\par
\par
\cf1\b int\cf2\b0  \b rotateRight\b0 (\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  byte)\cf0\par
\cf2\{\cf0\par
\cf2\tab\cf1\b if\cf2\b0 (byte == 0x01)\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //if you are on the right edge, return 0x80 (the left edge)\cf0\par
\cf2\tab\cf1\b return\cf2\b0  0x08;\cf0\par
\cf2\tab\cf1\b else\cf0\b0\par
\cf2\tab\cf1\b return\cf2\b0  (byte >>1); \tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //otherwise shift left once\cf0\par
\cf2\}\cf0\par
\par
\par
\cf1\b int\cf2\b0  \b main\b0 ()\cf0\par
\cf2\{\cf0\par
\cf2  \tab\cf1\b int\cf2\b0  statusCodes = 0;\cf0\par
\cf2  \tab\cf4 uint32_t\cf2  led_value = 0;\cf0\par
\cf2  \tab\cf4 uint32_t\cf2  buttons_value = 0;\cf0\par
\par
\cf2  \tab\cf1\b int\cf2\b0  i;\cf0\par
\cf2  \tab\cf1\b unsigned\cf2\b0  \cf1\b char\cf2\b0  input, output, input_rec, flag;\cf0\par
\par
\cf2  \tab input_rec = 0x00;\cf0\par
\par
\cf2  \tab init_platform();\cf0\par
\par
\cf2\tab\cf5 /* Initialize the GPIO driver for the \ul leds\ulnone  */\cf0\par
\cf2\tab statusCodes = XGpio_Initialize(&leds_inst, LEDS_DEV);\cf0\par
\cf2\tab\cf1\b if\cf2\b0  (statusCodes != XST_SUCCESS) \{\cf0\par
\cf2  \tab\tab xil_printf(\cf3 "ERROR: failed to \ul init\ulnone  LEDS. Aborting\\r\\n"\cf2 );\cf0\par
\cf2  \tab\tab\cf1\b return\cf2\b0  XST_FAILURE;\cf0\par
\cf2  \tab\}\cf0\par
\par
\cf2\tab\cf5 /* Initialize the GPIO driver for the buttons */\cf0\par
\cf2\tab statusCodes = XGpio_Initialize(&buttons_inst, BUTTONS_DEV);\cf0\par
\cf2  \tab\cf1\b if\cf2\b0  (statusCodes != XST_SUCCESS) \{\cf0\par
\cf2  \tab\tab xil_printf(\cf3 "ERROR: failed to \ul init\ulnone  BUTTONS. Aborting\\r\\n"\cf2 );\cf0\par
\cf2  \tab\tab\cf1\b return\cf2\b0  XST_FAILURE;\cf0\par
\cf2  \tab\}\cf0\par
\par
\par
\cf2\tab\cf5 /* Set the direction for all led signals as outputs */\cf0\par
\cf2  \tab XGpio_SetDataDirection(&leds_inst, 1, 0);\cf0\par
\par
\cf2  \tab\cf5 /* Set the direction for all buttons signals as inputs */\cf0\par
\cf2  \tab XGpio_SetDataDirection(&buttons_inst, 1, 1);\cf0\par
\par
\cf2  \tab XGpio_DiscreteWrite(&leds_inst, 1, led_value = 0x01);\cf0\par
\par
\cf2  \tab\cf1\b while\cf2\b0 (1) \{\cf0\par
\par
\cf2\tab\tab buttons_value = XGpio_DiscreteRead(&buttons_inst, 1);\cf0\par
\par
\cf2\tab\tab input = buttons_value;\cf0\par
\par
\cf2\tab\tab\cf5 //input_rec = buttons_value;\cf0\par
\par
\cf2\tab\tab input_rec = input_rec | input;\cf0\par
\par
\cf2\tab\tab flag = 4;\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //there are only SW0,SW1,SW2,SW3 so if flag = 4 no input has been given\cf0\par
\cf2\tab\tab\cf1\b for\cf2\b0 (i = 3; i >= 0; i--)\tab\tab\tab\tab\tab\tab\tab\cf5 //for loop start from 3 cause SW3 has higher priority\cf0\par
\cf2\tab\tab\cf5 //for(i=0; i<=3; i++)\cf0\par
\cf2\tab\tab\{\cf0\par
\cf2\tab\tab\tab\cf1\b if\cf2\b0 (checkBit(input_rec, i))\tab\tab\tab\tab\tab\tab\cf5 //check if input bit is 1\cf0\par
\cf2\tab\tab\tab\{\cf0\par
\cf2\tab\tab\tab\tab flag = i;\tab\tab\tab\tab\tab\tab\tab\tab\tab\cf5 //if it is 1 indeed, flag holds its position and then break\cf0\par
\cf2\tab\tab\tab\tab\cf1\b break\cf2\b0 ;\cf0\par
\cf2\tab\tab\tab\}\cf0\par
\cf2\tab\tab\}\cf0\par
\par
\cf2\tab\tab\cf5 //(input has been given) && (input_rec bit is set) && (input bit is reset)\cf0\par
\cf2\tab\tab\cf5 //**only when push button is \ul unpushed\ulnone  changes take place\cf0\par
\par
\cf2\tab\tab\cf1\b if\cf2\b0 (flag != 4 && checkBit(input_rec, flag) && checkBit(input, flag) == 0)\cf0\par
\cf2\tab\tab\{\cf0\par
\cf2\tab\tab\tab input_rec = resetBit(input_rec, flag);\tab\tab\tab\cf5 //reset input_rec bit which is about to serve its purpose\cf0\par
\cf2\tab\tab\tab\cf1\b switch\cf2\b0  (flag)\cf0\par
\cf2\tab\tab\tab\{\cf0\par
\cf2\tab\tab\tab\tab\cf1\b case\cf2\b0  3:\tab output = 0x01;\tab\tab\tab\tab\tab\tab\cf5 //set PB0\cf0\par
\cf2\tab\tab\tab\tab\tab\tab\cf1\b break\cf2\b0 ;\cf0\par
\cf2\tab\tab\tab\tab\cf1\b case\cf2\b0  2:\tab output = 0x08;\tab\tab\tab\tab\tab\tab\cf5 //set PB7\cf0\par
\cf2\tab\tab\tab\tab\tab\tab\cf1\b break\cf2\b0 ;\cf0\par
\cf2\tab\tab\tab\tab\cf1\b case\cf2\b0  1:\tab output = rotateRight(output);\cf0\par
\cf2\tab\tab\tab\tab\tab\tab\cf1\b break\cf2\b0 ;\cf0\par
\cf2\tab\tab\tab\tab\cf1\b case\cf2\b0  0:\tab output = rotateLeft(output);\cf0\par
\cf2\tab\tab\tab\tab\tab\tab\cf1\b break\cf2\b0 ;\cf0\par
\cf2\tab\tab\tab\}\cf0\par
\cf2\tab\tab\tab led_value = output;\cf0\par
\cf2\tab\tab\tab XGpio_DiscreteWrite(&leds_inst, 1, led_value );\cf0\par
\par
\cf2\tab\tab\}\cf0\par
\par
\cf2  \tab\}\cf0\par
\cf2  \tab cleanup_platform();\cf0\par
\cf2  \tab\cf1\b return\cf2\b0  0;\cf0\par
\cf2\}\cf0\par
\par
\f1\par
}
 