# Quick Start Guide

This guide will help you set up and deploy the lumanitech_erp_clients database.

## Prerequisites

- MySQL 8.0+
- Bash shell (Linux, macOS, or WSL2 on Windows)
- Git

## Quick Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd lumanitech-erp-db-clients
```

### 2. Secure Authentication Setup

**Option A: Using mysql_config_editor (Recommended)**

```bash
# Configure login path
mysql_config_editor set --login-path=local \
  --host=localhost \
  --user=admin \
  --password
```

**WSL2 local note:**  
Use a login-path configured with user 'admin'.  
Example:  
```bash
mysql_config_editor set --login-path=local --host=localhost --user=admin --password
```

**Option B: Using Command Line**

You can pass credentials directly (less secure):

```bash
./scripts/deploy.sh --host=localhost --user=admin --password=yourpass
```

### 3. Deploy Database

```bash
# Full deployment (schema + migrations)
./scripts/deploy.sh --login-path=local

# With development seed data
./scripts/deploy.sh --login-path=local --with-seeds
```

## Step-by-Step Deployment

### Deploy Schema Only

```bash
./scripts/setup.sh --login-path=local
```

This creates the database and deploys:
- Tables
- Views
- Stored procedures
- Functions
- Triggers
- Indexes

### Apply Migrations

```bash
./scripts/apply-migrations.sh --login-path=local
```

### Load Seed Data (Development Only)

```bash
./scripts/load-seeds.sh --login-path=local
```

## Validation

Validate the database setup:

```bash
./scripts/validate.sh
```

## Verify Deployment

```bash
mysql --login-path=local lumanitech_erp_clients -e "SHOW TABLES;"
mysql --login-path=local lumanitech_erp_clients -e "SELECT * FROM schema_migrations;"
```

## Common Issues

### Connection Failed

- Verify MySQL is running
- Check credentials
- Ensure user has proper permissions

### Permission Denied on Scripts

```bash
chmod +x scripts/*.sh
```

### Migration Already Applied

Migrations are idempotent - safe to run multiple times.

## Next Steps

- Review [schema.md](schema.md) for database structure
- Read [migration-strategy.md](migration-strategy.md) for development guidelines
- See [DATA_DICTIONARY.md](DATA_DICTIONARY.md) for detailed column information

## Support

For issues or questions, consult the main [README.md](../README.md) or contact the database team.
