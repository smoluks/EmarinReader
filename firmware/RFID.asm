

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
