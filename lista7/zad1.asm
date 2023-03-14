%include	'functions.asm'

section .text
global _start 

;section .text
_start:
;we need arguments in fucntion
;1st arg numebr of arg
;2nd program name	
	pop 	ecx
	pop	edx
	dec	ecx	;number of arg without program name
	mov	edx, 0

nextArg:
	cmp 	ecx, 0h
	jz	exit		;no args left? print number in hex
	pop 	eax
	call	atoi		;ASCII to integer
;	add	edx, eax	;ok we don't store them we print them
	call 	printhex	;we need to store those values
	dec 	ecx		;A-F 65-70
	jmp 	nextArg

;noMoreArgs:	
;I guess this is writing out
;length of what we write
;	mov 	edx, 
;where is it (where we start)
;	mov 	ecx, 
;fd
;	mov	ebx, 1
;operation (4 for write)
;	mov	eax, 4
;	int 	80h

exit:				;or we can just call quit
	mov	ebx, 0
	mov 	eax, 1
	int 	80h

 
