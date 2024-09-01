section .data
    end_message db 10  ; Newline character

section .text
    global input_number, output_number

; Função input_number
input_number:
    ; Salva os registradores que serão usados
    push ebp
    mov ebp, esp
    sub esp, 12               ; Buffer de 12 bytes

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
    ret

; Função output_number
output_number:
    ; Salva os registradores
    push ebp
    mov ebp, esp
    
    ; Converte o número para string
    mov eax, [ebp+8]          ; Número a ser impresso
    sub esp, 12               ; Aloca buffer de saída (12 bytes na pilha)
    lea esi, [esp+12]         ; Buffer de saída
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
    lea ecx, [esi]            ; Endereço do buffer
    int 0x80                  ; Chamada de sistema

    ; Libera espaço da pilha e restaura registradores
    add esp, 12
    pop ebp
    ret
