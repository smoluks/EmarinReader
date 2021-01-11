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
sbrc RFIDFLAGS, RFIDFLAGS_MAKE_SKIP
rjmp to1
 ;save comparator value
 cbr RFIDFLAGS, 1 << RFIDFLAGS_LINE_ONE_VALUE
 sbis ACSR, 5
 sbr RFIDFLAGS, 1 << RFIDFLAGS_LINE_ONE_VALUE
 ;make skip
 sbr RFIDFLAGS, 1 << RFIDFLAGS_MAKE_SKIP
 out TCNT0, CONST_TCNT0_SKIP_TIME
 ;
 rjmp tim0_exit
to1:
sbic ACSR, 3
rjmp to2
 ;comparator disable - it's skip
 ldi r16, 0b00011000 ; enable comparator interrupt
 out ACSR, r16
 ;
 out TCNT0, CONST_TCNT0_SKIP_TIME
 rjmp tim0_exit
to2:
 ;comparator enable - it's timeout
 out TIMSK, CONST_0
 sbr RFIDFLAGS, 1 << RFIDFLAGS_TIMER0_OVERFLOW
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
push r26
push r27
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
lds r26, RAW_RFID_READ_BUFFER+6
lds r27, RAW_RFID_READ_BUFFER+7
;disable comparator interrupt
ldi r16, 0b00010000
out ACSR, r16
;check time
cbr RFIDFLAGS, 1 << RFIDFLAGS_MAKE_SKIP
in r16, TCNT0
out TCNT0, CONST_TCNT0_PROBE_TIME
out TIMSK, CONST_TIMSK
;
;out udr, r16
cpi r16, TCNT0_CHECK_TIME_LOW
brlo ac2
cpi r16, TCNT0_CHECK_TIME_HIGH
brsh ac2
sbrs RFIDFLAGS, RFIDFLAGS_TIMER0_OVERFLOW
 rjmp ac1
ac2:
 ;timeout
 cbr RFIDFLAGS, 1 << RFIDFLAGS_TIMER0_OVERFLOW
 clr r17
 rjmp ac_exit
; 
ac1:
sec
sbrc RFIDFLAGS, RFIDFLAGS_LINE_ONE_VALUE
rjmp ac1_1
 clc
 cpi r17, 9
 brlo ac2  
ac1_1:
;
ror r27
ror r26
ror r23
ror r22
ror r21
ror r20
ror r19
ror r18
;
inc r17
cpi r17, 64
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
sts RAW_RFID_READ_BUFFER+6, r26
sts RAW_RFID_READ_BUFFER+7, r27
;
pop r16
out SREG, r16
pop r27
pop r26
pop r23
pop r22
pop r21
pop r20
pop r19
pop r18
pop r17
pop r16
reti

