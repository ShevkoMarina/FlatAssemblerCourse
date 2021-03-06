format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        VSIZE equ dword 4  ; ������������ ������ �������
        resStr         db 'Parameter n = %d', 0
        vec            dd 0,0,0,1
        N              dd 3

section '.code' code readable executable

start:
        mov edx, dword 0   ; �������� ������ ��� ����������������� ��������

; ������� ����
mainLoop:
        ; ��������� �������� ������� - ������� �������� �������
        xor eax, eax       ; ������� ��� �������� ������� �����
        mov ecx, VSIZE     ; � ecx ������ ������ ������� - 4
        mov ebx, vec       ; � ebx ��������� ������ �� ������ ������� �������

;���������� ����
sumLoop:
        add ax, [ebx]      ; ����������� ax �� ������� ������� �������
        jc endProc         ; �������� �� ������������
        add ebx, 4         ; i++, ���������� �� ��������� ������� �������
        loop sumLoop

        ; ����� ������ ������������
        inc [N]            ; ���� ������������ �� ���������, �� �� ����������� �������� n
        mov ebx, vec       ; ��������� � ������ �������
        mov [ebx+edx], eax ; �������������� ����� ������ ������� � �������

        ; ���������� � ���� �����
        add edx, 4         ; ���������� �������� �� ������ �������
        cmp edx, 12
        jle mainLoop
        xor edx, edx       ; ���� ��� ����������� ��������� �������, �� �������� ��������
        jmp mainLoop

endProc:
        mov eax, [N]       ; ���������� � ������� �������� �������� ��������� n
        push eax
        push resStr
        call [printf]      ; ������ �������� ���������
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