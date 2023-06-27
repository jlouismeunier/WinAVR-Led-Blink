      /* Blink Demo */
// Atmega16

#include <avr/io.h>
#include <util/delay.h>

#define LED      PD1
#define LED1     PD2
#define LED_DDR  DDRD
#define LED1_DDR  DDRD
#define LED_PORT PORTD
#define LED1_PORT PORTD

#define DELAYTIME 10000


int main(void) {

  // Init
  LED_DDR|=(1<<LED);    /* set LED pin for output */
  LED_PORT|=(1<<LED);
  LED1_DDR|=(1<<LED1);    /* set LED pin for output */
  LED1_PORT|=(1<<LED1);
	
  // Mainloop
  while (1) {

    LED_PORT^=(1<<LED);
	_delay_ms(DELAYTIME);
	LED1_PORT^=(1<<LED1);
  }
  return 0;                     /* end mainloop */
}
