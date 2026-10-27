# Banco de Dados: Mash

A fonte do schema da API são as [migrations do Back-End na revisão atual](https://github.com/conloq/Back-End/tree/main/migrations). Em 21/10/2026, uma consulta somente de leitura confirmou que o banco local `mash` corresponde às migrations da revisão então examinada nos itens descritos abaixo. [Evidências e reprodução](evidencias/README.md).

## Banco atual e ambiente conferido

| Item | Observado |
|---|---|
| Servidor local | MariaDB 10.4.32, acessado pelo dialeto MySQL do Sequelize |
| Banco | `mash` |
| Tabelas de negócio | `users`, `recipes`, `temperatures` |
| Tabela de infraestrutura | `sessions`, armazenamento de sessão da aplicação |
| Controle de migrations | `SequelizeMeta`, com quatro migrations registradas |
| Engine | InnoDB |
| Collation das tabelas de negócio | `utf8mb4_general_ci` |
| Collation de `SequelizeMeta` | `utf8_unicode_ci` |
| Sensibilidade a caixa | `lower_case_table_names=0` |
| Fonte das migrations | [`conloq/Back-End/migrations`](https://github.com/conloq/Back-End/tree/main/migrations) (conferência de 21/10/2026) |

MariaDB é a versão observada no ambiente local. A configuração da aplicação usa o dialeto `mysql`; a implantação planejada com MySQL externo deve ser conferida separadamente. Esta evidência não comprova o banco publicado.

### Atualização da fonte em 25/10/2026

Na `main` atual do Back-End, em relação à conferência de 21/10, entrou a quarta migration (`sessions`, criada em 24/10 para o armazenamento de sessão da aplicação). As quatro migrations criam `users`, `recipes`, `temperatures` e `sessions`; `lots` ainda não está nas migrations da `main` e permanece dependente da [#31 do conloq/mash](https://github.com/conloq/mash/issues/31). O MER implementado e o modelo planejado estão em diagramas separados.

O despejo `schema-api.sql` e os arquivos de `evidencias/` são observações de 21/10 e precedem a migration de `sessions`; por isso continuam descrevendo o banco com três tabelas de negócio. As colunas de `sessions` aqui vêm da definição da migration, não de uma consulta ao banco.

## Entidades implementadas nas migrations atuais

O arquivo [`diagrama_mer_mash.mmd`](diagrama_mer_mash.mmd) contém as três tabelas de negócio da API e a tabela de infraestrutura `sessions`. `SequelizeMeta` foi omitida por ser tabela administrativa do Sequelize, não parte do MER de negócio.

```mermaid
erDiagram
    users ||--o{ recipes : possui
    recipes ||--o{ temperatures : possui

    users {
        INT id PK
        VARCHAR name
        VARCHAR email UK
        VARCHAR phone "nullable"
        VARCHAR password
        VARCHAR url_image "nullable"
        DATETIME created_at
        DATETIME updated_at
    }
    recipes {
        INT id PK
        VARCHAR name
        INT user_id FK
        DATETIME created_at
        DATETIME updated_at
    }
    temperatures {
        INT id PK
        INT max_temperature_ramp
        INT min_temperature_ramp
        INT max_temperature_limit
        INT min_temperature_limit
        TIME timer
        TIME initialization
        TIME ideal_time
        INT order_ramp "nullable"
        INT recipe_id FK
        DATETIME created_at
        DATETIME updated_at
    }
    sessions {
        VARCHAR session_id PK
        INT expires
        TEXT data "nullable"
    }
```

Cada receita pertence a um usuário e cada rampa pertence a uma receita. As duas chaves estrangeiras são obrigatórias e usam `ON DELETE CASCADE` e `ON UPDATE CASCADE`. A tabela `sessions` não tem chave estrangeira: ela guarda o estado da sessão do navegador e é lida e apagada pelo armazenamento de sessão da aplicação.

## Entidades planejadas, ainda sem migrations na `main`

O arquivo [`diagrama_mer_planejado.mmd`](diagrama_mer_planejado.mmd) separa as entidades previstas e a adição `temperatures.active_temperature`. `lots` depende da #31; `analyses` não possui migration na `main` (escopo vigente na [#66](https://github.com/conloq/mash/issues/66)). `iodine_configs` e `login_history` vêm do schema complementar, ainda sem migrations da API. Os nomes `Telemetria_IOT` e `Registro`, citados na #87, não têm definição canônica de colunas e por isso não foram desenhados. Nenhum desses elementos representa o schema atualmente aplicado à API.

## Colunas físicas do modelo atualizado

As tabelas originais abaixo mostram os tipos observados; adições do complemento estão identificadas separadamente.

JSON e atributos dos models usam camelCase; tabelas e colunas físicas usam snake_case, com `define: { underscored: true }`. Exemplos: `urlImage → url_image`, `userId → user_id`, `recipeId → recipe_id`, `orderRamp → order_ramp` e `createdAt → created_at`.

### `users`

| Coluna | Tipo observado | Aceita NULL | Chave / default |
|---|---|---|---|
| `id` | `int(11)` | Não | PK, auto incremento |
| `name` | `varchar(255)` | Não | - |
| `email` | `varchar(255)` | Não | UNIQUE |
| `phone` | `varchar(255)` | Sim | - |
| `password` | `varchar(255)` | Não | - |
| `url_image` | `varchar(255)` | Sim | - |
| `created_at` | `datetime` | Não | default current_timestamp() |
| `updated_at` | `datetime` | Não | default current_timestamp() |

### `recipes`

| Coluna | Tipo observado | Aceita NULL | Chave / default |
|---|---|---|---|
| `id` | `int(11)` | Não | PK, auto incremento |
| `name` | `varchar(255)` | Não | - |
| `user_id` | `int(11)` | Não | FK → users.id |
| `created_at` | `datetime` | Não | default current_timestamp() |
| `updated_at` | `datetime` | Não | default current_timestamp() |

### `temperatures`

| Coluna | Tipo observado | Aceita NULL | Chave / default |
|---|---|---|---|
| `id` | `int(11)` | Não | PK, auto incremento |
| `max_temperature_ramp` | `int(11)` | Não | - |
| `min_temperature_ramp` | `int(11)` | Não | - |
| `max_temperature_limit` | `int(11)` | Não | - |
| `min_temperature_limit` | `int(11)` | Não | - |
| `timer` | `time` | Não | - |
| `initialization` | `time` | Não | - |
| `ideal_time` | `time` | Não | - |
| `order_ramp` | `int(11)` | Sim | - |
| `active_temperature` | `boolean` | Não | Adição do complemento, ainda não aplicada; default FALSE |
| `recipe_id` | `int(11)` | Não | FK → recipes.id |
| `created_at` | `datetime` | Não | default current_timestamp() |
| `updated_at` | `datetime` | Não | default current_timestamp() |

`users.email` possui índice único. O banco não tem UNIQUE composto em `recipes(user_id, name)`; a regra de nome de receita por usuário pertence à aplicação. `updated_at` é mantido pelo Sequelize nas operações da aplicação, sem cláusula `ON UPDATE` no DDL observado.

### `sessions`

| Coluna | Tipo na migration | Aceita NULL | Chave / default |
|---|---|---|---|
| `session_id` | `varchar(128)` | Não | PK |
| `expires` | `int unsigned` | Não | Epoch em segundos, para expiração pelo armazenamento de sessão |
| `data` | `mediumtext` | Sim | Estado serializado da sessão |

A tabela é criada pela migration `20261024120000-criar-tabela-sessions.js` do Back-End, com engine InnoDB, charset `utf8mb4` e collation `utf8mb4_bin`. As colunas vêm da definição da migration: a observação de banco disponível é de 21/10 e antecede essa tabela.

### `lots` (complemento, ainda não aplicado)

| Coluna | Tipo de referência | Aceita NULL | Chave / default |
|---|---|---|---|
| `id` | `int` | Não | PK, auto incremento |
| `name` | `varchar(255)` | Não | - |
| `user_id` | `int` | Não | FK → users.id |
| `recipe_id` | `int` | Não | FK → recipes.id |
| `mash_start` | `datetime` | Não | default CURRENT_TIMESTAMP |
| `status` | `enum('active', 'completed')` | Não | default active |
| `created_at` | `datetime` | Não | default CURRENT_TIMESTAMP |
| `updated_at` | `datetime` | Não | default CURRENT_TIMESTAMP |

### `iodine_configs` (complemento, ainda não aplicado)

| Coluna | Tipo de referência | Aceita NULL | Chave / default |
|---|---|---|---|
| `id` | `int` | Não | PK, auto incremento |
| `first_collection_time` | `time` | Não | - |
| `test_interval` | `time` | Não | - |
| `max_tests` | `int` | Não | - |
| `recipe_id` | `int` | Não | FK → recipes.id |
| `created_at` | `datetime` | Não | default CURRENT_TIMESTAMP |
| `updated_at` | `datetime` | Não | default CURRENT_TIMESTAMP |

### `login_history` (complemento, ainda não aplicado)

| Coluna | Tipo de referência | Aceita NULL | Chave / default |
|---|---|---|---|
| `id` | `int` | Não | PK, auto incremento |
| `ip_address` | `varchar(255)` | Não | - |
| `logged_at` | `datetime` | Não | default CURRENT_TIMESTAMP |
| `location` | `varchar(255)` | Não | - |
| `status` | `boolean` | Sim | - |
| `user_id` | `int` | Não | FK → users.id |
| `created_at` | `datetime` | Não | default CURRENT_TIMESTAMP |
| `updated_at` | `datetime` | Não | default CURRENT_TIMESTAMP |

## Como criar e evoluir o schema

No clone do Back-End, configure as variáveis `DB_*` para o ambiente desejado. Crie um banco vazio quando necessário e execute:

```bash
npm run db:migrate
npm start
```

`npm start` já executa `prestart` com as migrations. Não usar `sync()` como fonte paralela de criação. Depois de uma migration aplicada em ambiente compartilhado/publicado, mudanças de schema entram por nova migration.

Os testes de schema que criam dados ou fazem rollback devem usar banco descartável, separado do banco de trabalho. Para conferir o banco existente, use somente as consultas de metadados em `evidencias/consultas-schema.sql`.

## Implementado, planejado e simulado

- Implementado e observado: `users`, `recipes`, `temperatures` e `SequelizeMeta`.
- Planejado neste semestre: `lots`, conforme [#31](https://github.com/conloq/mash/issues/31); não existe no schema nem na main comparados nesta conferência.
- Escopo por semestre e funcionalidades fora do banco atual: consultar a [#66](https://github.com/conloq/mash/issues/66) e a documentação geral em [`conloq/documentation`](https://github.com/conloq/documentation/blob/main/geral/README.md).
- Sensores, leituras IoT, reprocessamento e avaliações são futuros; não aparecem no MER como implementados.

## Complemento de schema solicitado em 21/10/2026

Por solicitação do Haimon, somente neste repositório, o [SQL complementar](schema-complementar.sql) acrescenta as estruturas abaixo à base descrita em `schema-api.sql`. São definições de referência: não foram aplicadas ao banco de trabalho nem implementadas nos models ou migrations do Back-End. As evidências anteriores continuam descrevendo apenas o schema observado. O [diagrama complementar](diagrama_mer_complementar.mmd) mostra as adições e seus vínculos, abreviando as entidades existentes.

| Adição | Origem e campos |
|---|---|
| `temperatures.active_temperature` | Equivalente de `temperaturas.temperatura_ativa`: BOOLEAN obrigatório, default FALSE; preserva `order_ramp`. Não impõe unicidade de rampa ativa por receita, assim como o legado |
| `lots` | Contrato da [#31](https://github.com/conloq/mash/issues/31): `id`, `name`, `user_id`, `recipe_id`, `mash_start`, `status`, `created_at`, `updated_at`; status `active`/`completed`, default `active` |
| `iodine_configs` | Equivalente de `iodos`: `tempo_primeira_coleta → first_collection_time`, `intervalo_testes → test_interval`, `qtd_max_testes → max_tests`, `receita_id → recipe_id`, além de id e timestamps |
| `login_history` | Equivalente de `Historico_Logins`: `endereco_ip → ip_address`, `data_hora → logged_at`, `localidade → location`, `status`, `usuario_id → user_id`, além de id e timestamps; status continua anulável |

As colunas novas seguem inglês e snake_case. As tabelas novas usam InnoDB e `utf8mb4_general_ci`. O SQL preserva a exclusão em cascata dos vínculos legados de configuração e histórico; para lotes, usa RESTRICT na exclusão de usuário/receita para preservar os registros. O vínculo entre lote e receita do mesmo usuário precisa de validação na futura API. Os timestamps seguem o padrão atual: default de cadastro; atualização de `updated_at` pela aplicação, sem `ON UPDATE` automático.

Para validar o DDL, usar banco vazio descartável: primeiro `schema-api.sql`, depois `schema-complementar.sql`, uma única vez. O complemento não tem DROP, não copia dados legados e não deve ser aplicado manualmente ao banco da API. A adoção pela aplicação exige novas migrations e alinhamento dos models, em trabalho separado.

## Arquivos

| Arquivo | Papel |
|---|---|
| `schema-api.sql` | DDL de referência obtido de SHOW CREATE TABLE do banco local; sem dados e sem DROP; não substitui migrations nem deve ser importado no banco de trabalho |
| `diagrama_mer_mash.mmd` | Modelo atualizado completo, com adições ainda não aplicadas à API; renderizado neste README |
| `schema-complementar.sql` | Adições solicitadas: active_temperature, lotes, configuração de iodo e histórico de login; referência ainda não aplicada à API |
| `diagrama_mer_complementar.mmd` | Adições e relacionamentos do complemento; entidades existentes abreviadas |
| `evidencias/` | Metadados, resultado da comparação e consultas de leitura para reprodução |
| `mash.sql` | Script histórico do app legado `cervejaria`; contém DROP e não corresponde à API atual |
| `legacy/README.md` | Documentação anterior, preservada como histórico |

O SQL legado fica preservado para rastreabilidade. Não executar `mash.sql` para criar ou atualizar o banco da API. Não há dados de usuários ou credenciais nos arquivos de evidência.
