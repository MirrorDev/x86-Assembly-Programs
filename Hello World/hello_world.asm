.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
    message db "Hello, i386 Assembly World!", 0
    msgbox   db "MASM32 MessageBox", 0

.code
start:
    push MB_OK
    push offset msgbox
    push offset message
    push 0
    call MessageBoxA

    push 0
    call ExitProcess
end start
