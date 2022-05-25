/*
 * ModuleDist.asm
 *	This module make usable the distance sensor
 *  Created: 15/05/2021 10:59:44
 *   Author: vsupp
 */ 

;====Adresse mémoire====;
.equ capt_dist_enable = $100
.equ dist_sound = $102


;======Lookuptable======;
 dista: 
	.dw 0, 1000, 131, 80, 131, 79, 132, 78, 133, 77, 134, 76, 135, 75, 135, 74, 136, 73, 137, 72, 138, 71, 141, 70, 143, 69, 145, 68, 147, 67, 150, 66, 151, 65, 154, 64, 157, 63, 159, 62, 161, 61, 163, 60, 167, 59, 170, 58, 175, 57, 177, 56, 179, 55, 182, 54, 185, 53, 189, 52, 191, 51, 195, 50, 199, 49, 204, 48, 206, 47, 211, 46, 216, 45, 222, 44, 224, 43, 229, 42, 233, 41, 238, 40, 243, 39, 249, 38, 255, 37, 260, 36, 269, 35, 272, 34, 277, 33, 283, 32, 288, 31, 297, 30, 308, 29, 319, 28, 335, 27, 341, 26, 352, 25, 363, 24, 374, 23, 390, 22, 406, 21, 425, 20, 438, 19, 454, 18, 472, 17, 506, 16, 540, 15, 576, 14, 610, 13, 645, 12, 686, 11, 725, 10,820,0,1024 


;========Routines========;

Dist_init:
OUTI DDRE, (1<<SPEAKER)  ;make speaker an output
OUTI ADCSR, (1<<ADEN) + 6
OUTI ADMUX, CAPT_DIST ;multipkexeur du capteur de distan
OUTI TCCR2, 0b00001100 ; 0b00011100 
OUTI TCCR0, 3	; CS0=3 CK/64
clr	yh					; Z high-byte is always zero
OUTI TIMSK, (1<<OCIE2) + (1<<TOIE0)

Dist_enable:
ldi w, 0
sts capt_dist_enable, w
sts dist_sound,w
ldi b0, 20
out OCR2, b0  ;preset
clr	yh					; Z high-byte is always zero
sei
ret

Dist_start:
sbi ADCSR, ADSC		;begin conversion
WP1 ADCSR, ADSC		;wait til conversion
in a0, ADCL		
in a1, ADCH
WAIT_MS 100
ldi _w, 0b1000000
mov e0, _w
out OCR2, b0	
ret


Dist_print_LCD:
mov _u, r0
lds r0, capt_dist_enable
sbrs r0, 0
rjmp dist
mov _u, r0
rjmp main

dist:
ldi zl, low(2*dista)-3
ldi zh, high(2*dista)
push zl
push zh
repeat:
pop zh
pop zl
ldi _w, 3
ADDZ _w
lpm
mov c0, r0
adiw zl, 1
lpm 
mov c1, r0
push zl
push zh
CP2 a1,a0,c1,c0
brsh repeat
pop zh
pop zl
ldi a2, 3
ldi a3, 0
SUB2 zh,zl,a3,a2
lpm
mov c0, r0
adiw zl, 1
lpm 
mov c1, r0
PRINTF LCD
.db "dist=",FDEC2,c," cm",CR,0  ;affichage 
inc c0
mov b0, c0
ret

Dist_Activate:
lds w, capt_dist_enable
ldi _w, $ff
eor w, _w
sts capt_dist_enable, w
ret


Sound_enable:
lds w, dist_sound
ldi _w, $ff
eor w, _w
sts dist_sound, w
ret



