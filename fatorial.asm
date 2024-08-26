section .text
	global _start
_start:
	mov eax, [a22]
jmp4:
	sub eax, [a23]
	cmp eax, 0
	jz jmp18
	mov [a21], eax
	imul eax, [a22]
	mov [a22], eax
	mov eax, [a21]
	cmp eax, 0
	jmp jmp4
jmp18:
	mov eax, 1
	mov ebx, 0
	int 80h
section .data
a23 dd 1
section .bss
a21 resd 1
a22 resd 1
