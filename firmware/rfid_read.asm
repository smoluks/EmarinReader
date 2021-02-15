rfid_read:
cbr RFIDFLAGS, 1 << RFIDFLAGS_READ
sbi portc, 4
;
clr RFIDFLAGS
sts RFID_CURRENT_BIT_COUNT, CONST_0
lds r16, UART_RX_BUFFER+1
sts RFID_TARGET_BIT_COUNT, r16
sts RFID_BUFFER_HANDLER, CONST_RFID_BUFFER_HANDLER
;
ldi r16, 0b00011000
out ACSR, r16
;
out DDRB, CONST_DDRB_COILON
ret

TIM0_OVF:
push r16
in r16, SREG
push r16
;
out TCCR0, CONST_0
sts RFID_CURRENT_BIT_COUNT, CONST_0
sts RFID_BUFFER_HANDLER, CONST_RFID_BUFFER_HANDLER
;
pop r16
out SREG, r16
pop r16
reti

ANA_COMP:
push r16
in r16, SREG
push r16
push r17
push r30
push r31
;
sbis ACSR, 5
rjmp ac3
 sbi portc, 3
 rjmp ac4
ac3:
 cbi portc, 3
ac4:
rjmp ac_exit
;
in r16, TCNT0
;half-period check
cpi r16, 0x18
brlo ac_reset
cpi r16, 0x27
brlo ac_exit
;full-period check
cpi r16, 0x38
brlo ac_reset
cpi r16, 0x43
brlo ac0
 ac_reset:
 sts RFID_CURRENT_BIT_COUNT, CONST_0
 sts RFID_BUFFER_HANDLER, CONST_RFID_BUFFER_HANDLER
ac0:
out TCNT0, CONST_0
out TCCR0, CONST_TCCR0
;
lds r30, RFID_BUFFER_HANDLER
clr r31
ld r16, z
lsr r16
;
sbis ACSR, 5
 ;1
 sbr r16, 0b10000000
;
ac1:
st z, r16
;
lds r16, RFID_CURRENT_BIT_COUNT
inc r16
sts RFID_CURRENT_BIT_COUNT, r16
lds r17, RFID_TARGET_BIT_COUNT
cp r16, r17
breq ac_complete
andi r16, 0b00000111
brne ac_exit
 ;
 adiw r30, 1
 sts RFID_BUFFER_HANDLER, r30
 rjmp ac_exit
; 
ac_complete:
 out TCCR0, CONST_0
 out ACSR, CONST_0
 sbr RFIDFLAGS, 1 << RFIDFLAGS_DATA_READY
 cbi portc, 4
 out DDRB, CONST_DDRB_COILOFF
;
ac_exit:
pop r31
pop r30
pop r17
pop r16
out SREG, r16
pop r16
reti

