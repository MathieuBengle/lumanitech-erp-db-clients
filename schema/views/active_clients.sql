-- Active Clients View
-- Shows only active clients with their essential information

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
