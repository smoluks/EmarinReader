cyfral_read:
;
;даем ключу время накачаться
rcall delay480
;-----проверка на КЗ-----
sts TCNT2, r2
sts TIFR0, r8
;
cr2:
sbic pind, 4
rjmp cr1
lds r16, TIFR0
sbrs r16, 6
rjmp cr2
 ;КЗ 
 ldi r16, 2
 ret
;
cr1:
clr r18;обнуляем число чтений ключа
;-----ожидание стартовой декады (0001)-----
cr8:
rcall cyfral_readbit
brts cr3
brcs cr1
rcall cyfral_readbit
brts cr3
brcs cr1
rcall cyfral_readbit
brts cr3
brcs cr1
rcall cyfral_readbit
brts cr3
brcc cr1
;-----чтение данных-----
;1 байт
rcall cyfral_readbyte
brts cr3
lds r17, CYFRALBuffer
cp r16, r17
breq cr1comp
 sts CYFRALBuffer, r16
 clr r18
cr1comp:
;2 байт
rcall cyfral_readbyte
brts cr3
lds r17, CYFRALBuffer+1
cp r16, r17
breq cr2comp
 sts CYFRALBuffer+1, r16
 clr r18
cr2comp:
;3 байт
rcall cyfral_readbyte
brts cr3
lds r17, CYFRALBuffer+2
cp r16, r17
breq cr3comp
 sts CYFRALBuffer+2, r16
 clr r18
cr3comp:
;4 байт
rcall cyfral_readbyte
brts cr3
lds r17, CYFRALBuffer+3
cp r16, r17
breq cr4comp
 sts CYFRALBuffer+3, r16
 clr r18
cr4comp:
;
inc r18
cpi r18, 3
brlo cr8
;readed
ldi r16, 1
ret
;
cr3:
;not detected
ldi r16, 0
ret

cyfral_readbyte:
push r17
;
ldi r17, 8
readbytecycle:
;
rcall cyfral_readbit
brts readbyteexit
rol r16
;
dec r17
brne readbytecycle
;
readbyteexit:
pop r17
ret

cyfral_readbit:
push r16
;
clt
sts TCNT2, r2
sts TIFR0, r8
;---ожидание нуля---
cr4:
sbis pind, 4
rjmp cr5
lds r16, TIFR0
sbrs r16, 6
rjmp cr4
 ;timeout
 set
 pop r16
 ret
;----замер времени нуля---
cr5:
sts TCNT2, r2
sts TIFR0, r8
;ожидание 1
cr6:
sbic pind, 4
rjmp cr7
lds r16, TIFR0
sbrs r16, 6
rjmp cr6
 ;timeout 
 set
 pop r16
 ret
;
cr7: 
lds r16, TCNT2
cpi r16, CYFRAL_THRESHOLD
;
pop r16
ret
