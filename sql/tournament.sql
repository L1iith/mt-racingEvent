-- Racing Tournament Database Schema
-- Created for FiveM Racing Tournament Script

-- Tournaments Table
CREATE TABLE IF NOT EXISTS `tournaments` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `status` ENUM('registration', 'active', 'completed', 'cancelled') DEFAULT 'registration',
    `start_date` DATETIME NOT NULL,
    `end_date` DATETIME NULL,
    `max_teams` INT(11) NOT NULL DEFAULT 16,
    `current_teams` INT(11) NOT NULL DEFAULT 0,
    `registration_fee` INT(11) NOT NULL DEFAULT 5000,
    `prize_pool` INT(11) NOT NULL DEFAULT 0,
    `tournament_type` ENUM('single_elimination', 'double_elimination', 'round_robin') DEFAULT 'single_elimination',
    `description` TEXT NULL,
    `rules` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_start_date` (`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Teams Table
CREATE TABLE IF NOT EXISTS `teams` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `tournament_id` INT(11) NOT NULL,
    `team_name` VARCHAR(100) NOT NULL,
    `captain_cid` VARCHAR(50) NOT NULL,
    `status` ENUM('registered', 'active', 'eliminated', 'disqualified') DEFAULT 'registered',
    `registration_fee_paid` TINYINT(1) DEFAULT 0,
    `total_points` INT(11) DEFAULT 0,
    `wins` INT(11) DEFAULT 0,
    `losses` INT(11) DEFAULT 0,
    `team_tag` VARCHAR(10) NULL,
    `team_color` VARCHAR(7) DEFAULT '#FFFFFF',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`tournament_id`) REFERENCES `tournaments`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_team_tournament` (`tournament_id`, `team_name`),
    INDEX `idx_captain` (`captain_cid`),
    INDEX `idx_status` (`status`),
    INDEX `idx_tournament` (`tournament_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Team Members Table
CREATE TABLE IF NOT EXISTS `team_members` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `team_id` INT(11) NOT NULL,
    `citizen_id` VARCHAR(50) NOT NULL,
    `player_name` VARCHAR(100) NOT NULL,
    `role` ENUM('captain', 'driver', 'navigator', 'mechanic1', 'mechanic2') NOT NULL,
    `status` ENUM('active', 'inactive', 'kicked') DEFAULT 'active',
    `racing_license` TINYINT(1) DEFAULT 0,
    `total_races` INT(11) DEFAULT 0,
    `best_lap_time` DECIMAL(10,3) NULL,
    `joined_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `left_date` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_member_team` (`team_id`, `citizen_id`),
    INDEX `idx_citizen` (`citizen_id`),
    INDEX `idx_role` (`role`),
    INDEX `idx_team` (`team_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tournament Brackets Table
CREATE TABLE IF NOT EXISTS `tournament_brackets` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `tournament_id` INT(11) NOT NULL,
    `round_number` INT(11) NOT NULL,
    `match_number` INT(11) NOT NULL,
    `team1_id` INT(11) NULL,
    `team2_id` INT(11) NULL,
    `winner_id` INT(11) NULL,
    `loser_id` INT(11) NULL,
    `match_status` ENUM('pending', 'active', 'completed', 'bye') DEFAULT 'pending',
    `scheduled_time` DATETIME NULL,
    `completed_time` DATETIME NULL,
    `team1_score` INT(11) DEFAULT 0,
    `team2_score` INT(11) DEFAULT 0,
    `race_data` JSON NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`tournament_id`) REFERENCES `tournaments`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`team1_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`team2_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`winner_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`loser_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL,
    INDEX `idx_tournament_round` (`tournament_id`, `round_number`),
    INDEX `idx_match_status` (`match_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Race Results Table (for detailed race tracking)
CREATE TABLE IF NOT EXISTS `race_results` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `bracket_id` INT(11) NOT NULL,
    `race_number` INT(11) NOT NULL,
    `team_id` INT(11) NOT NULL,
    `citizen_id` VARCHAR(50) NOT NULL,
    `position` INT(11) NOT NULL,
    `lap_time` DECIMAL(10,3) NULL,
    `total_time` DECIMAL(10,3) NULL,
    `vehicle_model` VARCHAR(50) NULL,
    `checkpoints_hit` INT(11) DEFAULT 0,
    `penalties` INT(11) DEFAULT 0,
    `dnf` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`bracket_id`) REFERENCES `tournament_brackets`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE CASCADE,
    INDEX `idx_bracket_race` (`bracket_id`, `race_number`),
    INDEX `idx_team` (`team_id`),
    INDEX `idx_citizen` (`citizen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tournament Settings Table
CREATE TABLE IF NOT EXISTS `tournament_settings` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `tournament_id` INT(11) NOT NULL,
    `setting_key` VARCHAR(50) NOT NULL,
    `setting_value` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`tournament_id`) REFERENCES `tournaments`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_tournament_setting` (`tournament_id`, `setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
