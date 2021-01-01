uart_send:
ldi r26, low(uart_txbuffer)
ldi r27, high(uart_txbuffer)
;token
rcall wait_buffer
ldi r16, 0xAD
sts UDR0, r16
;length
rcall wait_buffer
sts UDR0, r17
;buffer
us1:
ld r16, x+
rcall wait_buffer
sts UDR0, r16
dec r17
brne us1
;
ret

wait_buffer:
lds r17, UCSR0A
sbrs r17, 5
rjmp wait_buffer
ret

uart_send1wire:
ldi r26, low(uart_txbuffer)
ldi r27, high(uart_txbuffer)
;type
ldi r16, 0x01
st x+, r16
;data
ldi r28, low(ONEWIREbuffer)
ldi r29, high(ONEWIREbuffer)
ldi r17,8
us2:
ld r16, y+
st x+, r16
dec r17
brne us2
;send
ldi r17,9
rcall uart_send
;
ret

uart_sendemarin:
ldi r26, low(uart_txbuffer)
ldi r27, high(uart_txbuffer)
;type
ldi r16, 0x02
st x+, r16
;data
ldi r28, low(RFIDBuffer)
ldi r29, high(RFIDBuffer)
ldi r17, 5
us3:
ld r16, y+
st x+, r16
dec r17
brne us3
;send
ldi r17, 6
rcall uart_send
;
ret

uart_sendcyfral:
ldi r26, low(uart_txbuffer)
ldi r27, high(uart_txbuffer)
;type
ldi r16, 0x03
st x+, r16
;data
ldi r28, low(CYFRALBuffer)
ldi r29, high(CYFRALBuffer)
ldi r17, 4
us4:
ld r16, y+
st x+, r16
dec r17
brne us4
;send
ldi r17, 5
rcall uart_send
;
ret