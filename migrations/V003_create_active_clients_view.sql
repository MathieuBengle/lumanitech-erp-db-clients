-- Migration: V003_create_active_clients_view
-- Description: Create view for active clients
-- Author: Database Team
-- Date: 2023-12-15

-- Create view for frequently queried active clients
CREATE OR REPLACE VIEW active_clients AS
SELECT 
    id,
    client_code,
    company_name,
    legal_name,
    email,
    phone,
    city,
    state_province,
    country,
    client_type,
    credit_limit,
    payment_terms,
    created_at,
    updated_at
FROM 
    clients
WHERE 
    status = 'active'
ORDER BY 
    company_name;

-- Record this migration
INSERT INTO schema_migrations (version, description) 
VALUES ('V003', 'create_active_clients_view')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;

-- Rollback instructions (for reference only - create new migration to rollback):
-- DROP VIEW IF EXISTS active_clients;
-- DELETE FROM schema_migrations WHERE version = 'V003';
