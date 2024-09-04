section .data
    input_prompt db "Enter a number: ", 0
    output_msg db "You entered: ", 0
    newline db 0xA, 0

section .bss
    input_buffer resb 12    ; Reserve 12 bytes for input (large enough for 32-bit integer + newline)

section .text
    global _start

_start:
    ; Test the input and output functions
    
    ; Call input_number to read a number from the user
    call input_number
    
    ; The number will be stored in EAX, call output_number to print it
    call output_number
    
    ; Exit the program
    mov eax, 1         ; System call number for exit
    xor ebx, ebx       ; Exit status 0
    int 0x80

; Function to read a number from the user (input_number)
input_number:
    ; Display prompt
    mov eax, 4          ; System call number for sys_write
    mov ebx, 1          ; File descriptor 1 (stdout)
    mov ecx, input_prompt ; Address of the input prompt
    mov edx, 15         ; Length of the message
    int 0x80
    
    ; Read input
    mov eax, 3          ; System call number for sys_read
    mov ebx, 0          ; File descriptor 0 (stdin)
    mov ecx, input_buffer ; Address of the input buffer
    mov edx, 12         ; Number of bytes to read
    int 0x80

    ; Convert string input to integer
    mov esi, input_buffer ; Point ESI to the input buffer
    xor eax, eax        ; Clear EAX (result accumulator)
    xor ebx, ebx        ; Clear EBX (sign flag, 0 = positive, 1 = negative)
    
    ; Check if the first character is '-'
    cmp byte [esi], '-' 
    jne .convert        ; If not '-', jump to conversion
    inc esi             ; Skip the minus sign
    mov bl, 1           ; Set sign flag (negative)
    
.convert:
    xor edx, edx        ; Clear EDX (remainder register)
    
.next_digit:
    movzx ecx, byte [esi] ; Load the next character
    cmp ecx, 0xA         ; Check if it's a newline
    je .end_conversion   ; If newline, end the conversion
    sub ecx, '0'         ; Convert ASCII to integer (subtract ASCII value of '0')
    imul eax, eax, 10    ; Multiply result by 10
    add eax, ecx         ; Add the new digit to the result
    inc esi              ; Move to the next character
    jmp .next_digit

.end_conversion:
    cmp bl, 0            ; Check if the sign flag is set
    je .done             ; If not negative, we are done
    neg eax              ; If negative, negate the result
    
.done:
    ret                  ; Return the result in EAX

; Function to print a number (output_number)
output_number:
    ; Display output message
    mov eax, 4          ; System call number for sys_write
    mov ebx, 1          ; File descriptor 1 (stdout)
    mov ecx, output_msg ; Address of the output message
    mov edx, 13         ; Length of the message
    int 0x80
    
    ; Convert integer in EAX to string and print it
    mov esi, input_buffer + 11 ; Point to the end of the buffer
    mov byte [esi], 0    ; Null-terminate the string
    dec esi              ; Move pointer to where the digits will go
    mov ecx, 10          ; Divisor for modulus operation
    
    ; Check if the number is negative
    cmp eax, 0
    jge .convert_positive ; If positive, skip to conversion
    neg eax              ; If negative, negate the number
    
    ; Add '-' to the buffer for negative numbers
    mov byte [esi], '-'
    dec esi
    
.convert_positive:
    xor edx, edx         ; Clear remainder
    
.convert_loop:
    div ecx              ; Divide EAX by 10, EAX = quotient, EDX = remainder
    add dl, '0'          ; Convert remainder to ASCII
    mov [esi], dl        ; Store the digit
    dec esi              ; Move to the next position
    test eax, eax        ; Check if EAX is zero
    jnz .convert_loop    ; If not, keep converting
    
    inc esi              ; Move pointer to the first digit
    
    ; Print the number
    mov eax, 4          ; System call number for sys_write
    mov ebx, 1          ; File descriptor 1 (stdout)
    mov ecx, esi        ; Address of the number string
    mov edx, input_buffer + 12 - esi ; Calculate the length of the string
    int 0x80
    
    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ret                  ; Return to caller
