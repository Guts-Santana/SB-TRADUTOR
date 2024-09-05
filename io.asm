
string_to_int:
    enter 0,0 ; create stack frame
    mov esi, [ebp+12] ; get pointer to string
    mov ecx, [ebp+8] ; get length of string
    xor ebx,ebx    ; clear ebx
.next_digit:
    movzx eax,byte[esi]
    inc esi
    sub al,'0'    ; convert from ASCII to number
    imul ebx,10
    add ebx,eax   ; ebx = ebx*10 + eax
    loop .next_digit  ; while (--ecx)
    mov eax,ebx
    leave ; remove stack frame
    ret

modulo:
    enter 0, 0
    mov eax, [ebp+8]
    test eax, 0xc0000000
    je .positive
    add eax, 2147483648 ; 2^31 -> because the max value of a signed 32-bit integer is 2147483647
.positive:
    leave
    ret

output:
    enter 0,0
    mov edi, buffer_number_read ; pega o endereco do buffer para preencher com 0
    mov ecx, 10 ; length of buffer
    mov al, 0 ; char to fill buffer with
    rep stosb ; fill buffer with char

    mov edi, [ebp+8] ; pega o endereco da variavel qualquer
    mov esi, buffer_number_read ; pointer to buffer to store the string in to print
    ; verificar se o valor é negativo
    mov eax, [edi] ; eax = *edi
    cmp eax, 0 ; to check if eax is negative
    jge .positive_o ; if not negative, jump to .positive_o
    ; se for negativo, converter para inteiro e multiplicar por -1
    neg eax ; eax = -eax
    ;  negative sign show '-' in the stdout
    push eax ; store eax
    push ebx ; store ebx
    push ecx ; store ecx
    push edx ; store edx
    mov eax, 4; sys_write
    mov ebx, 1; stdout
    mov ecx, minus_str ; pointer to string
    mov edx, 1 ; length of string
    int 0x80; call kernel
    pop edx ; restore
    pop ecx ; restore
    pop ebx ; restore
    pop eax ; restore
.positive_o:
    ; converter a string para inteiro
    push eax ; push eax as argument
    push esi ; push pointer to buffer as argument
    call int_to_string ; call int_to_string -> eax = pointer to string, ecx = length of string
    pop esi ; restore pointer to string
    pop ebx ; discard eax

    ; mostrar a string
    push eax ; store eax -> pointer to string
    push ecx ; store ecx -> length of string
    mov eax, 4; sys_write
    mov ebx, 1; stdout
    pop edx ; restore length of string
    pop ecx ; restore pointer to string
    int 0x80; call kernel

    mov ecx, edx ; ecx = length of string

    ; mostrar a quantidade de bytes lidos/escritos
    push eax ; store eax
    push ebx ; store ebx
    push ecx ; store ecx
    push edx ; store edx
    push edi ; store edi
    push esi ; store esi
    push ecx ; push length of buffer
    call show_output_msg ; call show_output_msg
    pop ecx ; restore
    pop esi ; restore
    pop edi ; restore
    pop edx ; restore
    pop ecx ; restore
    pop ebx ; restore
    pop eax ; restore

    ; retornar a quantidade de bytes lidos/escritos em eax
    mov eax, ecx ; return length of string
    leave
    ret

;  Input:
;  ESI = pointer to the buffer to store the char in (must have room for at least 1 byte)
;  Output:
;  EAX = quantidade de bytes lidos/escritos (1)
input:
    enter 0,0
    mov edi, buffer_number_read ; pega o endereco do buffer para preencher com 0
    mov ecx, 10 ; length of buffer
    mov al, 0 ; char to fill buffer with
    rep stosb ; fill buffer with char

    mov edi, [ebp+8] ; pega o endereco da variavel qualquer
    mov esi, buffer_number_read ; pega o endereco do buffer
    ; ler um valor decimal do stdin
    mov eax, 3; sys_read
    mov ebx, 0; stdin
    mov ecx, esi ; pointer to buffer
    mov edx, 10 ; length of buffer
    int 0x80; call kernel

    ; verificar se o valor é negativo
    movzx eax, byte [esi] ; eax = *esi
    cmp al, '-' ; check if char is '-'
    jne .positive ; if not '-', jump to .positive
    ; pegar o tamanho da string
    push esi ; push pointer to string as argument
    call len ; call len -> ecx = length of string
    pop esi ; restore pointer to string
    
    dec ecx ; decrement ecx to ignore '\n'
    push ecx ; push length of string including '-' but not '\n'

    ; se for negativo, desconsidera o sinal, converte para inteiro e multiplica por -1
    inc esi ; increment esi to point to next char
    dec ecx ; decrement ecx to ignore '-' (now it ignores '\n' and '-')

    ; converter a string para inteiro
    push esi ; push pointer to string as argument
    push ecx ; push length of string as argument
    call string_to_int ; call string_to_int -> eax = integer value
    pop ecx ; discard length of string
    pop esi ; restore pointer to string

    ; multiplicar por -1
    neg eax ; eax = -eax

    jmp .end ; jump to .end

.positive:
    ; pegar o tamanho da string
    push esi ; push pointer to string as argument
    call len ; call len -> ecx = length of string
    pop esi ; restore pointer to string

    dec ecx ; decrement ecx to ignore '\n'
    push ecx ; push length of string    

    ; converter a string para inteiro
    push esi ; push pointer to string as argument
    push ecx ; push length of string as argument
    call string_to_int ; call string_to_int -> eax = integer value
    pop ecx ; discard length of string
    pop esi ; restore pointer to string

.end:
    ; armazenar o valor convertido em store_decimal
    mov [edi], eax ; store eax in store_decimal
    pop ecx ; discard length of string

    ; mostrar a quantidade de bytes lidos/escritos
    push eax ; store eax
    push ebx ; store ebx
    push ecx ; store ecx
    push edx ; store edx
    push edi ; store edi
    push esi ; store esi
    push ecx ; push length of buffer
    call show_output_msg ; call show_output_msg 
    pop ecx ; restore
    pop esi ; restore
    pop edi ; restore
    pop edx ; restore
    pop ecx ; restore
    pop ebx ; restore
    pop eax ; restore

    ; retornar a quantidade de bytes lidos/escritos em eax
    mov eax, ecx ; return length of string
    leave
    ret


output_c:
    enter 0,0
    mov esi, [ebp+8] ; pega o endereco do buffer
    ; escrever o char no stdout
    mov eax, 4; sys_write
    mov ebx, 1; stdout
    mov ecx, esi ; pointer to buffer
    mov edx, 1 ; length of buffer
    int 0x80; call kernel
    ; calcular o tamanho da string
    push ecx ; push pointer to string
    push esi ; store esi
    call len ; call len -> ecx = length of string
    pop esi ; discard pointer to string
    pop esi ; restore esi

    ; mostrar a quantidade de bytes lidos/escritos
    push eax ; store eax
    push ebx ; store ebx
    push ecx ; store ecx
    push edx ; store edx
    push edi ; store edi
    push esi ; store esi
    push ecx ; push length of buffer
    call show_output_msg ; call show_output_msg
    pop ecx ; restore
    pop esi ; restore
    pop edi ; restore
    pop edx ; restore
    pop ecx ; restore
    pop ebx ; restore
    pop eax ; restore

    ; retornar a quantidade de bytes lidos/escritos em eax
    mov eax, ecx ; return length of string
    leave
    ret

;  Input:
;  ESI = pointer to the buffer to store the char in (must have room for at least 1 byte)
;  Output:
;  EAX = quantidade de bytes lidos/escritos (1)
input_c:
    enter 0,0
    mov esi, [ebp+8] ; pega o endereco do buffer
    ; ler um byte do stdin
    mov eax, 3; sys_read
    mov ebx, 0; stdin
    mov ecx, esi ; pointer to buffer
    mov edx, 1 ; length of buffer
    int 0x80; call kernel
    ; calcular o tamanho da string
    push ecx ; push pointer to string
    push esi ; store esi
    call len ; call len -> ecx = length of string
    pop esi ; discard pointer to string
    pop esi ; restore esi

    ; mostrar a quantidade de bytes lidos/escritos
    push eax ; store eax
    push ebx ; store ebx
    push ecx ; store ecx
    push edx ; store edx
    push edi ; store edi
    push esi ; store esi
    push ecx ; push length of buffer
    call show_output_msg ; call show_output_msg 
    pop ecx ; restore
    pop esi ; restore
    pop edi ; restore
    pop edx ; restore
    pop ecx ; restore
    pop ebx ; restore
    pop eax ; restore

    ; retornar a quantidade de bytes lidos/escritos em eax
    mov eax, ecx ; return length of string
    leave
    ret


; Input:
; ESI = pointer to the string to get the length of
; Output:
; ECX = length of the string
len:
    enter 0,0 ; create stack frame
    mov esi, [ebp+8] ; get pointer to string
    mov ecx,0 ; initialize counter
count:
    inc ecx ; increment counter
    inc esi ; increment esi to point to next char
    cmp byte [esi],0 ; check if char is null
    jnz count ; if not null, jump to count

    ;dec ecx ; decrement counter to get lengthint_to_strin
    leave ; remove stack frame
    ret ; return to caller

; Input:
; first value in stack +12 = integer value to convert
; second value in stack +8 = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; eax = pointer to the first character of the generated string
; ecx = length of the generated string 
int_to_string:
    enter 0,0 ; create stack frame
    mov eax, [ebp+12] ; push eax
    mov esi, [ebp+8] ; push esi
    add esi,9        ; Point to the end of the buffer
    mov byte [esi],0    ; String terminator

    mov ecx,0 ; initialize counter
    mov ebx,10 ; set base to 10
.next_digit:
    inc ecx ; increment counter
    xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
    div ebx             ; eax /= 10
    add dl,'0'          ; Convert the remainder to ASCII 
    dec esi             ; store characters in reverse order
    mov [esi],dl
    test eax,eax            
    jnz .next_digit     ; Repeat until eax==0

    ; return a pointer to the first digit (not necessarily the start of the provided buffer)
    mov eax,esi
    leave ; remove stack frame
    ret

show_output_msg:
    enter 0,0 ; create stack frame
    mov edi, [ebp+8] ; get pointer to integer value to print
    mov esi, buffer_number ; pointer to buffer to store the string in
    ; show output message
    mov eax, 4; sys_write
    mov ebx, 1; stdout
    mov ecx, output_msg ; pointer to string
    mov edx, len_output_msg ; length of string
    int 0x80; call kernel
    ; converter o inteiro para string
    push edi ; push integer value
    push esi ; push pointer to buffer
    call int_to_string ; call int_to_string -> eax = pointer to string, ecx = length of string
    pop esi ; restore pointer to buffer
    pop edi ; restore integer value
    ; escrever a string no stdout
    push eax ; push pointer to string
    push ecx ; push length of string
    mov eax, 4; sys_write
    mov ebx, 1; stdout
    pop edx ; pop length of string
    pop ecx ; pop pointer to string
    int 0x80; call kernel
    ; show new line
    mov eax, 4; sys_write
    mov ebx, 1; stdout
    mov ecx, new_line ; pointer to string
    mov edx, 1 ; length of string
    int 0x80; call kernel
    leave ; remove stack frame
    ret ; return to caller