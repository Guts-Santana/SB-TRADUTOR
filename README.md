Na forma q to organizando, primeiro o arquivo vai ser lido, dps vai ficar armazenado no vector object.
Ai ja chama a função de escrever o arquivo asm, que vai chamar a função que decodifica qual opcode ta sendo lido.
E ai a depender do opcode a função que escreve vai ser chamada.
Em casos de jmp, vou colocar todos em uma instrução só, o add e sub serão juntos tbm e vou ver quais mais são semelhantes
