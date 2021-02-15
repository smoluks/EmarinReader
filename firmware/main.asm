.ORG 0x00 rjmp RESET ; Reset Handler
;.ORG 0x01 rjmp EXT_INT0 ; IRQ0 Handler
;.ORG 0x02 rjmp EXT_INT1 ; IRQ1 Handler
;.ORG 0x03 rjmp TIM2_COMP ; Timer2 Compare Handler
;.ORG 0x04 rjmp TIM2_OVF ; Timer2 Overflow Handler
;.ORG 0x05 rjmp TIM1_CAPT ; Timer1 Capture Handler
;.ORG 0x06 rjmp TIM1_COMPA ; Timer1 CompareA Handler
;.ORG 0x07 rjmp TIM1_COMPB ; Timer1 CompareB Handler
;.ORG 0x08 rjmp TIM1_OVF ; Timer1 Overflow Handler
.ORG 0x09 rjmp TIM0_OVF ; Timer0 Overflow Handler
;.ORG 0x0a rjmp SPI_STC ; SPI Transfer Complete Handler
.ORG 0x0b rjmp USART_RXC ; USART RX Complete Handler
.ORG 0x0c rjmp USART_UDRE ; UDR Empty Handler
;.ORG 0x0d rjmp USART_TXC ; USART TX Complete Handler
;.ORG 0x0e rjmp ADC ; ADC Conversion Complete Handler
;.ORG 0x0f rjmp EE_RDY ; EEPROM Ready Handler
.ORG 0x10 rjmp ANA_COMP ; Analog Comparator Handler
;.ORG 0x11 rjmp TWSI ; Two-wire Serial Interface Handler
;.ORG 0x12 rjmp SPM_RDY ; Store Program Memory Ready Handler

RESET:
;stack
ldi r16,high(RAMEND)
out SPH,r16
ldi r16,low(RAMEND)
out SPL,r16
;const
#include "rammapping.asm"
;GPIO
ldi r16, 0b00000000;
out ddrb, r16
ldi r16, 0b00000110;
out portb, r16
ldi r16, 0b00111001;
out ddrc, r16
ldi r16, 0b00111001;
out portc, r16
ldi r16, 0b00001010;
out ddrd, r16
ldi r16, 0b00000011;
out portd, r16
;----- T0 - 125 KHz data strobe for manchester-----
;ldi r16, 0b00000011 ;/64
;out TCCR0, r16
out TCNT0, CONST_0
ldi r16, 0b00000001
out TIMSK, r16
;----- T1 250kHz / toggle carrier generator -----
out TCNT1H, CONST_0
out TCNT1L, CONST_0
;
out OCR1AH, CONST_0
ldi r16, 3
out OCR1AL, r16
;
out OCR1BH, CONST_0
ldi r16, 3
out OCR1BL, r16
;
ldi r16, 0b01010000 ;Toggle OC1A, OC1B on Compare Match
out TCCR1A, r16
ldi r16, 0b00001010 ;clk/8, CTC
out TCCR1B, r16
;----- T2 - 1us systick -----
ldi r16, 0b00000010
out TCCR2, r16 ;start t2
;----- UART 500000 ODD -----
;ldi r16, 0b00000010
out UCSRA, CONST_0
ldi r16, 0b10011000
out UCSRB, r16
ldi r16, 0b10110110
out UCSRC, r16
out UBRRH, CONST_0
;ldi r16, 25
out UBRRL, CONST_0
ldi r16, END_RAM
out UDR, r16
;----- Comp -----
ldi r16, 0b00011000
out ACSR, r16
out SFIOR, CONST_0
;
;rcall rfid_init
rcall uart_init
;
rcall delayhalfsec
cbi portc, 4
cbi portc, 3
cbi portc, 0
;
sei
;
l1:
;-----cyfral-----
;rcall cyfral_read
;cpi r16, 2
;breq l1
;cpi r16, 1
;brne l4
 ;
 ;rcall uart_sendcyfral
 ;beep
 ;rcall beep
 ;
 ;rcall delayhalfsec
 ;rcall delayhalfsec
 ;rjmp l1
;-----1wire-----
;l4:
;rcall onewire_readserialnumber
;cpi r16, 1
;brne l3
 ;--1wire present-- 
 ;rcall uart_send1wire
 ;beep
 ;rcall beep 
 ;
 ;rcall delayhalfsec
 ;rcall delayhalfsec
 ;rjmp l1
;-----rfid-----
sbrc RFIDFLAGS, RFIDFLAGS_DATA_READY
 rcall send_rfid
sbrc RFIDFLAGS, RFIDFLAGS_READ
 rcall rfid_read
sbrc RFIDFLAGS, RFIDFLAGS_LOGIN_4305
 rcall Login_4305
sbrc RFIDFLAGS, RFIDFLAGS_WRITE_4305
 rcall Write_4305
;
rjmp l1

send_rfid:
cbr RFIDFLAGS, 1 << RFIDFLAGS_DATA_READY
cbi portc, 4
;
rcall uart_sendemarin
;rcall beep
ret

beep:
sbi portd, 3
rcall delay200ms 
cbi portd, 3
ret

delay200ms:
push r18
push r17
push r16
;
ldi r18, 8
d9:
clr r17
d10:
 clr r16
 d11:
 dec r16
 brne d11
dec r17
brne d10
dec r18
brne d9
;
pop r16
pop r17
pop r18
ret

delayhalfsec:
push r18
push r17
push r16
;
ldi r18, 20
d8:
clr r17
d7:
 clr r16
 d6:
 dec r16
 brne d6
dec r17
brne d7
dec r18
brne d8
;
pop r16
pop r17
pop r18
ret

#include "rfid_read.asm"
#include "rfid4305.asm"
;#include "1wire.asm"
#include "uart.asm"
;#include "RFID_5577.asm"
;#include "cyfral.asm"
