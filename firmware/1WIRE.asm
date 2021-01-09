onewire_readserialnumber:
rcall onewire_reset
tst r16
brne or2
 ;not detected
 ret
or2:
;
ldi r26, low(ONEWIREbuffer)
ldi r27, high(ONEWIREbuffer)
sts onewirecrc, CONST_0
;
ldi r16, 0x33
rcall writebyte
;family_code
rcall readbyte
tst r16
brne or3
 ;bad family code
 ldi r16, 0x03
 ret
or3:
st x+, r16
rcall crc8
;serial number
rcall readbyte
st x+, r16
rcall crc8
rcall readbyte
st x+, r16
rcall crc8
rcall readbyte
st x+, r16
rcall crc8
rcall readbyte
st x+, r16
rcall crc8
rcall readbyte
st x+, r16
rcall crc8
rcall readbyte
st x+, r16
rcall crc8
;crc
rcall readbyte
st x+, r16
lds r17, onewirecrc
cp r16, r17
breq or1
 ;bad crc
 ldi r16, 0x03
 ret
or1:
ldi r16, 0x01
ret

crc8:
push r16
push r17
push r18
push r19
;
lds r18, onewirecrc
ldi r17, 8 ;количество бит
;--обработка одного байта
cc4:
 mov r19, r16
 eor r19, r18
 lsr r18
 sbrs r19, 0
 rjmp cc2  
  eor r18, CONST_CRC_POLYNOM
 cc2:
 lsr r16
 dec r17
 brne cc4 
;
sts onewirecrc, r18
;
pop r19
pop r18
pop r17
pop r16
ret

onewire_reset:
;reset pulse
cbi portd, 4
sbi ddrd, 4
rcall delay480
;presence pulse
cbi ddrd, 4
sbi portd, 4
rcall delay60
sbis pind, 4
rjmp keypresent
;key not present
ldi r16, 0x00
ret
keypresent:
rcall delay420
ldi r16, 0x01
ret

writebyte:
ldi r17, 8
wb3:
ror r16
brcs wb1
 rcall write0
 rjmp wb2
wb1:
 rcall write1
wb2: 
dec r17
brne wb3
ret

readbyte:
ldi r17, 8
rb1:
rcall read
lsr r16
bld r16, 7
;
dec r17
brne rb1
ret

write1:
push r16
;
cbi portd, 4
sbi ddrd, 4
;
ldi r16, 1
rcall delay
;
cbi ddrd, 4
sbi portd, 4
;
ldi r16, 57
rcall delay
;
pop r16
ret

write0:
push r16
;
cbi portd, 4
sbi ddrd, 4
;
ldi r16, 59
rcall delay
;
cbi ddrd, 4
sbi portd, 4
;
ldi r16, 1
rcall delay
;
pop r16
ret

read:
push r16
;
cbi portd, 4
sbi ddrd, 4
;
ldi r16, 1
rcall delay
;
cbi ddrd, 4
sbi portd, 4
;wait
ldi r16, 10
rcall delay
;read
clt
sbic pind, 4
set
;
ldi r16, 49
rcall delay
;
pop r16
ret

delay:
nop
nop
nop
nop
nop
dec r16
brne delay
ret

delay60:
ldi r16, 158
d1:
dec r16
brne d1
ret

delay420:
ldi r16, 220
d2:
nop
nop
nop
nop
nop
dec r16
brne d2
ldi r16, 200
d3:
nop
nop
nop
nop
nop
dec r16
brne d3
ret

delay480:
ldi r16, 240
d4:
nop
nop
nop
nop
nop
dec r16
brne d4
ldi r16, 240
d5:
nop
nop
nop
nop
nop
dec r16
brne d5
ret