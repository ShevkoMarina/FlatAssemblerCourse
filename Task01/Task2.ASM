format          PE console
include         'win32a.inc'
entry           start
 
; An example from the Internet with custom console. We can change it's size programmally

 
section         '.code' code readable executable
 
  start:
        invoke  FreeConsole
        invoke  AllocConsole
        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        mov     [stdout], eax
        invoke  GetStdHandle, STD_INPUT_HANDLE
        mov     [stdin], eax
 
        invoke  GetConsoleScreenBufferInfo,[stdout],lpConsoleScreenBufferInfo
 
        mov     [ConsoleWindow.Top], 0
        mov     [ConsoleWindow.Bottom], 0
        mov     ax, word [lpConsoleScreenBufferInfo.srWindow.Right]
        shr     ax,2
        mov     word [ConsoleWindow.Right], ax
        mov     ax, word [lpConsoleScreenBufferInfo.srWindow.Bottom]
        shr     ax,2
        mov     word [ConsoleWindow.Bottom], ax
 
        invoke  SetConsoleWindowInfo,[stdout],TRUE,ConsoleWindow
 
        invoke  Sleep,3000
        invoke  FreeConsole
 
  exit:
        invoke  ExitProcess, 0
 
;--- ?????? ?????? ---
 
section         '.data' data readable writeable
 
stdout          dd      ?
stdin           dd      ?
 
struct          COORD
  x             dw      ?
  y             dw      ?
ends
 
struct SMALL_RECT
  Left          dw      ?
  Top           dw      ?
  Right         dw      ?
  Bottom        dw      ?
ends
 
struct CONSOLE_SCREEN_BUFFER_INFO
  dwSize                COORD
  dwCursorPosition      COORD
  wAttributes           dw      ?
  srWindow              SMALL_RECT
  dwMaximumWindowSize   COORD
ends
 
lpConsoleScreenBufferInfo       CONSOLE_SCREEN_BUFFER_INFO
ConsoleWindow                   SMALL_RECT
dwSize                          COORD
 
;--- ?????? ??????? ---
 
section         '.idata' import data readable writeable
 
library         kernel32,'KERNEL32.DLL'
 
import          kernel32,\
                AllocConsole,'AllocConsole',\
                GetConsoleScreenBufferInfo,'GetConsoleScreenBufferInfo',\
                SetConsoleWindowInfo,'SetConsoleWindowInfo',\
                FreeConsole,'FreeConsole',\
                GetStdHandle,'GetStdHandle',\
                Sleep,'Sleep',\
                ExitProcess,'ExitProcess'