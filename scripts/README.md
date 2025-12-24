# Database Scripts

This directory contains scripts for database deployment, validation, and management.

## Scripts Overview

### Deployment Scripts

- **deploy.sh** - Main deployment script (schema + migrations + optional seeds)
- **setup.sh** - Deploy database schema only
- **apply-migrations.sh** - Apply migrations only
- **load-seeds.sh** - Load development seed data only

### Validation Scripts

- **validate.sh** - Run all validation checks
- **validate-migrations.sh** - Validate migration files
- **validate-sql-syntax.sh** - Basic SQL syntax validation

### Utility Scripts

- **mysql-common.sh** - Common MySQL utilities (sourced by other scripts)
- **test-migrations.sh** - Test migrations on temporary database
- **setup_login.sh** - Helper to configure mysql_config_editor login path

## Authentication

### Recommended: Login Path (mysql_config_editor)

The recommended way to authenticate is using `mysql_config_editor`:

```bash
# Configure login path (one-time setup)
mysql_config_editor set --login-path=local \
  --host=localhost \
  --user=admin \
  --password

# Use with scripts
./scripts/deploy.sh --login-path=local
```

**WSL2 local note:**  
Use a login-path configured with user 'admin' (for example:  
`mysql_config_editor set --login-path=local --host=localhost --user=admin --password`).

### Alternative: Command Line Options

```bash
./scripts/deploy.sh --host=localhost --user=admin --password=yourpass
```

## Usage Examples

### Full Deployment

```bash
# Deploy everything (schema + migrations)
./scripts/deploy.sh --login-path=local

# Deploy with seed data
./scripts/deploy.sh --login-path=local --with-seeds
```

### Schema Only

```bash
./scripts/setup.sh --login-path=local
```

### Migrations Only

```bash
./scripts/apply-migrations.sh --login-path=local
```

### Seeds Only

```bash
./scripts/load-seeds.sh --login-path=local
```

### Validation

```bash
# Run all validations
./scripts/validate.sh

# Validate specific components
./scripts/validate-migrations.sh
./scripts/validate-sql-syntax.sh
```

### Testing

```bash
# Test migrations on temporary database
./scripts/test-migrations.sh --login-path=local
```

## Database Configuration

Default values:
- **Database**: lumanitech_erp_clients
- **Host**: localhost
- **User**: admin (on WSL2) or root (on other systems)

Override with command-line options:
```bash
./scripts/deploy.sh --database=mydb --host=192.168.1.100 --user=myuser
```

## Common Options

All deployment scripts support:
- `--host HOST` - MySQL host (default: localhost)
- `--user USER` - MySQL user (default: admin on WSL2, root otherwise)
- `--password PASS` - MySQL password
- `--database DB` - Database name (default: lumanitech_erp_clients)
- `--login-path PATH` - Use mysql_config_editor login path
- `-h, --help` - Show help message

## File Naming Conventions

### Procedures
Files in `schema/procedures/` must follow the pattern: `sp_<name>.sql`

Example: `sp_update_client_status.sql`

### Triggers
Files in `schema/triggers/` must follow the pattern: `trg_<name>.sql`

Example: `trg_audit_client_changes.sql`

## Notes

- All scripts must be run from the project root or with proper paths
- Scripts are designed to be idempotent where possible
- Migration order is important - always run in V### sequence
- Seed data is for development only - never use in production
