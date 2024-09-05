section .text

input_number:
    push ebp
    mov ebp, esp

    ; Read input as string
    mov eax, 3                          ; syscall for sys_read
    mov ebx, 0                          ; file descriptor (0 = stdin)
    lea ecx, [input_buffer]             ; buffer to store user input
    mov edx, 12                         ; max number of bytes to read
    int 0x80                            ; system call

    push eax                            ; push number of bytes read to the stack

    ; Print "Bytes read: "
    mov eax, 4                          ; syscall for sys_write
    mov ebx, 1                          ; file descriptor (1 = stdout)
    lea ecx, [msg_bytes_read]           ; address of the "Bytes read: " string
    mov edx, 12                         ; length of the string
    int 0x80                            ; system call

    call print_read                     ; print number of bytes read

    ; Convert the string read into an integer
    lea esi, [input_buffer]             ; point to the start of the input buffer
    xor ebx, ebx                        ; clear ebx (multiplier)
    mov ecx, 0                          ; flag for negative number

    ; Check if the first character is a minus sign
    mov al, [esi]
    cmp al, '-'                         
    jne check_first_digit               ; if not '-', skip to digit check
    inc esi                             ; advance to the next character
    mov ecx, 1                          ; mark the number as negative

check_first_digit:
    xor eax, eax                        ; clear eax for number accumulation
convert_input_to_int:
    mov bl, [esi]                       ; load the next character
    cmp bl, 10                          ; check if it's a newline ('\n')
    je input_done                       ; if newline, stop
    sub bl, '0'                         ; convert character to numeric value
    imul eax, eax, 10                   ; multiply current number by 10
    add eax, ebx                        ; add the numeric value of the digit
    inc esi                             ; move to the next character
    jmp convert_input_to_int

input_done:
    cmp ecx, 1                          ; check if the number is negative
    je make_negative                    ; if negative, apply the sign
    jmp end_input

make_negative:
    neg eax                             ; negate the value in eax

end_input:
    push eax                            ; push the result (integer value) to the stack
    leave
    ret

output_number:
    push ebp
    mov ebp, esp

    ; Retrieve the number to be printed from the stack
    mov eax, [ebp+8]                    ; number to print

    ; Convert the number to a string
    mov ecx, buffer + 10                ; point to the end of the buffer
    mov byte [ecx], 0                   ; null-terminate the string
    call int_to_string                  ; convert number to string

    ; Print the number as string
    mov eax, 4                          ; syscall for sys_write
    mov ebx, 1                          ; file descriptor (1 = stdout)
    lea ecx, [buffer]                   ; point to the buffer
    mov edx, buffer + 10                ; length of the string
    sub edx, ecx                        ; calculate length
    int 0x80                            ; system call

    ; Print a newline after the number
    mov eax, 4                          ; syscall for sys_write
    mov ebx, 1                          ; file descriptor (1 = stdout)
    lea ecx, [newline]                  ; point to newline character
    mov edx, 1                          ; length = 1 byte
    int 0x80                            ; system call

    ; Print "Bytes written: "
    mov eax, 4                          ; syscall for sys_write
    mov ebx, 1                          ; file descriptor (1 = stdout)
    lea ecx, [msg_bytes_written]        ; address of the "Bytes written: " string
    mov edx, 15                         ; length of the string
    int 0x80                            ; system call

    leave
    ret

print_read:
    ; Retrieve number of bytes read from the stack
    push ebp
    mov ebp, esp
    push [ebp+8]                        ; push bytes read onto the stack

    ; Convert the value in [ebp+8] (bytes read) to a string and print it
    mov ecx, buffer + 10                ; point to the end of the buffer
    mov byte [ecx], 0                   ; null-terminate the string
    call int_to_string                  ; convert number to string

    ; Print the string
    mov eax, 4                          ; syscall for sys_write
    mov ebx, 1                          ; file descriptor (1 = stdout)
    lea ecx, [buffer]                   ; point to the buffer
    mov edx, buffer + 10                ; length of the string
    sub edx, ecx                        ; calculate length
    int 0x80                            ; system call

    leave
    ret

print_written:
    push ebp
    mov ebp, esp

    ; Convert the value in [ebp+8] (bytes written) to a string and print it
    mov ecx, buffer + 10                ; point to the end of the buffer
    mov byte [ecx], 0                   ; null-terminate the string
    call int_to_string                  ; convert number to string

    ; Print the string
    mov eax, 4                          ; syscall for sys_write
    mov ebx, 1                          ; file descriptor (1 = stdout)
    lea ecx, [buffer]                   ; point to the buffer
    mov edx, buffer + 10                ; length of the string
    sub edx, ecx                        ; calculate length
    int 0x80                            ; system call

    leave
    ret

int_to_string:
    ; Convert the number passed on the stack into a string
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]                    ; retrieve number from stack
    xor edx, edx                        ; clear edx
    mov ebx, 10                         ; divisor (base 10)
    mov esi, eax                        ; store the original eax value in esi

    ; If the number is negative, handle the sign
    test esi, esi                       ; check if the number is negative
    jns convert_loop                    ; if positive, skip the next part
    neg eax                             ; if negative, make it positive

convert_loop:
    xor edx, edx                        ; clear edx for division
    div ebx                             ; divide eax by 10, quotient in eax, remainder in edx
    add dl, '0'                         ; convert remainder to ASCII
    dec ecx                             ; move the pointer backward
    mov [ecx], dl                       ; store the ASCII character
    test eax, eax                       ; check if we're done
    jnz convert_loop                    ; if not, keep looping

    ; Add negative sign if necessary
    test esi, esi                       ; check if the original number was negative
    jns done                            ; if not, skip this part
    dec ecx                             ; move the pointer backward
    mov byte [ecx], '-'                 ; store the minus sign

done:
    leave
    ret
