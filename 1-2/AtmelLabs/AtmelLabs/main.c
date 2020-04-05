#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>

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

void delaySpeed() {
	switch (speed) {
		case 0:
			_delay_ms(350);
			break;
			
		case 1:
			_delay_ms(250);
			break;
			
		case 2:
			_delay_ms(100);
			break;
			
		default:
			_delay_ms(250);
			break;
		
	}
}

void changeMode() {
	PORTA = 0;
	
	switch (mode) {
		case 0:
			PORTA = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3);
			break;
			
		case 1:
			PORTA = (1 << 0) | (1 << 2);
			break;
			
		case 2:
			PORTA = (1 << 0);
			break;
			
		default:
			PORTA = 0;
			break;
	
	}
}

int main (void)
{
	DDRA = 0xFF;
	DDRB = 0b11111000;
	
	while(1) {
		if ((PINB & (1 << 0)) != 0) {
			power = (power == 1) ? 0 : 1;
			if (power) {
				mode = 0;
				speed = 0;
				changeMode();
			}
		} else if ((PINB & (1 << 1)) != 0) {
			mode = (mode == 2) ? 0 : mode + 1;
			changeMode();
		} else if ((PINB & (1 << 2)) != 0) {
			speed = (speed > 2) ? 0 : speed + 1;
			
		}
		
		if (power) {
			tick();
		}
		else {
			PORTA = 0;
		}
		delaySpeed();
	}
}
