rfid_init:
clr RFIDFLAGS
;
sts RFID_READ_BYTENUMBER, CONST_0
ret

TIM0_OVF:
push r16
in r16, SREG
push r16
;
in r16, ACSR
sbrs r16, 3
rjmp t0_normal
 ;if comparator interrupt enable - its timeout
 sbr RFIDFLAGS, 1 << RFIDFLAGS_TIMER0_OVERFLOW 
 ;
 ;TODO: T0 stop
 rjmp tim0_exit
t0_normal:
 ;save comparator level
 sbr RFIDFLAGS, 1 << RFIDFLAGS_LINE_ONE_VALUE
 sbrs r16, 5
 cbr RFIDFLAGS, 1 << RFIDFLAGS_LINE_ONE_VALUE
 ;
 ldi r16, 224
 out TCNT0, r16
 ;
 ldi r16, 0b00011000 ; enable comparator interrupt
 out ACSR, r16
;
tim0_exit:
pop r16
out SREG, r16
pop r16
reti

ANA_COMP:
push r16
push r17
push r18
push r19
push r20
push r21
push r22
push r23
in r16, SREG
push r16
;
lds r17, RFID_READ_BYTENUMBER
lds r18, RAW_RFID_READ_BUFFER
lds r19, RAW_RFID_READ_BUFFER+1
lds r20, RAW_RFID_READ_BUFFER+2
lds r21, RAW_RFID_READ_BUFFER+3
lds r22, RAW_RFID_READ_BUFFER+4
lds r23, RAW_RFID_READ_BUFFER+5
;disable comparator interrupt
ldi r16, 0b00010000
out ACSR, r16
;check time
in r16, TCNT0
out TCNT0, CONST_TCNT0_PROBE_TIME;
cpi r16, 0xF0
brlo ac2
sbrs RFIDFLAGS, RFIDFLAGS_TIMER0_OVERFLOW
 rjmp ac1
ac2:
 ;timeout
 cbr RFIDFLAGS, 1 << RFIDFLAGS_TIMER0_OVERFLOW
 clr r17
 rjmp ac_exit
; 
ac1:
clc
sbrc RFIDFLAGS, RFIDFLAGS_LINE_ONE_VALUE
sec
;
ror r23
ror r22
ror r21
ror r20
ror r19
ror r18
;
inc r17
cpi r17, 48
brlo ac_exit
 out ddrb, CONST_DDRB_COILOFF
 out ACSR, CONST_0
 out TIMSK, CONST_0
 sbr RFIDFLAGS, 1 << RFIDFLAGS_DATA_READY
 clr r17
;
ac_exit:
sts RFID_READ_BYTENUMBER, r17
sts RAW_RFID_READ_BUFFER, r18
sts RAW_RFID_READ_BUFFER+1, r19
sts RAW_RFID_READ_BUFFER+2, r20
sts RAW_RFID_READ_BUFFER+3, r21
sts RAW_RFID_READ_BUFFER+4, r22
sts RAW_RFID_READ_BUFFER+5, r23
;
pop r16
out SREG, r16
pop r23
pop r22
pop r21
pop r20
pop r19
pop r18
pop r17
pop r16
reti

