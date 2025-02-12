; EPSON COLOUR COPY
; FOR RX/FX80s
; (C) A.PENNELL 1984

ESC	EQU 27
	ORG	64000
;setup
	LD	A,152
	OUT	($7F),A
BEGIN:	LD	A,ESC
	CALL	OUTCH
	LD	A,"A"
	CALL	OUTCH
	LD	A,3
	CALL	OUTCH ;set up small line feeds
	LD	C,0 ;zero X counter
NLINE:	LD	A,ESC
	CALL	OUTCH
	LD	A,"*"
	CALL	OUTCH
	LD	A,4 ;put in mode 4
	CALL	OUTCH
	LD	A,16
	CALL	OUTCH
	LD	A,2
	CALL	OUTCH ;set up for 3*176 bits of data
	LD	B,0 ;zero Y counter
NXY:	PUSH	BC
	CALL	#22AA ;HL=screen memory
	LD	B,A
	INC	B
	LD	A,1
L1:	RRCA
	DJNZ	L1
	AND	(HL) ;Z if ink,NZ if paper
	EX	AF,AF'
	LD	A,H
	RRCA
	RRCA
	RRCA
	AND	3
	OR	#58
	LD	H,A ;HL=atribute byte
	LD	B,(HL) ;B=ATR
	EX	AF,AF'
	LD	A,B ;A=ATTR
	JR	NZ,INK
	RRCA	;if PAPER then /8
	RRCA
	RRCA
INK:	AND	7 ;mask other bits
	LD	HL,TABLE
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	D,0
	ADD	HL,DE ;HL=data specified colour
	LD	B,3 ;=no of bytes per pixel
OUTLP:	LD	A,(HL) ;read byte
	CALL	OUTCH ;send it
	INC	HL
	DJNZ	OUTLP ;do 3 bytes
	POP	BC ;restore X & Y
	INC	B
	LD	A,B
	CP	176
	JR	C,NXY ;do all 176
	LD	A,13 ;end of line so do a CR
	CALL	OUTCH
	LD	A,10 ;LF code
	CALL	OUTCH
	INC	C
	JR	NZ,NLINE ;do all 256 X pixels
	LD	A,ESC ;resert line feed distance
	CALL	OUTCH
	LD	A,"A"
	CALL	OUTCH
	LD	A,12
	CALL	OUTCH
	RET	;finish
;data table for colour patterns
TABLE:	DEFB	%11100000 ;black
	DEFB	%11100000
	DEFB	%11100000
	DEFB	0
	DEFB	%11000000 ;blue
	DEFB	%01100000
	DEFB	%11000000
	DEFB	0
	DEFB	%10100000 ;red
	DEFB	%01000000
	DEFB	%10100000
	DEFB	0
	DEFB	%00100000 ;magenta
	DEFB	%01000000
	DEFB	%10000000
	DEFB	0
	DEFB	%01100000 ;green
	DEFB	%00000000
	DEFB	%01100000
	DEFB	0
	DEFB	%01000000 ;cyan
	DEFB	%00000000
	DEFB	%01000000
	DEFB	0
	DEFB	%00000000 ;yellow
	DEFB	%01000000
	DEFB	%00000000
	DEFB	0
	DEFB	%00000000 ;white
	DEFB	%00000000
	DEFB	%00000000
	DEFB	0

; OUTCH - the send character to printer routine
OUTCH:	PUSH	BC
	PUSH	AF
BUSY:	IN	A,($5F)
	BIT	7,A
	JR	NZ,BUSY
	POP	AF
	OUT	($3F),A
	LD	A,$FF
	OUT	($5F),A
	NOP
	LD	A,$00
	OUT	($5F),A
	CALL	#1F54 ;test break
	JP	NC,#0D00; error if pressed
	POP	BC
	RET
