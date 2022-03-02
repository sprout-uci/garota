#include <isr_compat.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include "hardware.h"
#define WDTCTL_               0x0120    /* Watchdog Timer Control */
#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))

__attribute__ ((section (".exec.lib"))) void setup (void) {
  // Disables WDT
  WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

  P1DIR  = 0x00;                     // Port 1.0-1.7 = input
  P1IE   = 0x01;                     // Port 1.0 interrupt enabled
  P1IES  = 0x00;                     // Port 1.0 interrupt edge selection (0=pos 1=neg)
  P1IFG  = 0x00;                     // Clear all Port 1 interrupt flags (just in case)
  P3DIR  = 0xFF; 
  P3OUT = 0x00;
}

// TCB ISR
__attribute__ ((section (".exec.call"))) ISR(PORT1, TCB) {
  //Uses GIE to distinguish between first TCB run after boot and regular interrupts.
  uint16_t* var = 0x0300;
  __asm__ volatile("push    r10" "\n\t");
  __asm__ volatile("mov    #0x0300,		r10" "\n\t");
  __asm__ volatile("mov    r2,   @(r10)" "\n\t");
  __asm__ volatile("pop    r10" "\n\t");
  uint16_t first_run = !CHECK_BIT((*var),3);

  dint();

  //setup after boot
  if (first_run) {
  	setup();
  }

  //call tcb implementation
  tcb_behavior(first_run);

  eint();

  // Postamble trick to enable calling an ISR directly and transparently.
  // needed because ISR uses "reti" while normal functions use "ret"
  // reti pops the status register (r2) before poping PC (r0)
  // ret only pops (r0)
    if(!first_run) {
		__asm__ volatile( "pop		r11" "\n\t");
		__asm__ volatile( "pop		r12" "\n\t");
		__asm__ volatile( "pop		r13" "\n\t");
		__asm__ volatile( "pop		r14" "\n\t");
		__asm__ volatile( "pop		r15" "\n\t");

		__asm__ volatile( "pop      r2" "\n\t");
    } else {
		__asm__ volatile( "pop		r11" "\n\t");
		__asm__ volatile( "pop		r12" "\n\t");
		__asm__ volatile( "pop		r13" "\n\t");
		__asm__ volatile( "pop		r14" "\n\t");
		__asm__ volatile( "pop		r15" "\n\t");
	}

    __asm__ volatile( "br      #__exec_leave" "\n\t");
}

__attribute__ ((section (".exec.leave"), naked)) void TCB_exit() {
    __asm__ volatile("ret" "\n\t");
}

int main() {
	 TCB();
     main_loop();
	 return 0; 
}

// XXX: Users can implement trigger-based tcb behavior below (this example flips P3 LEDs)
// first_run flag can be used to distinguish between first (post-boot) and later executions
// Some applications might wanna use that ,i.e., do extra stuff after a reset/boot,
// such as cleaning secret leftovers from the stack before untrusted apps can run.
__attribute__ ((section (".exec.lib"))) void tcb_behavior (uint16_t first_run) {

	//XXX: user implementation goes here

	P3OUT = ~P3OUT;
}


int main_loop (void){

  volatile uint64_t count = 0;
  P3OUT = 0x00;
  while (1) {	// loops forever
	count++;
	if (count % 200000 == 0) {
		// on boot irq is disabled
		P3OUT++;
	}
  }
  return 0;
}
