# Database Schema Documentation

## Overview

**Database Name**: lumanitech_erp_clients  
**Character Set**: utf8mb4  
**Collation**: utf8mb4_unicode_ci  
**Engine**: InnoDB  

This database stores client and customer master data for the Lumanitech ERP system.

## Schema Structure

```
schema/
├── 01_create_database.sql
├── tables/
│   ├── schema_migrations.sql
│   └── clients.sql
├── views/
│   └── active_clients.sql
├── procedures/
├── functions/
├── triggers/
└── indexes/
```

**Naming conventions:**
- procedures: `sp_<name>.sql`
- triggers: `trg_<name>.sql`

## Tables

### schema_migrations

Tracks all applied database migrations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| version | VARCHAR(50) | PRIMARY KEY | Migration version (e.g., V001, V002) |
| description | VARCHAR(255) | NOT NULL | Brief description of the migration |
| applied_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | When the migration was applied |

**Indexes:**
- `idx_applied_at` on `applied_at`

### clients

Main table storing client/customer information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| client_code | VARCHAR(50) | NOT NULL, UNIQUE | Unique client reference code |
| company_name | VARCHAR(255) | NOT NULL | Company or individual name |
| legal_name | VARCHAR(255) | NULL | Legal business name if different |
| email | VARCHAR(255) | NULL | Primary email address |
| phone | VARCHAR(50) | NULL | Primary phone number |
| website | VARCHAR(255) | NULL | Company website |
| address_line1 | VARCHAR(255) | NULL | Address line 1 |
| address_line2 | VARCHAR(255) | NULL | Address line 2 |
| city | VARCHAR(100) | NULL | City |
| state_province | VARCHAR(100) | NULL | State/Province |
| postal_code | VARCHAR(20) | NULL | Postal/ZIP code |
| country | VARCHAR(2) | NULL | ISO 3166-1 alpha-2 country code |
| tax_id | VARCHAR(50) | NULL | Tax identification number |
| industry | VARCHAR(100) | NULL | Industry sector |
| client_type | ENUM | DEFAULT 'business' | Type: individual, business, government, nonprofit |
| status | ENUM | DEFAULT 'active' | Status: active, inactive, suspended, archived |
| credit_limit | DECIMAL(15,2) | NULL | Credit limit in base currency |
| payment_terms | INT | NULL | Payment terms in days |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update timestamp |
| created_by | INT | NULL | User ID who created record |
| updated_by | INT | NULL | User ID who last updated |

**Indexes:**
- `idx_client_code` on `client_code`
- `idx_company_name` on `company_name`
- `idx_email` on `email`
- `idx_status` on `status`
- `idx_created_at` on `created_at`
- `idx_client_type` on `client_type`

**Business Rules:**
- `client_code` must be unique across all clients
- `status` determines if client is active in the system
- `payment_terms` is in days (e.g., 30, 60, 90)
- `country` should use ISO 3166-1 alpha-2 codes (e.g., US, GB, FR)

## Views

### active_clients

Filtered view showing only active clients with essential information.

**Columns**: id, client_code, company_name, legal_name, email, phone, city, state_province, country, client_type, credit_limit, payment_terms, created_at, updated_at

**Filter**: `status = 'active'`  
**Ordering**: `company_name` ASC

## Stored Procedures

_None currently defined_

## Functions

_None currently defined_

## Triggers

_None currently defined_

## Data Types Reference

### ENUM Values

**client_type:**
- `individual`: Individual person
- `business`: Business/company
- `government`: Government entity
- `nonprofit`: Non-profit organization

**status:**
- `active`: Client is active and can be used
- `inactive`: Client is temporarily inactive
- `suspended`: Client account is suspended
- `archived`: Client is archived (historical record)

## Migration History

Migrations are applied in sequential order:

1. `V000_create_schema_migrations_table.sql` - Migration tracking
2. `V001_create_clients_table.sql` - Main clients table
3. `V002_create_active_clients_view.sql` - Active clients view

For complete migration history, see the `migrations/` directory.

## Relationships

Currently, the schema is designed to be self-contained. Future expansions may include:

- Contacts table (many contacts per client)
- Addresses table (multiple addresses per client)
- Client notes/history table
- Client documents table

## Indexing Strategy

Indexes are created on:
1. Primary keys (automatic)
2. Unique constraints (automatic)
3. Foreign keys (when implemented)
4. Frequently queried columns (status, client_code, email)
5. Columns used in WHERE clauses
6. Columns used in ORDER BY clauses

## Maintenance

### Regular Tasks

1. **Monitor table size**: Check growth of clients table
2. **Index optimization**: Analyze slow queries and adjust indexes
3. **Archival**: Move old/inactive clients to archive if needed
4. **Backups**: Ensure regular backups are performed

### Performance Considerations

- Indexes on frequently queried columns improve SELECT performance
- Avoid over-indexing (impacts INSERT/UPDATE performance)
- Use appropriate column types (VARCHAR vs TEXT)
- Monitor query performance with EXPLAIN

## See Also

- [DATA_DICTIONARY.md](DATA_DICTIONARY.md) - Detailed data dictionary
- [migration-strategy.md](migration-strategy.md) - Migration guidelines
- [ERD.md](ERD.md) - Entity relationship diagrams
