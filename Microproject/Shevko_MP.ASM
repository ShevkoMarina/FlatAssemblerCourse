format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        VSIZE equ dword 4  ; фиксированый размер очереди
        resStr         db 'Parameter n = %d', 0
        vec            dd 0,0,0,1
        N              dd 3

section '.code' code readable executable

start:
        mov edx, dword 0   ; смещение ссылки для перезаписываемого элемента

; внешний цикл
mainLoop:
        ; суммируем элементы очереди - находим значение функции
        xor eax, eax       ; очищаем для зранения текущей суммы
        mov ecx, VSIZE     ; в ecx кладем размер очереди - 4
        mov ebx, vec       ; в ebx находится ссылка на первый элемент очереди

;внутренний цикл
sumLoop:
        add ax, [ebx]      ; увеличиваем ax на текущий элемент очереди
        jc endProc         ; проверка на переполнение
        add ebx, 4         ; i++, ссылкаемся на следующий элемент очереди
        loop sumLoop

        ; конец секции суммирования
        inc [N]            ; если переполнения не произошло, то мы увеличиваем параметр n
        mov ebx, vec       ; смещаемся в начало очереди
        mov [ebx+edx], eax ; перезаписываем самый старый элемент в очереди

        ; подготовка к след циклу
        add edx, 4         ; запоминаем смещение от начала очереди
        cmp edx, 12
        jle mainLoop
        xor edx, edx       ; если был перезаписан последний элемент, то обнуляем смещение
        jmp mainLoop

endProc:
        mov eax, [N]       ; запоминаем в регистр итоговое значение параметра n
        push eax
        push resStr
        call [printf]      ; печать значения параметра
        call [getch]

        push 0
        call [ExitProcess]

;-----------------------------Importing-libraries-----------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'


include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess'

  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           getch, '_getch'