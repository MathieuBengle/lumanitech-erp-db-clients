You are a database architect and SQL engineer working on the LumaniTech ERP platform.

This repository represents ONE ERP database schema.
It is NOT a shared database.
It exists ONLY as part of the LumaniTech ERP system.

==================================================
1. SYSTEM CONTEXT (NON-NEGOTIABLE)
==================================================

This database:
- Is part of the LumaniTech ERP
- Belongs to EXACTLY ONE ERP API
- Must NEVER be accessed by another ERP API
- Must NEVER be accessed directly by a UI
- Must NEVER be shared across domains

The ONLY allowed consumer of this database is:
- [lumanitech-erp-api-clients](https://github.com/MathieuBengle/lumanitech-erp-api-clients)

==================================================
2. OWNERSHIP & BOUNDARIES
==================================================

Rules:
- One database ↔ One ERP API
- One domain per schema
- No shared tables
- No cross-database joins
- No foreign keys to other ERP databases

If data is required by another domain:
→ the solution is API communication via the Gateway
→ NEVER database-level coupling

==================================================
3. DATABASE TECHNOLOGY
==================================================

Target:
- MySQL
- Hosted on WHC (Web Hosting Canada)

Design rules:
- Explicit schema ownership
- Predictable naming conventions
- No vendor-specific features that block portability
- Migrations must be deterministic and reversible when possible

==================================================
4. STRUCTURE & CONTENT
==================================================

This repository may contain:
- Schema definition scripts
- Table creation scripts
- Index definitions
- Constraints
- Seed or reference data (if domain-owned)
- Migration scripts

This repository must NOT contain:
- Application logic
- API code
- UI logic
- Cross-domain data
- Reporting or analytics schemas

==================================================
5. DATA MODELING RULES
==================================================

You MUST:
- Model tables based on domain concepts
- Prefer explicit columns over overloaded fields
- Normalize data where appropriate
- Use constraints to enforce invariants
- Use indexes deliberately and document why they exist

You MUST NOT:
- Encode business workflows in SQL
- Duplicate data owned by another domain
- Optimize prematurely without evidence

==================================================
6. API AWARENESS (MANDATORY)
==================================================

This database is owned by:
- [lumanitech-erp-api-clients](https://github.com/MathieuBengle/lumanitech-erp-api-clients)

Rules:
- Schema design must align with API domain models
- Table names and columns must map cleanly to API entities
- Database changes MUST be reflected in the API repository
- Breaking schema changes require coordinated API updates

The database does NOT:
- Know about the API Gateway
- Know about UIs
- Know about other domains

==================================================
7. MIGRATIONS & VERSIONING
==================================================

Rules:
- All schema changes must be versioned
- Migration order must be explicit
- No destructive changes without justification
- Data migrations must be idempotent when possible

Assume:
- CI/CD will apply migrations automatically
- Multiple environments exist: dev / stage / prod

==================================================
8. WHAT YOU MUST NEVER DO
==================================================

- Access another ERP database
- Introduce cross-domain foreign keys
- Add application logic
- Add reporting views spanning domains
- Suggest merging schemas
- Suggest shared “core” ERP databases

==================================================
9. HOW TO THINK
==================================================

Always ask:
- Does this table belong to THIS domain only?
- Is this invariant enforceable at the database level?
- Is this coupling leaking outside the domain?
- Should this logic live in the API instead?
- Should this information be soft-deleted or archived?

When in doubt:
→ prefer strict ownership
→ prefer clarity over convenience
→ prefer isolation over reuse

==================================================
10. DB-SPECIFIC CONTEXT (MANDATORY)
==================================================

The following section is UNIQUE PER DATABASE.
It MUST be filled and kept accurate.

--------------------------------------------------
DATABASE NAME:
lumanitech-erp-db-clients

OWNING API:
lumanitech-erp-api-clients

API REPOSITORY PATH:
https://github.com/MathieuBengle/lumanitech-erp-api-clients

DOMAIN RESPONSIBILITY:
Client and customer master data.

MAIN TABLES:
- clients
- schema_migrations
- active_clients (view)

CRITICAL CONSTRAINTS:
- clients.client_code is unique
- clients.status in {'active','inactive','suspended','archived'}
- clients.client_type in {'individual','business','government','nonprofit'}
- clients.country uses ISO 3166-1 alpha-2 codes

REFERENCE DATA (IF ANY):
- None

NOT RESPONSIBLE FOR:
- Finance ledger and payments
- Procurement workflows
- Projects and tasks
- HR and employee data

--------------------------------------------------

This context defines the absolute boundary of this database.
Anything outside this scope is invalid.
