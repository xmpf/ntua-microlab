; Author: Michalis Papadopoullos

.include "m16def.inc"
;----------------------------------
.def intrc=r15                     ; register alias
;----------------------------------
.org 0x0                           ; reset routine
rjmp reset                         ;
;----------------------------------
.org 0x2                           ;
rjmp ISR0                          ; Interrupt ISR0 routine
;----------------------------------
reset:
    ; INIT STACK
    ldi r24,low(RAMEND)
    ldi r25,high(RAMEND)
    out SPL,r24
    out SPH,r25

    ; level of INTR activation => anerxomeni akmh
    ldi r24,(1 << ISC01) | (1 << ISC00)
    out MCUCR,r24
    ; enable INT0 external INTR
    ldi r24,(1 << INT0)
    out GICR,r24

    ; PORTA => OUTPUT
    ; PORTB => OUTPUT
    ser r26
    out DDRA,r26
    out DDRB,r26

    ; PORTD => INPUT
    clr r26
    out DDRD,r26

    ; Interrupt counter = 0
    clr intrc

MAIN_LOOP:
    ; enable interrupts
    sei
    
    ; output current value (starting from 0)
    out PORTA,r26
    
    ; INIT DELAY => 200 msec
    ldi r24 , low(200)
    ldi r25 , high(200)
    
    ; DELAY => 200 msec
    rcall wait_msec
    
    ; increment counter
    inc r26
    rjmp MAIN_LOOP
;----------------------------------
ISR0:                               ; Interrupt Service Routine ISR0
    push r26                        ; store registers in stack
    in r26,SREG                     ; store SREG
    push r26

loop1:
    ; apofygh spinthirismou
    ldi r24,(1 << INTF0)
    out GIFR,r24
    
    ; wait 5msec
    ldi r24,0x05
    ldi r25,0x00
    rcall wait_msec
    
    ; check GIFR if changed
    in r24,GIFR
    sbrc r24,6
    ; if GIFR[7th bit] = 1 then goto loop1, else skip following instruction
    rjmp loop1

    ; an to plhktro PD0 den einai patimeno => return
    sbis PIND,0
    rjmp ISR0_EXIT

    inc intrc
    out PORTB,intrc
    ;rcall wait_msec ; WAIT=0.2 sec

ISR0_EXIT:
    pop r26          ; restore kataxoritwn poy eginan store
    out SREG, r26       
    pop r26
    reti             ; return
;----------------------------------
wait_usec:
    sbiw r24,1
    nop
    nop
    nop
    nop
    brne wait_usec
    ret
;----------------------------------
wait_msec:
    push r24
    push r25
    ldi r24,low(998)
    ldi r25,high(998)
    rcall wait_usec
    pop r25
    pop r24
    sbiw r24,1
    brne wait_msec
    ret