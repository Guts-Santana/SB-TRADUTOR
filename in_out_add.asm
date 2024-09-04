section .text

; input_number: lê um número de stdin, com suporte para números negativos
; Argumentos: na pilha, local de armazenamento do número
; Retorno: EAX contém o número de bytes lidos

input_number:
    push ebp
    mov ebp, esp

    sub esp, 4                   ; reservar espaço para variável local
    push eax                     ; preservar registrador eax
    push ebx                     ; preservar registrador ebx
    push ecx                     ; preservar registrador ecx
    push edx                     ; preservar registrador edx

    ; Ler a entrada como string
    mov eax, 3                   ; syscall número para leitura (sys_read)
    mov ebx, 0                   ; file descriptor (0 = stdin)
    lea ecx, [input_buffer]      ; buffer para armazenar a entrada do usuário
    mov edx, 11                  ; número máximo de bytes para ler (10 dígitos + newline)
    int 0x80                     ; chamada ao sistema

    ; Armazena o número de bytes lidos em edx
    mov edx, eax                 ; edx vai guardar o número de bytes lidos

    ; Exibir a mensagem "Foram lidos XXX bytes"
    call print_read_message

    ; Converter a string lida para um número inteiro
    lea esi, [input_buffer]      ; apontar para o início do buffer de entrada
    xor eax, eax                 ; limpar eax para acumular o número
    xor ebx, ebx                 ; limpar ebx (sinalizador de número negativo)

    mov dl, [esi]                ; pegar o primeiro caractere
    cmp dl, '-'                  ; verificar se é um número negativo
    jne check_digit              ; se não for "-", verificar se é dígito
    inc esi                      ; mover para o próximo caractere
    mov ebx, 1                   ; definir sinalizador para número negativo

check_digit:
    xor edx, edx
convert_input_to_int:
    mov dl, [esi]                ; carregar o próximo caractere
    cmp dl, 10                   ; verificar se é o caractere newline ('\n')
    je input_done                ; se for newline, terminar
    sub dl, '0'                  ; converter o caractere para o valor numérico
    imul eax, eax, 10            ; multiplicar o número atual por 10
    add eax, edx                 ; adicionar o valor do dígito ao acumulador
    inc esi                      ; mover para o próximo caractere
    jmp convert_input_to_int

input_done:
    cmp ebx, 1                   ; verificar se é um número negativo
    jne finish_input
    neg eax                      ; se for negativo, inverter o valor

finish_input:
    ; Restaura os registradores
    pop edx
    pop ecx
    pop ebx
    pop eax

    leave
    ret

print_read_message:
    ; Exibir mensagem "Foram lidos XXX bytes"
    mov eax, 4                   ; syscall para escrita (sys_write)
    mov ebx, 1                   ; stdout
    lea ecx, [msg_input]         ; mensagem de leitura
    mov edx, 12                  ; tamanho da mensagem
    int 0x80

    ; Escrever o número de bytes lidos
    push edx                     ; guardar número de bytes lidos em edx
    call print_number             ; imprime o número de bytes lidos
    pop edx

    ; Exibir newline
    mov eax, 4
    mov ebx, 1
    lea ecx, [newline]
    mov edx, 1
    int 0x80

    ret

; Função de imprimir um número (em eax)
print_number:
    push eax
    mov ecx, buffer + 10          ; buffer de saída
    mov byte [ecx], 0             ; null terminator
    call int_to_string            ; converter o número em string
    mov eax, 4                    ; syscall para escrita
    mov ebx, 1                    ; stdout
    lea ecx, [buffer]             ; buffer convertido
    mov edx, 11                   ; até 11 bytes
    int 0x80
    pop eax
    ret

; Função para converter número em string (eax contém o número)
int_to_string:
    xor edx, edx                  ; limpar edx
    mov ebx, 10                   ; divisor (base 10)

convert_loop:
    xor edx, edx                  ; limpar edx
    div ebx                       ; dividir eax por 10
    add dl, '0'                   ; converter o dígito para ASCII
    dec ecx                       ; decrementar o ponteiro
    mov [ecx], dl                 ; armazenar o dígito
    test eax, eax                 ; verificar se terminamos a divisão
    jnz convert_loop              ; repetir até o número ser zero

    inc ecx                       ; ajustar o ponteiro de volta para o primeiro dígito
    ret

; output_number: escreve um número de stdout
; Argumentos: o número está no registrador EAX
; Retorno: EAX contém o número de bytes escritos

output_number:
    push ebp
    mov ebp, esp
    sub esp, 4                    ; reservar espaço para variável local

    ; Converter o número em eax para string
    push eax
    mov ecx, buffer + 10          ; buffer, começando pelo final menos um
    mov byte [ecx], 0             ; null terminator
    call int_to_string            ; converter o número em eax para string

    ; Imprimir o número
    mov eax, 4                    ; syscall número para escrita (sys_write)
    mov ebx, 1                    ; file descriptor (1 = stdout)
    lea ecx, [buffer]             ; buffer contendo string
    mov edx, 11                   ; no máximo 11 bytes
    int 0x80                      ; chamada ao sistema

    ; Retornar o número de bytes escritos
    mov eax, edx

    ; Exibir mensagem "Foram escritos XXX bytes"
    call print_write_message

    leave
    ret

print_write_message:
    ; Exibir mensagem "Foram escritos XXX bytes"
    mov eax, 4                   ; syscall para escrita (sys_write)
    mov ebx, 1                   ; stdout
    lea ecx, [msg_output]        ; mensagem de escrita
    mov edx, 16                  ; tamanho da mensagem
    int 0x80

    ; Escrever o número de bytes escritos
    push eax                     ; guardar valor de eax
    call print_number             ; imprime o número de bytes
    pop eax

    ; Exibir newline
    mov eax, 4
    mov ebx, 1
    lea ecx, [newline]
    mov edx, 1
    int 0x80

    ret

global _start
_start:
    push eax
    call input_number            ; Lê um número de entrada
    mov [a11], eax               ; Armazena o número lido em a11
    pop eax

    mov eax, [a11]               ; Carrega o valor de a11
    add eax, [a12]               ; Adiciona o valor de a12
    mov [a11], eax               ; Armazena o resultado de volta em a11

    push eax
    mov eax, [a11]
    call output_number           ; Exibe o valor atualizado de a11
    pop eax

    mov eax, 1
    mov ebx, 0
    int 0x80

section .data
    msg_input db "Foram lidos ", 0
    msg_output db "Foram escritos ", 0
    newline db 10, 0            ; newline character
    a12 dd 2
    a11 dd 0

section .bss
    buffer resb 12               ; buffer para conversão de número
    input_buffer resb 12         ; buffer de entrada de até 11 caracteres
