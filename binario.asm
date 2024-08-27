section .text
	global _start
_start:
	mov eax, [a29]
jmp4:
	push edx
	push ebx
	mov ebx, a28
	cdq
	idiv ebx
	pop ebx
	pop edx
	mov [a30], eax
	imul eax, [a28]
	mov [a31], eax
	mov eax, [a29]
	sub eax, [a31]
	mov [a31], eax
	push eax
	mov eax, [a30]
	mov [a29], eax
	pop eax
	mov eax, [a29]
	cmp eax, 0
	jg jmp4
	mov eax, 1
	mov ebx, 0
	int 80h
section .data
a28 dd 2
section .bss
a29 resd 1
a30 resd 1
a31 resd 1
