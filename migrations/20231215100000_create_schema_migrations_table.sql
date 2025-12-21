-- Migration: 20231215100000_create_schema_migrations_table
-- Description: Create the schema_migrations table to track applied migrations
-- Author: Database Team
-- Date: 2023-12-15

-- This is the first migration and creates the tracking table
-- The API service will use this table to determine which migrations have been applied

CREATE TABLE IF NOT EXISTS schema_migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(14) NOT NULL UNIQUE COMMENT 'Migration version timestamp (YYYYMMDDHHMMSS)',
    description VARCHAR(255) NOT NULL COMMENT 'Migration description',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When the migration was applied',
    checksum VARCHAR(64) NULL COMMENT 'Optional checksum for migration integrity',
    
    INDEX idx_version (version),
    INDEX idx_applied_at (applied_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tracks applied database migrations';

-- Record this migration
INSERT INTO schema_migrations (version, description) 
VALUES ('20231215100000', 'create_schema_migrations_table')
ON DUPLICATE KEY UPDATE version = version;
