uart_init:
sts UART_RX_STATE, CONST_0
sts UART_RX_CRC, CONST_0

sts UART_TX_STATE, CONST_0
sts UART_TX_HANDLE, CONST_UART_TX_BUFFER
sts UART_TX_CRC, CONST_START_TOKEN_CRC
ret

;reseive byte handler
USART_RXC:
push r16
push r17
push r28
push r29
in r16, SREG
push r16
;
in r16, UDR
rcall rx_crc
lds r17, UART_RX_STATE
cpi r17, UART_RX_STATE_WAIT_START
brne ur1
 ;start token
 cp r16, CONST_START_TOKEN
 brne ur_exit_with_clear
 inc r17
 rjmp ur_exit
ur1:
cpi r17, UART_RX_STATE_WAIT_LENGTH
brne ur2
 ;length
 cpi r16, UART_RX_BUFFER_SIZE + 1
 brsh ur_exit_with_clear
 sts UART_RX_COUNT, r16
 sts UART_RX_COUNT_TEMP, r16
 sts UART_RX_HANDLE, CONST_UART_RX_BUFFER 
 inc r17
 ;
 tst r16
 brne ur_exit
 inc r17
 rjmp ur_exit
ur2:
cpi r17, UART_RX_STATE_WAIT_DATA
brne ur3
 ;data
 clr r29
 lds r28, UART_RX_HANDLE
 st y+, r16
 sts UART_RX_HANDLE, r28
 ;
 lds r16, UART_RX_COUNT_TEMP
 dec r16
 sts UART_RX_COUNT_TEMP, r16
 brne ur_exit
 inc r17
 rjmp ur_exit
ur3:
cpi r17, UART_RX_STATE_WAIT_CRC
brne ur_exit_with_clear
 ;crc
 lds r16, UART_RX_CRC
 tst r16
 brne ur3_3
  rcall process_packet
 ur3_3:
 ;
 sts UART_RX_CRC, CONST_0
 ;
ur_exit_with_clear:
ldi r17, UART_RX_STATE_WAIT_START
;
ur_exit:
sts UART_RX_STATE, r17
;
pop r16
out SREG, r16
pop r29
pop r28
pop r17
pop r16
reti

process_packet:
lds r16, UART_RX_BUFFER
cpi r16, 0x20
brne pp1
 sbr RFIDFLAGS, 1 << RFIDFLAGS_READ_COMMAND
pp1:
ret

USART_UDRE:
push r16
push r17
push r28
push r29
in r16, SREG
push r16
;
lds r17, UART_TX_STATE
cpi r17, UART_TX_STATE_SEND_LENGTH
brne ud1
 ;length
 lds r16, UART_TX_COUNT
 ;
 rcall tx_crc
 ;
 inc r17
 sts UART_TX_STATE, r17
 ;
 rjmp ud_exit
ud1:
cpi r17, UART_TX_STATE_SEND_DATA
brne ud2
 ;data
 clr r29
 lds r28, UART_TX_HANDLE
 ld r16, y+ 
 sts UART_TX_HANDLE, r28
 ;
 rcall tx_crc
 ;
 lds r28, UART_TX_COUNT
 dec r28
 sts UART_TX_COUNT, r28
 brne ud_exit
 ;
 inc r17
 sts UART_TX_STATE, r17
 rjmp ud_exit
ud2:
 ;crc
 lds r16, UART_TX_CRC
 ;
 cbi UCSRB, 5
 sts UART_TX_STATE, CONST_0
 sts UART_TX_HANDLE, CONST_UART_TX_BUFFER
 sts UART_TX_CRC, CONST_START_TOKEN_CRC
ud_exit:
out UDR, r16
;
pop r16
out SREG, r16
pop r29
pop r28
pop r17
pop r16
reti

;uart_send1wire:
;ldi r26, low(UART_TXBUFFER)
;ldi r27, high(UART_TXBUFFER)
;type
;ldi r16, 0x01
;;st x+, r16
;data
;ldi r28, low(ONEWIREbuffer)
;ldi r29, high(ONEWIREbuffer)
;ldi r17,8
;us2:
;ld r16, y+
;st x+, r16
;dec r17
;brne us2
;send
;ldi r17,9
;rcall uart_send
;
;ret

uart_sendemarin:
lds r16, RAW_RFID_READ_BUFFER
sts UART_TX_BUFFER, r16
lds r16, RAW_RFID_READ_BUFFER+1
sts UART_TX_BUFFER+1, r16
lds r16, RAW_RFID_READ_BUFFER+2
sts UART_TX_BUFFER+2, r16
lds r16, RAW_RFID_READ_BUFFER+3
sts UART_TX_BUFFER+3, r16
lds r16, RAW_RFID_READ_BUFFER+4
sts UART_TX_BUFFER+4, r16
lds r16, RAW_RFID_READ_BUFFER+5
sts UART_TX_BUFFER+5, r16
;
ldi r16, 6
sts UART_TX_COUNT, r16
out UDR, CONST_START_TOKEN
sbi UCSRB, 5
;
ret

;ldi r26, low(uart_txbuffer)
;ldi r27, high(uart_txbuffer)
;type
;ldi r16, 0x02
;st x+, r16
;data
;ldi r28, low(RFID_READ_Buffer)
;ldi r29, high(RFID_READ_Buffer)
;ldi r17, 5
;us3:
;ld r16, y+
;st x+, r16
;dec r17
;brne us3
;send
;ldi r17, 6
;rcall uart_send
;
;ret

;uart_sendcyfral:
;ldi r26, low(UART_TXBUFFER)
;ldi r27, high(UART_TXBUFFER)
;type
;ldi r16, 0x03
;st x+, r16
;data
;ldi r28, low(CYFRALBuffer)
;ldi r29, high(CYFRALBuffer)
;ldi r17, 4
;us4:
;ld r16, y+
;st x+, r16
;dec r17
;brne us4
;send
;ldi r17, 5
;rcall uart_send
;
;ret

;in - r16
tx_crc:
push r16
push r17
push r18
push r19
;
lds r18, UART_TX_CRC
ldi r17, 8
;--
utc1:
 mov r19, r16
 eor r19, r18
 lsr r18
 sbrs r19, 0
 rjmp utc2  
  eor r18, CONST_CRC_POLYNOM
 utc2:
 lsr r16
 ;
 dec r17
 brne utc1 
;
sts UART_TX_CRC, r18
;
pop r19
pop r18
pop r17
pop r16
ret

;in - r16
rx_crc:
push r16
push r17
push r18
push r19
;
lds r18, UART_RX_CRC
ldi r17, 8
;--
utc3:
 mov r19, r16
 eor r19, r18
 lsr r18
 sbrs r19, 0
 rjmp utc4  
  eor r18, CONST_CRC_POLYNOM
 utc4:
 lsr r16
 ;
 dec r17
 brne utc3 
;
sts UART_RX_CRC, r18
;
pop r19
pop r18
pop r17
pop r16
ret