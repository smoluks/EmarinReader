rfid_init:
sts RAM_BitCounter, r2;//������� ���������� �������� ��� 
sts RAM_GroupNumber, r2;//������� ������ ������ (0 - ����� ������, 1-5 ������, 6 ������ �������� �� ���������)
sts RAM_BitMask, r2;//����� ������������ ���� (0x80 - 0x01)
sts RAM_ReceivedByte, r2;//����������� ����
sts RAM_ParityVertical, r2;//���� ������������ ����� �������� ����������	
sts RAM_ParityHorizontal, r2;//���� ���������� ���� �������� �� �����������
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
