;
; AtmelLabs.asm
;
; Created: 20.05.2020 14:57:41
; Author : EAZY_LAPTOP
;

.include "m8515def.inc"

.def power = r16
.def speed = r17
.def mode = r18
.def temp = r19
.def temp2 = r20

.cseg
.org $000 RJMP START
.org $001 RJMP INT0_HAND
.org $002 RJMP INT1_HAND
.org $00D RJMP INT2_HAND
.org $007 RJMP TIMER0_OVF_HAND
.org $00E RJMP TIMER0_COMP_HAND

START:
	SER temp
	OUT DDRA, temp

	LDI temp, 0
	OUT PORTA, temp

	LDI temp, 0b11100000
	OUT GICR, temp

	LDI temp, 0b00001111
	OUT MCUCR, temp
	
	LDI temp, 1
	OUT EMCUCR, temp

	SEI

	MAIN_LP:
		RJMP MAIN_LP

TICK:
	CLR temp
	
	CPI mode, 1
	BREQ TM_1

	CPI mode, 2
	BREQ TM_2

	RJMP TDEFAULT

	TM_1:
		LDI temp, 15
		IN temp2, PORTA
		EOR temp2, temp
		OUT PORTA, temp2
		RJMP TDEFAULT

	TM_2:
		IN temp2, PORTA
		SBRS temp2, 3
		RJMP TM_2_ELSE
		
		LDI temp, 1
		OUT PORTA, temp
		RJMP TDEFAULT

		TM_2_ELSE:
			IN temp2, PORTA
			LSL temp2
			OUT PORTA, temp2
			RJMP TDEFAULT

	TDEFAULT:
RET
	
CHANGE_SPEED:
	CLR temp
	
	CPI speed, 0
	BREQ CS_0
	
	CPI speed, 1
	BREQ CS_1
	
	CPI speed, 2
	BREQ CS_2
	
	RJMP CS_DEFAULT
	
	CS_0:
		LDI temp, 0xFF
		RJMP CS_DEFAULT
		
	CS_1:
		LDI temp, 0xAA
		RJMP CS_DEFAULT

	CS_2:
		LDI temp, 0x55
		RJMP CS_DEFAULT

	CS_DEFAULT:
		OUT OCR0, temp
RET

CHANGE_MODE:
	CLR temp
	OUT PORTA, temp

	CPI power, 0
	BREQ CM_DEFAULT

	CPI mode, 0
	BREQ CM_0

	CPI mode, 1
	BREQ CM_1

	CPI mode, 2
	BREQ CM_2

	RJMP CM_DEFAULT

	CM_0:
		CLR temp
		OUT TIMSK, temp

		LDI temp, 0b00000101
		OUT TCCR0, temp

		LDI temp, 0x0F
		OUT PORTA, temp

		RJMP CM_DEFAULT

	CM_1:
		LDI temp, 0x02
		OUT TIMSK, temp

		LDI temp, 0b01001101
		OUT TCCR0, temp

		LDI temp, 0b00000101
		OUT PORTA, temp

		RJMP CM_DEFAULT

	CM_2:
		LDI temp, 0x01
		OUT TIMSK, temp

		LDI temp, 0b01000101
		OUT TCCR0, temp

		LDI temp, 0x01
		OUT PORTA, temp

		RJMP CM_DEFAULT

	CM_DEFAULT:
RET

INT0_HAND:
	CLI

	CPI power, 0
	BREQ SET_PW

	RJMP CLR_PW

	SET_PW:
		LDI power, 1

		CLR mode
		CLR speed
		RCALL CHANGE_MODE
		RCALL CHANGE_SPEED

		IN temp2, TCCR0
		SBR temp2, 0
		SBR temp2, 2
		CBR temp2, 1
		OUT TCCR0, temp2

		RJMP PW_NEXT

	CLR_PW:
		LDI power, 0

		CLR temp2
		OUT TCCR0, temp2
		OUT PORTA, temp2

	PW_NEXT:
		SEI
RETI

INT1_HAND:
	CLI

	CPI mode, 2
	BRNE MD_INC

	CLR mode
	RJMP MD_NEXT

	MD_INC:
		INC mode
	
	MD_NEXT:
		RCALL CHANGE_MODE
	
	SEI
RETI

INT2_HAND:
	CLI

	CPI speed, 2
	BRNE SPD_INC

	CLR speed
	RJMP SPD_NEXT

	SPD_INC:
		INC speed
	
	SPD_NEXT:
		RCALL CHANGE_SPEED
	
	SEI
RETI


TIMER0_OVF_HAND:
	CLI

	SBRC power, 0
	RCALL TICK

	SEI
RETI

TIMER0_COMP_HAND:
	CLI

	SBRC power, 0
	RCALL TICK

	SEI
RETI
	
		


