# Migrations Directory

This directory contains **versioned SQL migration scripts** that define the evolution of the database schema over time.

## Purpose

Migrations are the **source of truth** for database schema changes. They:
- Track all schema changes chronologically
- Enable reproducible database setup across environments
- Provide audit trail of schema evolution
- Support forward-only migration strategy

## Naming Convention

All migration files follow this pattern:

```
V###_description.sql
```

**Components:**
- `V###`: Version number with leading zeros (V001, V002, V003, etc.)
- `description`: Brief, lowercase, snake_case description
- `.sql`: SQL file extension

**Examples:**
- `V001_create_schema_migrations_table.sql`
- `V002_create_clients_table.sql`
- `V003_create_active_clients_view.sql`

## Migration Template

Use `TEMPLATE.sql` as a starting point for new migrations. The template includes:
- Standard header with metadata
- Placeholder SQL
- Self-tracking INSERT statement
- Rollback instructions in comments

## Creating a Migration

1. **Determine next version number:**
   ```bash
   # List existing migrations to see the latest version
   ls migrations/V*.sql | sort | tail -1
   ```

2. **Copy template:**
   ```bash
   cp migrations/TEMPLATE.sql migrations/V004_your_description.sql
   ```

3. **Edit migration:**
   - Update header (version, description, author, date)
   - Write your SQL changes
   - Update self-tracking INSERT with correct version/description
   - Document rollback instructions

4. **Test locally:**
   ```bash
   mysql -u root -p database_name < migrations/V004_your_description.sql
   ```

5. **Validate:**
   ```bash
   ./scripts/validate.sh
   ```

## Migration Rules

### DO ✅

- Create new migrations for all schema changes
- Use idempotent SQL (IF NOT EXISTS, IF EXISTS)
- Include rollback instructions in comments
- Test on local database before committing
- Keep migrations small and focused
- Document complex changes

### DON'T ❌

- Modify existing migrations after they're committed
- Delete migrations
- Include sensitive data
- Make breaking changes without coordination
- Skip the validation script

## Migration Execution

Migrations are executed by the API service during deployment. The service:

1. Connects to the database
2. Checks `schema_migrations` table
3. Identifies unapplied migrations
4. Executes them in chronological order (alphabetically by filename)
5. Records successful migrations in `schema_migrations`

### Manual Execution

For local development or testing:

```bash
# Apply all migrations
for f in migrations/*.sql; do
    [ "$f" = "migrations/TEMPLATE.sql" ] && continue
    echo "Applying $f"
    mysql -u root -p database_name < "$f"
done

# Apply specific migration
mysql -u root -p database_name < migrations/20231215143000_your_description.sql

# Check applied migrations
mysql -u root -p database_name -e "SELECT version, description, applied_at FROM schema_migrations ORDER BY version;"
```

## Migration Patterns

### Creating a Table

```sql
CREATE TABLE IF NOT EXISTS table_name (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Adding a Column

```sql
ALTER TABLE table_name 
ADD COLUMN IF NOT EXISTS column_name VARCHAR(255) NULL COMMENT 'Description';
```

### Creating an Index

```sql
CREATE INDEX IF NOT EXISTS idx_column_name ON table_name(column_name);
```

### Creating a View

```sql
CREATE OR REPLACE VIEW view_name AS
SELECT id, name FROM table_name WHERE active = 1;
```

## Rollback Strategy

To undo a migration, **create a new migration** that reverses the change:

```sql
-- Original migration: V004_add_notes_column.sql
ALTER TABLE clients ADD COLUMN notes TEXT;

-- Rollback migration: V005_remove_notes_column.sql
ALTER TABLE clients DROP COLUMN IF EXISTS notes;
```

## Troubleshooting

### Migration Failed Halfway

1. Check `schema_migrations` to see if it was recorded
2. Manually verify which changes were applied
3. Fix issues manually or create corrective migration
4. Document any manual changes in a new migration

### Duplicate Version Numbers

If two developers create migrations at the same time:

1. One developer regenerates timestamp for their migration
2. Rename file and update version in SQL
3. Resolve merge conflict
4. Both migrations will apply in new order

## Current Migrations

This directory contains:

1. `TEMPLATE.sql` - Template for new migrations (not executed)
2. `V001_create_schema_migrations_table.sql` - Migration tracking
3. `V002_create_clients_table.sql` - Main clients table
4. `V003_create_active_clients_view.sql` - Active clients view

For detailed migration strategy, see `docs/migration-strategy.md`.
