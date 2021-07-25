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

dllname db "\1.dll",0
currentdir db 255 dup(?)
processname db "csgo.exe",0
handle dd 00000000
threadid dd 00000000
ps db 128 dup(?)
pid dd 00000000

modulename db "kernel32.dll",0
p32fAName db "Process32First",0
p32nAName db "Process32Next",0
loadlibraryStr db "LoadLibraryA",0
exitthreadstr db "ExitThread",0

p32fA dd 00000000
p32nA dd 00000000
loadlibraryAddr dd 00000000
exitthreadaddr dd 00000000

allocbase dd 00000000
shellcode db 0B8h,00,00,00,00,068h,00,00,00,00,0FFh,0D0h,0B8h,00,00,00,00,0FFh,0D0h

.code    
;--------------------------
fastexit proc
fn ExitProcess,0
fastexit endp
;--------------------------
Process32FirstA proc

jmp [p32fA]

Process32FirstA endp
;--------------------------
Process32NextA proc

jmp [p32nA]

Process32NextA endp
;--------------------------
start:
    fn GetModuleHandleA,offset modulename
    mov ebx,eax
    fn GetProcAddress,ebx,offset p32fAName
    test eax,eax
    je EXIT
    mov [p32fA],eax
    fn GetProcAddress,ebx,offset p32nAName
    test eax,eax
    je EXIT
    mov [p32nA],eax
    fn GetProcAddress,ebx,offset loadlibraryStr
    test eax,eax
    je EXIT
    mov [loadlibraryAddr],eax
    fn GetProcAddress,ebx,offset exitthreadstr
    test eax,eax
    je EXIT
    mov [exitthreadaddr],eax
    
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
    invoke Process32FirstA

    test al,al
    je EXIT

CMPNAME:
    lea eax,[ebx+024h] ; mov eax,ps.szExeFile

    fn crt_strcmp,eax,&processname

    test al,al
    je INJECT

    push offset ps
    push handle
    invoke Process32NextA
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

    mov ebx,allocbase
    add ebx,070h
    
    mov eax,offset shellcode
    mov ecx,loadlibraryAddr
    mov [eax+1],ecx
    mov [eax+6],ebx
    mov ecx,exitthreadaddr
    mov [eax+13],ecx
    
    fn WriteProcessMemory,handle,allocbase,eax,19,0
    test al,al
    je FREEANDEXIT
    
	sub ebx,010h
    fn crt_strlen,offset currentdir
    fn WriteProcessMemory,handle,ebx,offset currentdir,eax,0
    test al,al
    je FREEANDEXIT                                         ;library dir           
    
    fn CreateRemoteThread,handle,0,0,allocbase,0,0,threadid
    test eax,eax
    je EXIT

    fn WaitForSingleObject,threadid,0FFFFFFFFh
    
NORMALEXIT:
    fn CloseHandle,handle
    fn VirtualFreeEx,handle,allocbase,01000h,04000h
    invoke fastexit

FREEANDEXIT:
    fn CloseHandle,handle
    fn VirtualFreeEx,handle,allocbase,01000h,04000h
    jmp EXIT

EXIT:
    fn MessageBox,0,"failed to inject",0,MB_OK
    invoke fastexit

end     start
