;##########################################################
;##                                                      ##
;##       ����������� ��������, ����������� �������      ##
;##                (MK ATtiny2313A, 4 ���)               ##
;##  (PD6-������� TSOP, PB3-������� ����� ����������)   ##
;##  (LCD 1602A, PB4-PB7-LCD Data, PB0-PB2-LCD Control)  ##
;##                                                      ##
;##########################################################

.include "tn2313adef.inc"	; ������������� ����� ��������
.include "LCD4_macro.inc"	; ���� �������� ������ � �������� 

.list				; ��������� ��������

.def	LastIcpLow = R0		; ���������� �������� �������, ��.����
.def	LastIcpHigh = R1	; ���������� �������� �������, ��.����
.def	NewIcpLow = R2		; ���������� �������� �������, ��.����
.def	NewIcpHigh = R3		; ���������� �������� �������, ��.����

.def	temp = R16		; ��������������� �������
.def	temp1 = R17		; ������ ��������������� �������

.def	count = R18		; ����������� ��������-��������

.def	fnota = R19		; ������� ������� ����
.def	dnota = R20		; ������������ ������� ����
.def	loop = R21		; ������ ��� ��������� ��������

.def	flag = R22		; �������� �������
.def	addr = R23		; ��� ������ ������
.def	comm = R24		; ��� ������� ������

.equ	F_CAPTURE = 1		; ���� ������� ��������
.equ	F_RECEIVE = 2		; ���� ���������� ����� �������
.equ	F_RECEIVE_OK = 3	; ���� ���������� ��������� �������

.equ	BIT_LINE = 0x2c		; 0x2c00=11264(*0,25=2816���) ����� ����������� ���� (0,25��� ������� �1)
				; ��� ������ Supra: ���������� "0"=2��, ���������� "1"=3��
.equ	ST_MIN = 0x59		; 0x5900=22784(*0,25=5696���) ������� ��������� �������
.equ	ST_MAX = 0x66		; 0x66ff=26367(*0,25=6592���) �������� ��������� �������
				; ����� ��������� ������� ������  Supra = 6��
.equ	ADDRESS = 0b00000010	; ��� ������ ������

;�������������� ����� ������ ���
;==========================================================
	.dseg			; �������� ������� ���
	.org	0x60		; ������������� ������� ����� ��������
LastI:	.byte	2		; ���������� �������� �������� �������
NewI:	.byte	2		; ����� �������� �������� �������

;������ ������������ ����
;==========================================================
	.cseg 			; ����� �������� ������������ ����
	.org	0		; ��������� �������� ������ �� ����

start:	rjmp	init		; ������� �� ������ ���������
	reti			; ������� ���������� 0
	reti			; ������� ���������� 1
	rjmp	prer1		; ���������� �� ������� ������� T1
	reti			; ���������� �� ���������� T1
	reti			; ���������� �� ������������ T1
	reti			; ���������� �� ������������ T0
	reti			; ���������� UART ����� ��������
	reti			; ���������� UART ������� ������ ����
	reti			; ���������� UART �������� ���������
	reti			; ���������� �� �����������
	reti			; ���������� �� ��������� �� ����� ��������
	reti			; ������/������� 1. ���������� B 
	reti			; ������/������� 0. ���������� B 
	reti			; ������/������� 0. ���������� A 
	reti			; USI ��������� ����������
	reti			; USI ������������
	reti			; EEPROM ����������
	reti			; ������������ ��������� �������

;������ �������������
;==========================================================

;������������� �����
init:	ldi	temp, RAMEND		; ����� ������ ������� ����� 
	out	SPL, temp		; ������ ��� � ������� �����

;������������� ������ �/�
	clr	temp			; ������������� ����� PB
	out	PORTB, temp		; ��� ������� PB = 0
	ldi	temp, 0xFF		; temp=0xFF
	out	DDRB, temp		; ��� ������� PB �� �����

	ldi 	temp, 0x7F		; ������������� ����� PD
	out	PORTD, temp		; �������� ���������� ���������
	clr	temp			; �������� temp
	out	DDRD, temp		; ���� PD �� ����

;������������� (����������) �����������
	ldi	temp, 0x80
	out	ACSR, temp

;������������� ������� T1
	ldi	temp, 0x09		; �������� ����� CTC, ��� ������������
	out	TCCR1B, temp
	clr	temp			; ��������� ����
	out	TCCR1A, temp

	ldi	temp,0b00001000		; ����������� ����� ����������
	out	TIMSK, temp		; ��������� ���������� �� �������

	ldi	temp, 0xFF
	out	OCR1AH, temp		; ������������� �� ��������
	out	OCR1AL, temp		; ������� ����������

;������������� ����������
	clr	flag			; ����� ����� � 0
	clr	dnota			; ����������� ��������
	clr	LastIcpLow		; ��������� �������� �������
	clr	LastIcpHigh		; ��. � ��. ������
	clt				; ���� �=0, ��������� �� - ��������

;������������� �������
	rcall	wait			; ����� ��� �������� �������
	INIT_LCD			; ������������� �������
	rcall	newCharRus		; ������ ������� �������� � �������
	
	WR_DDADR 1			; ��������� �� 1-� ������
	ldi	ZH, high(str1*2)	; �������� ������ ��������
	ldi	ZL, low(str1*2)		; 1-� ������ � ������� Z
	rcall	printString		; ����� ������ �� �������

	WR_DDADR 0x43			; ��������� �� 2-� ������
	ldi	ZH, high(str2*2)	; �������� ������ ��������
	ldi	ZL, low(str2*2)		; 2-� ������ � ������� Z
	rcall	printString		; ����� ������ �� �������

;������ �������� ���������
;==========================================================
main:	sei				; ��������� ��� ����������
	rcall	handle			; ������������ ����� �������
	rcall	signal			; ������������ ��������� �������
	rcall	muz			; ������������ ��������������� �������
	rjmp	main			; ���������� �����

;���� �������
;==========================================================
handle:	push	temp			; ��������� � ����� ��������
	push	temp1

	cpi	flag, F_CAPTURE		; �������� �������?
	brne	h_exit			; ���� ���, �������

	clr	flag			; ����� ���������� ����

;�������� ����������� �������� ������� �� 0
	clr	temp			; �������� temp
	cp	LastIcpHigh,temp	; ������� ���� ������� �������=0?
	brne	h1			; ���� ���, ��� �� ���������
	cp	LastIcpLow,temp		; ���� ������� ����=0,
	breq	h_save			; ����� � ����������� �������� �������

;��������� ����������� � ������ �������� �������
h1:	cp	LastIcpHigh,NewIcpHigh	; ������ ��� ����� ������ ������?
	brne	h2			; ���� ������� ����� �������� �����,
	cp	LastIcpLow,NewIcpLow	; ���������� ������� �����
h2:	brsh	h3			; ���� ������ ������ ������, �� h3

;���������� ������� ��������
	mov	temp1,NewIcpLow		; ��������� ����� ������ �������
	mov	temp,NewIcpHigh		; ��.���� - � temp1, ��.���� - � temp
	sub	temp1, LastIcpLow	; �� ������ �������� ������ ��������
	sbc	temp, LastIcpHigh	; Period=New-Last
	rjmp	h4

h3:	ldi	temp1, 0xFF		; temp1=0xFF
	ldi	temp, 0xFF		; temp=0xFF
	sub	temp1, LastIcpLow	; temp=0xFF-Last
	sub	temp, LastIcpHigh
	add	temp1, NewIcpLow
	adc	temp, NewIcpHigh	; PeriodHigh=New+(FF-Last)

h4:	brts	h_recv			; ���� �=1, ��-����, ��� �� ���������

;��������� ��������� �������� - �������� ��������� �������
h_idle:	cpi	temp, ST_MIN		; ���������� ����� �������� � ���������
	brlo	h_clr			; ���� ������, �� �������

	cpi	temp, ST_MAX		; ���������� ����� �������� � ����������
	brsh	h_clr			; ���� ������, �� �������

	set				; ������ �=1, ������ ��������� �������
	ldi	count, 16		; ��������� �� - ����, count=16
	rjmp	h_save			; ����� � ����������� �������� �������

;��������� ��������� �������� - ���� ���������, ������������ �������
h_recv:	cpi	count, 0		; ��� ������� �������?
	brne	h_byte			; ���� ���, ���������� ��������� ����

	ldi	flag, F_RECEIVE		; ����� ���������� ���� ���������� �����
	clt				; ������ �=0, ��������� �� - ��������
	rjmp	h_clr			; � ����� � ���������� �������� �������

;��������� ����
h_byte:	lsl	comm			; �������� ���� �������
	cpi	temp, BIT_LINE		; ���������� ������� � �������
	brlo	h_0			; ���� ������, ��� ������� = 0
	sbr	comm, 0b00000001	; ����� ��� ������� = 1
	rjmp	h_end			; ��������� ����������� ����
h_0:	cbr	comm, 0b00000001	; �������� ������� ��� �������

h_end:	dec	count			; ��������� �� 1 ���������� ���
	cpi	count, 8		; ��� ������ ������ �������?
	brne	h_save			; ���� ���, ����� � ����������� ��������
	mov	addr, comm		; ��������� ��������� ���� � addr
	rjmp	h_save			; ����� � ����������� �������� �������

h_clr:	clr	NewIcpLow		; �������� �������� �������
	clr	NewIcpHigh

h_save:	mov	LastIcpLow,NewIcpLow	; ��������� ����� �������� �������
	mov	LastIcpHigh,NewIcpHigh

h_exit:	pop	temp1			; ��������������� ��������
	pop	temp
	ret

;��������� �������
;==========================================================
signal:	cpi	flag, F_RECEIVE		; ������ ������?
	brne	s_exit			; ���� ���, �����

	clr	flag			; ���������� ����
	rcall	printCod		; ������� �� ������� ��� ������� ������

	cpi	addr, ADDRESS		; ������� ������ ����� ������?
	brne	s_exit			; ���, �����

	cpi	comm, 10		; �� ������ ������ ������ � ������?
	brsh	s_exit			; ���, �����

	ldi	flag, F_RECEIVE_OK	; ������ ���������
	cpi	comm, 9			; ������ 9? 
	brne	s_exit			; ���, ������� ����.����
	ldi	comm, 3			; ��, �������� ����� �3

s_exit:	ret

;����� �������
;==========================================================
muz:	push	temp			; ��������� ������� temp � ����
	cpi	flag, F_RECEIVE_OK	; ������ ���������?
	brne	m_exit			; ���� ���, �����

	clr	flag			; 
	dec	comm			; ��������� comm �� 1
	brmi	m_exit

	mov	YL, comm		; ��������� �����, ���
	ldi	ZL, low(tabm*2)		; �������� ������ �������
	ldi	ZH, high(tabm*2)
	rcall	addw			; � ������������ 16-���������� ��������

	lpm	XL, Z+			; ��������� ������ �� �������
	lpm	XH, Z			; � �������� � X

;��������������� �������
m_1:	mov	ZH, XH			; ���������� � Z ������ �������
	mov	ZL, XL

m_2:	lpm	temp, Z			; ��������� ��� ����
	cpi	temp, 0xFF		; ��������� �� ����� �� �������
	breq	m_1			; ���� �����, �������� ������� �������

	andi	temp, 0x1F		; �������� �� ���� �������
	mov	fnota, temp		; ���������� � ������� ������� ����
	lpm	temp, Z+		; ��� ��� ����� ��� ����
	rol	temp			; �������� ���, ��� �� ��� �������
	rol	temp			; ������� ����� ��������
	rol	temp
	rol	temp
	andi	temp, 0x07		; ��������� ��� ������������ ��������
	mov	dnota, temp		; ��������� �� � ������ ������������

	rcall	nota			; � ������������ ��������������� ����
	cpi	flag, F_RECEIVE_OK	; ��������� ����� �������?
	brne	m_2			; ���, � ������ ����� (��������� ����)

m_exit:	pop	temp			; ��������������� ������� temp �� �����
	ret

;������������ 16-�� ���������� ��������
;==========================================================
addw:	push	YH
	lsl	YL			; ��������� ������� ���������� �� 2
	ldi	YH, 0			; ������ ���� ������� ���������� = 0
	add	ZL, YL			; ���������� ��� ���������
	adc	ZH, YH
	pop	YH
	ret

;������������ ���������� ����� ����
;==========================================================
nota:	push	ZH			; ��������� �������� � ����
	push	ZL
	push	YL
	push	temp
	push	temp1

	cpi	fnota, 0		; �������� �� ����� ��
	breq	nt1			; ���� �����, ��������� ����� � ��������

	mov	YL, fnota		; ��������� �����, ��� ��������
	ldi	ZL, low(tabkd*2)	; ����������� ������� ��� ������� ����
	ldi	ZH, high(tabkd*2)
	rcall	addw			; � ������������ 16-���������� ��������

	lpm	temp, Z+		; ��������� ��.������ �� ��� ������� ����
	lpm	temp1, Z		; ��������� ��.������ �� ��� ������� ����
	out	OCR1AH, temp1		; �������� � ��.����� �������� ����������
	out	OCR1AL, temp		; �������� � ��.����� �������� ����������

	ldi	temp, 0x40		; �������� ����
	out	TCCR1A, temp

nt1:	rcall	wait			; ��������

	ldi	temp, 0			; ��������� ����
	out	TCCR1A, temp

	ldi	dnota,0			; ���������� �������� 
	rcall	wait			; ����� ����� ������

	pop	temp1			; ��������������� �������� �� �����
	pop	temp
	pop	YL
	pop	ZL
	pop 	ZH
	ret

;������������ ��������
;==========================================================
wait:	push	ZH			; ��������� �������� � ����
	push	ZL
	push	YH
	push	YL

	mov	YL, dnota		; ��������� �����, ��� ��������
	ldi	ZL, low(tabz*2)		; ������ ����������� ��������
	ldi	ZH, high(tabz*2)
	rcall	addw			; � ������������ 16-���������� ��������

	lpm	YL, Z+			; ������ ������ ���� ������������ ��������
	lpm	YH, Z			; ������ ������ ���� ������������ ��������

w0:	clr	ZL			; �������� ����������� ���� Z
	clr	ZH

w1:	ldi	loop,255		; ���� ��������
w2:	dec	loop			; ������ ���������� ����
	brne 	w2

	cpi	flag, F_CAPTURE		; �������� �������?
	brne	w_1			; ���� ���, ����������

	ldi	temp, 0			; ���� ��, ��������� ����
	out	TCCR1A, temp
	rcall	handle			; � ������������ �����
	brts	w0			; ���� �=1, ��-����, �����

w_1:	cpi	flag, F_RECEIVE		; �������� ������?
	brne	w_2			; ���� ���, ����������
	rcall	signal			; � ������������ ���������

w_2:	cpi	flag, F_RECEIVE_OK	; ������ ���������?
	breq w3				; ���� ��, �������

	adiw	R30, 1			; ���������� ����������� ���� Z �� �������
	cp	YL, ZL			; �������� �������� �������
	brne	w1
	cp	YH, ZH			; �������� �������� �������
	brne	w1

w3:	pop	YL			; ��������������� �������� �� �����
	pop	YH
	pop	ZL
	pop 	ZH
	ret				; ���������� ������������

.include "LCD4.asm"			; ������������� ����������

;������ ����� (�������) �������� � ��������������
;==========================================================
newCharRus:
	WR_CGADR 0			; ��������� �� ������ ���������������
	WR_DATA 0b00010101		; �
	WR_DATA 0b00010101
	WR_DATA 0b00010101
	WR_DATA 0b00001110
	WR_DATA 0b00010101
	WR_DATA 0b00010101
	WR_DATA 0b00010101
 	WR_DATA 0b00000000

	WR_CGADR 8			; 1
	WR_DATA 0b00010001		; �
	WR_DATA 0b00010001
	WR_DATA 0b00010011
	WR_DATA 0b00010101
	WR_DATA 0b00011001
	WR_DATA 0b00010001
	WR_DATA 0b00010001
	WR_DATA 0b00000000

	WR_CGADR 16			; 2
	WR_DATA 0b00011111		; �
	WR_DATA 0b00010001
	WR_DATA 0b00010001
 	WR_DATA 0b00010001
	WR_DATA 0b00010001
 	WR_DATA 0b00010001
	WR_DATA 0b00010001
	WR_DATA 0b00000000

	WR_CGADR 24			; 3
	WR_DATA 0b00010001		; �
	WR_DATA 0b00010001
	WR_DATA 0b00010001
 	WR_DATA 0b00001010
	WR_DATA 0b00000100
 	WR_DATA 0b00001000
	WR_DATA 0b00010000
	WR_DATA 0b00000000

	WR_CGADR 32			; 4
	WR_DATA 0b00001111		; �
	WR_DATA 0b00000101
 	WR_DATA 0b00000101
	WR_DATA 0b00000101
 	WR_DATA 0b00000101
	WR_DATA 0b00010101
	WR_DATA 0b00001001
	WR_DATA 0b00000000

	WR_CGADR 40			; 5
	WR_DATA 0b00010001		; �
	WR_DATA 0b00010001
 	WR_DATA 0b00010001
	WR_DATA 0b00010001
 	WR_DATA 0b00010001
	WR_DATA 0b00010001
	WR_DATA 0b00011111
	WR_DATA 0b00000001

	WR_CGADR 48			; 6
	WR_DATA 0b00000100		; �
	WR_DATA 0b00001110
 	WR_DATA 0b00010101
	WR_DATA 0b00010101
 	WR_DATA 0b00010101
	WR_DATA 0b00001110
	WR_DATA 0b00000100
	WR_DATA 0b00000000
	
	ret

;����� ������ �� ����������� ������ �� ������� (����� � Z)
;==========================================================
printString:
ps_1:	lpm	temp1, Z+		; ��������� ������ � temp1
	cpi	temp1, 0xFF		; ����� ������?
	breq	ps_exit			; ���� ��, �������
	rcall	DATA_WR			; ����� ������� ������ �� R17 �� �������
	rjmp	ps_1			; ��� �� ��������� ������
ps_exit:	ret

;����� �� ������� ����� ������ � ������� ������
;==========================================================
printCod:
	LCDCLR				; �������� �����
	WR_DDADR 0			; ����� �� ������� ������ � �������
	WR_DATA 0x4B			; K
	WR_DATA 0x6F			; o
	WR_DATA 0x67			; g
	WR_DATA 0x3A			; :
	WR_DATA 0x20			; ������

	mov	temp1, addr		; ��������� addr � ������� temp1
	rcall	printValue		; � ������������ ������ 2-��. �����
	mov	temp1, comm		; ��������� comm � ������� temp1
	rcall	printValue		; � ������������ ������ 2-��. �����

	ret

;����� �� ����� ����������� �������� �� temp1
;==========================================================
printValue:
	clr	temp			; �������� temp
s1:	cpi	temp1, 10		; temp1 >= 10 ?
	brlo	s2			; ���� ���, ��� �� ������

	inc	temp			; ����� temp++
	subi	temp1, 10		; temp1 - 10
	rjmp	s1			; ��� �� �������� temp1

s2:	cpi	temp, 0			; temp=0? 
	breq	s3			; ���� ��, ��� �� ������ temp1
	push	temp1			; ����� ��������� temp1 � ����
	ldi	temp1, 0x30		; temp1=0x30
	add	temp1, temp		; temp1+=temp
	rcall	DATA_WR			; �������� ������ � ����� temp1
	pop	temp1			; ��������������� temp1 �� �����

s3:	ldi	temp, 0x30		; temp=0�30
	add	temp1, temp		; temp1+=temp
	rcall	DATA_WR			; �������� ������ � ����� temp1
	WR_DATA 0x20			; ������

	ret

;������������ ��������� ����������
;==========================================================
;��������� ���������� �� ������� �������� ������� �1
prer1:	cli				; ��������� ��� ����������

	ldi	temp, 0xFF
	out	OCR1AH, temp		; ������� ���������� �� ��������
	out	OCR1AL, temp
		
	in	NewIcpLow, ICR1L	; ��������� �������� �������,
	in	NewIcpHigh, ICR1H	; ������� � ������� �����

	ldi	flag, F_CAPTURE		; ���� - �������� �������

	sei				; ��������� ��� ����������
	reti

;������ ������ �� �������
;==========================================================
;������� �����
str1:   .db	0x48,0x41,0,0x4D,1,0x54,0x45,0x20,5,1,6,0x50,3,0xFF
;�� ������
str2:   .db	0x48,0x41,0x20,2,3,4,0x62,0x54,0x45,0xFF

;������� ��������
;==========================================================
tabz:   .dw	128,256,512,1024,2048,4096,8192

;������� ������������� �������
;==========================================================
tabkd:	.dw	0
	.dw	4748,4480,4228,3992,3768,3556,3356,3168,2990,2822,2664,2514
	.dw	2374,2240,2114,1996,1884,1778,1678,1584,1495,1411,1332,1257
	.dw	1187,1120,1057, 998, 942, 889, 839, 792

;������� ����� ���� �������
;==========================================================
tabm:	.dw	mel1*2,mel2*2,mel3*2,mel4*2
	.dw	mel5*2,mel6*2,mel7*2,mel8*2

;������� �������
;==========================================================

;� ����� ����� ��������
mel1:	.db	109,104,109,104,109,108,108, 96,108,104 
	.db	108,104,108,109,109, 96,109,104,109,104 
	.db	109,108,108, 96,108,104,108,104,108,141 
	.db	 96,109,111, 79, 79,111,111,112, 80, 80 
	.db	112,112,112,111,109,108,109,109, 96,109 
	.db	111, 79, 79,111,111,112, 80, 80,112,112 
	.db	112,111,109,108,141,128, 96,255 

;������� ��������� ����
mel2:	.db	109,110,141,102,104,105,102,109,110,141 
	.db	104,105,107,104,109,110,141,104,105,139 
	.db	109,110,173, 96,114,115,146,109,110,112 
	.db	109,114,115,146,107,109,110,114,112,110 
	.db	146,109,105,136,107,105,134,128,128,102 
	.db	105,137,136,128,104,107,139,137,128,105 
	.db	109,141,139,128,110,109,176,112,108,109 
	.db	112,144,142,128,107,110,142,141,128,105 
	.db	109,139,128,173,134,128,128,109,112,144 
	.db	142,128,107,110,142,141,128,105,109,139 
	.db	128,173,146,128, 96,255

;� ���� �������� ������
mel3:	.db	132,141,141,139,141,137,132,132,132,141 
	.db	141,142,139,176,128,144,146,146,154,154 
	.db	153,151,149,144,153,153,151,153,181,128 
	.db	 96,255

;Happy births to you
mel4:	.db	107,107,141,139,144,143,128,107,107,141
	.db	139,146,144,128,107,107,151,148,146,112
	.db	111,149,117,117,148,144,146,144,128,255

;� ���� ���������� ������
mel5:	.db	 99,175,109,107,106,102, 99,144,111,175 
	.db	 96, 99,107,107,107,107,102,104,170, 96 
	.db	 99,109,109,109,109,107,106,143,109,141 
	.db	 99,109,109,109,109,104,106,171, 96, 99 
	.db	111,109,107,106,102, 99,144,111,143,104 
	.db	114,114,114,114,109,111,176, 96,104,116 
	.db	112,109,107,106, 64, 73,143,107,131, 99 
	.db	144, 80, 80,112,111, 64, 75,173,128,255

;�� ���������� "������� ������"
mel6:	.db	105,109,112,149,116, 64, 80,148,114, 64 
	.db	 78,146,112, 96,105,105,109,144,111, 64 
	.db	 80,145,112, 64, 81,178, 96,117,117,117 
	.db	149,116, 64, 82,146,112, 64, 79,146,144 
	.db	 96,105,105,107,141,108,109,112,110,102 
	.db	104,137,128, 96,105,105,105,137,102, 64 
	.db	 73,142,105,107,109, 64, 75,137, 96,105 
	.db	105,105,137,102,105,142,112, 64, 82,180 
	.db	 96,116,116,116,148,114,112,142,109, 64 
	.db	 78,146,144, 96,105,105,107,141,108,109 
	.db	112,110,102,104,169, 96, 96,255

;������
mel7:	.db	107,104,141,139,102,105,104,102,164,128 
	.db	104,107,109,109,109,111,114,112,111,109 
	.db	144,139,128,109,111,144, 96,111,109,104 
	.db	107,105,173,128,111,109,112,107,111,109 
	.db	109,107,102,104,134,132,128,100,103,107
	.db	107,107,107,139,112,100,103,102,102,102 
	.db	134,102,103,107,105,107,108,108,108,108 
	.db	107,105,107,108,144,142,128,112,107,110 
	.db	140,112,105,108,107,107,107,105,140,139 
	.db	139,112,103,102,103,105,108,107,105,103 
	.db	128,112,107,110,108,108,108,140,112,105 
	.db	108,107,107,107,139,112,103,102,103,105 
	.db	108,107,105,103,105,139,132,128, 96, 96 
	.db	 96,255

;������
mel8:	.db	102,105,141,107,105,141, 96,107,171, 96 
	.db	104,105,139,104,105,166,128,160,109,110 
	.db	144,110,109,144, 96,110,174,128,110,112 
	.db	146,112,114,205,117,117,149,116,114,149
	.db	 96,116,174,128,110,112,146,112,114,205 
	.db	128,102,105,141,107,105,141, 96,107,171 
	.db	128,104,105,139,104,105,166,128,128,117 
	.db	117,149,116,114,149, 96,116,174,128,110
	.db	112,146,112,114,205,128,102,105,141,107 
	.db	105,141, 96,107,171,128,104,105,139,104
	.db	105,166,128,128, 96,255 
