# Database Design

## Overview

The lumanitech_erp_clients database is designed to store client and customer master data for the Lumanitech ERP system.

## Design Principles

### 1. Single Responsibility

This database focuses exclusively on client master data:
- Client information
- Contact details
- Business relationships
- Client status and metadata

### 2. Domain Isolation

- One database per ERP module
- No cross-domain foreign keys
- API-based inter-module communication
- Clear ownership boundaries

### 3. Data Integrity

- Primary keys on all tables
- Unique constraints where appropriate
- NOT NULL constraints for required fields
- ENUM types for controlled vocabularies
- Appropriate indexes for performance

### 4. Auditability

- created_at / updated_at timestamps
- created_by / updated_by user tracking
- Migration history in schema_migrations table

## Architecture

### Database Layer

```
lumanitech_erp_clients (MySQL 8.0+)
├── Tables (core data)
├── Views (derived/filtered data)
├── Procedures (business logic)
├── Functions (reusable computations)
└── Triggers (automated actions)
```

### API Layer

This database is accessed exclusively through:
- lumanitech-erp-api-clients

### UI Layer

No direct database access from UI.  
All access through API Gateway → API → Database.

## Table Design

### Normalization

Tables are normalized to 3NF (Third Normal Form):
- Eliminate redundant data
- Ensure data dependencies make sense
- Separate concerns appropriately

### Denormalization (Where Justified)

Some calculated/derived columns may be denormalized for:
- Performance optimization
- Simplified queries
- Reduced join complexity

Document justification in table comments.

## Data Types

### Standard Types Used

- **INT**: Integer identifiers, counts
- **VARCHAR**: Variable-length strings (names, codes, emails)
- **TEXT**: Long text content
- **DECIMAL**: Monetary values, precise numbers
- **TIMESTAMP**: Dates and times
- **ENUM**: Controlled vocabularies
- **BOOLEAN**: True/false flags

### Conventions

- UTF-8 encoding (utf8mb4)
- Case-insensitive collation (utf8mb4_unicode_ci)
- InnoDB storage engine
- Auto-increment primary keys

## Indexing Strategy

### Index Types

1. **Primary Key**: Unique identifier (automatic)
2. **Unique Index**: Enforce uniqueness (e.g., client_code)
3. **Regular Index**: Speed up lookups (e.g., email, status)
4. **Composite Index**: Multi-column queries (when needed)

### Index Naming

- Primary key: No explicit name needed
- Unique index: Use column name
- Regular index: `idx_tablename_columnname`
- Composite: `idx_tablename_col1_col2`

## Character Set and Collation

- **Character Set**: utf8mb4 (full Unicode support)
- **Collation**: utf8mb4_unicode_ci (case-insensitive)
- **Why**: Support international characters, emoji, and special symbols

## Storage Engine

- **Engine**: InnoDB
- **Why**: ACID compliance, foreign key support, row-level locking, crash recovery

## Constraints

### Primary Keys

- Every table has a primary key
- Usually auto-increment INT
- Single-column preferred

### Foreign Keys

- Currently none (domain isolation)
- Future: May add within-database relationships
- Never cross-database

### Unique Constraints

- client_code (unique business key)
- Other business-unique values

### Check Constraints

- Using ENUM for controlled values
- Additional CHECK constraints as needed

## Security Considerations

### Data Protection

- No sensitive data in plain text
- Use application-layer encryption for sensitive fields
- Regular backups with encryption
- Access control via database users

### SQL Injection Prevention

- Always use parameterized queries in application
- Never construct SQL from user input
- Validate and sanitize all inputs

## Performance Optimization

### Query Optimization

- Appropriate indexes
- Avoid SELECT *
- Use EXPLAIN to analyze queries
- Optimize JOIN operations

### Table Optimization

- Regular ANALYZE TABLE
- Monitor table sizes
- Archive old data
- Partition large tables if needed

## Scalability

### Vertical Scaling

- Increase server resources
- Optimize queries and indexes
- Use connection pooling

### Horizontal Scaling

- Read replicas for read-heavy workloads
- Sharding (if needed in future)
- Caching layer (Redis/Memcached)

## Backup and Recovery

### Backup Strategy

- Daily full backups
- Point-in-time recovery capability
- Test restore procedures regularly
- Store backups securely off-site

### Disaster Recovery

- Documented recovery procedures
- Regular recovery drills
- RPO/RTO objectives defined
- Failover procedures

## Monitoring

### Key Metrics

- Query performance
- Table sizes and growth
- Index usage
- Connection pool status
- Replication lag (if applicable)

### Alerts

- Slow queries
- Failed backups
- Disk space warnings
- Connection limit approaching

## Future Enhancements

Potential future additions:

- Client contacts table
- Multiple addresses per client
- Client categories/tags
- Client documents and attachments
- Audit trail/change history
- Client relationships (parent/child companies)
- Custom fields support

## See Also

- [schema.md](schema.md) - Current schema documentation
- [DATA_DICTIONARY.md](DATA_DICTIONARY.md) - Detailed data dictionary
- [ERD.md](ERD.md) - Entity relationship diagrams
- [migration-strategy.md](migration-strategy.md) - Migration guidelines
