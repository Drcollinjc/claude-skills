# Data Modeling Skill v1.0.0

## Purpose
Domain-specific data modeling best practices and validation for analytical, transactional, and streaming applications.

## Application Type Detection

Automatically detect application type from feature specification keywords:

### Analytical Applications
**Keywords**: analytics, metrics, reporting, dashboard, BI, data warehouse, medallion, lakehouse, aggregation, OLAP, dimensional model, star schema, fact table, dimension table

**Primary Concerns**: Query performance, denormalization, aggregation patterns, grain consistency

**Validation Focus**: Star schema structure, slowly changing dimensions, partitioning strategy, fact/dimension separation

### Transactional Applications
**Keywords**: CRUD, application backend, API, microservice, REST, user management, OLTP, normalized, relational, foreign key

**Primary Concerns**: Write performance, referential integrity, ACID compliance, data consistency

**Validation Focus**: Normal forms (3NF), foreign key constraints, cascading rules, audit trails

### Streaming Applications
**Keywords**: real-time, event, stream, Kafka, Kinesis, CDC, event-driven, pub/sub, message queue, event sourcing

**Primary Concerns**: Throughput, idempotency, late arrival handling, schema evolution

**Validation Focus**: Event schemas, idempotency keys, versioning, immutability

## Detection Logic

```python
def detect_application_type(spec_text):
    """
    Detect primary data modeling domain from spec
    Returns: ("analytical" | "transactional" | "streaming" | "hybrid")
    """
    spec_lower = spec_text.lower()

    analytical_score = sum(1 for kw in [
        "analytics", "metrics", "reporting", "dashboard", "bi",
        "data warehouse", "medallion", "lakehouse", "aggregation",
        "olap", "dimensional", "star schema", "fact table"
    ] if kw in spec_lower)

    transactional_score = sum(1 for kw in [
        "crud", "api", "microservice", "rest", "oltp",
        "normalized", "relational", "foreign key"
    ] if kw in spec_lower)

    streaming_score = sum(1 for kw in [
        "real-time", "event", "stream", "kafka", "kinesis",
        "cdc", "event-driven", "pub/sub", "event sourcing"
    ] if kw in spec_lower)

    scores = {
        "analytical": analytical_score,
        "transactional": transactional_score,
        "streaming": streaming_score
    }

    primary = max(scores, key=scores.get)
    is_hybrid = sum(1 for s in scores.values() if s > 2) > 1

    return (primary, is_hybrid, scores)
```

## Best Practices by Domain

### Analytical Data Models

**Pattern**: Star Schema / Medallion Architecture

**Principles**:
1. **Denormalize for reads**: Minimize joins in analytical queries
2. **Grain consistency**: Every fact table has clear grain (one row = one business event)
3. **Slowly Changing Dimensions (SCD)**: Track historical changes
4. **Partitioning**: Partition by time for query pruning
5. **Separate facts from dimensions**: Clear distinction between measures and attributes

**Validation Checklist**:
- [ ] All fact tables have documented grain statements
- [ ] Dimension tables identified and separated
- [ ] Foreign keys to dimensions defined (even if not enforced)
- [ ] Partitioning strategy specified
- [ ] No many-to-many without bridge tables
- [ ] Time dimension present (or justification for absence)
- [ ] Wide tables (<50 columns threshold)

**Naming Conventions**:
- Fact tables: `fct_` prefix (e.g., `fct_sales`, `fct_usage`)
- Dimension tables: `dim_` prefix (e.g., `dim_customer`, `dim_product`)
- Staging tables: `stg_` prefix (e.g., `stg_raw_events`)
- Bridge tables: `bridge_` prefix (e.g., `bridge_product_category`)

**Common Patterns**:

**Slowly Changing Dimension (Type 2)**:
```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,        -- Surrogate key
    customer_id TEXT NOT NULL,              -- Natural key
    customer_name VARCHAR NOT NULL,
    segment VARCHAR,
    valid_from DATE NOT NULL,               -- SCD tracking
    valid_to DATE,                          -- NULL = current
    is_current BOOLEAN DEFAULT TRUE,
    UNIQUE (customer_id, valid_from)
);
```

**Fact Table with Grain**:
```sql
-- Grain: One row per customer per fiscal quarter
CREATE TABLE fct_customer_quarterly_metrics (
    metric_id VARCHAR PRIMARY KEY,          -- Surrogate key
    customer_id TEXT NOT NULL,
    quarter VARCHAR NOT NULL,               -- Q1-2025
    quarterly_revenue DECIMAL(18,2),
    won_deals INTEGER,
    active_users INTEGER,
    UNIQUE (customer_id, quarter)
);
```

**Anti-Patterns**:
- ❌ Normalized schemas (OLTP patterns in OLAP database)
- ❌ Undefined grain (mixing transaction and summary rows)
- ❌ Missing time dimension
- ❌ Excessive table width (>100 columns without justification)

### Transactional Data Models

**Pattern**: Normalized Schema (3NF)

**Principles**:
1. **3rd Normal Form (3NF)**: Minimize redundancy
2. **Strong referential integrity**: Foreign keys with CASCADE rules
3. **Single source of truth**: Each entity has one canonical table
4. **Audit trails**: created_at, updated_at, updated_by on all tables
5. **Soft deletes**: deleted_at instead of hard deletes

**Validation Checklist**:
- [ ] All foreign keys defined with ON DELETE/ON UPDATE rules
- [ ] No duplicate data across tables
- [ ] Primary keys on all tables
- [ ] Unique constraints on natural keys
- [ ] Indexes on foreign keys
- [ ] Audit columns present (created_at, updated_at)
- [ ] Soft delete pattern for important entities

**Naming Conventions**:
- Tables: Plural nouns (`customers`, `orders`, `products`)
- Primary keys: `{table_singular}_id` (e.g., `customer_id`)
- Foreign keys: Match referenced PK name
- Boolean columns: `is_` or `has_` prefix (`is_active`, `has_subscription`)
- Timestamps: `_at` suffix (`created_at`, `deleted_at`)
- Junction tables: Combine table names (`users_roles`, `orders_products`)

**Common Patterns**:

**Base Entity with Audit**:
```sql
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'suspended', 'deleted')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL                    -- Soft delete
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_status ON customers(status) WHERE deleted_at IS NULL;
```

**Foreign Key with Cascade**:
```sql
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_amount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

**Anti-Patterns**:
- ❌ Denormalized schemas (update anomalies)
- ❌ Missing foreign keys (orphaned records)
- ❌ NULL-heavy schemas (use defaults or separate tables)
- ❌ JSON columns for queryable data (normalize or use JSONB with indexes)

### Streaming Data Models

**Pattern**: Event Sourcing / Immutable Events

**Principles**:
1. **Immutable events**: Never update, only append
2. **Self-contained messages**: Include all context
3. **Schema evolution**: Forward/backward compatibility
4. **Idempotency keys**: Enable exactly-once processing
5. **Event versioning**: Track schema version in payload

**Validation Checklist**:
- [ ] Event schema includes event_id, event_type, event_timestamp, schema_version
- [ ] Idempotency keys defined for critical events
- [ ] Schema evolution strategy documented
- [ ] Event ordering requirements specified
- [ ] Late arrival handling strategy defined
- [ ] No update semantics (append-only)

**Naming Conventions**:
- Event types: Past tense verbs (`OrderPlaced`, `PaymentProcessed`)
- Event fields: Include full context (`order_id`, `customer_id`, `amount`)
- Timestamps: ISO 8601 format with timezone
- Versions: Semantic versioning (`1.0.0`, `1.1.0`)

**Common Patterns**:

**Event Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "OrderPlaced",
  "event_timestamp": "2025-01-15T10:30:00Z",
  "schema_version": "1.0.0",
  "aggregate_id": "order-123",
  "idempotency_key": "unique-operation-id",
  "payload": {
    "order_id": "order-123",
    "customer_id": "cust-456",
    "items": [...],
    "total_amount": 99.99
  },
  "metadata": {
    "source": "web-app",
    "user_id": "user-789"
  }
}
```

**Event Store Table**:
```sql
CREATE TABLE event_store (
    event_id UUID PRIMARY KEY,
    aggregate_id UUID NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    event_version INT NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    idempotency_key VARCHAR(255) UNIQUE,
    INDEX idx_aggregate (aggregate_id, occurred_at),
    INDEX idx_idempotency (idempotency_key)
);
```

**Anti-Patterns**:
- ❌ Mutable events (UPDATE semantics)
- ❌ Events requiring joins to understand
- ❌ Undocumented schema changes
- ❌ Missing idempotency keys

## Data Source Discovery

### Source Types

**CSV Files**:
- Parse first row for headers
- Infer types from sample (100 rows)
- Detect naming convention (camelCase vs snake_case)
- Count rows for volume estimation

**SQL Schema Files**:
- Parse CREATE TABLE statements
- Extract column names, types, constraints
- Identify primary/foreign keys
- Document relationships

**ORM Models** (Python SQLAlchemy, Django):
- Parse class definitions
- Extract field definitions
- Identify relationships (ForeignKey, ManyToMany)
- Map ORM types to SQL types

**Database Connection**:
- Query information_schema
- Extract complete schema metadata
- Validate constraints
- Check indexes

### Naming Convention Detection

```python
def detect_naming_convention(column_names):
    """
    Detect camelCase vs snake_case
    Returns: ("camelCase" | "snake_case" | "mixed")
    """
    camel_count = sum(1 for col in column_names if any(c.isupper() for c in col[1:]))
    snake_count = sum(1 for col in column_names if '_' in col)

    if camel_count > snake_count:
        return "camelCase"
    elif snake_count > camel_count:
        return "snake_case"
    else:
        return "mixed"
```

## Validation Framework

### Validation Severity Levels

**Critical** (❌): Blocks implementation, must fix before proceeding
- Schema mismatches (column names, types don't match actual data)
- Missing primary keys
- Broken foreign key references
- Inconsistent grain in fact tables
- Missing idempotency in critical events

**Warning** (⚠️): Tech debt, should fix but not blocking
- Wide tables (>50 columns)
- Missing indexes on foreign keys
- Undocumented transformations
- Missing audit columns
- No time dimension in analytical model

**Info** (ℹ️): Suggestions for improvement
- Consider normalization/denormalization
- Add convenience views
- Optimize partitioning strategy
- Enhance documentation

### Validation Checks by Domain

**Analytical Validation**:
```yaml
checks:
  - id: analytical_grain_defined
    severity: critical
    check: "All fact tables have documented grain statements"

  - id: analytical_dimension_separation
    severity: critical
    check: "Dimension tables separated from fact tables"

  - id: analytical_partitioning
    severity: warning
    check: "Partitioning strategy specified for large tables"

  - id: analytical_wide_tables
    severity: warning
    check: "Tables have <50 columns (threshold)"

  - id: analytical_time_dimension
    severity: info
    check: "Time dimension table present for calendar operations"
```

**Transactional Validation**:
```yaml
checks:
  - id: transactional_fk_defined
    severity: critical
    check: "All foreign keys defined with CASCADE rules"

  - id: transactional_pk_present
    severity: critical
    check: "Primary keys defined on all tables"

  - id: transactional_audit_columns
    severity: warning
    check: "Audit columns (created_at, updated_at) present"

  - id: transactional_soft_delete
    severity: info
    check: "Soft delete pattern for important entities"
```

**Streaming Validation**:
```yaml
checks:
  - id: streaming_event_schema
    severity: critical
    check: "Events include event_id, event_type, event_timestamp, schema_version"

  - id: streaming_idempotency
    severity: critical
    check: "Critical events include idempotency keys"

  - id: streaming_immutability
    severity: critical
    check: "No UPDATE operations in event stream (append-only)"

  - id: streaming_schema_evolution
    severity: warning
    check: "Schema evolution strategy documented"
```

## Output Format

When validating data models, produce:

### 1. Application Type Report
```markdown
**Detected Application Type**: Analytical (score: 15 keywords)
**Hybrid**: No
**Pattern**: Medallion Architecture (bronze/silver/gold)
```

### 2. Data Sources Discovered
```markdown
| Source Type | Path | Tables/Files | Confidence |
|-------------|------|--------------|------------|
| CSV | data/raw/customers.csv | 1 file, 60 cols | High |
| SQL Schema | data/schema/create.py | 14 tables | High |

**Naming Convention**: CSV (camelCase) → DB (snake_case)
```

### 3. Validation Results
```markdown
#### ✅ PASSED (10/15)
- [x] Bronze layer preserves raw data
- [x] Partitioning strategy specified
...

#### ⚠️ WARNINGS (3/15)
- [ ] customers_master has 60 columns (threshold: 50)
  Recommendation: Split into core + firmographic
  Impact: Medium | Effort: 2-3 hours

#### ❌ FAILED (2/15)
- [ ] fct_financial_data grain inconsistent
  Issue: Transactional model vs quarterly summary
  Impact: CRITICAL | Effort: 2 hours
```

### 4. Recommendations
```markdown
**Critical Fixes Required**:
1. Update fct_financial_data to match actual quarterly summary structure
2. Fix foreign key references (INTEGER → TEXT)

**Warnings to Address**:
1. Split wide tables (>50 columns)
2. Document CSV → DB transformations
3. Add time dimension table
```

## Common Data Type Standards

### Analytical Databases (DuckDB, Redshift, BigQuery)
```sql
customer_id TEXT                    -- Flexible for UUIDs
revenue DECIMAL(18,2)               -- Exact precision
win_rate_pct DECIMAL(5,2)          -- 0.00-100.00
transaction_date DATE               -- Day precision
event_timestamp TIMESTAMP           -- Second precision
customer_name VARCHAR               -- No length penalty
```

### Transactional Databases (PostgreSQL, MySQL)
```sql
customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid()
account_balance DECIMAL(18,2) NOT NULL DEFAULT 0
status VARCHAR(20) CHECK (status IN ('active', 'suspended'))
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

## Evolution

- v1.0.0: Initial version with analytical, transactional, streaming patterns
- Future: Graph database patterns, time-series patterns, document stores
