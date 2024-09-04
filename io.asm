section .text

input_number:
    push ebp
    mov ebp, esp

    ; Ler a entrada como string
    mov eax, 3                  ; syscall número para leitura (sys_read)
    mov ebx, 0                  ; file descriptor (0 = stdin)
    lea ecx, [input_buffer]     ; buffer para armazenar a entrada do usuário
    mov edx, 12                 ; número máximo de bytes para ler (11 dígitos + newline)
    int 0x80                    ; chamada ao sistema

    ; Converter a string lida para um número inteiro
    lea esi, [input_buffer]     ; apontar para o início do buffer de entrada
    xor eax, eax                ; limpar eax para acumular o número
    xor ebx, ebx                ; limpar ebx (multiplicador)
    mov ecx, 0                  ; flag para sinal negativo

    ; Verificar se o primeiro caractere é um sinal negativo
    mov al, [esi]
    cmp al, '-'                 
    jne check_first_digit        ; se não for '-', pular
    inc esi                     ; avançar para o próximo caractere
    mov ecx, 1                  ; marcar que o número é negativo

check_first_digit:
    xor eax, eax                ; limpar eax para acumular o número
convert_input_to_int:
    mov bl, [esi]               ; carregar o próximo caractere
    cmp bl, 10                  ; verificar se é o caractere newline ('\n')
    je input_done               ; se for newline, terminar
    sub bl, '0'                 ; converter o caractere para o valor numérico
    imul eax, eax, 10           ; multiplicar o número atual por 10
    add eax, ebx                ; adicionar o valor do dígito ao acumulador
    inc esi                     ; mover para o próximo caractere
    jmp convert_input_to_int

input_done:
    cmp ecx, 1                  ; verificar se o número é negativo
    je make_negative            ; se for, aplicar o sinal
    jmp end_input

make_negative:
    neg eax                     ; negar o valor em eax (tornar negativo)

end_input:
    leave
    ret

output_number:
    push ebp
    mov ebp, esp

    ; Converter o número em eax para string
    push eax
    mov ecx, buffer + 10         ; local buffer, começando pelo final menos um (reserva espaço para '\0')
    mov byte [ecx], 0            ; coloca o terminador nulo na última posição
    call int_to_string           ; converter o número em eax para string

    ; Imprimir o número
    mov eax, 4                   ; syscall número para escrita (sys_write)
    mov ebx, 1                   ; file descriptor (1 = stdout)
    lea ecx, [buffer]            ; apontar para o buffer de string
    mov edx, 11                  ; comprimento máximo de 11 bytes (ajustado pelo número de dígitos)
    int 0x80                     ; chamada ao sistema

    pop eax
    leave
    ret

int_to_string:
    ; Entrada: eax contém o número
    ; Saída: ecx aponta para o início da string resultante (cresce de trás para frente)
    ; Usamos a base 10 para conversão

    xor edx, edx                 ; Limpa o registrador edx
    mov ebx, 10                  ; Divisor (base 10)

    ; Verificar se o número é negativo
    test eax, eax
    jns convert_loop             ; Se positivo ou zero, ir para a conversão
    neg eax                      ; Caso contrário, tornar positivo
    dec ecx                      ; Reservar espaço para o sinal negativo
    mov byte [ecx], '-'          ; Adicionar o sinal negativo na string

convert_loop:
    xor edx, edx                 ; Limpa edx
    div ebx                      ; Divide eax por 10, o quociente fica em eax, o resto em edx
    add dl, '0'                  ; Converte o dígito para ASCII
    dec ecx                      ; Decrementa o ponteiro da string
    mov [ecx], dl                ; Armazena o dígito convertido
    test eax, eax                ; Verifica se terminamos a divisão
    jnz convert_loop             ; Se eax não for zero, continue convertendo

    inc ecx                      ; Ajustar o ponteiro de volta para o primeiro dígito
    ret