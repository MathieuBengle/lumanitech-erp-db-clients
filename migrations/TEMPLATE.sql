-- Migration: V###_description
-- Description: Detailed description of what this migration does and why
-- Author: Your Name
-- Date: YYYY-MM-DD

-- [Optional] Any notes about the migration, dependencies, or considerations
-- Example: This migration adds email verification to support the new authentication flow

-- Main migration SQL
-- Use IF NOT EXISTS / IF EXISTS for idempotency when possible

-- Example: Creating a table
CREATE TABLE IF NOT EXISTS example_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Description of what this table stores';

-- Example: Adding a column
-- ALTER TABLE table_name 
-- ADD COLUMN IF NOT EXISTS column_name VARCHAR(255) NULL COMMENT 'Column description';

-- Example: Creating an index
-- CREATE INDEX IF NOT EXISTS idx_column_name ON table_name(column_name);

-- Example: Creating a view
-- CREATE OR REPLACE VIEW view_name AS
-- SELECT id, name FROM table_name WHERE status = 'active';

-- Record this migration
INSERT INTO schema_migrations (version, description) 
VALUES ('V###', 'description')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;

-- Rollback instructions (for reference only - create new migration to rollback):
-- Include SQL statements that would reverse this migration
-- DROP TABLE IF EXISTS example_table;
-- DELETE FROM schema_migrations WHERE version = 'V###';
