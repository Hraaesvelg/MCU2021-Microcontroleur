/*
 * Interuptions.asm
 *	This file contains all the interuptiosn needed
 *  Created: 15/05/2021 12:08:13
 *   Author: vsupp
 */ 

 ;=========  interupt vector table ===========
.org 0
	rjmp reset

.org OVF0addr
	rjmp ovf0

.org OC2addr
	rjmp oc2

.org 0x30

; ========= interrupt routines ========

ovf0:
	mov _u, r0
	sbrs r0, 0
	reti
	mov r0, _u
	reti

oc2:
	mov _u, r0
	lds r0, dist_sound
	sbrc r0, 0
	INVP PORTE, SPEAKER
	reti