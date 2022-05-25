/*
 * Projet.asm
 *	this project aims to emulate a pseudo domotic system which can monitor and control temperature by opening/closing the windows, 
 *	open the door by a distance sensor. These data can be stored in the eeprom memory and actions can be made with the uart protocol
 *  Created: 13/05/2021 09:34:48
 *  Author: Valentin SUPPA--GALLEZOT
 */ 


.include	"macros.asm"		
.include	"definitions.asm"	
.include	"Interuptions.asm"

reset:		
		LDSP	RAMEND			; load stack pointer (SP)
		OUTI	PORTC, 0x00
		OUTI	DDRD, $00		;butons input

		rcall	lcd_init		; initialize LCD
		rjmp	main

;========  include  =======;
; LCD
.include "lcd.asm"			
.include "printf.asm"	

; Temperature 1 wire	
.include "wire1.asm"
.include "ModuleTemp.asm"

; Distance Sharp
.include "ModuleDist.asm"

; UART/eeprom
.include "ModuleUart.asm"
.include "eeprom.asm"
.include "uart.asm"

; Encodeur 
.include "menu.asm"
.include "encoder.asm"

main:	
		rcall	LCD_clear
		PRINTF	LCD
	.db		"Rolex", 0
		CP0		PIND,0,	bouton1
		CP0		PIND,1,	bouton2
		CP0		PIND,2, bouton3
		CP0		PIND,3, bouton4
		CP0		PIND,4, bouton5
		CP0		PIND,5, bouton6
		CP0		PIND,7, main
		rjmp main

Bouton1:
	OUTI	DDRC, 0b00000001
	CP0		PIND,7, main		

	rcall	wire1_init
	rcall	Temp_print_LCD
	rjmp	Bouton1

Bouton2:
	rcall	Dist_init		; Initialize the distance module
	rcall	Dist_enable

	distance: 
		OUTI	DDRC, 0b00000010
		CP0		PIND,7, main

		rcall	Dist_start
		rcall	Dist_Activate
		rcall	LCD_clear
		rcall	Sound_enable
		rcall	dist
		rjmp	distance

Bouton3:
	rcall	UART0_init	; initialize UART
	mov		b3, a0
	clr		a0
GUart:
	OUTI	DDRC, 0b00000100
	CP0		PIND,7, main
	rcall	uart_gestion_LCD
	rjmp	GUart;


Bouton4:
	OUTI	DDRC, 0b00001000
	CP0		PIND,7, main
	rcall	LCD_clear
	PRINTF	LCD
.db "Fenetre: ", 0
	rcall	print_etat_fen
	rcall	LCD_lf
	PRINTF	LCD
.db "Porte: ", 0
	rcall	print_etat_porte
	WAIT_MS	100
	rjmp	Bouton4

Bouton5:
	rcall	encoder_init
	info:
		OUTI	DDRC, 0b00010000
		CP0		PIND,7, main
		rcall	LCD_clear
		rcall	encoder
		PRINTF	LCD
.db		"Gestion Rolex: ", 0
		rcall	LCD_lf
		CYCLIC	a0,0,4
		rcall menui
.db		"B0: Temperature |B1: Distance| B2: Uart,gestion| B4: Vision etat|B7: Menu",0
		WAIT_MS	100
		rjmp	info


Bouton8:
	OUTI	DDRC, 0b10000000
	rcall	LCD_clear
	rjmp	main

