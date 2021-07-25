.486
.model flat, stdcall
option casemap :none
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib

include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\windows.inc
include \masm32\include\msvcrt.inc
include \masm32\include\masm32.inc
include \masm32\macros\macros.asm

.data

dllname db "\1.dll",0       ; dll name (relative path)
currentdir db 255 dup(?)
processname db "csgo.exe",0 ; game name
handle dd 00000000
threadid dd 00000000
ps db 128 dup(?)
pid dd 00000000

modulename db "kernel32.dll",0
p32fAName db "Process32First",0
p32nAName db "Process32Next",0
loadlibraryStr db "LoadLibraryA",0

p32fA dd 00000000
p32nA dd 00000000
loadlibraryAddr dd 00000000

allocbase dd 00000000

.code

gmha proc var1:DWORD

fn GetProcAddress,ebx,var1
test eax,eax
je EXIT
ret 4

gmha endp
    
start:
    fn GetModuleHandleA,offset modulename
    mov ebx,eax

    invoke gmha,offset p32fAName
    mov [p32fA],eax

    invoke gmha,offset p32nAName
    mov [p32nA],eax

    invoke gmha,offset loadlibraryStr
    mov [loadlibraryAddr],eax
    
    fn GetCurrentDirectory,255,&currentdir
    fn crt_strcat,offset currentdir,offset dllname
    fn CreateToolhelp32Snapshot,2,0

    cmp eax,0FFFFFFFFh
    je EXIT
    
    mov [handle],eax
    mov eax,296
    mov ebx,offset ps
    mov [ebx],eax

    push offset ps
    push handle
    call p32fA

    test al,al
    je EXIT

CMPNAME:
    lea eax,[ebx+024h] ; mov eax,ps.szExeFile

    fn crt_strcmp,eax,&processname

    test al,al
    je INJECT

    push offset ps
    push handle
    call p32nA
    test al,al
    je EXIT
    jmp CMPNAME

INJECT:
    fn CloseHandle,handle
    mov eax,[ebx+08h]
    mov [pid],eax
    
    fn OpenProcess,2035711,0,pid
    cmp eax,0FFFFFFFFh
    je EXIT
    mov [handle],eax

    fn VirtualAllocEx,handle,0,01000h,01000h,040h
    test eax,eax
    je EXIT
    mov [allocbase],eax

    fn crt_strlen,offset currentdir
    fn WriteProcessMemory,handle,allocbase,offset currentdir,eax,0
    test al,al
    je FREEANDEXIT                                         ;library dir           
    
    fn CreateRemoteThread,handle,0,0,loadlibraryAddr,allocbase,0,threadid
    test eax,eax
    je EXIT

    fn CloseHandle,handle
    jmp EXITT

FREEANDEXIT:
    fn CloseHandle,handle
    fn VirtualFreeEx,handle,allocbase,01000h,04000h
    jmp EXIT

EXIT:
    fn MessageBox,0,"failed to inject",0,MB_OK
EXITT:
    fn ExitProcess,0

end     start
