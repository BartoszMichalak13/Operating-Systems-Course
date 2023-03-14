%include 'functions.asm'

section .text
global _start

_start:
	mov	edx, 0
	mov	eax, 0 
;	mov	ecx, eax
	mov	ebx, 1 
.plusone:
	inc	ebx
	mov	ecx, ebx	
.checkloop:		;if ecx==1 break, if edx!=0 not prime
	mov	eax, ebx
	dec 	ecx
	cmp	ecx, 1
	jz	.print
	mov	edx, 0
	div 	ecx
	cmp 	edx, 0
	jnz	.checkloop
	jmp 	.plusone  
	
.print:
	mov	eax, ebx
	call 	iprintLF		;prints in New Line
	cmp	ebx, 100000
	jl	.plusone
	call 	quit
