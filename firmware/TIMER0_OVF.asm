TIM0_OVF:
push r16
in r16, SREG
push r16
;
lds r16, ACSR
sbrs r16, 3
rjmp t0_normal
 ;���� ���������� ����������� ���� ��������, �� � ��� ������������ �������
 sbr RFIDFlags, 1 << TIMER0_OVERFLOW 
 ;
 pop r16
 out SREG, r16
 pop r16
 reti
t0_normal:
;���������� ������� ������ ����������� 
sbr RFIDFlags, 1 << LINE_ONE_VALUE
sbrs r16, 5
cbr RFIDFlags, 1 << LINE_ONE_VALUE
;
sbr r16, 0b00011000;//���������� ���� ���������� �����������(�� ������������ ������� 1), ��������� ����������
sts ACSR, r16;
;
pop r16
out SREG, r16
pop r16
reti