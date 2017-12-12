======
PT_BR:
======


Descrição Geral
----------------

Este projeto tem como objetivo otimizar estruturas dos arquivos de taxonomia do NCBI para recuperação de informações taxonômicas.
As otimizações serão realizadas principalmente a partir de um hash que deverá ligar um identificador da taxonomia do NCBI para sua taxonomia completa (no formato Reino->Filo->Classe->Ordem->Família->Gênero->Espécie).


Tabela Subespécie <> Espécie
--------------------------

O objetivo principal é mapear os identificadores para os identificadores de espécie.

Estrutura:
ID_SUBESPÉCIE | ID_ESPÉCIE
...

Um exemplo desse caso é o mapeamento do identificador 8667779 (Bifidobacterium breve ACS-071-V-Sch8b) para 1685 (Bifidobacterium breve). Logo essa tabela deverá incluir um registro:
8667779 | 1685
1385938 | 1685
...
