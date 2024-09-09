%define INPUT_BUFFER [ebp+12]
%define BUFFER [ebp+12]

MAX_BUFFER_SIZE_INPUT equ 12

section .text
global _start, input, output, overflow, s_input, s_output

overflow:
	mov eax, 4                    
    mov ebx, 1                    
    mov ecx, output_overflow                     
    mov edx, len_overflow
    int 0x80

	mov eax, 4                   ; sys_write
    mov ebx, 1                   ; stdout
    mov ecx, newline             ; Newline character
    mov edx, 1                   ; Length of newline
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80

; -----------------------------------------------
; Input: Read a decimal value from stdin and convert it to an integer
; Input: EBP+8 - Pointer to variable to store the result
;        EBP+12 - Pointer to the buffer to store the input
; Output: Integer in EAX - Bytes read
input:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the destination pointer
    mov esi, INPUT_BUFFER         ; Buffer to store input

    ; Read input from stdin
    mov eax, 3                       ; sys_read
    mov ebx, 0                       ; stdin
    mov ecx, esi                     ; Buffer pointer
    mov edx, MAX_BUFFER_SIZE_INPUT   ; Buffer size
    int 0x80

    push eax

    ; Check if input is negative
    movzx eax, byte [esi]         ; Load the first character
    pop ecx

    pusha
    push esi
    push ecx
    call output_read
    pop ecx 
    pop esi 
    popa

    cmp al, '-'                   ; Compare with '-'
    jne .positive                 ; If not negative, jump to positive

    ; Handle negative input
    dec ecx                       ; Exclude the '\n'
    push ecx                      ; Push length of string including '-'

    inc esi                       ; Move to next character (skip '-')
    dec ecx                       ; Adjust length to ignore '-'

    push esi                      ; Push pointer to string (after '-')
    push ecx                      ; Push length of the string
    call convert_input_to_int     ; Convert string to integer
    pop ecx
    pop esi

    neg eax                       ; Negate the result for negative numbers
    jmp .end_input                      ; Jump to the end

.positive:
    ; Handle positive input
    dec ecx                       ; Exclude the '\n'
    push ecx                      ; Push length of the string

    push esi                      ; Push pointer to string
    push ecx                      ; Push length of the string
    call convert_input_to_int     ; Convert string to integer
    pop ecx
    pop esi

.end_input:
    mov [edi], eax                ; Store the result in the destination pointer
    
    pop ecx 
    mov eax, ecx                  ; Return the number of bytes read in eax
    leave
    ret


; -----------------------------------------------
; Convert a string to an integer
; Input: EBP+12 - Pointer to the string
;        EBP+8  - Length of the string
; Output: Integer in EAX
convert_input_to_int:
    enter 0, 0
    mov esi, [ebp + 12]           ; Get pointer to the string
    mov ecx, [ebp + 8]            ; Get length of the string
    xor ebx, ebx                  ; Clear result accumulator (EBX)

.string_to_int:
    movzx eax, byte [esi]         ; Load the next character
    inc esi
    sub al, '0'                   ; Convert ASCII to integer
    imul ebx, 10                  ; Multiply previous result by 10
    add ebx, eax                  ; Add the current digit
    loop .string_to_int           ; Repeat for all characters

    mov eax, ebx                  ; Move result to EAX
    leave
    ret

; -----------------------------------------------
; Show output message and print integer result
; Input: EBP+8 - Pointer to the integer value to print
;        EPB+12 - Buffer
output_read:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the integer to print
    mov esi, BUFFER               ; Buffer to store the converted string

    cmp edi, MAX_BUFFER_SIZE_INPUT
    jg overflow

    ; Print the output message
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; stdout
    mov ecx, read_msg           ; Message to print
    mov edx, len_read_msg       ; Length of the message
    int 0x80

    ; Convert the integer to string
    push edi                      ; Push integer value
    push esi                      ; Push pointer to buffer
    call int_to_string            ; Convert integer to string
    pop esi                       ; Restore buffer pointer
    pop edi                       ; Restore integer value

    ; Print the converted string
    push eax                      ; Push pointer to string
    push ecx                      ; Push length of string
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    pop edx                       ; Length of string
    pop ecx                       ; Pointer to string
    int 0x80

    ; Print a new line
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, newline              ; Newline character
    mov edx, 1                    ; Length of newline
    int 0x80
    leave
    ret

; -----------------------------------------------
; Show output message and print integer result
; Input: EBP+8 - Pointer to the integer value to print
;        EPB+12 - Buffer
output_written:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the integer to print
    mov esi, BUFFER               ; Buffer to store the converted string

    ; Print the output message
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, written_msg           ; Message to print
    mov edx, len_written_msg       ; Length of the message
    int 0x80

    ; Convert the integer to string
    push edi                      ; Push integer value
    push esi                      ; Push pointer to buffer
    call int_to_string             ; Convert integer to string
    pop esi                       ; Restore buffer pointer
    pop edi                       ; Restore integer value

    ; Print the converted string
    push eax                      ; Push pointer to string
    push ecx                      ; Push length of string
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    pop edx                       ; Length of string
    pop ecx                       ; Pointer to string
    int 0x80

    ; Print a new line
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, newline             ; Newline character
    mov edx, 1                    ; Length of newline
    int 0x80
    leave
    ret


; -----------------------------------------------
; Convert an integer to a string
; Input: EBP+8 - Pointer to the buffer to store the string
;        EBP+12 - Integer to convert
; Output: Pointer to the beginning of the string in EAX
int_to_string:
    enter 0, 0                 ; Set up the stack frame
    
    mov eax, [ebp + 12]        ; Load the integer to convert (from EBP+12) into EAX
    mov esi, [ebp + 8]         ; Load the destination buffer address (from EBP+8) into ESI
    add esi, 9                 ; Move to the end of the buffer (assuming max 9 digits)
    mov byte [esi], 0          ; Null-terminate the string (set last byte to 0)
    
    mov ecx, 0                 ; ECX will count the digits
    mov ebx, 10                ; Set divisor to 10 (for base-10 division)
    
.next_digit:
    inc ecx                    ; Increment the digit counter
    xor edx, edx               ; Clear EDX (high part of EAX) before division
    div ebx                    ; Divide EAX by 10, result in EAX, remainder in EDX
    add dl, '0'                ; Convert the remainder (DL) to ASCII by adding '0'
    dec esi                    ; Move back in the buffer
    mov [esi], dl              ; Store the ASCII digit in the buffer
    test eax, eax              ; Check if EAX (quotient) is zero
    jnz .next_digit            ; If not zero, continue with the next digit

    mov eax, esi               ; Return the pointer to the beginning of the string (ESI)
    leave                      ; Restore the stack frame
    ret                        ; Return to the caller

; --------------------------------------------------
; Output: Print an integer to stdout
; Input: EBP+8 - Pointer to the integer to print
;       EBP+12 - Buffer to store the string representation    
output:
    enter 0, 0
    sub esp, 4                 ; Reserve space for the negative flag
    mov byte [esp], 0          ; Clear the negative flag
    ; Clear the buffer
    mov edi, INPUT_BUFFER

    mov edi, [ebp + 8]          ; Get the pointer to the integer value
    mov esi, INPUT_BUFFER       ; Buffer to store the string representation
    mov eax, [edi]              ; Load integer into EAX for checking

    ; Check if the number is negative
    cmp eax, 0
    jge .positive_output        ; If non-negative, jump to positive case

    ; Handle negative numbers
    neg eax                     ; Negate the number
    mov byte [esp], 1           ; Set the negative flag

.positive_output:
    ; Convert the integer to a string
    push eax                    ; Preserve integer value
    push esi                    ; Push buffer pointer
    call int_to_string          ; Convert integer to string
    pop esi                     ; Restore buffer pointer
    pop ebx                     ; Discard preserved value

    cmp byte [esp], 1           ; Check if the number was negative
    jne .end_output             ; If not negative, jump to done

    dec eax
    mov byte [eax], '-'
    inc ecx

.end_output:
    push eax                    ; Pointer to string
    push ecx                    ; Length of the string
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; stdout
    pop edx                     ; Restore length of the string
    pop ecx                     ; Restore pointer to string
    int 0x80

    mov ecx, edx                ; Store string length in ECX

    pusha

    ; Print a new line
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, newline             ; Newline character
    mov edx, 1                    ; Length of newline
    int 0x80

    popa

    ; Call show_output_msg to display output
    pusha
    push esi
    push ecx                    ; Push length of string
    call output_written         ; Call show_output_msg
    pop ecx                     ; Restore length of string
    pop esi
    popa

    ; Return the length of the string in EAX
    mov eax, ecx
    leave
    ret

; --------------------------------------------------
; Input: EBP+8 - Pointer to the memory location with the data to print
;        EBP+12 - Number of characters to print
; Output: Prints the data to stdout, returns number of bytes written in EAX
s_output:
    enter 0, 0
    
    ; Get parameters from the stack
    mov ecx, [ebp + 8]  ; Memory address of the data to be printed (buffer)
    mov edx, [ebp + 12] ; Number of characters to print

    ; Syscall for writing data to stdout
    mov eax, 4          ; Syscall number for sys_write
    mov ebx, 1          ; File descriptor for stdout (1)
    int 0x80            ; Call kernel

    push eax

    ; Print a new line
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, newline             ; Newline character
    mov edx, 1                    ; Length of newline
    int 0x80

    pop ecx
    push ecx 
    call output_written 
    pop ecx

    mov eax, ecx
    
    leave
    ret


; --------------------------------------------------
; Input: EBP+8 - Pointer to the memory location to store the number of bytes read
;        EBP+12 - Number of characters to read
; Output: Reads data from stdin and stores it in memory, returns number of bytes read in EAX
s_input:
    enter 0, 0

    ; Get parameters from the stack
    mov ecx, [ebp + 8]  ; Memory address where data will be stored (buffer)
    mov edx, [ebp + 12] ; Number of characters to read

    ; Syscall for reading data from stdin
    mov eax, 3          ; Syscall number for sys_read
    mov ebx, 0          ; File descriptor for stdin (0)
    int 0x80            ; Call kernel

    push eax
    pop ecx
    push ecx 
    call output_read 
    pop ecx

    mov eax, ecx

    leave
    ret