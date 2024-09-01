section .text
global input_number, output_number

; Função input_number
input_number:
    ; Salva os registradores que serão usados
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx

    ; Reserva espaço na pilha para o buffer de leitura
    sub esp, 12               ; Buffer de 12 bytes (máx. 10 dígitos + sinal + null)
    
    ; Leitura da string
    mov eax, 3                ; syscall número para sys_read
    mov ebx, 0                ; 0 indica a entrada padrão (teclado)
    lea ecx, [esp]            ; Endereço do buffer
    mov edx, 12               ; Tamanho máximo da leitura
    int 0x80                  ; Chamada de sistema

    ; Converte a string lida para um número
    lea esi, [esp]            ; Ponteiro para o buffer
    xor edi, edi              ; Zera edi (será usado como o número lido)
    mov ecx, 0                ; Zera ecx (será usado para o sinal)

    ; Verifica o sinal
    cmp byte [esi], '-'       
    jne .read_number          ; Se não for '-', vai para a leitura do número
    mov ecx, 1                ; Indica que o número é negativo
    inc esi                   ; Avança o ponteiro para o próximo caractere

.read_number:
    xor eax, eax              ; Zera eax para começar a construir o número
.loop:
    mov bl, [esi]             ; Lê um byte do buffer
    cmp bl, 0                 ; Verifica se é o fim da string (null terminator)
    je .done                  ; Se for, termina a leitura
    sub bl, '0'               ; Converte caractere para número
    imul eax, eax, 10         ; Multiplica o número atual por 10
    add eax, ebx              ; Adiciona o dígito ao número
    inc esi                   ; Avança para o próximo caractere
    jmp .loop                 ; Continua no loop

.done:
    cmp ecx, 0                ; Verifica se o número é negativo
    je .final
    neg eax                   ; Se for negativo, inverte o sinal

.final:
    mov [ebp+8], eax          ; Armazena o número no endereço passado como argumento

    ; Limpa a pilha e restaura os registradores
    add esp, 12
    pop ebx
    pop esi
    pop edi
    pop ebp

    ; Retorna o número de bytes lidos no eax
    ret



; Função output_number
output_number:
    ; Salva os registradores
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx
    
    ; Converte o número para string
    mov eax, [ebp+8]          ; Número a ser impresso
    lea esi, [esp-12]         ; Buffer de saída (12 bytes na pilha)
    add esi, 12
    mov byte [esi], 0         ; Null terminator

    ; Verifica se o número é negativo
    cmp eax, 0
    jge .convert              ; Se for positivo, pula
    neg eax                   ; Se for negativo, inverte o sinal
    mov byte [esi-1], '-'     ; Adiciona o sinal de negativo
    dec esi

.convert:
    xor ecx, ecx              ; Zera ecx (contagem de dígitos)
    mov ebx, 10               ; Divisor para obter cada dígito

.print_loop:
    xor edx, edx              ; Zera edx para a divisão
    div ebx                   ; Divide eax por 10
    add dl, '0'               ; Converte o dígito para caractere
    dec esi                   ; Decrementa o ponteiro do buffer
    mov [esi], dl             ; Armazena o caractere no buffer
    inc ecx                   ; Incrementa a contagem de dígitos
    test eax, eax             ; Verifica se o número acabou
    jnz .print_loop           ; Se não acabou, continua

    ; Se tinha sinal de negativo, decrementa o ponteiro
    cmp byte [esi-1], '-'
    jne .write_number
    dec esi
    inc ecx                   ; Incrementa a contagem para incluir o '-'

.write_number:
    ; Escreve a string na saída padrão
    mov eax, 4                ; syscall número para sys_write
    mov ebx, 1                ; 1 indica a saída padrão (tela)
    mov edx, ecx              ; Tamanho da string
    int 0x80                  ; Chamada de sistema

    ; Imprime a quantidade de bytes escritos
    push ecx                  ; Salva o número de bytes escritos

    ; Converte o número de bytes para string
    mov eax, ecx
    lea esi, [esp-12]         ; Buffer para a conversão
    add esi, 12
    mov byte [esi], 0         ; Null terminator

.bytes_convert:
    xor edx, edx              ; Zera edx para a divisão
    div ebx                   ; Divide eax por 10
    add dl, '0'               ; Converte o dígito para caractere
    dec esi                   ; Decrementa o ponteiro do buffer
    mov [esi], dl             ; Armazena o caractere no buffer
    test eax, eax             ; Verifica se o número acabou
    jnz .bytes_convert        ; Continua se não acabou

    ; Escreve a mensagem na saída padrão
    mov eax, 4                ; syscall número para sys_write
    mov ebx, 1                ; 1 indica a saída padrão (tela)
    mov edx, 16               ; Tamanho da mensagem (ajustar conforme necessário)
    lea ecx, [esp-32]         ; Mensagem "Foram lidos/escritos XXX bytes\n"
    int 0x80                  ; Chamada de sistema

    ; Escreve o número de bytes na saída padrão
    mov eax, 4                ; syscall número para sys_write
    mov ebx, 1                ; 1 indica a saída padrão (tela)
    lea ecx, [esi]            ; Endereço do número convertido
    mov edx, 12               ; Tamanho do número convertido (ajustar conforme necessário)
    int 0x80                  ; Chamada de sistema

    ; Escreve o final da mensagem (por exemplo, "\n")
    mov eax, 4                ; syscall número para sys_write
    mov ebx, 1                ; 1 indica a saída padrão (tela)
    mov ecx, end_message      ; Endereço da mensagem final
    mov edx, 1                ; Tamanho da mensagem final
    int 0x80                  ; Chamada de sistema

    ; Restaura os registradores
    pop ebx                   ; Restaura o número de bytes escritos
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret

section .data
end_message db 10 ; Caracter de nova linha (0x0A)
