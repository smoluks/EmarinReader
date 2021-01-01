 .ORG 0x00 rjmp RESET ; Reset Handler
;.ORG 0x01 rjmp EXT_INT0 ; IRQ0 Handler
;.ORG 0x02 rjmp EXT_INT1 ; IRQ1 Handler
;.ORG 0x03 rjmp EXT_INT0 ; PCINT0 Handler
;.ORG 0x04 rjmp EXT_INT1 ; PCINT1 Handler
;.ORG 0x05 rjmp EXT_INT0 ; PCINT2 Handler
;.ORG 0x06 rjmp EXT_INT1 ; WDT Handler
;.ORG 0x07 rjmp TIM2_COMPA ; Timer2 Compare Handler
;.ORG 0x08 rjmp TIM2_COMPB ; Timer2 Compare Handler
;.ORG 0x09 rjmp TIM2_OVF ; Timer2 Overflow Handler
;.ORG 0x0a rjmp TIM1_CAPT ; Timer1 Capture Handler
;.ORG 0x0B rjmp TIM1_COMPA ; Timer1 CompareA Handler
;.ORG 0x0C rjmp TIM1_COMPB ; Timer1 CompareB Handler
;.ORG 0x0D rjmp TIM1_OVF ; Timer1 Overflow Handler
;.ORG 0x0E rjmp TIM0_COMPA ; Timer1 CompareA Handler
;.ORG 0x0F rjmp TIM0_COMPB ; Timer1 CompareB Handler
.ORG 0x10 rjmp TIM0_OVF ; Timer0 Overflow Handler
;.ORG 0x11 rjmp SPI_STC ; SPI Transfer Complete Handler
;.ORG 0x12 rjmp USART_RXC ; USART RX Complete Handler
;.ORG 0x13 rjmp USART_UDRE ; UDR Empty Handler
;.ORG 0x14 rjmp USART_TXC ; USART TX Complete Handler
;.ORG 0x15 rjmp ADC ; ADC Conversion Complete Handler
;.ORG 0x16 rjmp EE_RDY ; EEPROM Ready Handler
.ORG 0x17 rjmp ANA_COMP ; Analog Comparator Handler
;.ORG 0x18 rjmp TWSI ; Two-wire Serial Interface Handler
;.ORG 0x19 rjmp SPM_RDY ; Store Program Memory Ready Handler

#define CRC_POLYNOM 0x8C
#define TOV2_MASK 0b01000000
#define OCF1A_MASK 0b00010000
#define CYFRAL_THRESHOLD 128
#define DDRB_COILOFF 0b00000000
#define DDRB_COILON 0b00000110

#define RFIDFlags r24
#define LINE_ONE_VALUE 0
#define DATA_ENABLED 1
#define TIMER0_OVERFLOW 7

#include "rammapping.asm"
#include "TIMER0_OVF.asm"
#include "ANA_COMP.asm"

RESET:
;стек
ldi r16,high(RAMEND)
out SPH,r16
ldi r16,low(RAMEND)
out SPL,r16
;константы
clr r16
ser r17
movw r2, r16
ldi r16, 1
ldi r17, TCNT0VALUE
movw r4, r16
ldi r16, CRC_POLYNOM
ldi r17, 0b00000010
movw r6, r16
ldi r16, TOV2_MASK
ldi r17, OCF1A_MASK
movw r8, r16
ldi r16, DDRB_COILOFF
ldi r17, DDRB_COILON
movw r10, r16
;порты
ldi r16, 0b00000000;
out ddrb, r16
ldi r16, 0b00000010;
out portb, r16
ldi r16, 0b00000100;
out ddrc, r16
ldi r16, 0b00000000;
out portc, r16
ldi r16, 0b00011010;
out ddrd, r16
ldi r16, 0b00010111;
out portd, r16
;T0 - 125 KHz data strobe + 2khx
sts TCCR0A, r2
ldi r16, 0b00000011 ;/64
sts TCCR0B, r16
sts TCNT0, r2
;ldi r16, 0b00000001
;sts TIMSK0, r16 
;T1 250kHz / toggle carrier generator
;ldi r16, 0b10000000
;sts TCCR1C, r16
sts TCNT1H, r2
sts TCNT1L, r2
sts OCR1AH, r2
ldi r16, 7
sts OCR1AL, r16
sts OCR1BH, r2
ldi r16, 7
sts OCR1BL, r16
ldi r16, 0b01010000 ;Toggle OC1A, OC1B on Compare Match
sts TCCR1A, r16
ldi r16, 0b00001010 ;clk/8, CTC
sts TCCR1B, r16
ldi r16, 0b10000000 
sts TCCR1C, r16
;T2 - 1us systick
sts TCCR2A, r2
ldi r16, 0b00000010
sts TCCR2B, r16 ;start t2
;UART 19200 ODD
ldi r16, 0b0000000 
sts UCSR0A, r16
ldi r16, 0b00011000
sts UCSR0B, r16
ldi r16, 0b10110110
sts UCSR0C, r16
sts UBRR0H, r2
ldi r16, 25
sts UBRR0L, r16
ldi r16, 0xAB
sts UDR0, r16
;COMP
;sts ADCSRB, r2
;ldi r16, 0b00001000
;sts ACSR, r16
;ldi r16, 0b00000011
;sts DIDR1, r16
;
rcall rfid_init
;
out ddrb, r11 ;coil on
rcall delayhalfsec
rcall delayhalfsec
rcall delayhalfsec
rcall delayhalfsec
;
;sei
;
l1:
lds r16, ACSR
sbrs r16, 5
rjmp a1
sbi portd, 4
rjmp a2
a1:
cbi portd, 4
a2:
rjmp l1

;-----cyfral-----
rcall cyfral_read
cpi r16, 2
breq l1
cpi r16, 1
brne l4
 ;
 rcall uart_sendcyfral
 ;beep
 rcall beep
 ;
 rcall delayhalfsec
 rcall delayhalfsec
 rjmp l1
;-----1wire-----
l4:
rcall onewire_readserialnumber
cpi r16, 1
brne l3
 ;--1wire present-- 
 rcall uart_send1wire
 ;beep
 rcall beep 
 ;
 rcall delayhalfsec
 rcall delayhalfsec
 rjmp l1
;-----rfid-----
l3:
lds r16, RAM_RFIDOP
cpi r16, RFIDOP_WRITE5577
brne l1_1
  ;--write-- 
  ;cli
  ;
  rcall rf5577_write
  ;
  ldi r16, 0xBD
  sts UDR0, r16
  ;
  sts RAM_RFIDOP, r2
  cbr RFIDFlags, 1 << DATA_ENABLED
  ;beep
  rcall beep
  ;
  rcall delayhalfsec
  rcall delayhalfsec
  ;
  ;sei
  rjmp l1
;--read--
l1_1: 
sbrs RFIDFlags, DATA_ENABLED;код RFID считан
rjmp l1
 ;----rfid present----
  rcall uart_sendemarin
  cbr RFIDFlags, 1 << DATA_ENABLED
  ;beep
  rcall beep
  ;
  rcall delayhalfsec
  rcall delayhalfsec
  ;
  rjmp l1

 
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

#include "1WIRE.asm"
#include "UART.asm"
#include "RFID.asm"
#include "RFID_5577.asm"
#include "cyfral.asm"

