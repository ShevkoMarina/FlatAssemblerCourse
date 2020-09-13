format PE console
; Hello console app

entry start

include 'win32a.inc'

section '.data' data readable writable
        helloStr db 'Hello, everyone!'
        NULL = 0

section '.code' code readable executable
        start:
                push helloStr
                call [printf]

                call [getch]
                push NULL
                call [ExitProcess]

section '.idata' import data readable
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               getch,  '_getch'

