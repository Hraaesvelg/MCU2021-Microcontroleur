/*
 * encoder1.asm
 *  Created: 17/05/2021 14:23:02
 *   Author: vsupp
 */ 

.include	"macros.asm"		
.include	"definitions.asm"	
.include	"Interuptions.asm"

.equ	etat_porte = $200
.equ	etat_fenetre = $202


reset:		
		LDSP	RAMEND			; load stack pointer (SP)
		OUTI	PORTC, 0x00
		OUTI	DDRD, $00		;butons input
		OUTI	DDRB, $ff		;LEDs output

		rcall	Dist_init		; Initialize the distance module
		rcall	Dist_enable
		rcall	wire1_init		; initialize 1-wire(R) interface
		rcall	lcd_init		; initialize LCD

		rcall	encoder_init
		ldi		a0,0

		rjmp	main

;========  include  =======;
; LCD
.include "lcd.asm"			
.include "printf.asm"	

;Temperature 1 wire	
.include "wire1.asm"
.include "ModuleTemp.asm"

;Distance Sharp
.include "ModuleDist.asm"

.include "encoder.asm"
.include "menu.asm"
.include "eeprom.asm"


main:
		rcall	LCD_clear
		PRINTF	LCD
.db		"Gestion Rolex: ", 0
		rcall	LCD_lf
		CYCLIC	a0,0,4
		rcall menui
.db		"B0: Temperature|B1: Distance|B2: Uart,gestion|B4: Vision etat|B7: Menu",0
		WAIT_MS	100
		rjmp main

