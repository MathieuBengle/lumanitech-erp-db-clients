# Data Dictionary

This document provides detailed information about all database objects in the lumanitech_erp_clients database.

## Tables

### schema_migrations

**Purpose**: Track applied database migrations

| Column | Data Type | Null | Default | Description |
|--------|-----------|------|---------|-------------|
| version | VARCHAR(50) | NO | - | Migration version (V000, V001, etc.) - PRIMARY KEY |
| description | VARCHAR(255) | NO | - | Brief description of the migration |
| applied_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | When the migration was applied |

**Indexes:**
- PRIMARY KEY on `version`
- INDEX `idx_applied_at` on `applied_at`

**Notes:**
- Automatically managed by migration system
- Do not modify manually

---

### clients

**Purpose**: Store client/customer master data

| Column | Data Type | Null | Default | Description |
|--------|-----------|------|---------|-------------|
| id | INT | NO | AUTO_INCREMENT | Unique identifier - PRIMARY KEY |
| client_code | VARCHAR(50) | NO | - | Unique client code/reference - UNIQUE |
| company_name | VARCHAR(255) | NO | - | Company or individual name |
| legal_name | VARCHAR(255) | YES | NULL | Legal business name if different |
| email | VARCHAR(255) | YES | NULL | Primary email address |
| phone | VARCHAR(50) | YES | NULL | Primary phone number |
| website | VARCHAR(255) | YES | NULL | Company website |
| address_line1 | VARCHAR(255) | YES | NULL | Address line 1 |
| address_line2 | VARCHAR(255) | YES | NULL | Address line 2 |
| city | VARCHAR(100) | YES | NULL | City |
| state_province | VARCHAR(100) | YES | NULL | State or province |
| postal_code | VARCHAR(20) | YES | NULL | Postal or ZIP code |
| country | VARCHAR(2) | YES | NULL | ISO 3166-1 alpha-2 country code |
| tax_id | VARCHAR(50) | YES | NULL | Tax identification number |
| industry | VARCHAR(100) | YES | NULL | Industry sector |
| client_type | ENUM | NO | 'business' | Client type: individual, business, government, nonprofit |
| status | ENUM | NO | 'active' | Status: active, inactive, suspended, archived |
| credit_limit | DECIMAL(15,2) | YES | NULL | Credit limit in base currency |
| payment_terms | INT | YES | NULL | Payment terms in days (30, 60, 90, etc.) |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | When record was created |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP ON UPDATE | When record was last updated |
| created_by | INT | YES | NULL | User ID who created the record |
| updated_by | INT | YES | NULL | User ID who last updated the record |

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE on `client_code`
- INDEX `idx_client_code` on `client_code`
- INDEX `idx_company_name` on `company_name`
- INDEX `idx_email` on `email`
- INDEX `idx_status` on `status`
- INDEX `idx_created_at` on `created_at`
- INDEX `idx_client_type` on `client_type`

**Business Rules:**
- `client_code` must be unique across all clients
- `country` should use ISO 3166-1 alpha-2 codes (US, GB, FR, CA, etc.)
- `payment_terms` is in days
- `credit_limit` is in the system's base currency

**Valid Values:**

client_type:
- `individual`: Individual person
- `business`: Business or company
- `government`: Government entity
- `nonprofit`: Non-profit organization

status:
- `active`: Client is active and can be used
- `inactive`: Client is temporarily inactive
- `suspended`: Client account is suspended (billing/payment issues)
- `archived`: Client is archived (historical record, no longer active)

---

## Views

### active_clients

**Purpose**: Filtered view of active clients with essential information

**Base Table**: clients

**Filter**: WHERE status = 'active'

**Columns:**
- id
- client_code
- company_name
- legal_name
- email
- phone
- city
- state_province
- country
- client_type
- credit_limit
- payment_terms
- created_at
- updated_at

**Ordering**: company_name ASC

**Usage**: Quick access to active client records without filtering

---

## Stored Procedures

_None currently defined_

---

## Functions

_None currently defined_

---

## Triggers

_None currently defined_

---

## Enumerations

### client_type

| Value | Description |
|-------|-------------|
| individual | Individual person or sole proprietor |
| business | Business, company, or corporation |
| government | Government agency or entity |
| nonprofit | Non-profit organization or charity |

### status

| Value | Description |
|-------|-------------|
| active | Client is active and can be used in transactions |
| inactive | Client is temporarily inactive (may be reactivated) |
| suspended | Client account is suspended (e.g., payment issues) |
| archived | Client is archived (historical record only) |

---

## Common Queries

### Get all active clients

```sql
SELECT * FROM active_clients;
```

### Find client by code

```sql
SELECT * FROM clients WHERE client_code = 'CLI-001';
```

### Get clients by country

```sql
SELECT * FROM clients WHERE country = 'US' AND status = 'active';
```

### Get recently created clients

```sql
SELECT * FROM clients 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY created_at DESC;
```

### Count clients by type

```sql
SELECT client_type, COUNT(*) as count
FROM clients
WHERE status = 'active'
GROUP BY client_type;
```

---

## Maintenance Notes

### Regular Checks

- Monitor growth of clients table
- Review and optimize indexes based on query patterns
- Archive old/inactive clients periodically
- Validate data integrity (email format, country codes, etc.)

### Data Quality

- Ensure client_code uniqueness
- Validate email addresses
- Check country codes against ISO 3166-1
- Review duplicate company names
- Monitor null values in key fields

---

## See Also

- [schema.md](schema.md) - Schema overview
- [DATABASE_DESIGN.md](DATABASE_DESIGN.md) - Design principles
- [migration-strategy.md](migration-strategy.md) - Migration guidelines
