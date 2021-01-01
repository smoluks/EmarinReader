rfid_init:
sts RAM_BitCounter, r2;//счетчик количества принятых бит 
sts RAM_GroupNumber, r2;//счетчик номера группы (0 - пилот сигнал, 1-5 группы, 6 группа четности по вертикали)
sts RAM_BitMask, r2;//маска принимаемого бита (0x80 - 0x01)
sts RAM_ReceivedByte, r2;//принимаемый байт
sts RAM_ParityVertical, r2;//байт формирования битов четности вертикалей	
sts RAM_ParityHorizontal, r2;//флаг вычисления бита четности по горизонтали
sts RAM_RFIDOP, r4
ret

;4uS +/-1T delay
t1delay:
push r16
;
out TIFR0, r9
;
t1:
in r16, TIFR0
sbrs r16, 4
rjmp t1
out TIFR0, r9
dec r17
brne t1
;
pop r16
ret
