# Migration Strategy

## Overview

This repository implements a **forward-only migration strategy** for database schema management. This approach ensures consistency, traceability, and safety across all environments.

## Core Principles

### 1. Forward-Only Migrations

**Never modify or delete existing migrations.** Once a migration file is committed to the repository, it is immutable.

**Why?**
- Different environments may be at different migration states
- Modifying existing migrations can cause checksum mismatches
- Historical record of all schema changes is preserved
- Prevents accidental data loss

### 2. Versioned Sequential Naming

All migrations follow this naming convention:
```
V###_description.sql
```

**Components:**
- `V###`: Version number with leading zeros (V001, V002, V003, etc.)
- `description`: Brief, lowercase, snake_case description of the change

**Examples:**
- `V001_create_clients_table.sql`
- `V002_add_email_index_to_clients.sql`
- `V003_alter_clients_add_status_column.sql`

### 3. Idempotency

Migrations should be idempotent whenever possible, meaning they can be safely run multiple times without causing errors or unintended side effects.

**Techniques:**
```sql
-- Tables
CREATE TABLE IF NOT EXISTS table_name (...);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_name ON table_name(column);

-- Columns (check before adding)
ALTER TABLE table_name 
ADD COLUMN IF NOT EXISTS column_name VARCHAR(255);

-- For MySQL < 8.0.29, use procedural approach:
DELIMITER $$
CREATE PROCEDURE add_column_if_not_exists()
BEGIN
  IF NOT EXISTS (
    SELECT * FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'table_name' 
    AND COLUMN_NAME = 'column_name'
  ) THEN
    ALTER TABLE table_name ADD COLUMN column_name VARCHAR(255);
  END IF;
END$$
DELIMITER ;
CALL add_column_if_not_exists();
DROP PROCEDURE add_column_if_not_exists;
```

### 4. Self-Tracking

Each migration records itself in the `schema_migrations` table:

```sql
INSERT INTO schema_migrations (version, description) 
VALUES ('V001', 'create_clients_table')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
```

### 5. Rollback via Forward Migration

To undo changes, create a new migration that reverses the previous one:

```sql
-- Original: V004_add_notes_column.sql
ALTER TABLE clients ADD COLUMN notes TEXT;

-- Rollback: V005_remove_notes_column.sql
ALTER TABLE clients DROP COLUMN IF EXISTS notes;
```

## Migration Workflow

### Creating a New Migration

1. **Determine next version number:**
   ```bash
   # List existing migrations to see the latest version
   ls migrations/V*.sql | sort | tail -1
   ```

2. **Create migration file:**
   ```bash
   touch migrations/V004_your_description.sql
   ```

3. **Write migration with standard header:**
   ```sql
   -- Migration: V004_your_description
   -- Description: Detailed description of what this migration does
   -- Author: Your Name
   -- Date: 2023-12-15
   
   -- Your SQL here
   CREATE TABLE IF NOT EXISTS ...;
   
   -- Record this migration
   INSERT INTO schema_migrations (version, description) 
   VALUES ('V004', 'your_description')
   ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
   
   -- Rollback instructions (for reference only):
   -- DROP TABLE IF EXISTS ...;
   -- DELETE FROM schema_migrations WHERE version = 'V004';
   ```

4. **Test locally:**
   ```bash
   mysql -u root -p database_name < migrations/V004_your_description.sql
   ```

5. **Validate:**
   ```bash
   ./scripts/validate.sh
   ```

6. **Commit and push:**
   ```bash
   git add migrations/V004_your_description.sql
   git commit -m "Add migration: your_description"
   git push
   ```

### Migration Execution

Migrations are executed by the API service during deployment:

1. API connects to database
2. Checks `schema_migrations` table for applied migrations
3. Identifies unapplied migrations (sorted alphabetically/chronologically)
4. Executes each migration in order
5. Records successful migrations in `schema_migrations`
6. Reports any failures

### Manual Execution (Development)

For local testing:

```bash
# Apply all pending migrations
for f in migrations/*.sql; do
    echo "Applying $f"
    mysql -u root -p database_name < "$f"
done

# Apply specific migration
mysql -u root -p database_name < migrations/20231215143000_your_description.sql

# Check applied migrations
mysql -u root -p database_name -e "SELECT * FROM schema_migrations ORDER BY version;"
```

## Best Practices

### DO ✅

- **Use descriptive names**: `add_client_email_index` not `update_clients`
- **Keep migrations small**: One logical change per migration
- **Test on production-like data**: Use anonymized production dumps
- **Include rollback comments**: Document how to reverse the change
- **Use transactions when possible**:
  ```sql
  START TRANSACTION;
  -- Your changes
  COMMIT;
  ```
- **Add comments**: Explain complex logic or business rules
- **Check for existence**: Use `IF NOT EXISTS` / `IF EXISTS`
- **Handle dependencies**: Ensure referenced tables/columns exist

### DON'T ❌

- **Never modify existing migrations**: Create new ones instead
- **Never delete migrations**: They are historical records
- **Avoid breaking changes without coordination**: 
  - Renaming columns (use new column + deprecation period)
  - Changing data types incompatibly
  - Dropping tables with data
- **Don't commit sensitive data**: No passwords, API keys, or real user data
- **Don't use database-specific features unnecessarily**: Stick to standard SQL when possible
- **Avoid long-running migrations in production**: Split into smaller chunks

## Common Patterns

### Adding a Column

```sql
-- Migration: V004_add_email_verified_to_clients.sql
ALTER TABLE clients 
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE 
COMMENT 'Whether email address has been verified';

INSERT INTO schema_migrations (version, description) 
VALUES ('V004', 'add_email_verified_to_clients')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
```

### Adding an Index

```sql
-- Migration: V005_add_email_index_to_clients.sql
CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);

INSERT INTO schema_migrations (version, description) 
VALUES ('V005', 'add_email_index_to_clients')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
```

### Modifying Column (Safe Pattern)

```sql
-- Migration: V006_extend_client_code_length.sql
-- Extending VARCHAR is generally safe (does not require table rebuild in MySQL 5.7+)
ALTER TABLE clients 
MODIFY COLUMN client_code VARCHAR(100) NOT NULL COMMENT 'Unique client code/reference';

INSERT INTO schema_migrations (version, description) 
VALUES ('V006', 'extend_client_code_length')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
```

### Data Migration

```sql
-- Migration: V007_populate_client_type_from_legacy.sql
-- Migrate data from old system
UPDATE clients 
SET client_type = 'business' 
WHERE client_type IS NULL AND tax_id IS NOT NULL;

UPDATE clients 
SET client_type = 'individual' 
WHERE client_type IS NULL AND tax_id IS NULL;

INSERT INTO schema_migrations (version, description) 
VALUES ('V007', 'populate_client_type_from_legacy')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
```

### Creating a View

```sql
-- Migration: V008_create_active_clients_view.sql
CREATE OR REPLACE VIEW active_clients AS
SELECT id, client_code, company_name, email, status
FROM clients
WHERE status = 'active';

INSERT INTO schema_migrations (version, description) 
VALUES ('V008', 'create_active_clients_view')
ON DUPLICATE KEY UPDATE applied_at = CURRENT_TIMESTAMP;
```

## Handling Failures

### If a Migration Fails in Development

1. Fix the issue in the migration file (only if not yet committed)
2. Drop the partially applied changes manually
3. Re-run the migration
4. Test thoroughly

### If a Migration Fails in Production

1. **Immediate response:**
   - Check `schema_migrations` to see what was applied
   - Assess impact on application
   - Determine if rollback is needed

2. **Rollback options:**
   - Create a new migration that reverses the change
   - Apply manually if urgent (document in migration later)

3. **Post-incident:**
   - Create migration documenting manual changes
   - Update migration to be more robust
   - Add better error handling

## Migration Review Checklist

Before merging a migration:

- [ ] Timestamp is correct and unique
- [ ] Description is clear and accurate
- [ ] Migration is idempotent (when possible)
- [ ] Tested on local development database
- [ ] Tested on database with existing data
- [ ] Self-tracking INSERT statement included
- [ ] Rollback instructions documented in comments
- [ ] No sensitive data included
- [ ] Passes `./scripts/validate.sh`
- [ ] Breaking changes are coordinated with API team
- [ ] Performance impact considered for large tables

## FAQ

### Q: Can I modify a migration after it's been merged?

**A: No.** Once merged, migrations are immutable. Create a new migration to make changes.

### Q: How do I handle merge conflicts in migration version numbers?

**A: Renumber your migration** to be the next available version, rename your file, update the version in the SQL, and resolve the conflict.

### Q: What if I need to rollback a migration?

**A: Create a new migration** that reverses the changes. Document it clearly.

### Q: Can migrations contain data?

**A: Yes,** for reference data, configuration, or data migrations. Never include sensitive or user-specific data.

### Q: How do I test migrations with large datasets?

**A: Use anonymized production dumps** in a staging environment. Test for performance and correctness.

### Q: What about schema.sql files?

**A: They are reference only** showing current state. Migrations are the source of truth. Don't modify schema files directly.

## Version Control

- All migrations must be committed to version control
- Never commit directly to main/master
- Create feature branch for new migrations
- Require pull request review before merging
- Tag releases with applied migrations

## References

- [MySQL ALTER TABLE Documentation](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)
- [MySQL Data Types](https://dev.mysql.com/doc/refman/8.0/en/data-types.html)
- [Database Migration Best Practices](https://www.liquibase.org/get-started/best-practices)
