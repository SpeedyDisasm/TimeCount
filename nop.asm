 .686
		.model	flat,stdcall
		option	casemap:none
		BSIZE equ 15
		COUNT equ 100000

include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc		
includelib kernel32.lib

		.data
ifmt	db "%0lu", 0
outp	db BSIZE dup(?)
FileNam db '\fuck.txt', 0
hParametr dd 0h
nemA dd 0h

		.code
main proc
	push edx
	push eax
	push ebx
	push ecx
	
commands MACRO 
		rept COUNT
			nop
			endm
		endm
		
		invoke	GetStdHandle, STD_OUTPUT_HANDLE
		mov esi, eax
		
		mov ecx, 1
		mov edi, 1
		
		rdtsc
		push eax
		push edx
		
		commands
		rdtsc
		mov ebx, eax
		mov ecx, edx
		pop edx
		pop eax
		sub ebx, eax
		sub ecx, edx
		
		invoke	wsprintf, addr outp, addr ifmt, ebx
		invoke	WriteConsoleA, esi, addr outp, 10, 0, 0
		
		invoke CreateFile, addr FileNam, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
		mov hParametr, eax
		invoke WriteFile, hParametr, addr outp, 10, addr nemA, NULL
		invoke CloseHandle, hParametr
		
	pop edx
	pop eax
	pop ebx
	pop ecx
	
		invoke	ExitProcess, 0

		main endp
	end main