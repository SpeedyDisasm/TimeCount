 
			.686
			.MMX
			.XMM
			.model	flat,stdcall
			option	casemap:none
			BSIZE equ 15

	include windows.inc
	include user32.inc
	includelib user32.lib
	include kernel32.inc		
	includelib kernel32.lib

			.data
	ifmt	db "%0lu", 0
	outp	db BSIZE dup(?)
	FileNam db 'result.txt', 0
	hParametr dd 0h
	nemA dd 0h
			.data?
		var db BSIZE dup(?)

			.code
	main proc
		push edx
		push eax
		push ebx
		push ecx
		
		
	commands MACRO 
			rept 10
		mov eax, ebx 
				endm
			endm
			
			mov ecx, 1
			mov edi, 1
			lea edi, var
			;mov [edi], 1
			
			rdtsc
			push eax
			push edx
			lfence
			commands
			lfence
			rdtsc
			
			mov ebx, eax
			mov ecx, edx
			pop edx
			pop eax
			sub ebx, eax
			sub ecx, edx
			push ecx			
				invoke CreateFile, addr FileNam, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
				mov hParametr, eax
			pop ecx
			cmp ecx, 0
			je equal
			invoke	wsprintf, addr outp, addr ifmt, ecx
			invoke WriteFile, hParametr, addr outp, 16, addr nemA, NULL
equal:
			invoke	wsprintf, addr outp, addr ifmt, ebx
			invoke WriteFile, hParametr, addr outp, 16, addr nemA, NULL
			invoke CloseHandle, hParametr
			
		pop edx
		pop eax
		pop ebx
		pop ecx
		
			invoke	ExitProcess, 0

			main endp
		end main
