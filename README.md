# SB-TRADUTOR

Tradutor para a linguagem de programação SB.

## Uso

### Opção 1 - Usando o Makefile

Para utilizar o tradutor, basta executar o comando abaixo:

```bash
make FILE=<arquivo>
```

Onde `<arquivo>` é o arquivo que contém o código fonte **sem extensão**.

**OBS:** O arquivo **deve estar** dentro do diretório `arquivos`.

## Exemplo

Para traduzir o arquivo `in_out_var.obj` dentro do diretório `arquivos`, basta executar o comando abaixo:

```bash
make FILE=in_out_var
```

O comando irá gerar um arquivo `in_out_var.asm` no diretório `output`, irá montar e executar o código gerado.

### Opção 2 - Compilando e executando manualmente

Para compilar o tradutor, basta executar o comando abaixo:

```bash
g++ -o tradutor tradutor.cpp
```

Para executar o tradutor, basta executar o comando abaixo:

```bash
./tradutor <arquivo>.obj
```

Onde `<arquivo>` é o arquivo `.obj` que contém o código fonte.

Para montar, ligar e executar o código gerado, basta executar o comando abaixo:

```bash
nasm -f <arquivo>.asm -o <arquivo>.o
ld -m elf_i386 -s -o <arquivo> <arquivo>.o
ld -m elf_i386 -o <arquivo> <arquivo>.o
./<arquivo>
```
