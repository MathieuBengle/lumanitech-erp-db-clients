# Lumanitech ERP - Clients Database

This repository contains the MySQL database schema, migrations, and seed data for the Clients module of the Lumanitech ERP system.

## Overview

This is a **SQL-only repository** containing database definitions and migration scripts. No application code is included here.

## Ownership

This database is **owned and managed by the Clients API**. The API service is responsible for:
- Executing migrations during deployment
- Managing database schema changes
- Ensuring data integrity and consistency

⚠️ **Important**: Direct database modifications outside of the migration system are not permitted. All schema changes must be made through versioned migration scripts.

## Repository Structure

```
.
├── schema/              # Current database schema (DDL)
│   ├── tables/         # Table definitions
│   ├── views/          # View definitions
│   ├── procedures/     # Stored procedures
│   └── functions/      # User-defined functions
├── migrations/         # Versioned migration scripts
│   └── YYYYMMDDHHMMSS_description.sql
├── seeds/              # Seed data for development/testing
│   └── dev/           # Development seed data
├── docs/               # Documentation
│   └── migration-strategy.md
└── scripts/            # CI/CD validation scripts
    └── validate.sh
```

## Migration Strategy

This repository follows a **forward-only migration** strategy:

### Principles

1. **Never modify existing migrations** - Once a migration is committed, it should never be changed
2. **Always create new migrations** - To fix issues, create a new migration that corrects the problem
3. **Sequential versioning** - Migrations are named with timestamp: `YYYYMMDDHHMMSS_description.sql`
4. **Idempotent when possible** - Migrations should check for existence before creating objects
5. **Rollback via new migrations** - To undo changes, create a new migration that reverses them

### Migration Naming Convention

```
YYYYMMDDHHMMSS_description.sql
```

Examples:
- `20231215143000_create_clients_table.sql`
- `20231215150000_add_email_index_to_clients.sql`
- `20231216090000_alter_clients_add_status_column.sql`

### Creating a Migration

1. Generate timestamp: `date +%Y%m%d%H%M%S`
2. Create file: `migrations/YYYYMMDDHHMMSS_your_description.sql`
3. Write SQL with proper guards:

```sql
-- Migration: YYYYMMDDHHMMSS_your_description
-- Description: Brief description of what this migration does
-- Author: Your Name
-- Date: YYYY-MM-DD

-- Check if change already applied (idempotent when possible)
CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

4. Test locally
5. Commit and push

### Migration Execution Order

Migrations are executed in alphabetical order (timestamp ensures chronological order).
The API service tracks which migrations have been applied using a `schema_migrations` table.

## Seed Data

The `seeds/` directory contains SQL scripts to populate the database with initial or test data:

- `seeds/dev/` - Development environment data
- Use seed data for local development and testing
- Seed scripts should be idempotent (safe to run multiple times)

## CI/CD Validation

The `scripts/validate.sh` script validates SQL syntax and migration naming conventions.
This script runs automatically in CI/CD pipelines before merging.

### Running Validation Locally

```bash
./scripts/validate.sh
```

## Getting Started

### Prerequisites

- MySQL 8.0+
- Access to the target database environment

### Local Development

1. Clone this repository:
```bash
git clone <repository-url>
cd lumanitech-erp-db-clients
```

2. Make the deployment script executable (required once):
```bash
chmod +x ./scripts/deploy.sh
```

3. Store credentials with mysql_config_editor (the script defaults to login-path `local` / user `admin`):
```bash
mysql_config_editor set --login-path=local \
    --host=localhost \
    --user=admin \
    --password
```

4. Deploy schema, migrations, and maintenance seeds:
```bash
./scripts/deploy.sh --login-path=local --with-seeds
```

The new deployment script installs the schema (tables, views, procedures, functions), applies every versioned migration under `migrations/`, and conditionally loads `seeds/dev/`. It prints the login path (or reports that it will prompt for a password) so you always know which credentials are in use.

## Contributing

### Making Schema Changes

1. Create a new migration file with timestamp
2. Write idempotent SQL when possible
3. Test migration locally
4. Run validation: `./scripts/validate.sh`
5. Commit and create pull request
6. Ensure CI checks pass

### Best Practices

- ✅ Use `IF NOT EXISTS` / `IF EXISTS` for idempotency
- ✅ Include rollback instructions in migration comments
- ✅ Test migrations on a copy of production data
- ✅ Keep migrations small and focused
- ✅ Document complex changes
- ❌ Never modify existing migrations
- ❌ Never commit sensitive data or credentials
- ❌ Avoid breaking changes without coordination

## Support

For questions or issues:
- Create an issue in this repository
- Contact the Clients API team
- See `docs/` for additional documentation

## License

Internal use only - Lumanitech ERP System
