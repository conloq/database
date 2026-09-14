-- ============================================================
-- MASH / Projeto Integrador
-- Banco de dados atual do backend
--
-- Gerado a partir dos models Sequelize:
--   Usuario.js
--   Receita.js
--   Iodo.js
--   Temperatura.js
--   log.js
--
-- Configuração validada em sequelize-config.js:
--   Dialect: MySQL
--   Database: cervejaria
--   Timezone: -03:00
--
-- Observação:
-- Como timestamps não foram desativados no Sequelize,
-- id, createdAt e updatedAt fazem parte das tabelas.
-- ============================================================

CREATE DATABASE IF NOT EXISTS `cervejaria`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `cervejaria`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Historico_Logins`;
DROP TABLE IF EXISTS `iodos`;
DROP TABLE IF EXISTS `temperaturas`;
DROP TABLE IF EXISTS `receitas`;
DROP TABLE IF EXISTS `usuarios`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- USUARIOS
-- ============================================================

CREATE TABLE `usuarios` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `telefone` VARCHAR(255) NULL,
    `senha` VARCHAR(255) NOT NULL,
    `url_imagem` VARCHAR(255) NULL,
    `createdAt` DATETIME NOT NULL,
    `updatedAt` DATETIME NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- RECEITAS
--
-- Cardinalidade:
-- usuarios 1 : 0..N receitas
-- Cada receita pertence obrigatoriamente a 1 usuário.
-- ============================================================

CREATE TABLE `receitas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(255) NOT NULL,
    `usuario_id` INT NOT NULL,
    `createdAt` DATETIME NOT NULL,
    `updatedAt` DATETIME NOT NULL,

    PRIMARY KEY (`id`),

    INDEX `idx_receitas_usuario_id` (`usuario_id`),

    CONSTRAINT `fk_receitas_usuario`
        FOREIGN KEY (`usuario_id`)
        REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- IODOS
--
-- Cardinalidade:
-- receitas 1 : 0..N iodos
-- Cada registro de iodo pertence obrigatoriamente a 1 receita.
-- ============================================================

CREATE TABLE `iodos` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `tempo_primeira_coleta` TIME NOT NULL,
    `intervalo_testes` TIME NOT NULL,
    `qtd_max_testes` INT NOT NULL,
    `receita_id` INT NOT NULL,
    `createdAt` DATETIME NOT NULL,
    `updatedAt` DATETIME NOT NULL,

    PRIMARY KEY (`id`),

    INDEX `idx_iodos_receita_id` (`receita_id`),

    CONSTRAINT `fk_iodos_receita`
        FOREIGN KEY (`receita_id`)
        REFERENCES `receitas` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TEMPERATURAS
--
-- Cardinalidade:
-- receitas 1 : 0..N temperaturas
-- Cada configuração de temperatura pertence a 1 receita.
-- ============================================================

CREATE TABLE `temperaturas` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `rampa_temperatura_minima` INT NOT NULL,
    `rampa_temperatura_maxima` INT NOT NULL,
    `temp_maxima_limite` INT NOT NULL,
    `temp_minima_limite` INT NOT NULL,
    `temporizador` TIME NOT NULL,
    `inicializacao` TIME NOT NULL,
    `tempo_ideal` TIME NOT NULL,
    `temperatura_ativa` BOOLEAN NOT NULL DEFAULT FALSE,
    `receita_id` INT NOT NULL,
    `createdAt` DATETIME NOT NULL,
    `updatedAt` DATETIME NOT NULL,

    PRIMARY KEY (`id`),

    INDEX `idx_temperaturas_receita_id` (`receita_id`),

    CONSTRAINT `fk_temperaturas_receita`
        FOREIGN KEY (`receita_id`)
        REFERENCES `receitas` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- HISTORICO_LOGINS
--
-- Model Sequelize: Historico_Login
-- Com a pluralização padrão do Sequelize:
-- tabela esperada: Historico_Logins
--
-- Cardinalidade:
-- usuarios 1 : 0..N Historico_Logins
-- ============================================================

CREATE TABLE `Historico_Logins` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `endereco_ip` VARCHAR(255) NOT NULL,
    `data_hora` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `localidade` VARCHAR(255) NOT NULL,
    `status` BOOLEAN NULL,
    `usuario_id` INT NOT NULL,
    `createdAt` DATETIME NOT NULL,
    `updatedAt` DATETIME NOT NULL,

    PRIMARY KEY (`id`),

    INDEX `idx_historico_login_usuario_id` (`usuario_id`),
    INDEX `idx_historico_login_data_hora` (`data_hora`),

    CONSTRAINT `fk_historico_login_usuario`
        FOREIGN KEY (`usuario_id`)
        REFERENCES `usuarios` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;
