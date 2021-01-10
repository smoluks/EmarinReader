;----------------------------RAM------------------------------------
;onewire
#define ONEWIREbuffer 0x60
#define ONEWIREbuffer_size 8
#define onewirecrc ONEWIREbuffer+ONEWIREbuffer_size

;cyfral
#define CYFRALBuffer onewirecrc+1
#define CYFRALBuffer_size 4

;emarin
#define RAW_RFID_READ_BUFFER CYFRALBuffer+CYFRALBuffer_size
#define RAW_RFID_READ_BUFFER_SIZE 8
#define RFID_READ_BYTENUMBER RAW_RFID_READ_BUFFER + RAW_RFID_READ_BUFFER_SIZE

;uart
#define UART_RX_STATE RFID_READ_BYTENUMBER + 1
#define UART_RX_STATE_WAIT_START 0
#define UART_RX_STATE_WAIT_LENGTH 1 
#define UART_RX_STATE_WAIT_DATA 2
#define UART_RX_STATE_WAIT_CRC 3

#define UART_RX_BUFFER UART_RX_STATE + 1
#define UART_RX_BUFFER_SIZE 7

#define UART_RX_COUNT UART_RX_BUFFER + UART_RX_BUFFER_SIZE
#define UART_RX_COUNT_TEMP UART_RX_COUNT + 1
#define UART_RX_HANDLE UART_RX_COUNT_TEMP + 1
#define UART_RX_CRC UART_RX_HANDLE + 1

#define UART_TX_COUNT UART_RX_CRC + 1

#define UART_TX_STATE UART_TX_COUNT + 1
#define UART_TX_STATE_SEND_LENGTH 0 
#define UART_TX_STATE_SEND_DATA 1 
#define UART_TX_STATE_SEND_CRC 2 

#define UART_TX_HANDLE UART_TX_STATE + 1
#define UART_TX_CRC UART_TX_HANDLE + 1
#define UART_TX_BUFFER UART_TX_CRC + 1
#define UART_TX_BUFFER_SIZE 12

#define END_RAM UART_TX_BUFFER + UART_TX_BUFFER_SIZE

;----------------------------CONST------------------------------------
#define CRC_POLYNOM 0x8C
#define CONST_0 r2
#define CONST_CRC_POLYNOM r3
clr r16
ldi r17, CRC_POLYNOM
movw r2, r16

#define RFID_PERIOD_LENGTH 62.5 ;one-bit time in cycles - F_CPU/64/2000
#define TCNT0_PROBE_TIME 241 ;probe time 1/4 - 0x100-(RFID_PERIOD_LENGTH*1/4)
#define TCNT0_SKIP_TIME 225 ;skip time 3/4 +- - 0x100-(RFID_PERIOD_LENGTH*2/4)
#define TCNT0_CHECK_TIME_LOW 0xEF
#define TCNT0_CHECK_TIME_HIGH 0xF6 
#define CONST_TCNT0_PROBE_TIME r4
#define CONST_TCNT0_SKIP_TIME r5
ldi r16, TCNT0_PROBE_TIME
ldi r17, TCNT0_SKIP_TIME
movw r4, r16

#define DDRB_COILOFF 0b00000000
#define CONST_DDRB_COILOFF r6
#define DDRB_COILON 0b00000110
#define CONST_DDRB_COILON r7
ldi r16, DDRB_COILOFF
ldi r17, DDRB_COILON
movw r6, r16

#define CONST_UART_RX_BUFFER r8
#define CONST_UART_TX_BUFFER r9
ldi r16, UART_RX_BUFFER
ldi r17, UART_TX_BUFFER
movw r8, r16

#define CONST_START_TOKEN r10
#define CONST_START_TOKEN_CRC r11
ldi r16, 0xAB
ldi r17, 0x8F
movw r10, r16

#define CONST_TIMSK r12
ldi r16, 0b00000001
movw r12, r16

;#define TOV2_MASK 0b01000000
;#define OCF1A_MASK 0b00010000
#define CYFRAL_THRESHOLD 128

;----------------------------REGS------------------------------------
#define RFIDFLAGS r24
#define RFIDFLAGS_LINE_ONE_VALUE 0
#define RFIDFLAGS_DATA_READY 1
#define RFIDFLAGS_TIMER0_OVERFLOW 2
#define RFIDFLAGS_MAKE_SKIP 3

#define RFIDFLAGS_READ_COMMAND 4
