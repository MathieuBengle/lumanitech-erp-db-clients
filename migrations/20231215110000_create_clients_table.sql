-- Migration: 20231215110000_create_clients_table
-- Description: Create the main clients table for storing customer information
-- Author: Database Team
-- Date: 2023-12-15

-- Create the clients table
CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Basic Information
    client_code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Unique client code/reference',
    company_name VARCHAR(255) NOT NULL COMMENT 'Company or individual name',
    legal_name VARCHAR(255) NULL COMMENT 'Legal business name if different',
    
    -- Contact Information
    email VARCHAR(255) NULL COMMENT 'Primary email address',
    phone VARCHAR(50) NULL COMMENT 'Primary phone number',
    website VARCHAR(255) NULL COMMENT 'Company website',
    
    -- Address Information
    address_line1 VARCHAR(255) NULL,
    address_line2 VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state_province VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    country VARCHAR(2) NULL COMMENT 'ISO 3166-1 alpha-2 country code',
    
    -- Business Information
    tax_id VARCHAR(50) NULL COMMENT 'Tax identification number',
    industry VARCHAR(100) NULL COMMENT 'Industry sector',
    client_type ENUM('individual', 'business', 'government', 'nonprofit') DEFAULT 'business',
    
    -- Status and Metadata
    status ENUM('active', 'inactive', 'suspended', 'archived') DEFAULT 'active',
    credit_limit DECIMAL(15, 2) NULL COMMENT 'Credit limit in base currency',
    payment_terms INT NULL COMMENT 'Payment terms in days (e.g., 30, 60, 90)',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT NULL COMMENT 'User ID who created the record',
    updated_by INT NULL COMMENT 'User ID who last updated the record',
    
    -- Indexes
    INDEX idx_client_code (client_code),
    INDEX idx_company_name (company_name),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_client_type (client_type)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Main clients/customers table';

-- Record this migration
INSERT INTO schema_migrations (version, description) 
VALUES ('20231215110000', 'create_clients_table')
ON DUPLICATE KEY UPDATE version = version;

-- Rollback instructions (for reference only - create new migration to rollback):
-- DROP TABLE IF EXISTS clients;
-- DELETE FROM schema_migrations WHERE version = '20231215110000';
