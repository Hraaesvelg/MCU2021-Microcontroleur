/*
 * ModuleUart.asm
 * Ce module met en place la gestion de l'ouverture des portes et fenetre depuis l'UART, il permet aussi de connaitre le code ASCI de n'importe quelle touche du clavie
 * ATTENTION: Ce module fonctionne uniquement en 9600 bauds  
 *  Created: 30/05/2021 20:13:17
 *   Author: Valentin Suppa-Gallezot
 */ 

.equ	etat_porte = $200
.equ	etat_fenetre = $202


uart_gestion_LCD:
	rcall	LCD_clear
	PRINTF	LCD
.db "UART: ", FDEC, a, CR, 0
	rcall	UART0_getc	; read a character from the terminal
	rcall	UART0_putc	; write a character to the terminal
	subi	a0,$30

	cpi		a0, 221
	breq	S
	cpi		a0, 250
	breq	P 
	cpi		a0, 244
	breq	F
	WAIT_MS	100
	ret



P:	rjmp	door
F:	rjmp	fenetre
S:	rjmp	sortie


sortie:
		rcall	LCD_clear
		PRINTF	LCD
	.db		"stop ",0
		WAIT_MS	1500
		rjmp main
		ret
door : 
		rcall porte_en
		WAIT_MS	1500
		ret
fenetre:
		rcall fenetre_en
		WAIT_MS	1500
		ret


fenetre_en:
mov		b2, a0
clr		a0
ldi		xl, low(etat_fenetre)
ldi		xh, high(etat_fenetre)
rcall	eeprom_load
cpi		a0, 0
breq	set_high_fen
cpi		a0, $ff
breq	set_low_fen
ret

set_high_fen :
rcall	LCD_clear
PRINTF LCD
.db  "Fenetre Ouverte",0
WAIT_MS	100
mov		b2, a0
clr		a0
ldi		a0, $ff
ldi		xl, low(etat_fenetre)
ldi		xh, high(etat_fenetre)
rcall	eeprom_store
mov		a0, b2
ret

set_low_fen :
rcall	LCD_clear
PRINTF LCD
.db  "Fenetre Ferme",0
WAIT_MS	100
mov		b2, a0
clr		a0
ldi		a0, 0
ldi		xl, low(etat_fenetre)
ldi		xh, high(etat_fenetre)
rcall	eeprom_store
mov		a0, b2
ret

porte_en:
mov		b2, a0
clr		a0
ldi		xl, low(etat_porte)
ldi		xh, high(etat_porte)
rcall	eeprom_load
cpi		a0, 0
breq	set_high_por
cpi		a0, $ff
breq	set_low_por
ret

set_high_por :
rcall	LCD_clear
PRINTF LCD
.db  "Porte Ouverte",0
WAIT_MS	100
mov		b2, a0
clr		a0
ldi		a0, $ff
ldi		xl, low(etat_porte)
ldi		xh, high(etat_porte)
rcall	eeprom_store
mov		a0, b2
ret

set_low_por :
rcall	LCD_clear
PRINTF LCD
.db  "Porte Ferme",0
WAIT_MS	100
mov		b2, a0
clr		a0
ldi		a0, 0
ldi		xl, low(etat_porte)
ldi		xh, high(etat_porte)
rcall	eeprom_store
mov		a0, b2
ret

print_etat_fen:
mov		b2, a0
clr		a0
ldi		xl, low(etat_fenetre)
ldi		xh, high(etat_fenetre)
rcall	eeprom_load
cpi		a0, 0
breq	print_close
cpi		a0, $ff
breq	print_open
mov		a0, b2
ret

print_etat_porte:
mov		b2, a0
clr		a0
ldi		xl, low(etat_porte)
ldi		xh, high(etat_porte)
rcall	eeprom_load
cpi		a0, 0
breq	print_close
cpi		a0, $ff
breq	print_open
mov		a0, b2
ret


print_open:
PRINTF	LCD
.db		"Ouverte", 0
ret

print_close:
PRINTF	LCD
.db		"Fermee ", 0
ret