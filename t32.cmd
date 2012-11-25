;@goto -)
		.model	flat,stdcall
		option	casemap:none

GetCommandLineA	proto
GetStdHandle	proto	:dword
WriteFile	proto	:dword,:dword,:dword,:dword,:dword
ExitProcess	proto	:dword

includelib	kernel32.lib

		.data
helpm		db	't32 (Instruction Timing for IA-32) v0.5',13,10
		db	'Copyright (C) 2012 Baklanovsky@mail.ru',13,10,13,10
		db	'... SER,rdtsc,SV,SER Code SER,rdtsc ...',13,10,13,10
		db	'Usage: t32 [SER] [SV] I [C1] [J C2]',13,10
		db	'  SER - n(default)|m|x|mx',13,10
		db	'    n - none',13,10
		db	'    m - memory load/save (mfence)',13,10
		db	'    x - instruction stream (cpuid)',13,10
		db	'  SV  - m(default)|p|x',13,10
		db	'    m - in memory',13,10
		db	'    p - in stack (push/pop)',13,10
		db	'    x - in mmx registers (mm0,mm1)',13,10
		db	'  I = 1 - 4294967295',13,10
		db	'  J = 1 - floor((2000000 - len(C1)) / len(C2))',13,10
		db	'  C1,C2 - even number of chars 0-9a-fA-F',13,10
		db	'  Code = C1 C2 C2 ... (J times)',13,10,13,10
		db	'BE CARE! Code will be execute.',13,10
helpm_l		=	$ - offset helpm
sersv		dw	4
ucodo		dd	0,0
ucodl		dd	0,0
c1jc2		dd	0
svesp		dd	0
tstn		dd	0
rptn		dd	0
tscv		dd	0,0
tscmo		dd	0
		db	20 dup(0)
tscmx		db	13,10
tscml		dd	0
xx		dd	0
tbuf		db	64 dup(0)

		.code
err:		invoke	GetStdHandle,-11
		mov	ebx,offset helpm
		mov	ecx,helpm_l
		mov	edx,offset xx
		invoke	WriteFile,eax,ebx,ecx,edx,0
		invoke	ExitProcess,1

_:		invoke	GetCommandLineA
		call	srchp1
		call	gets
		jz	err
		push	esi
		clc
		call	twrite
		pop	esi
		call	srchp2
		call	getn
		jz	err
		mov	tstn,eax
		call	srchp2
		jz	tcycle

		mov	c1jc2,esi
		call	getc
		jz	jc2
		mov	ucodl,eax
		add	eax,ucodo
		mov	ucodo+4,eax
		call	srchp2
		jz	c__
		call	getn
		jz	jc2
		mov	rptn,eax
		call	srchp2
		jz	jc2
		call	getc
		jz	err
		mov	ucodl+4,eax
		mul	rptn
		or	edx,edx
		jnz	err
		add	eax,ucodl
		jc	err
		cmp	eax,1000000
		ja	err
		jmp	c__

jc2:		mov	esi,c1jc2
		mov	rptn,0
		mov	ucodl,0
		mov	ucodo+4,0
		call	getn
		jz	err
		mov	rptn,eax
		call	srchp2
		call	getc
		jz	err
		mov	ucodl,eax
		mul	rptn
		or	edx,edx
		jnz	err
		cmp	eax,1000000
		ja	err

c__:		call	srchp2
		jnz	err
		call	rptc

tcycle:		mov	ecx,offset tbuf
		mov	ebx,ecx
		mov	esi,ecx
		mov	edi,ecx
		mov	ebp,ecx
		mov	svesp,esp		; ->
tcod:		; SER				; 0|2|3|5
		; rdtsc				; 2
		; SV				; 2|6|11
		; SER				; 0|2|3|5
		; C1		<- ucodo
		; C2 C2 ...	<- ucodo+4
		; SER				; 0|2|3|5
		; rdtsc				; 2
		; [jmp	tprn]			; 5
		db	1000030 dup(90h)
tprn:		bt	sersv,2
		jnc	@F
		sub	eax,tscv
		sbb	edx,tscv+4
@@:		bt	sersv,3
		jnc	@F
		pop	ebx
		pop	ecx
		sub	eax,ebx
		sbb	edx,ecx
@@:		bt	sersv,4
		jnc	@F
		movd	ebx,mm0
		movd	ecx,mm1
		sub	eax,ebx
		sbb	edx,ecx
@@:		mov	esp,svesp		; <-
		call	d20
		invoke	GetStdHandle,-11
		mov	edx,offset xx
		invoke	WriteFile,eax,tscmo,tscml,edx,0

		dec	tstn
		jnz	@F
		invoke	ExitProcess,0
@@:		jmp	tcycle


srchp1		proc				; eax(ASCIZ) -> esi
		cld
		xor	ebx,ebx
		mov	esi,eax
@@:		lodsb
		mov	edi,offset @@a
		mov	ecx,5
	repne	scasb
		lea	edi,[ebx+edi+(offset @@t-offset @@a-1)]
		mov	bl,byte ptr [ebx*4+edi]
		cmp	bl,4
		jne	@B
		dec	esi
		ret
@@a:
		db	0,9,32,'"',0
@@t:
		db	4,0,0,2,1
		db	4,3,3,2,1
		db	4,2,2,1,2
		db	4,3,3,4,4
srchp1		endp

srchp2		proc				; esi(ASCIZ) -> ZF,esi
		cld
@@:		lodsb
		or	al,al
		jz	@F
		cmp	al,9
		je	@B
		cmp	al,32
		je	@B
@@:		dec	esi
		or	al,al
		ret
srchp2		endp

gets		proc				; esi -> sersv,eax(BOOL),ZF,esi
		cld
		mov	eax,0FFFF0000h
		xor	ebx,ebx
@@c:		lodsb
		mov	edi,offset @@a
		mov	ecx,12
	repne	scasb
		sub	edi,offset @@a
		shr	edi,1
		mov	bl,byte ptr @@t[ebx*8+edi]
		cmp	bl,9
		ja	@@e
		je	@@x
		mov	al,byte ptr @@t[ebx*8+7]
		sub	al,1
		jb	@@c
		cmp	al,2
		jb	@F
		and	sersv,not 28
@@:		bts	sersv,ax
		jmp	@@c
@@e:		xor	eax,eax
@@x:		dec	esi
		or	eax,eax
		ret
@@a:
		db	0,9,32,'nNmMxXpP',0
@@t:		;       0  S  n  m  x  p  *  F
		db	9, 9, 1, 3, 2, 6, 9, 0	; 0
		db	9, 5,10,10,10,10,10, 0	; 1
		db	9, 5,10,10,10,10,10, 2	; 2  SER x
		db	9, 5,10,10, 4,10,10, 1	; 3  SER m
		db	9, 5,10,10,10,10,10, 2	; 4  SER x
		db	9, 5, 9, 8, 7, 6, 9, 0	; 5
		db	9, 9,10,10,10,10,10, 4	; 6  SV p
		db	9, 9,10,10,10,10,10, 5	; 7  SV x
		db	9, 9,10,10,10,10,10, 3	; 8  SV m
gets		endp

getn		proc				; esi -> eax(n),ZF,esi
		cld
		xor	ebx,ebx
@@:		lodsb
		mov	edi,offset @@a
		mov	ecx,14
	repne	scasb
		sub	edi,offset @@a+4
		jb	@@x
		cmp	edi,10
		jae	@@e
		mov	eax,10
		mul	ebx
		or	edx,edx
		jnz	@@e
		lea	ebx,[eax+edi]
		jmp	@B
@@e:		xor	ebx,ebx
@@x:		dec	esi
		mov	eax,ebx
		or	eax,eax
		ret
@@a:
		db	0,9,32,'0123456789',0
getn		endp

getc		proc				; esi -> ucod,eax(length),ZF,esi
		cld
		mov	ebp,ucodo+4
		or	ebp,ebp
		cmovz	ebp,ucodo
		mov	ebx,ebp
@@c:		lodsb
		mov	edi,offset @@a
		mov	ecx,26
	repne	scasb
		sub	edi,offset @@a+4
		jb	@@x
		cmp	edi,22
		jae	@@e
		cmp	edi,16
		jb	@F
		sub	edi,6
@@:		mov	edx,edi
		shl	edx,4
		lodsb
		mov	edi,offset @@a
		mov	ecx,26
	repne	scasb
		sub	edi,offset @@a+4
		jb	@@e
		cmp	edi,22
		jae	@@e
		cmp	edi,16
		jb	@F
		sub	edi,6
@@:		add	edx,edi
		mov	[ebx],dl
		inc	ebx
		jmp	@@c
@@e:		mov	ebx,ebp
@@x:		dec	esi
		mov	eax,ebx
		sub	eax,ebp
		ret
@@a:
		db	0,9,32,'0123456789abcdefABCDEF',0
getc		endp

twrite		proc				; CF=0 -> tcod; CF=1,edi -> after ucod
		cld
		jc	@@auc
		mov	edi,offset tcod
		call	@@ser
		mov	esi,offset @@rd
		movsw
		bt	sersv,2
		jnc	@F
		mov	esi,offset @@2m
		mov	ecx,11
	rep	movsb
@@:		bt	sersv,3
		jnc	@F
		mov	esi,offset @@2p
		movsw
@@:		bt	sersv,4
		jnc	@F
		mov	esi,offset @@2x
		movsd
		movsw
@@:		call	@@ser
		mov	ucodo,edi
@@auc:		call	@@ser
		mov	esi,offset @@rd
		movsw
		cmp	edi,offset tprn-5
		jae	@F
		movsb
		mov	eax,offset tprn-4
		sub	eax,edi
		stosd
@@:		ret

@@ser:		mov	esi,offset @@1m
		bt	sersv,0
		jnc	@F
		movsw
		movsb
@@:		mov	esi,offset @@1x
		bt	sersv,1
		jnc	@F
		movsw
@@:		ret

@@1m:		mfence				; 0FAEF0
@@1x:		cpuid				; 0FA2
@@rd:		rdtsc				; 0F31
		db	0E9h			; jmp xxxxxxxx (1st byte)
@@2m:		mov	tscv,eax		; A3 xxxxxxxx
		mov	tscv+4,edx		; 8915 xxxxxxxx
@@2p:		push	edx			; 52
		push	eax			; 50
@@2x:		movd	mm0,eax			; 0F6EC0
		movd	mm1,edx			; 0F6ECA
twrite		endp

rptc		proc
		cld
		mov	esi,ucodo+4
		mov	ebx,ucodl+4
		or	esi,esi
		cmovz	esi,ucodo
		cmovz	ebx,ucodl
		lea	edi,[esi+ebx]
		mov	edx,rptn
@@:		sub	edx,1
		jbe	@F
		mov	ecx,ebx
	rep	movsb
		jmp	@B
@@:		stc
		call	twrite
		ret
rptc		endp

d20		proc				; edx:eax -> tscm
		mov	esi,10
		mov	edi,offset tscmx
		mov	ebx,eax
		mov	ecx,edx
@@:		xor	edx,edx
		mov	eax,ecx
		div	esi
		mov	ecx,eax
		mov	eax,ebx
		div	esi
		mov	ebx,eax
		dec	edi
		add	dl,'0'
		mov	[edi],dl
		or	ecx,ecx
		jnz	@B
		or	ebx,ebx
		jnz	@B
		mov	tscmo,edi
		mov	tscml,offset tscml
		sub	tscml,edi
		ret
d20		endp
		end	_
:-)
@echo off
for %%A in (ml.exe,link.exe) do if "%%~$path:A"=="" call bin.bat
ml /nologo /c %~f0
link /subsystem:console /section:.text,rwe /nologo %~dpn0.obj
del %~dpn0.obj
