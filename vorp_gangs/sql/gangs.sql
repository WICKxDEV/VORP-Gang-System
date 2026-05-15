CREATE TABLE IF NOT EXISTS `vorp_gangs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(50) NOT NULL,
    `owner` varchar(50) NOT NULL,
    `balance` decimal(15,2) DEFAULT 0.00,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `vorp_gang_members` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `gang_id` int(11) NOT NULL,
    `char_identifier` varchar(50) NOT NULL,
    `rank` int(11) DEFAULT 1,
    `joined_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `gang_id` (`gang_id`),
    CONSTRAINT `fk_gang` FOREIGN KEY (`gang_id`) REFERENCES `vorp_gangs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
