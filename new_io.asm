section .text
global _start, input, string_to_int, len, show_output_msg, output, OVERFLOW


; TEMPORARY!!!
OVERFLOW:
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
    mov edi, input_buffer   ; Clear buffer
    mov ecx, 12
    mov al, 0
    rep stosb                     ; Fill buffer with 0's

    mov edi, [ebp + 8]            ; Get the destination pointer
    mov esi, input_buffer   ; Buffer to store input

    ; Read input from stdin
    mov eax, 3                    ; sys_read
    mov ebx, 0                    ; stdin
    mov ecx, esi                  ; Buffer pointer
    mov edx, 12                   ; Buffer size
    int 0x80

    ; Check if input is negative
    movzx eax, byte [esi]         ; Load the first character
    cmp al, '-'                   ; Compare with '-'
    jne .positive                 ; If not negative, jump to positive

    ; Handle negative input
    push esi
    call len                      ; Get the length of the string
    pop esi
    dec ecx                       ; Exclude the '\n'
    push ecx                      ; Push length of string including '-'

    inc esi                       ; Move to next character (skip '-')
    dec ecx                       ; Adjust length to ignore '-'

    push esi                      ; Push pointer to string (after '-')
    push ecx                      ; Push length of the string
    call string_to_int             ; Convert string to integer
    pop ecx
    pop esi

    neg eax                       ; Negate the result for negative numbers
    jmp .end                      ; Jump to the end

.positive:
    ; Handle positive input
    push esi
    call len                      ; Get the length of the string
    pop esi
    dec ecx                       ; Exclude the '\n'
    push ecx                      ; Push length of the string

    push esi                      ; Push pointer to string
    push ecx                      ; Push length of the string
    call string_to_int             ; Convert string to integer
    pop ecx
    pop esi

.end:
    mov [edi], eax 
    pop ecx 

    
    push eax 
    push ebx 
    push ecx 
    push edx 
    push edi 
    push esi 
    push ecx 
    call show_output_msg 
    pop ecx 
    pop esi 
    pop edi 
    pop edx 
    pop ecx 
    pop ebx 
    pop eax 

    
    mov eax, ecx 
    leave
    ret


; -----------------------------------------------
; Convert a string to an integer
; Input: EBP+12 - Pointer to the string
;        EBP+8  - Length of the string
; Output: Integer in EAX
string_to_int:
    enter 0, 0
    mov esi, [ebp + 12]           ; Get pointer to the string
    mov ecx, [ebp + 8]            ; Get length of the string
    xor ebx, ebx                  ; Clear result accumulator (EBX)

.next_digit:
    movzx eax, byte [esi]         ; Load the next character
    inc esi
    sub al, '0'                   ; Convert ASCII to integer
    imul ebx, 10                  ; Multiply previous result by 10
    add ebx, eax                  ; Add the current digit
    loop .next_digit               ; Repeat for all characters

    mov eax, ebx                  ; Move result to EAX
    leave
    ret

; -----------------------------------------------
; Get the length of a string
; Input: EBP+8 - Pointer to the string
; Output: Length in ECX
len:
    enter 0, 0
    mov esi, [ebp + 8]            ; Get pointer to the string
    xor ecx, ecx                  ; Initialize length counter

count:
    inc ecx                       ; Increment length
    inc esi                       ; Move to next character
    cmp byte [esi], 0             ; Check if character is null
    jnz count                     ; Repeat until null terminator is found

    leave
    ret

; -----------------------------------------------
; Show output message and print integer result
; Input: EBP+8 - Pointer to the integer value to print
show_output_msg:
    enter 0, 0
    mov edi, [ebp + 8]            ; Get the integer to print
    mov esi, buffer               ; Buffer to store the converted string

    ; Print the output message
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, output_msg           ; Message to print
    mov edx, len_output_msg       ; Length of the message
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
    ; Clear the buffer
    mov edi, input_buffer
    mov ecx, 12
    mov al, 0
    rep stosb                   ; Fill buffer with 0's

    mov edi, [ebp + 8]          ; Get the pointer to the integer value
    mov esi, input_buffer ; Buffer to store the string representation
    mov eax, [edi]              ; Load integer into EAX for checking

    ; Check if the number is negative
    cmp eax, 0
    jge .positive_o             ; If non-negative, jump to positive case

    ; Handle negative numbers
    neg eax                     ; Negate the number

    ; Output the negative sign
    push eax                    ; Preserve the negated value
    push ebx
    push ecx
    push edx
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; stdout
    mov ecx, minus_str          ; Write the minus sign '-'
    mov edx, 1                  ; Length = 1
    int 0x80
    pop edx                     ; Restore registers
    pop ecx
    pop ebx
    pop eax                     ; Restore the negated value

.positive_o:
    ; Convert the integer to a string
    push eax                    ; Preserve integer value
    push esi                    ; Push buffer pointer
    call int_to_string           ; Convert integer to string
    pop esi                     ; Restore buffer pointer
    pop ebx                     ; Discard preserved value

    ; Output the converted string
    push eax                    ; Pointer to string
    push ecx                    ; Length of the string
    mov eax, 4                  ; sys_write
    mov ebx, 1                  ; stdout
    pop edx                     ; Restore length of the string
    pop ecx                     ; Restore pointer to string
    int 0x80

    mov ecx, edx                ; Store string length in ECX
    
    push eax
    push ebx
    push ecx
    push edx

    ; Print a new line
    mov eax, 4                    ; sys_write
    mov ebx, 1                    ; stdout
    mov ecx, newline             ; Newline character
    mov edx, 1                    ; Length of newline
    int 0x80

    pop edx
    pop ecx                     ; Restore registers
    pop ebx
    pop eax

    ; Call show_output_msg to display output
    push eax                    ; Preserve registers
    push ebx
    push ecx
    push edx
    push edi
    push esi
    push ecx                    ; Push length of string
    call show_output_msg         ; Call show_output_msg
    pop ecx                     ; Restore registers
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; Return the length of the string in EAX
    mov eax, ecx
    leave
    ret

	