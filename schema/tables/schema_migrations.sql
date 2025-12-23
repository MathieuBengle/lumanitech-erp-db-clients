-- Schema Migrations Tracking Table
-- This table tracks which migrations have been applied to the database
-- It is automatically managed by the migration system

CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(50) NOT NULL PRIMARY KEY COMMENT 'Migration version (V###)',
    description VARCHAR(255) NOT NULL COMMENT 'Migration description',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When the migration was applied',
    
    INDEX idx_applied_at (applied_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tracks applied database migrations';
