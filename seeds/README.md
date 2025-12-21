# Seeds Directory

This directory contains SQL scripts to populate the database with initial or test data.

## Purpose

Seed data files:
- Provide sample data for local development
- Enable testing with realistic data
- Populate reference/lookup tables
- Support different environments (dev, staging, etc.)

⚠️ **Important**: Seed data is for **development and testing only**. Production data should never be committed to this repository.

## Structure

```
seeds/
└── dev/              # Development environment seed data
    └── clients_seed.sql
```

**Environments:**
- `dev/` - Local development and testing
- `staging/` - (Future) Staging environment data
- `test/` - (Future) Automated test data

## Usage

### Loading Seed Data

```bash
# Load all dev seed data
for f in seeds/dev/*.sql; do
    echo "Loading $f"
    mysql -u root -p lumanitech_erp_clients < "$f"
done

# Load specific seed file
mysql -u root -p lumanitech_erp_clients < seeds/dev/clients_seed.sql
```

### Typical Workflow

```bash
# 1. Create fresh database
mysql -u root -p -e "CREATE DATABASE lumanitech_erp_clients CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. Apply migrations
for f in migrations/*.sql; do
    [ "$f" = "migrations/TEMPLATE.sql" ] && continue
    mysql -u root -p lumanitech_erp_clients < "$f"
done

# 3. Load seed data
mysql -u root -p lumanitech_erp_clients < seeds/dev/clients_seed.sql
```

## Seed File Guidelines

### DO ✅

- Use `INSERT IGNORE` for idempotency
- Include diverse, realistic test data
- Document what the seed data represents
- Use consistent formatting
- Include data for edge cases
- Make seeds rerunnable

### DON'T ❌

- Include real customer data
- Include sensitive information (passwords, keys, PII)
- Include production data
- Make seeds environment-dependent
- Use absolute values for timestamps (use CURRENT_TIMESTAMP or relative dates)

## Seed File Format

```sql
-- Description of what this seed file provides
-- Safe to run multiple times (uses INSERT IGNORE)

INSERT IGNORE INTO table_name (id, name, status) VALUES
(1, 'Example 1', 'active'),
(2, 'Example 2', 'active'),
(3, 'Example 3', 'inactive');

-- Optionally verify
SELECT COUNT(*) as total FROM table_name;
```

## Current Seed Files

### dev/clients_seed.sql

Provides 8 sample clients covering:
- Different client types (business, individual, government, nonprofit)
- Different countries and regions
- Different statuses (active, inactive)
- Various industries
- Range of credit limits and payment terms

**Sample clients:**
- CLI-001: Acme Corporation (US business)
- CLI-002: TechStart Solutions (US tech company)
- CLI-003: Global Traders Inc (UK retail)
- CLI-004: Green Energy Solutions (FR energy company)
- CLI-005: John Smith Consulting (US individual)
- CLI-006: City Government Services (US government)
- CLI-007: Nonprofit Health Initiative (US nonprofit)
- CLI-008: Inactive Corp (inactive business)

## Creating New Seed Files

1. **Create file in appropriate environment:**
   ```bash
   touch seeds/dev/new_seed.sql
   ```

2. **Use INSERT IGNORE for idempotency:**
   ```sql
   INSERT IGNORE INTO table_name (id, column1, column2) VALUES
   (1, 'value1', 'value2');
   ```

3. **Include verification query:**
   ```sql
   SELECT COUNT(*) FROM table_name;
   ```

4. **Test the seed:**
   ```bash
   mysql -u root -p database_name < seeds/dev/new_seed.sql
   # Run again to verify idempotency
   mysql -u root -p database_name < seeds/dev/new_seed.sql
   ```

## Idempotency Strategies

### Using INSERT IGNORE

```sql
INSERT IGNORE INTO clients (id, client_code, company_name, status)
VALUES (1, 'CLI-001', 'Test Company', 'active');
```

### Using ON DUPLICATE KEY UPDATE

```sql
INSERT INTO clients (id, client_code, company_name, status)
VALUES (1, 'CLI-001', 'Test Company', 'active')
ON DUPLICATE KEY UPDATE status = status;
```

### Using INSERT with NOT EXISTS

```sql
INSERT INTO clients (client_code, company_name, status)
SELECT 'CLI-001', 'Test Company', 'active'
WHERE NOT EXISTS (SELECT 1 FROM clients WHERE client_code = 'CLI-001');
```

## Environment-Specific Considerations

### Development (dev/)

- Diverse test data
- Cover edge cases
- Include enough data for realistic testing
- Can use placeholder/fake data

### Staging (future)

- Production-like volume
- Anonymized production data
- Realistic patterns and distributions

### Test (future)

- Minimal data sets
- Specific test scenarios
- Predictable and consistent

## Data Privacy

**NEVER** include:
- Real customer names, emails, or phone numbers
- Actual tax IDs or government identifiers
- Real payment information
- Production passwords or API keys
- Personal Identifiable Information (PII)

Use:
- Fake but realistic data
- Example.com domain emails
- Placeholder phone numbers (555-xxxx in US)
- Generic company names
- Test tax IDs

## Maintenance

Regularly review and update seed data to:
- Add new test scenarios
- Include examples of new features
- Remove obsolete data
- Ensure data remains realistic
- Update for schema changes
