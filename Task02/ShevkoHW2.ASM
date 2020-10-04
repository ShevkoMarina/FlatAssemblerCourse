format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
; Variant 6
; —формировать массив из элементов входного массива, значени€ которых
; кратны введенному числу x (Create new array with elements of input array,
; that multiple of input number x)
;--------------------------------------------------------------------------

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize      db 'Enter size of vector: ', 0
        strEnterNum     db 'Enter number (more than zero): ', 0
        strIncorSize    db 'Incorrect size of vector = %d', 10, 0
        strIncorDivider db 'Incorrect value of devider = %d', 10, 0
        strInputVector  db 'Input array', 10, 0
        strOutputVector db 'New output array', 10, 0
        strVecElemI     db '[%d]? ', 0
        strScanInt      db '%d', 0
        strMaskVector   db 'Array has %d element(s) multiple of %d:', 10, 0
        strVecElemOut   db '[%d] = %d', 10, 0
        strErrMemAlloc  db 'Error allocating memory',0

        vec_size     dd 0    ; dd - 4-bytes
        new_size     dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec          dd ?
        new_vec      dd ?
        num          dd ?

;--------------------------------------------------------------------------
section '.code' code readable executable
start:


; 1) Input data
        call VectorInput
        call NumberInput
; 2) Print input array
        call VectorOut

; 3) Start Main Algorithm
        call main_algo

; 4) Print result info
        push [num]
        push [new_size]
        push strMaskVector
        call [printf]

; 5) Print new vector

        call NewVectorOut
finish:
        call [getch]
        push 0
        call [ExitProcess]

;-----------------------------------Input-array---------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector

; incorrect  size
        push [vec_size]
        push strIncorSize
        call [printf]

        call [getch]

        push 0
        call [ExitProcess]
; else continue...
getVector:

        mov ecx, [vec_size]
        imul ecx, 4

        ; dynamic memory allocation
        push ecx
        push ecx
        call mem_alloc
        mov [new_vec], eax

        call mem_alloc
        mov [vec], eax
       ; int3

        xor ecx, ecx
        mov ebx, [vec]

getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop

endInputVector:
        ret
;---------------------------Input-devider-number-----------------------
NumberInput:

        push strEnterNum
        call [printf]
        add esp, 4

        push num
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [num]
        cmp eax, 0
        jg inputOK

          ; incorrect size
          push [num]
          push strIncorDivider
          call [printf]

          call [getch]

          push 0
          call [ExitProcess]

      inputOK:
        ret
;----------------------------Print-new-array----------------------------
NewVectorOut:

        ;int3
        push strOutputVector
        call [printf]
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, [new_vec]


putNewVecLoop:
        mov [tmp], ebx
        cmp ecx, [new_size]
        je endOutNewVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putNewVecLoop

endOutNewVector:
        mov esp, [tmpStack]
        ret

;----------------------------Print-new-array-------------------------
VectorOut:

        ;int3
        push strInputVector
        call [printf]
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, [vec]

putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop

endOutputVector:
        mov esp, [tmpStack]
        ret

;---------------------------------Dynamic-memory-allocation------------------

proc mem_alloc, bsize

    call   [GetProcessHeap]

    push    [bsize]
    push    HEAP_ZERO_MEMORY
    push    eax

    call   [HeapAlloc]

    ;allocation failed
    or     eax, eax
    jnz    _no_err

    push strErrMemAlloc          ; warning
    call [printf]
    call [getch]
    push 0
    call [ExitProcess]

  _no_err:
    ret

endp

;------------------------------------Main-algorithm--------------------------
proc main_algo

        ;int3
        mov ecx, [vec_size]
        mov ebx, [vec]
        mov edi, [new_vec]

findMultLoop:
        xor edx, edx
        mov eax, [ebx]

        div [num]
        cmp edx, dword 0

        jne ifend
        ; remainder is 0 => multiple of num
        mov edx, [ebx]
        mov [edi], edx

        add edi, 4
        inc [new_size]

      ifend:
        add ebx, 4                ; i++
        loop findMultLoop         ; replace on loop

endMaskVector:
        ret
endp

;-------------------------------Including-libraries--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           GetProcessHeap,'GetProcessHeap',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'