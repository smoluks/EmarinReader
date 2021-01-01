;������������ ������� �������� ����� RFID (����� ������� ����������/(������������_�������_T0*�������_RFID_�������)
#define F_CPU 16000000
#define RFID_PERIOD_LENGTH (F_CPU/64/2000) ;125
#define TCNT0VALUE 162 ;0x100-(RFID_PERIOD_LENGTH*3/4);

;lds r18, BitCounter
;lds r19, GroupNumber
;lds r20, BitMask
;lds r21, ReceivedByte
;lds r22, ParityHorizontal
;lds r23, ParityVertical

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
;sbrc RFIDFlags, DATA_ENABLED
rjmp actrueexit
;
lds r16,  ACSR
cbr r16, 3;//��������� ���������� �����������
sbr r16, 4;//���������� ���� ���������� �����������, ��� ���������� �������� �����
sts ACSR, r16
;
in r16, TCNT0
out TCNT0, r5;//������� ������� ����� ��������� �� 3\4 ����� ������� RFID ���� ������
;
lds r18, RAM_BitCounter
inc r18
lds r19, RAM_GroupNumber
lds r20, RAM_BitMask
lds r21, RAM_ReceivedByte
lds r22, RAM_ParityHorizontal
lds r23, RAM_ParityVertical
;���� ���� ������������ ������� ���� ���������� �������� ������ �������� ������� RFID
cpi r16, RFID_PERIOD_LENGTH/2
brsh ac2
sbrs RFIDFlags, TIMER0_OVERFLOW
rjmp ac1
ac2:
;�������� ���� ������ 
 cbr RFIDFlags, 1 << TIMER0_OVERFLOW
 ldi r18, 1
 clr r19
;
ac1:
;-----����� ������ ��������� �����-----  
tst r19
brne ac3
;							
  sbrc RFIDFlags, LINE_ONE_VALUE
  rjmp ac4   
   ;������, ��� ��� ��������� ������ ������
   ;�������� ���� ������  
   clr r18
   clr r19
   rjmp acexit
  ac4:  
  cpi r18, 9
  brlo acexit
   ;��� ���� ������� - ��������� � ����� ������        
   clr r18
   ldi r19, 1
   ldi r20, 0x80;	
   ldi r21, 0;
   ldi r22, 0;
   ldi r23, 0;
   rjmp acexit
;-----���� ������ ������ (���� ����� �� 10 ����� � ������ �������� �������)-----
ac3:  
cpi r18, 5
brne ac5
 ;����� ��� - �����������
 cpi r19, 6
 brsh ac31				
   ;������ 1-5 ��������� ��� ��������
   andi r22, 0x01
   mov r16, RFIDFlags
   andi r16, 0x01
   cp r22, r16
   brne ac32
    ;�������� ������
    clr r22
	rjmp acexit
   ac32:
    ;�������� ���� ������
    clr r18
    clr r19
    rjmp acexit
  ac31:
  ;������ ������ - ���� �������� ������������ �������  
  cp r21, r23
  brne ac33
	rcall rfid_checknotzero
	brtc ac33
	 ;���� ������ �� ����
	 sbr RFIDFlags, 1 << DATA_ENABLED
   ac33:
   ;�������� ���� ������
   clr r18
   clr r19
   rjmp acexit
ac5:
cpi r18, 10
brne ac6
 ;����� ������������ 10-�� ���� �������� 					
  andi r22, 0x01
  mov r16, RFIDFlags
  andi r16, 0x01
  cp r22, r16
  brne ac52
   ;   
   mov r16, r21
   andi r16, 0xF0
   eor r23, r16;��������� ���� �������� �� ���������
   mov r16, r21
   swap r16
   andi r16, 0xF0
   eor r23, r16;
   ;
   rcall save
   ;
   clr r18
   inc r19
   ldi r20, 0x80
   clr r21
   clr r22
   rjmp acexit
  ac52:
  ;�������� ���� ������
  clr r18
  clr r19
  rjmp acexit 
ac6:
;���� ��� �� 5-� � �� 10-� ����, �� ��������� ������
sbrs RFIDFlags, LINE_ONE_VALUE
rjmp ac7
 or r21, r20
 eor r22, r4;//������� ���� �������������� ��������
ac7: 
lsr r20;   
;
acexit:
sts RAM_BitCounter, r18
sts RAM_GroupNumber, r19
sts RAM_BitMask, r20
sts RAM_ReceivedByte, r21
sts RAM_ParityHorizontal, r22
sts RAM_ParityVertical, r23
;
actrueexit:
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

save:
push r26
push r27
;
ldi r26, low(RFIDBuffer-1);����� �� ������ ��������� ������ -1
ldi r27, high(RFIDBuffer-1)
add r26, r19
adc r27, r2
;
st x, r21
;
pop r27
pop r26
ret

;t = true, ���� ��������� ������ �� ����
rfid_checknotzero:
push r16
push r17
push r26
push r27
;
ldi r26, low(RFIDBuffer)
ldi r27, high(RFIDBuffer)
ldi r17, 5
clt
;
rc0:
ld r16, x+
tst r16
breq rc1
 set
rc1:
dec r17
brne rc0
;
pop r27
pop r26
pop r17
pop r16
ret
