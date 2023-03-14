%include	'functions.asm'

section .text
global _start
;lets say there is only 1 argument for simplicity sake
_start:
	pop	ecx
	pop	edx;name of a program
	pop 	eax
	
	call	atoi

	call	printBCD
	call	quit	
