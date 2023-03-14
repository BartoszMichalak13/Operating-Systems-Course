	;lea 	di,Screen
;section .data
;CntrA	dw -510*256
;X	w 0
;CntrB	dw -270*256
;Y	w 200


section .text
global _start
_start:	

	lea	di,0xa0000
;poczatkowe ustawienie licznikow odpowiedzialne za frag fraktala wid na ekranie
	;mov	dword ptr [CntrA],-510*256
	;mov	word ptr [X],0
	mov	dword [CntrA],-510*256
	mov	word [X],0

@@LoopHoriz:
	;mov	dword ptr [CntrB],-270*256
	;mov 	word ptr [Y],200
	mov	[CntrB],-270*256
	mov	[Y],200
@@LoopVert:
;Wyliczaenie frak wdlg wzoru iteracyjnego
;
;	x->x^2-y^2+c
;	y->2*x*y+c

	xor 	ecx,ecx		;x=0
	xor	edx,edx		;y=0
	mov	si,32-1		;kolor
@@LoopFractal:
	mov	eax,ecx
	imul	eax,eax		;x^2
	mov	ebx,edx		
	imul	ebx,ebx		;y^2
	sub	eax,ebx		;x^2-y^2
	;add	eax,dword ptr [CntrA]	;x^2-y^2+c
	add	eax,[CntrA]
	mov	ebx,ecx	
	imul	ebx,edx		;x*y
	sal	ebx,1		;2*x*y
	;add	ebx,dword ptr [CntrB]	;2*x*y+c
	add	ebx,[CntrB]	
	sar	eax,8
	sar	ebx,8
	mov	ecx,eax
	mov	edx,ebx
	imul	eax,eax		;x^2
	imul	ebx,ebx		;y^2
	add 	eax,ebx		;x^2+y^2
	sar	eax,8
	cmp	eax,1024	;if(x^2+y^2)>1024 then
	jg	Break		;Break
	dec	si		;kolor--
	jnz	@@LoopFractal
;	Liczba iteracji == numer koloru jaki nadajmey pikselowi

Break:	
	mov	ax,si
	;mov	byte ptr [di],al
	;add 	dword ptr [CntrB],720
	mov	[di],al
	add	[CntrB],720
	add	di,320
	;dec 	word ptr [Y]
	dec	[Y]
	jnz 	@@LoopVert
	;add	dword ptr [CntrA],568
	;inc	word ptr [X]
	add	[CntrA],568
	inc	[X]
	;lea	di,Screen
	;add	di,word ptr [X]
	;cmp	word ptr [X],320
	lea	di,0xa0000
	add 	di,[X]
	cmp	[X],320
	jnz	@@LoopHoriz
	ret
