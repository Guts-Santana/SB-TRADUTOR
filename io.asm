section .data
    end_message db 10  ; Newline character

section .text
    global input_number, output_number

input_number:
    ; Save registers
    push ebp
    mov ebp, esp
    sub esp, 12               ; Allocate buffer space

    ; Read string from input
    mov eax, 3                ; sys_read
    mov ebx, 0                ; stdin (file descriptor 0)
    lea ecx, [esp]            ; Buffer address
    mov edx, 12               ; Max number of bytes to read
    int 0x80                  ; System call

    ; Convert the string to a number
    lea esi, [esp]            ; Point to buffer
    xor edi, edi              ; Zero edi (to accumulate the number)
    xor ecx, ecx              ; Zero ecx (for sign)

    ; Check if negative
    cmp byte [esi], '-'
    jne .read_number
    mov ecx, 1                ; Mark as negative
    inc esi                   ; Move to the next character

.read_number:
    xor eax, eax              ; Clear eax for number assembly
.loop:
    mov bl, [esi]             ; Read a byte
    cmp bl, 0                 ; Check for null terminator
    je .done
    sub bl, '0'               ; Convert ASCII to digit
    imul eax, eax, 10         ; Multiply current number by 10
    add eax, ebx              ; Add new digit
    inc esi                   ; Move to next character
    jmp .loop

.done:
    cmp ecx, 0
    je .final
    neg eax                   ; Negate if negative

.final:
    mov [ebp+8], eax          ; Store the number

    ; Clean up
    add esp, 12
    pop ebp
    ret

output_number:
    ; Save registers
    push ebp
    mov ebp, esp

    ; Convert number to string
    mov eax, [ebp+8]          ; Load number
    sub esp, 12               ; Allocate buffer
    lea esi, [esp+12]         ; Point to end of buffer
    mov byte [esi], 0         ; Null terminator

    ; Check if negative
    cmp eax, 0
    jge .convert
    neg eax
    mov byte [esi-1], '-'     ; Add negative sign
    dec esi

.convert:
    xor ecx, ecx              ; Clear digit count
    mov ebx, 10               ; Division base

.print_loop:
    xor edx, edx              ; Clear edx for division
    div ebx                   ; Divide eax by 10
    add dl, '0'               ; Convert digit to ASCII
    dec esi
    mov [esi], dl             ; Store digit
    inc ecx
    test eax, eax
    jnz .print_loop

    ; Output the string
.write_number:
    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout (file descriptor 1)
    mov edx, ecx              ; Number of bytes
    lea ecx, [esi]            ; Pointer to string
    int 0x80

    ; Clean up
    add esp, 12
    pop ebp
    ret
