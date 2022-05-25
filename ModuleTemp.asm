/*
 * ModuleTemp.asm
 *	Use this module to acces temperature
 *  Created: 15/05/2021 10:57:43
 *   Author: vsupp
 */ 


;========Routines========;
Temp_print_LCD:
		clr		a0
		clr		a1
		rcall	wire1_reset			; send a reset pulse
		CA		wire1_write, skipROM	; skip ROM identification
		CA		wire1_write, convertT	; initiate temp conversion
		WAIT_MS	750					; wait 750 msec
	
		rcall	lcd_home			; place cursor to home position
		rcall	wire1_reset			; send a reset pulse
		CA		wire1_write, skipROM
		CA		wire1_write, readScratchpad	
		rcall	wire1_read			; read temperature LSB
		mov		c3,a0
		rcall	wire1_read			; read temperature MSB
		mov		a1,a0
		mov		a0,c3

		rcall	LCD_clear
		PRINTF	LCD
	.db	"T =",FFRAC2+FSIGN,a,4,$42,"C",CR,0
		ret