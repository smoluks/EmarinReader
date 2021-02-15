login_4305:
push r16
push r17
push r20
push r21
push r22
push r23
;
cbr RFIDFLAGS, 1 << RFIDFLAGS_LOGIN_4305
sbi portc, 0
;
out DDRB, CONST_DDRB_COILON
;
ldi r17, 39 - 1 ;Tpu
rcall delay128
;
rcall SendFirstField_4305
rcall SendZero_4305
; login cmd - 0011
rcall SendZero_4305;//CC0
rcall SendZero_4305;//CC1
rcall SendOne_4305;//CC2
rcall SendOne_4305;//P
; send password
lds r20, UART_RX_BUFFER + 1
lds r21, UART_RX_BUFFER + 2
lds r22, UART_RX_BUFFER + 3
lds r23, UART_RX_BUFFER + 4
rcall SendDataBlock_4305
;
ldi r17, 5 - 1 ;Tpp
rcall delay128
;out DDRB, CONST_DDRB_COILOFF
;
cbi portc, 0
rcall uart_sendbyte
;
pop r23
pop r22
pop r21
pop r20
pop r17
pop r16
ret

write_4305:
push r16
push r17
push r20
push r21
push r22
push r23
;
cbr RFIDFLAGS, 1 << RFIDFLAGS_WRITE_4305
sbi portc, 0
;
rcall SendFirstField_4305
rcall SendZero_4305
; write cmd - 0101
rcall SendZero_4305;//CC0
rcall SendOne_4305;//CC1
rcall SendZero_4305;//CC2
rcall SendOne_4305;//P
; send address
lds r16, UART_RX_BUFFER + 1
ldi r17, 4
rcall SendByte_4305
rcall SendZero_4305
rcall SendZero_4305
brts w1
 rcall SendZero_4305
 rjmp w2
w1:
  rcall SendOne_4305
w2:
; send data
lds r20, UART_RX_BUFFER + 2
lds r21, UART_RX_BUFFER + 3
lds r22, UART_RX_BUFFER + 4
lds r23, UART_RX_BUFFER + 5
rcall SendDataBlock_4305
;
ldi r17, 84 - 1 ;Tpp
rcall delay128
;
cbi portc, 0
rcall uart_sendbyte
;
pop r23
pop r22
pop r21
pop r20
pop r17
pop r16
ret

;----------------------------------------------------------
;in r20-23
SendDataBlock_4305:
push r16
;
mov r16, r20
ldi r17, 8
rcall SendByte_4305
brts sdb1
 rcall SendZero_4305
 rjmp sdb2
sdb1:
  rcall SendOne_4305
sdb2:
;
mov r16, r21
ldi r17, 8
rcall SendByte_4305
brts sdb3
 rcall SendZero_4305
 rjmp sdb4
sdb3:
  rcall SendOne_4305
sdb4:
;
mov r16, r22
ldi r17, 8
rcall SendByte_4305
brts sdb5
 rcall SendZero_4305
 rjmp sdb6
sdb5:
  rcall SendOne_4305
sdb6:
;
mov r16, r23
ldi r17, 8
rcall SendByte_4305
brts sdb7
 rcall SendZero_4305
 rjmp sdb8
sdb7:
  rcall SendOne_4305
sdb8:
;column parity
mov r16, r20
eor r16, r21
eor r16, r22
eor r16, r23
ldi r17, 8
rcall SendByte_4305
;
rcall SendZero_4305
;
pop r16
ret

;in r16 - data, r17 - count
SendByte_4305:
push r16
push r17
;
clt
;
send_byte_cycle:
sbrs r16, 0
rjmp sb_send0
 ;send 1
 rcall SendOne_4305
 ;
 brts sb0_1
  set
  rjmp sb1
 sb0_1:
  clt
  rjmp sb1
sb_send0:
 ;send 0
 rcall SendZero_4305
sb1:
lsr r16
dec r17
brne send_byte_cycle
;
pop r17
pop r16
ret

;-----------------------routine-------------------------
SendFirstField_4305:
push r16
push r17
;
;wait IC is in the MOD_ON state (modulator switch is ON)
sff1:
sbis ACSR, 5
rjmp sff1
;
out DDRB, CONST_DDRB_COILOFF
ldi r17, 55-1
rcall delay4305
out DDRB, CONST_DDRB_COILON
;
pop r17
pop r16
ret

SendOne_4305:
push r17
;
out DDRB, CONST_DDRB_COILON
ldi r17, 32 - 1
rcall delay4305
;
pop r17
ret

SendZero_4305:
push r17
;
;wait IC is in the MOD_ON state (modulator switch is ON)
sz1:
sbis ACSR, 5
rjmp sz1
;
out DDRB, CONST_DDRB_COILOFF
ldi r17, 23 - 1
rcall delay4305
out DDRB, CONST_DDRB_COILON
;
pop r17
ret

;delay (r17+1)*8 us
delay4305:
out SFIOR, CONST_TOV2_CLEAR_PRESCALER
out TCNT2, CONST_0
out OCR2, r17
ldi r17, 0b11000000
out TIFR, r17
ldi r17, 0b00001100
out TCCR2, r17
;
del1:
in r17, TIFR
sbrs r17, 7
rjmp del1
;
OUT TCCR2, CONST_0
ret

;delay (r17+1)*128 us
delay128:
out SFIOR, CONST_TOV2_CLEAR_PRESCALER
out TCNT2, CONST_0
out OCR2, r17
ldi r17, 0b11000000
out TIFR, r17
ldi r17, 0b00001111
out TCCR2, r17
;
del11:
in r17, TIFR
sbrs r17, 7
rjmp del11
;
OUT TCCR2, CONST_0
ret