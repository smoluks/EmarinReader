;�������� ����� Em4305 �����
SendEM4305Login:
;
rcall FirstFieldStop_4305
rcall SendZero_4305
;��� 0011
rcall SendZero_4305;//CC0
rcall SendZero_4305;//CC1
rcall SendOne_4305;//CC2
rcall SendOne_4305;//P
;��� ������
lds r20, RAM_RFIDPass0
lds r21, RAM_RFIDPass1
lds r22, RAM_RFIDPass2
lds r23, RAM_RFIDPass3
rcall SendEM4305DataBlock
;
ret

;����� FirstFieldStop ��� em4305
FirstFieldStop_4305:
;wait front
sbi TIFR, 4
ff1:
in r16, tifr
sbrs r16, 4
rjmp ff1
sbi TIFR, 4
;6 off
cbi ddrb, 1
cbi ddrb, 2
ldi r17, 6
rcall waitcycles
;12 on
sbi ddrb, 1
sbi ddrb, 2
ldi r17, 12
rcall waitcycles
;40 off
cbi ddrb, 1
cbi ddrb, 2
ldi r17, 40
rcall waitcycles
;17 on
sbi ddrb, 1
sbi ddrb, 2
ldi r17, 17
rcall waitcycles
cbi ddrb, 1
cbi ddrb, 2
ret

;��������� ������� ��� em4305
SendOne_4305:
sbi ddrb, 1
sbi ddrb, 2
ldi r17, 30
rcall waitcycles
ret

;��������� ���� ��� em4305
SendZero_4305:
cbi ddrb, 1
cbi ddrb, 2
ldi r17, 18
rcall waitcycles
sbi ddrb, 1
sbi ddrb, 2
ldi r17, 17
rcall waitcycles
ret

//----------------------------------------------------------------------------------------------------
//�������� ����� Em4305 ���� ������ 32 ����
//----------------------------------------------------------------------------------------------------
void SendEM4305DataBlock(char b0,char b1,char b2,char b3)
{
 unsigned char n;
 unsigned char data[4]={b0,b1,b2,b3};
 //��� ������
 unsigned char p=0; 
 for(n=0;n<4;n++)
 {
  unsigned char l_p=0;
  p^=data[n];
  for(unsigned char m=0;m<8;m++)
  {
   unsigned char mask=(1<<m);
   if (data[n]&mask)
   {
    SendOne_4305();
	l_p^=1;
   }
   else SendZero_4305();   
  }
  //��� �������� �� �������  
  if (l_p==0) SendZero_4305();
         else SendOne_4305();
 }
 //��� �������� �� ��������		  
 for(n=0;n<8;n++)
 {
  unsigned char mask=(1<<n);
  if (p&mask) SendOne_4305();
         else SendZero_4305();   
 }
 //��� 0
 SendZero_4305(); 
 FieldOn();
 _delay_ms(500);
}



//----------------------------------------------------------------------------------------------------
//�������� ����� � Em4305
//----------------------------------------------------------------------------------------------------
void WriteEM4305Word(unsigned char addr,char b0,char b1,char b2,char b3)
{
 //HIGHT - ���� ���������
 FirstFieldStop_4305(); 
 SendZero_4305();//'0'
 //��� 0101
 SendZero_4305();//CC0
 SendOne_4305();//CC1
 SendZero_4305();//CC2
 SendOne_4305();//P
 //��� ����� ����� (������� ��� ������)
 unsigned char p=0;
 for(unsigned char n=0;n<4;n++)
 {
  if (addr&(1<<n))
  {
   SendOne_4305();
   p^=1;
  }
  else SendZero_4305();
 }
 //����������� ���� � �������� 
 SendZero_4305();
 SendZero_4305();
 if (p==0) SendZero_4305();
      else SendOne_4305(); 
 //��� ������
 SendEM4305DataBlock(b0,b1,b2,b3);
}

