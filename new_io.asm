section .text
global _start, input, convert_input_to_int, len, output_read, output_written, output, overflow, s_input, s_output

overflow:
	mov eax, 4                    
    mov ebx, 1                    
    mov ecx, output_overflow                     
    mov edx, len_overflow
    int 0x80

	mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, newline             ; Newline character
    mov edx, 1                    ; Length of newline
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80

; -----------------------------------------------
; Input: Read a decimal value from stdin and convert it to an integer
; Input: EBP+8 - Pointer to variable to store the result
; Output: Integer in EAX
input:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the destination pointer
    mov esi, input_buffer         ; Buffer to store input

    ; Read input from stdin
    mov eax, 3                    ; sys_read
    mov ebx, 0                    ; stdin
    mov ecx, esi                  ; Buffer pointer
    mov edx, 12                   ; Buffer size
    int 0x80

    push eax

    ; Check if input is negative
    movzx eax, byte [esi]         ; Load the first character
    pop ecx

    pusha
    push ecx 
    call output_read 
    pop ecx 
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
    call convert_input_to_int             ; Convert string to integer
    pop ecx
    pop esi

    neg eax                       ; Negate the result for negative numbers
    jmp .end                      ; Jump to the end

.positive:
    ; Handle positive input
    dec ecx                       ; Exclude the '\n'
    push ecx                      ; Push length of the string

    push esi                      ; Push pointer to string
    push ecx                      ; Push length of the string
    call convert_input_to_int             ; Convert string to integer
    pop ecx
    pop esi

.end:
    mov [edi], eax                ; Store the result in the destination pointer
    pop ecx 
    
    mov eax, ecx 
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
    loop .string_to_int              ; Repeat for all characters

    mov eax, ebx                  ; Move result to EAX
    leave
    ret

; -----------------------------------------------
; Show output message and print integer result
; Input: EBP+8 - Pointer to the integer value to print
output_read:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the integer to print
    mov esi, buffer               ; Buffer to store the converted string

    cmp edi, 11
    jg overflow

    ; Print the output message
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, read_msg           ; Message to print
    mov edx, len_read_msg       ; Length of the message
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
; Show output message and print integer result
; Input: EBP+8 - Pointer to the integer value to print
output_written:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the integer to print
    mov esi, buffer               ; Buffer to store the converted string

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


int_to_string:
    enter 0,0 ;
    mov eax, [ebp+12] 
    mov esi, [ebp+8] 
    add esi,9        
    mov byte [esi],0    

    mov ecx,0 
    mov ebx,10 
.next_digit:
    inc ecx 
    xor edx,edx         
    div ebx             
    add dl,'0'          
    dec esi             
    mov [esi],dl
    test eax,eax            
    jnz .next_digit     

    
    mov eax,esi
    leave 
    ret

; --------------------------------------------------
; Output: Print an integer to stdout
; Input: EBP+8 - Pointer to the integer to print
output:
    enter 0, 0
    sub esp, 4 ; Reserve space for the negative flag
    mov byte [esp], 0          ; Clear the negative flag
    ; Clear the buffer
    mov edi, input_buffer

    mov edi, [ebp + 8]          ; Get the pointer to the integer value
    mov esi, input_buffer ; Buffer to store the string representation
    mov eax, [edi]              ; Load integer into EAX for checking

    ; Check if the number is negative
    cmp eax, 0
    jge .positive_output             ; If non-negative, jump to positive case

    ; Handle negative numbers
    neg eax                     ; Negate the number
    mov byte [esp], 1          ; Set the negative flag

.positive_output:
    ; Convert the integer to a string
    push eax                    ; Preserve integer value
    push esi                    ; Push buffer pointer
    call int_to_string          ; Convert integer to string
    pop esi                     ; Restore buffer pointer
    pop ebx                     ; Discard preserved value

    cmp byte [esp], 1        ; Check if the number was negative
    jne .done                    ; If not negative, jump to done

    dec eax
    mov byte [eax], '-'
    inc ecx

.done:
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
    push ecx                    ; Push length of string
    call output_written         ; Call show_output_msg
    pop ecx                     ; Restore length of string
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


tst:
    ret