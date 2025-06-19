.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc ; brings in everything we need

.data
    className     db "CalcClass", 0
    windowTitle   db "MASM32 Calculator", 0

    btnAddText      db "Add", 0
    btnSubText      db "Subtract", 0
    btnMulText      db "Multiply", 0
    btnDivText      db "Divide", 0

    resultLabel     db "Result: ", 0
    resultBuffer    db 64 dup(0)
    inputBuffer1    db 20 dup(0)
    inputBuffer2    db 20 dup(0)
    errDivByZero    db "Cannot divide by zero!", 0

.data?
    hInstance       HINSTANCE ?
    hwndMain        HWND ?
    hwndEdit1       HWND ?
    hwndEdit2       HWND ?
    hwndBtnAdd      HWND ?
    hwndBtnSub      HWND ?
    hwndBtnMul      HWND ?
    hwndBtnDiv      HWND ?
    msg             MSG <>
    wc              WNDCLASSEX <>

.const
    IDC_EDIT1       equ 1001
    IDC_EDIT2       equ 1002
    IDC_BTN_ADD     equ 2001
    IDC_BTN_SUB     equ 2002
    IDC_BTN_MUL     equ 2003
    IDC_BTN_DIV     equ 2004

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov wc.hInstance, eax
    mov wc.hbrBackground, COLOR_BTNFACE+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset className
    invoke LoadIcon, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax

    invoke RegisterClassEx, addr wc

    invoke CreateWindowEx, 0, addr className, addr windowTitle,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT,\
           400, 250, NULL, NULL, hInstance, NULL
    mov hwndMain, eax

    invoke ShowWindow, hwndMain, SW_SHOWNORMAL
    invoke UpdateWindow, hwndMain

message_loop:
    invoke GetMessage, addr msg, NULL, 0, 0
    test eax, eax
    jz exit_app
    invoke TranslateMessage, addr msg
    invoke DispatchMessage, addr msg
    jmp message_loop

exit_app:
    invoke ExitProcess, 0

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL num1:DWORD
    LOCAL num2:DWORD
    LOCAL result:DWORD

    .if uMsg == WM_CREATE
        ; Input Field 1
        invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("EDIT"), NULL,\
               WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL,\
               50, 30, 120, 20, hWnd, IDC_EDIT1, hInstance, NULL
        mov hwndEdit1, eax

        ; Input Field 2
        invoke CreateWindowEx, WS_EX_CLIENTEDGE, chr$("EDIT"), NULL,\
               WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL,\
               200, 30, 120, 20, hWnd, IDC_EDIT2, hInstance, NULL
        mov hwndEdit2, eax

        ; Add Button
        invoke CreateWindowEx, 0, chr$("BUTTON"), addr btnAddText,\
               WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
               40, 80, 70, 30, hWnd, IDC_BTN_ADD, hInstance, NULL

        ; Subtract Button
        invoke CreateWindowEx, 0, chr$("BUTTON"), addr btnSubText,\
               WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
               120, 80, 70, 30, hWnd, IDC_BTN_SUB, hInstance, NULL

        ; Multiply Button
        invoke CreateWindowEx, 0, chr$("BUTTON"), addr btnMulText,\
               WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
               200, 80, 70, 30, hWnd, IDC_BTN_MUL, hInstance, NULL

        ; Divide Button
        invoke CreateWindowEx, 0, chr$("BUTTON"), addr btnDivText,\
               WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
               280, 80, 70, 30, hWnd, IDC_BTN_DIV, hInstance, NULL

    .elseif uMsg == WM_COMMAND
    mov eax, wParam
    and eax, 0FFFFh
    mov ecx, eax ; ECX = Control ID (e.g. IDC_BTN_ADD)

    ; Check notification code (HIWORD(wParam))
    mov eax, wParam
    shr eax, 16
    cmp eax, BN_CLICKED
    jne skip_command ; Ignore if not button click

    ; Get user inputs
    invoke GetWindowText, hwndEdit1, addr inputBuffer1, sizeof inputBuffer1
    invoke GetWindowText, hwndEdit2, addr inputBuffer2, sizeof inputBuffer2
    invoke atodw, addr inputBuffer1
    mov ebx, eax ; EBX = num1
    invoke atodw, addr inputBuffer2
    mov edx, eax ; EDX = num2

    ; Handle specific button
    cmp ecx, IDC_BTN_ADD
    je do_add
    cmp ecx, IDC_BTN_SUB
    je do_sub
    cmp ecx, IDC_BTN_MUL
    je do_mul
    cmp ecx, IDC_BTN_DIV
    je do_div
    jmp skip_command

    do_add:
     mov eax, ebx
     add eax, edx
     jmp show_result

    do_sub:
     mov eax, ebx
     sub eax, edx
     jmp show_result

    do_mul:
     mov eax, ebx
     imul eax, edx
     jmp show_result

    do_div:
     cmp edx, 0
     je div_by_zero
     xor edx, edx
     mov eax, ebx
     div edx
     jmp show_result

    div_by_zero:
      invoke MessageBox, hWnd, addr errDivByZero, addr resultLabel, MB_ICONERROR
      jmp skip_command

    show_result:
      invoke dwtoa, eax, addr resultBuffer
      invoke MessageBox, hWnd, addr resultBuffer, addr resultLabel, MB_OK

    skip_command:


    default_case:

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0

    .else
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif

    xor eax, eax
    ret
WndProc endp

end start

; Something's wrong with it
