#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

int power = 0;
int speed = 0;
int mode = 0;

void tick() {
	
	switch (mode) {
		
		case 1:
			PORTA ^= 0b00001111;
			break;
		
		case 2:
			if ((PORTA & (1 << 3)) != 0) {
				PORTA = (1 << 0);
			}
			else {
				PORTA <<= 1;
			}
			break;
		
		default:
			break;

	}
}

void changeSpeed() {
	// Изменение скорости только для СТС, т.е. для mode = 1
	switch (speed) {
		case 0:
			OCR0 = 0xFF;
			break;
			
		case 1:
			OCR0 = 2 * 0xFF / 3;
			break;
			
		case 2:
			OCR0 = 0xFF / 3;
			break;
			
		default:
			OCR0 = 0xFF;
			break;
		
	}
}

void changeMode() {
	PORTA = 0;
	
	if (power == 0) {
		return;
	}
	
	switch (mode) {
		case 0:
			// Нормальный режим
			TIMSK = 0;
			TCCR0 = 0b00000101;
			PORTA = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3);
			break;
			
		case 1:
			// СТС
			TIMSK = 0b00000010;
			
			TCCR0 = 0b01001101;
			PORTA = (1 << 0) | (1 << 2);
			break;
			
		case 2:
			// Быстрый ШИМ
			TIMSK = 0b00000001;
			TCCR0 = 0b01000101;
			PORTA = (1 << 0);
			break;
			
		default:
			PORTA = 0;
			break;
	
	}
}

ISR(TIMER0_COMP_vect)
{
	cli();
	
	if (power) {
		tick();
	}
	
	sei();
}

ISR(TIMER0_OVF_vect)
{
	cli();
	
	if (power) {
		tick();
	}
	
	sei();
}

ISR(USART_RX_vect)
{
	cli();
	
	switch (UDR) {
		case 'm':
			mode = (mode == 2) ? 0 : mode + 1;
			changeMode();
		
			break;
		
		case 's':
			speed = (speed > 2) ? 0 : speed + 1;
			changeSpeed();
		
			break;
		
		case 'e':
			power = (power == 1) ? 0 : 1;
		
			if (power) {
				mode = 0;
				speed = 0;
				changeMode();
				changeSpeed();
				TCCR0 = (TCCR0 & ~ (1<<1)) | (1<<0) | (1<<2);
			}
			else {
				TCCR0 = 0;
				PORTA = 0;
			}
			break;
		
		default:
			break;
	}
	
	sei();
}

int main (void)
{	
	DDRA = 0xFF;
	PORTA = 0;
	
	UCSRB |= (1 << RXCIE) | (1 << RXEN);
	UBRRL = 0x06;
	
	sei();
	
	while(1)
	{}
}
