section .text
	global _start
_start:
	mov eax, 1
	mov ebx, 0
	int 80h
section .data
section .bss
a5 resd 1
