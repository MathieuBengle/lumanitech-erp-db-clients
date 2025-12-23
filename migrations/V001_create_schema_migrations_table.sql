-- Migration: V001_create_schema_migrations_table
-- Description: Create the schema_migrations table to track applied migrations
-- Author: Database Team
-- Date: 2023-12-15

-- This is the first migration and creates the tracking table
-- The API service will use this table to determine which migrations have been applied

CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(50) NOT NULL PRIMARY KEY COMMENT 'Migration version (V###)',
    description VARCHAR(255) NOT NULL COMMENT 'Migration description',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When the migration was applied',
    
    INDEX idx_applied_at (applied_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tracks applied database migrations';

-- Record this migration
INSERT INTO schema_migrations (version, description) 
VALUES ('V001', 'create_schema_migrations_table')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
