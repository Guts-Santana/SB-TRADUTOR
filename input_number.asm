section .text
global input_number

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

