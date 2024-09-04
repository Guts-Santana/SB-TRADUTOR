section .data
    buffer db 12                  ; Buffer to store the converted string
    newline db 10                 ; Newline character (for printing)
    msg db "EDX contains: ", 0    ; Message prefix

section .text
    global _start

_start:
    ; Move some value to EAX (example)
    mov eax, 12345                ; Example value in EAX

    ; Move EAX to EDX
    mov edx, eax                  ; Move the value from EAX to EDX

    ; Print message: "EDX contains: "
    mov eax, 4                    ; sys_write system call
    mov ebx, 1                    ; File descriptor (stdout)
    lea ecx, [msg]                ; Address of the message
    mov edx, 15                   ; Length of the message
    int 0x80                      ; Call the kernel

    ; Now, print the value in EDX (which was originally in EAX)
    ; Convert the value in EDX to a string
    mov eax, edx                  ; Move the value in EDX to EAX (for conversion)
    lea ecx, [buffer + 11]        ; Point to the end of the buffer
    mov byte [ecx], 0             ; Null-terminate the string
    mov ebx, 10                   ; Base 10 for the conversion

convert_loop:
    xor edx, edx                  ; Clear EDX for division
    div ebx                       ; Divide EAX by 10, quotient in EAX, remainder in EDX
    add dl, '0'                   ; Convert remainder to ASCII
    dec ecx                       ; Move back the pointer in the buffer
    mov [ecx], dl                 ; Store the ASCII digit
    test eax, eax                 ; Check if quotient is zero
    jnz convert_loop              ; If not, continue the loop

    ; Print the converted string
    mov eax, 4                    ; sys_write system call
    mov ebx, 1                    ; File descriptor (stdout)
    lea edx, [ecx]                ; Address of the buffer
    mov edx, buffer + 11 - ecx    ; Length of the string
    int 0x80                      ; Call the kernel

    ; Print a newline
    mov eax, 4                    ; sys_write system call
    mov ebx, 1                    ; File descriptor (stdout)
    lea ecx, [newline]            ; Address of newline character
    mov edx, 1                    ; Length of newline (1 byte)
    int 0x80                      ; Call the kernel

    ; Exit the program
    mov eax, 1                    ; sys_exit system call
    xor ebx, ebx                  ; Return 0
    int 0x80                      ; Call the kernel
