section .data
    prompt db "Enter a number: ", 0
    newline db 0x0A, 0    ; New line character

section .bss
    buffer resb 20        ; Reserve 20 bytes for input buffer

section .text
    global input_number
    global output_number

input_number:
    push ebp
    mov ebp, esp

    ; Load the address of the integer from the stack
    mov eax, [ebp + 8]    ; EAX = address of the integer

    ; Print the prompt message
    mov eax, 4            ; sys_write
    mov ebx, 1            ; File descriptor 1 (stdout)
    mov ecx, prompt       ; Pointer to the message
    mov edx, 16           ; Length of the message
    int 0x80

    ; Read user input
    mov eax, 3            ; sys_read
    mov ebx, 0            ; File descriptor 0 (stdin)
    mov ecx, buffer       ; Buffer to store the input
    mov edx, 20           ; Max number of bytes to read
    int 0x80

    ; Convert string to number
    xor eax, eax          ; Clear EAX (result accumulator)
    xor ebx, ebx          ; EBX will store the current digit

.convert_loop:
    movzx ecx, byte [buffer + ebx] ; Get the current character
    cmp ecx, 0x0A         ; Check if it's a newline (Enter key)
    je .done_conversion   ; If newline, end the loop
    sub ecx, '0'          ; Convert ASCII to digit
    imul eax, eax, 10     ; Multiply EAX by 10 (shift left by one decimal place)
    add eax, ecx          ; Add the current digit
    inc ebx               ; Move to the next character
    jmp .convert_loop     ; Repeat the loop for the next character

.done_conversion:
    mov ebx, [ebp + 8]    ; Get the address where the result should be stored
    mov [ebx], eax        ; Store the result at the provided address

    leave
    ret

output_number:
    push ebp
    mov ebp, esp

    ; Load the number from the stack
    mov eax, [ebp + 8]

    mov ecx, buffer + 19  ; Point to the end of the buffer
    mov ebx, 10           ; Set divisor to 10
    mov byte [ecx], 0     ; Null-terminate the buffer
    dec ecx               ; Move to the last character position in the buffer

.output_loop:
    xor edx, edx          ; Clear EDX before division
    div ebx               ; Divide EAX by 10
    add dl, '0'           ; Convert remainder to ASCII
    mov [ecx], dl         ; Store the digit in the buffer
    dec ecx               ; Move buffer pointer back
    test eax, eax         ; Check if quotient is zero
    jnz .output_loop      ; If not, continue the loop

    inc ecx               ; Move pointer forward to the first digit

    ; Print the number
    mov eax, 4            ; sys_write
    mov ebx, 1            ; File descriptor 1 (stdout)
    mov edx, buffer + 19  ; End of the buffer
    sub edx, ecx          ; Calculate the length of the number string
    mov ecx, ecx          ; Set ECX to the start of the number string
    int 0x80

    ; Print a newline
    mov eax, 4            ; sys_write
    mov ebx, 1            ; File descriptor 1 (stdout)
    mov ecx, newline      ; Pointer to the newline character
    mov edx, 1            ; Length of the newline character
    int 0x80

    leave
    ret
