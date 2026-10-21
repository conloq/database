-- Complemento de referência solicitado por Haimon em 21/10/2026.
-- Aplicável uma única vez DEPOIS de schema-api.sql, em banco descartável.
-- Não aplicado ao banco de trabalho; não substitui migrations do Back-End.
-- Não registra migrations em SequelizeMeta nem implementa funcionalidades.

ALTER TABLE `temperatures`
  ADD COLUMN `active_temperature` BOOLEAN NOT NULL DEFAULT FALSE;

-- Lotes: campos do contrato conloq/mash#31.
-- As FKs RESTRICT preservam lotes quando há tentativa de excluir usuário/receita.
-- A API ainda deve conferir que recipe_id pertence ao mesmo user_id.
CREATE TABLE `lots` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `user_id` INT NOT NULL,
  `recipe_id` INT NOT NULL,
  `mash_start` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('active', 'completed') NOT NULL DEFAULT 'active',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lots_user_id` (`user_id`),
  KEY `idx_lots_recipe_id` (`recipe_id`),
  CONSTRAINT `fk_lots_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lots_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Equivalente estrutural da tabela legada iodos: configuração por receita.
-- Não é uma tabela de resultados de análise, imagens ou classificação.
CREATE TABLE `iodine_configs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_collection_time` TIME NOT NULL,
  `test_interval` TIME NOT NULL,
  `max_tests` INT NOT NULL,
  `recipe_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_iodine_configs_recipe_id` (`recipe_id`),
  CONSTRAINT `fk_iodine_configs_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Equivalente estrutural de Historico_Logins; nulabilidade preservada.
CREATE TABLE `login_history` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ip_address` VARCHAR(255) NOT NULL,
  `logged_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `location` VARCHAR(255) NOT NULL,
  `status` BOOLEAN NULL,
  `user_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_login_history_user_id` (`user_id`),
  KEY `idx_login_history_logged_at` (`logged_at`),
  CONSTRAINT `fk_login_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
