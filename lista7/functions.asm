;------------------------------------------
; int atoi(Integer number)
; Ascii to integer function (atoi)
atoi:
    push    ebx             ; preserve ebx on the stack to be restored after function runs
    push    ecx             ; preserve ecx on the stack to be restored after function runs
    push    edx             ; preserve edx on the stack to be restored after function runs
    push    esi             ; preserve esi on the stack to be restored after function runs
    mov     esi, eax        ; move pointer in eax into esi (our number to convert)
    mov     eax, 0          ; initialise eax with decimal value 0
    mov     ecx, 0          ; initialise ecx with decimal value 0

.multiplyLoop:
    xor     ebx, ebx        ; resets both lower and uppper bytes of ebx to be 0
    mov     bl, [esi+ecx]   ; move a single byte into ebx register's lower half
    cmp     bl, 48          ; compare ebx register's lower half value against ascii value 48 (char value 0)
    jl      .finished       ; jump if less than to label finished
    cmp     bl, 57          ; compare ebx register's lower half value against ascii value 57 (char value 9)
    jg      .finished       ; jump if greater than to label finished

    sub     bl, 48          ; convert ebx register's lower half to decimal representation of ascii value
    add     eax, ebx        ; add ebx to our interger value in eax
    mov     ebx, 10         ; move decimal value 10 into ebx
    mul     ebx             ; multiply eax by ebx to get place value
    inc     ecx             ; increment ecx (our counter register)
    jmp     .multiplyLoop   ; continue multiply loop

.finished:
    cmp     ecx, 0          ; compare ecx register's value against decimal 0 (our counter register)
    je      .restore        ; jump if equal to 0 (no integer arguments were passed to atoi)
    mov     ebx, 10         ; move decimal value 10 into ebx
    div     ebx             ; divide eax by value in ebx (in this case 10)

.restore:
    pop     esi             ; restore esi from the value we pushed onto the stack at the start
    pop     edx             ; restore edx from the value we pushed onto the stack at the start
    pop     ecx             ; restore ecx from the value we pushed onto the stack at the start
    pop     ebx             ; restore ebx from the value we pushed onto the stack at the start
    ret


;------------------------------------------
; void iprint(Integer number)
; Integer printing function (itoa)
iprint:
    push    eax             ; preserve eax on the stack to be restored after function runs
    push    ecx             ; preserve ecx on the stack to be restored after function runs
    push    edx             ; preserve edx on the stack to be restored after function runs
    push    esi             ; preserve esi on the stack to be restored after function runs
    mov     ecx, 0          ; counter of how many bytes we need to print in the end

.divideLoop:
    inc     ecx             ; count each byte to print - number of characters
    mov     edx, 0          ; empty edx
    mov     esi, 10         ; mov 10 into esi
    idiv    esi             ; divide eax by esi
    add     edx, 48         ; convert edx to it's ascii representation - edx holds the remainder after a divide instruction
    push    edx             ; push edx (string representation of an intger) onto the stack
    cmp     eax, 0          ; can the integer be divided anymore?
    jnz     .divideLoop      ; jump if not zero to the label divideLoop

.printLoop:
    dec     ecx             ; count down each byte that we put on the stack
    mov     eax, esp        ; mov the stack pointer into eax for printing
    call    sprint          ; call our string print function
    pop     eax             ; remove last character from the stack to move esp forward
    cmp     ecx, 0          ; have we printed all bytes we pushed onto the stack?
    jnz     .printLoop       ; jump is not zero to the label printLoop

    pop     esi             ; restore esi from the value we pushed onto the stack at the start
    pop     edx             ; restore edx from the value we pushed onto the stack at the start
    pop     ecx             ; restore ecx from the value we pushed onto the stack at the start
    pop     eax             ; restore eax from the value we pushed onto the stack at the start
    ret


;------------------------------------------
; void iprintLF(Integer number)
; Integer printing function with linefeed (itoa)
iprintLF:
    call    iprint          ; call our integer printing function

    push    eax             ; push eax onto the stack to preserve it while we use the eax register in this function
    mov     eax, 0Ah        ; move 0Ah into eax - 0Ah is the ascii character for a linefeed
    push    eax             ; push the linefeed onto the stack so we can get the address
    mov     eax, esp        ; move the address of the current stack pointer into eax for sprint
    call    sprint          ; call our sprint function
    pop     eax             ; remove our linefeed character from the stack
    pop     eax             ; restore the original value of eax before our function was called
    ret


;------------------------------------------
; int slen(String message)
; String length calculation function
slen:
    push    ebx
    mov     ebx, eax

.nextchar:
    cmp     byte [eax], 0
    jz      .finished
    inc     eax
    jmp     .nextchar

.finished:
    sub     eax, ebx
    pop     ebx
    ret


;------------------------------------------
; void sprint(String message)
; String printing function
sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax
    call    slen

    mov     edx, eax
    pop     eax

    mov     ecx, eax
    mov     ebx, 1
    mov     eax, 4
    int     80h

    pop     ebx
    pop     ecx
    pop     edx
    ret
    
;------------------------------------------
; void sprintLF(String message)
; String printing with line feed function
sprintLF:
    call    sprint

    push    eax
    mov     eax, 0AH
    push    eax
    mov     eax, esp
    call    sprint
    pop     eax
    pop     eax
    ret


;------------------------------------------
;void printhex(number in dec)
;prints given number in hex
printhex:
	push	eax
	;push	ebx
	push	ecx
	push	esi
	push	edx
	mov 	ecx, 0		;our counter
.mainloop:
	inc	ecx
	mov 	edx, 0
	mov	esi, 16
	idiv	esi		;we have quotient in eax and remainder in edx
	cmp	edx, 9h		; to print letter or number
	jg	.letter
	add 	edx, 48
	jmp 	.saveloop
.letter:
	add 	edx, 55
.saveloop:
	push	edx
	cmp	eax, 0
	jnz 	.mainloop
	;new line
	;mov 	edx, 0Ah
	;push 	edx
	;inc 	ecx

.printloop:
	dec	ecx
	mov	eax, esp
	call 	sprint		; so we need to store them
	pop 	eax
	cmp	ecx, 0h
	jnz	.printloop

.quit:	 
;new line
	mov	edx, 0Ah
	push	edx
	mov	eax, esp
	call 	sprint
	pop 	edx
;;;exit part
	pop	edx
	pop	esi
	pop	ecx
	;pop 	ebx
	pop 	eax
	ret
;----------------------------------------
;void print in BCD
;Prints given number in BCD
printBCD:
	push	eax
	push	ebx
	push	ecx
	push	edx
	push 	esi
	push	edi
	mov 	esi, 2
	mov 	ecx, 0
.divloop:
	inc	ecx
	mov	ebx, 10
	mov	edx, 0
	idiv	ebx
	push 	edx	;our remainder
	cmp 	eax, 0
	jnz	.divloop

	
	push	eax
	mov	ebx, 4
	mov	eax, ecx
	mul	ebx	;each number 4 bits
	mov	ecx, eax
	mov	edi, eax
	pop	eax
.prep:
	mov	ebx, 16 
	pop	edx
.tobinloop:
	cmp	edi, 0
	jz	.ploop2
	cmp 	ebx, 1
	jz	.ploop2	

	;divide ebx by 2
	push	eax
	push	edx
	mov 	eax, ebx
	mov 	ebx, 2
	mov	edx, 0
	idiv	ebx
	mov	ebx, eax
	pop	edx
	pop	eax
	
	;tak jak w hex, podziel na 8 if eax==1 print 1, petla, na 4 if 
	dec	edi
	cmp 	edx, ebx
	jl	.print0
.print1:
	mov 	esi, 49
	push	esi
	sub	edx, ebx
	mov	eax, edx
	jmp 	.tobinloop
	
.print0:
	mov	esi, 48
	push	esi
	jmp	.tobinloop
	
.ploop2:
	pop 	eax
	pop	ebx
	pop	edx
	pop	esi
	push	eax
	push	ebx
	push	edx
	push 	esi
	mov 	ebx, ecx
	mov	eax, 4
	sub	ebx, eax
	;mov	edx, esp
	;mov	eax, 16
	;sub	edx, eax
	;mov	eax, esp
	;push	edx;
	
.pl2in:
	dec	ecx
	;eax, ebx, edx, esi
	;push	ecx
	;mov	ecx, 4
	;add	edx, ecx
	;pop	ecx

	mov	eax, esp
	;mov	eax, edx
	call 	sprint
	pop	eax
	cmp	ecx, ebx
	jnz	.pl2in
	cmp	ecx, 0
	jnz	.prep
	mov	eax, 0Ah
	push	eax
	mov	eax, esp
	call 	sprint
	pop	eax
.quit:
	pop	edi
	pop 	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret

;------------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
    ret

