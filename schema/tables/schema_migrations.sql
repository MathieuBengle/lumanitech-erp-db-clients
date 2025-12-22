-- Schema Migrations Tracking Table
-- This table tracks which migrations have been applied to the database
-- It is automatically managed by the migration system

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
