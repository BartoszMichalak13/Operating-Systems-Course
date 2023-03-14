; ------------------------------DWORDMUL PROC
  COMMENT *
    Description : Multiplies the DWORD value located at DX:AX by another DWORD
                  located at CX:BX and stores the result in DX:CX:BX:AX as a QWORD.
                  See note(s).

    Calling Convention : Register.

    Parameter(s) :
      WORD AX (Register) = The Low Order Word of the first DWORD value.
      WORD DX (Register) = The High Order word of the first DWORD value.
      WORD BX (Register) = The Low Order Word of the second DWORD value.
      WORD CX (Register) = The High Order Word of the second DWORD value.

    Stack Usage: 14 Bytes.

    Note : 1) When the procedure is through, DX:CX will hold the High Order DWORD
              and BX:AX will hold the Low Order DWORD of the result.

    Example : Multiply the DWORD number 0xFFFFFFFF by another DWORD with the same value.

    .CODE
      MOV    AX , 0FFFFh ; AX = 0xFFFF
      MOV    DX , AX    ; DX:AX = 0xFFFFFFFF
      MOV    BX , AX    ; BX = 0xFFFF
      MOV    CX , AX    ; CX:BX = 0xFFFFFFFF
      CALL    DWORDMUL    ; Multiply them now
      ; DX:CX:BX:AX = 0xFFFFFFFE00000001
  *
  PUSH    BP                              ; Push the base pointer onto the stack
  MOV    BP , SP                        ; Move the stack pointer to the base pointer
  SUB    SP , 000Ch                      ; Allocate 12 Bytes of space in the stack
  MOV    WORD PTR , AX          ; Store the AX register in BP-0Ch
  MOV    WORD PTR , DX          ; Store the DX register in BP-0Ah
  MOV    WORD PTR , 0000h      ; Zero out the content of the Result#4
  MOV    WORD PTR , 0000h      ; Zero out the content of the Result#3
  MUL    BX                              ; Multiply AX by BX
  MOV    WORD PTR , AX          ; BP-08h now holds the Result#1
  MOV    WORD PTR , DX          ; BP-06h now holds the Result#2
  MOV    AX , WORD PTR           ; AX is now equal to the original DX
  MUL    BX                              ; Multiplt AX by BX
  ADD    WORD PTR , AX          ; Result#2 = Result#2 + AX
  ADC    WORD PTR , DX          ; Result#3 = Result#3 + DX + Carry Flag
  MOV    AX , WORD PTR           ; AX is now equal to the original AX
  MUL    CX                              ; Multiply AX by AX
  ADD    WORD PTR , AX          ; Result#2 = Result#2 + AX
  ADC    WORD PTR , DX          ; Result#3 = Result#3 + DX + Carry Flag
  ADC    WORD PTR , 0000h      ; Result#4 = Result#4 + Carry Flag
  MOV    AX , WORD PTR           ; AX is now equal to the original DX
  MUL    CX                              ; Multiply AX by CX
  ADD    WORD PTR , AX          ; Result#3 = Result#3 + AX
  ADC    WORD PTR , DX          ; Result#4 = Result#4 + DX + Carry Flag
  MOV    AX , WORD PTR           ; AX = Result#1
  MOV    BX , WORD PTR           ; BX = Result#2
  MOV    CX , WORD PTR           ; CX = Result#3
  MOV    DX , WORD PTR           ; DX = Result#4
  ADD    SP , 000Ch                      ; Jump over the temporary results
  POP    BP                              ; Restore the base pointer
  RET                                    ; Return to the calling procedure
DWORDMUL ENDP; ------------------------------
