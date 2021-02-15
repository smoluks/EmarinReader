rf5577_write:
;data1
ldi r19, 1
ldi r20, 0xFF;
ldi r21, 0x96;
ldi r22, 0x20;
ldi r23, 0x18;
rcall rf5577_writepage
;data2
ldi r19, 2
ldi r20, 0x29;
ldi r21, 0xB6;
ldi r22, 0x33;
ldi r23, 0xA4;
rcall rf5577_writepage
;config
ldi r19, 0
ldi r20, 0x00;
ldi r21, 0x14;
ldi r22, 0x80;
ldi r23, 0x40;
rcall rf5577_writepage
;
rcall rf5577_makeStartGap
rcall rf5577_writeReset;
ret

rf5577_writepage:
rcall rf5577_makeStartGap
rcall rf5577_writeOpWithLock
;
mov r16, r20
rcall rf5577_writebyte
mov r16, r21
rcall rf5577_writebyte
mov r16, r22
rcall rf5577_writebyte
mov r16, r23
rcall rf5577_writebyte
;
mov r16, r19
rcall rf5577_writeaddress
;
rcall delay200ms
ret

rf5577_writeOpWithLock:
rcall rf5577_write1
rcall rf5577_write0
rcall rf5577_write0
ret

rf5577_writeReset:
;
rcall rf5577_write0
rcall rf5577_write0
;
ret

rf5577_writebyte:
push r16
push r17
;
ldi r17, 8
;
rfwb2:
rol r16
brcs rfwb1
 rcall rf5577_write0
 rjmp rfwb0
rfwb1: 
 rcall rf5577_write1
rfwb0:
;
dec r17
brne rfwb2
;
pop r17
pop r16
ret

rf5577_writeaddress:
push r16
push r17
;
rol r16
rol r16
rol r16
rol r16
rol r16
;
ldi r17, 3
;
rfwa2:
rol r16
brcs rfwa1
 rcall rf5577_write0
 rjmp rfwa0
rfwa1: 
 rcall rf5577_write1
rfwa0:
;
dec r17
brne rfwa2
;
pop r17
pop r16
ret

rf5577_makeStartGap:
push r17
;
out ddrb, CONST_DDRB_COILON
ldi r17, 60
rcall t1delay
out ddrb, CONST_DDRB_COILOFF
;
pop r17 
ret

rf5577_write1:
push r17
;
ldi r17, 85
rcall t1delay
out ddrb, CONST_DDRB_COILON
ldi r17, 55
rcall t1delay
out ddrb, CONST_DDRB_COILOFF
;
pop r17   
ret

rf5577_write0:
push r17
;
ldi r17, 17
rcall t1delay
out ddrb, CONST_DDRB_COILON
ldi r17, 55
rcall t1delay
out ddrb, CONST_DDRB_COILOFF 
;
pop r17    
ret

;4uS +/-1T delay
t1delay:
push r16
;
sbi TIFR, 4
;
t1:
in r16, TIFR
sbrs r16, 4
rjmp t1
sbi TIFR, 4
dec r17
brne t1
;
pop r16
ret
