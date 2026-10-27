# Conferência do banco local em 21/10/2026

Leitura realizada em `2026-10-21T17:17:42.862Z`, em transação somente de leitura. Nenhuma migration, DDL ou escrita em dados foi executada.

## Fontes e resultado

- Código comparado: [`conloq/Back-End`](https://github.com/conloq/Back-End/tree/main) (revisão da `main` em 21/10/2026).
- Servidor observado: MariaDB 10.4.32, banco `mash`, `lower_case_table_names=0`.
- Tabelas: `users`, `recipes`, `temperatures` e a tabela administrativa `SequelizeMeta`.
- Comparação: 25 colunas de negócio, tipos, ordem, nulabilidade, defaults, PKs, auto incremento, índices UNIQUE/FK, duas FKs com DELETE/UPDATE CASCADE e três migrations registradas; zero divergências nos itens conferidos.
- Os timestamps físicos têm default `CURRENT_TIMESTAMP`; `updated_at` não tem `ON UPDATE` automático no DDL observado.
- Collation das tabelas de negócio: `utf8mb4_general_ci`. A tabela administrativa usa `utf8_unicode_ci`.

Os metadados estão em [schema-local-2026-10-21.json](schema-local-2026-10-21.json); o resultado da comparação está em [comparacao-2026-10-21.json](comparacao-2026-10-21.json). Não há registros de negócio, host, usuário, senha, token ou próximo valor de auto incremento nesses arquivos.

## Reprodução somente de leitura

Conecte ao banco de trabalho com o cliente SQL e execute [consultas-schema.sql](consultas-schema.sql). O arquivo consulta apenas metadados e nomes de migrations; não aplica o [schema de referência](../schema-api.sql).

Compare as colunas com as três migrations em [`migrations/`](https://github.com/conloq/Back-End/tree/main/migrations), os atributos mapeados em [`models/`](https://github.com/conloq/Back-End/tree/main/models) e as relações em [`config/associations.js`](https://github.com/conloq/Back-End/blob/main/config/associations.js).

## Limites

Esta evidência comprova a estrutura do banco local consultado nessa data. Não comprova o ambiente publicado (TiDB Cloud), conteúdo ou integridade de todos os registros, execução de cascatas por exclusão, nem o funcionamento HTTP ou do Cloudinary. `SequelizeMeta` comprova o registro dos nomes; a comparação independente dos metadados confere a estrutura correspondente. A validação histórica em MySQL 8.4.9 é outro ambiente, descrito no Back-End, e não muda a versão observada aqui.
