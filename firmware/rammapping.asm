;onewire
#define ONEWIREbuffer 0x60
#define ONEWIREbuffer_size 8
#define onewirecrc ONEWIREbuffer+ONEWIREbuffer_size
;cyfral
#define CYFRALBuffer onewirecrc+1
#define CYFRALBuffer_size 4
;emarin
#define RFIDBuffer CYFRALBuffer+CYFRALBuffer_size
#define RFIDBuffer_size 5
#define RAM_BitCounter RFIDBuffer+RFIDBuffer_size
#define RAM_GroupNumber RAM_BitCounter+1
#define RAM_BitMask RAM_BitCounter+2
#define RAM_ReceivedByte RAM_BitCounter+3
#define RAM_ParityVertical RAM_BitCounter+4
#define RAM_ParityHorizontal RAM_BitCounter+5
#define RAM_RFIDPass0 RAM_BitCounter+6
#define RAM_RFIDPass1 RAM_BitCounter+7
#define RAM_RFIDPass2 RAM_BitCounter+8
#define RAM_RFIDPass3 RAM_BitCounter+9
#define RAM_RFIDOP RAM_BitCounter+10
;#define RFIDOP_READ 0 по умолчанию
#define RFIDOP_WRITE5577 1
;uart
#define uart_txbuffer 0x100
