# Schema Directory

This directory contains the **current state** of the database schema, organized by object type.

## Purpose

The schema files serve as:
- Reference documentation for the current database structure
- Source for creating fresh database instances
- Quick lookup for table/view definitions

⚠️ **Important**: These files are **reference only**. The **source of truth** is the migrations directory. Schema changes must be made through versioned migrations.

## Structure

```
schema/
├── tables/       # Table definitions (CREATE TABLE)
├── views/        # View definitions (CREATE VIEW)
├── procedures/   # Stored procedures
└── functions/    # User-defined functions
```

## Usage

### Creating a Fresh Database

To create a new database from scratch:

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE lumanitech_erp_clients CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Apply tables
for f in schema/tables/*.sql; do
    mysql -u root -p lumanitech_erp_clients < "$f"
done

# Apply views
for f in schema/views/*.sql; do
    mysql -u root -p lumanitech_erp_clients < "$f"
done

# Apply procedures (if any)
for f in schema/procedures/*.sql; do
    mysql -u root -p lumanitech_erp_clients < "$f"
done

# Apply functions (if any)
for f in schema/functions/*.sql; do
    mysql -u root -p lumanitech_erp_clients < "$f"
done
```

### Updating Schema Files

After applying migrations, schema files should be updated to reflect the current state:

```bash
# Export current table structure
mysqldump -u root -p --no-data --skip-add-drop-table lumanitech_erp_clients clients > schema/tables/clients.sql

# Export views
mysqldump -u root -p --no-data --skip-add-drop-table lumanitech_erp_clients active_clients > schema/views/active_clients.sql
```

## Guidelines

- **One file per object**: Each table, view, procedure, or function in its own file
- **Use IF NOT EXISTS**: Make definitions idempotent when possible
- **Include comments**: Document purpose and important fields
- **Keep synchronized**: Update after significant migrations
- **No data**: Schema only, no INSERT statements (use seeds/ for data)

## Files

### tables/

- `schema_migrations.sql` - Migration tracking table
- `clients.sql` - Main clients table

### views/

- `active_clients.sql` - Filtered view of active clients

### procedures/

_None currently defined_

### functions/

_None currently defined_
