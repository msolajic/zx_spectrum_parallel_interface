ESC	EQU $1B
CR	EQU $0D
LF	EQU $0A
; Load this routine using the BASIC loader to set up the interface and P channel hook

	ORG 23296	;BASIC LPRINT & LLIST support
	CP $A5		;token?
	JP NC, $09F4	;yes, tokenize
	CP CR		;CR?
	JR Z, CRLF	;yes, print CRLF
	CALL OUTBYT
	RET
CRLF:	CALL OUTBYT
	LD A, LF
	CALL OUTBYT
	RET

	ORG 23330	;Screen dump
	LD A, ESC	
	CALL OUTBYT
	LD A, "A"
	CALL OUTBYT
	LD A, $08	;set line spacing to 8/72 inch
	CALL OUTBYT
	LD BC,$0000

SCREEN: PUSH BC
	PUSH DE
	PUSH HL

	LD A, CR
	CALL OUTBYT
	LD A, LF
	CALL OUTBYT	;CRLF

	LD A, ESC
	CALL OUTBYT
	LD A, "K"
	CALL OUTBYT
	LD A, $00
	CALL OUTBYT
	LD A, $01
	CALL OUTBYT	; Normal Density (60 dpi) 256 bytes wide.

	POP HL
	POP DE
	POP BC

ROW:	LD A, B
	AND $F8
	ADD A, $40
	LD H, A
	LD A, B
	AND $07
	RRCA
	RRCA
	RRCA
	ADD A, C
	LD L, A
	PUSH BC
	LD C, $80

CHAR:	LD B, $08

STICK:	LD A, (HL)
	INC H
	AND C
	JR NZ, BITON
	SLA D
	JR BITOFF

BITON:	SLL D

BITOFF:	DJNZ STICK

	PUSH BC
	PUSH DE
	PUSH HL
	LD A, D
	CALL OUTBYT
	POP HL
	POP DE
	POP BC

	LD A, H
	SUB $08
	LD H, A
	RRC C
	JR NC, CHAR
	POP BC
	INC C
	LD A, $20
	CP C
	JR NZ, ROW

	LD C, $00
	INC B
	LD A, $18
	CP B
	JR NZ, SCREEN

	LD A, ESC
	CALL OUTBYT
	LD A, "2"
	CALL OUTBYT	;set line spacing to 1/6 inch
	RET

OUTBYT: PUSH AF		;common routine for output
BUSY2:	IN A, ($5F)
	BIT 7, A
	JR NZ, BUSY2
	POP AF
	OUT ($3F), A
	LD A, $FF
	OUT ($5F), A
	NOP
	LD A, $00
	OUT ($5F), A
	RET
