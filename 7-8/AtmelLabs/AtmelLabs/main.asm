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
.org $009 RJMP USART_RX_HAND
.org $007 RJMP TIMER0_OVF_HAND
.org $00E RJMP TIMER0_COMP_HAND


START:
	SER temp
	OUT DDRA, temp

	LDI temp, 0
	OUT PORTA, temp
	
	LDI temp, 0x06
	OUT UBRRL, temp

	LDI temp2, 0b10010000
	OUT UCSRB, temp2

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

USART_RX_HAND:
	CLI

	IN temp2, UDR

	CPI temp2, 0x65
	BREQ US_POWER

	CPI temp2, 0x6D 
	BREQ US_MODE

	CPI temp2, 0x73
	BREQ US_SPEED

	RJMP US_DEFAULT

	US_POWER:
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

			RJMP US_DEFAULT

		CLR_PW:
			LDI power, 0

			CLR temp2
			OUT TCCR0, temp2
			OUT PORTA, temp2

			RJMP US_DEFAULT

	US_MODE:
		CLI

		CPI mode, 2
		BRNE MD_INC

		CLR mode
		RJMP MD_NEXT

		MD_INC:
			INC mode
	
		MD_NEXT:
			RCALL CHANGE_MODE

		RJMP US_DEFAULT

	US_SPEED:
		CPI speed, 2
		BRNE SPD_INC

		CLR speed
		RJMP SPD_NEXT

		SPD_INC:
			INC speed
	
		SPD_NEXT:
			RCALL CHANGE_SPEED
		
		RJMP US_DEFAULT

	US_DEFAULT:
		SEI
RETI
	
		


