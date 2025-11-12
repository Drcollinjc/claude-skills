# Cloud Architecture Skill v1.0.0

## Purpose
Architect AI/ML/Data applications on AWS with pragmatic Python-first approach, considering project stage (demo/development/scale/production) and applying Amazon's Type 1 vs Type 2 decision framework.

## Core Principles

### 1. Stage-Appropriate Architecture
Different project stages demand different architectural approaches:

**Demo Stage** (Prove Concept):
- Optimize for: Speed to demo, local development, iteration velocity
- Accept: Higher operational complexity, self-managed services
- Avoid: Over-engineering, premature optimization, expensive managed services

**Development Stage** (Build MVP):
- Optimize for: Developer experience, testing, modularity
- Accept: Technical debt if documented, monolithic start
- Avoid: Distributed systems complexity, microservices prematurely

**Scale Stage** (Handle Growth):
- Optimize for: Performance, cost efficiency at volume
- Accept: Increased operational complexity, migration effort
- Avoid: Rewrites, breaking changes to stable APIs

**Production Stage** (Enterprise):
- Optimize for: Reliability, security, compliance
- Accept: Higher costs, slower velocity, process overhead
- Avoid: Unproven technologies, undocumented dependencies

### 2. Python-First Philosophy
Maintain single-language codebase to minimize context-switching:

✅ **Embrace:**
- Python for application logic, infrastructure (CDK), data processing, orchestration
- Domain-specific languages where appropriate (SQL for queries, YAML for static config)
- Python-native AWS services (Lambda, ECS with Python containers)

⚠️ **Consider Carefully:**
- Node.js, Go, Java - only if AWS service strictly requires it
- Polyglot architectures - high context-switching cost

❌ **Avoid:**
- Mixing languages for same concern (e.g., Python app + Node.js orchestration)
- JSON/YAML as business logic (e.g., Step Functions state machines)

### 3. Local-First Development
Every feature MUST be testable on developer laptop without AWS:

**Requirements:**
- Full transformation pipeline runnable locally
- Test suites execute without AWS credentials
- Fast feedback loops (<5 min edit-test-debug)
- Standard Python tooling (pytest, debuggers, type hints)

**Strategies:**
- LocalStack for AWS service mocking
- DuckDB instead of Aurora for analytics
- File-based queues instead of SQS for development
- Docker Compose for multi-service orchestration

### 4. Type 1 vs Type 2 Decisions (Amazon Framework)

**Type 1 Decisions (One-Way Doors):**
- Irreversible or very costly to reverse
- Require careful analysis, senior review, POCs
- Examples: Data model design, API contracts, database choice (managed vs self-hosted paradigm)

**Type 2 Decisions (Two-Way Doors):**
- Reversible with reasonable effort
- Can experiment, iterate, change direction
- Examples: Orchestration tool, specific library version, deployment approach

**Decision Classification Matrix:**

| Factor | Type 1 (Irreversible) | Type 2 (Reversible) |
|--------|----------------------|---------------------|
| **Data migration cost** | High (weeks) | Low (days) |
| **API contract changes** | Breaking changes to clients | Internal only |
| **Vendor lock-in** | Proprietary formats/APIs | Open standards |
| **Learning curve** | Team retraining required | Individual ramp-up |
| **Infrastructure coupling** | Tightly coupled to cloud primitives | Abstracted, portable |

**Decision-Making Speed:**
- Type 1: Slow, deliberate (days-weeks for analysis)
- Type 2: Fast, experimental (hours-days to try)

## AWS Architecture Patterns

### Data Architecture

**Demo/Development:**
```
DuckDB (local + S3 Parquet) → For analytics workloads <100GB
├─ Pros: Perfect local dev, Python-native, fast queries
├─ Cons: Not managed, manual scaling
└─ Type 2: Easy migration to Aurora/Redshift
```

**Scale/Production:**
```
Aurora Serverless v2 → For transactional workloads
Redshift Serverless → For analytical workloads >100GB
├─ Pros: Managed, auto-scaling, enterprise features
├─ Cons: Minimum costs, AWS-specific
└─ Type 1: Harder to migrate away from AWS
```

### Workflow Orchestration

**Demo/Development (PREFERRED):**
```
Prefect OSS → Python-native orchestration
├─ Pros: Full local testing, Python DAGs, great DX
├─ Cons: Self-managed, requires control plane
├─ Local: Prefect server runs on laptop
├─ AWS: ECS tasks with push work pools
└─ Type 2: Can switch to Step Functions if needed
```

**Alternative (Cost-Constrained):**
```
AWS Step Functions → JSON state machines
├─ Pros: Fully managed, very cheap (<$0.01/execution)
├─ Cons: Poor local testing, JSON not Python
├─ Local: Docker simulator or mocks
├─ AWS: Native integration
└─ Type 2: Can migrate to Prefect
```

**Production (Enterprise):**
```
Prefect Cloud or AWS Step Functions
├─ Prefect Cloud: Team collaboration, managed control plane
├─ Step Functions: AWS-native, scales to millions
└─ Type 2: Both are viable long-term
```

### Compute Patterns

**Lambda** (Stateless, <15min runtime):
- Event-driven processing, API endpoints
- Python 3.11+, arm64 for cost savings
- Type 2: Can move to ECS if timeout limits hit

**ECS Fargate** (Stateful, long-running):
- Data transformations, agent services, background workers
- Prefer ARM64 (Graviton) for 20% cost savings
- Type 2: Container portability enables migration

**Batch** (Large-scale ML training):
- Only when Fargate insufficient
- Type 2: Can downgrade to Fargate

### Storage Patterns

**S3** (Primary data lake):
- Raw data, transformed data, model artifacts
- Parquet format for analytics
- Type 1: Once in S3 object model, hard to change structure

**DynamoDB** (Metadata, small state):
- Table design is Type 1 (partition key hard to change)
- Use single-table design for flexibility

## Decision Framework

### Evaluation Criteria (Priority Order)

1. **Local Testability** (30% weight):
   - Can developers run full workflow on laptop?
   - Do tests need AWS credentials?
   - How long is edit-test-debug cycle?

2. **Single-Language Alignment** (25% weight):
   - Pure Python or introduces new language?
   - Context-switching cost for team?
   - Learning curve and documentation quality?

3. **Developer Experience** (20% weight):
   - IDE support (debugging, type hints, linting)?
   - Standard Python patterns and libraries?
   - Community size and resources?

4. **Iteration Speed** (15% weight):
   - How fast to add new features?
   - How easy to refactor?
   - Deployment and testing time?

5. **Cost** (5% weight):
   - Monthly cost for demo/dev stage?
   - Cost scaling curve at production?

6. **Operational Simplicity** (5% weight):
   - Managed vs self-hosted trade-offs?
   - Monitoring and debugging complexity?

### Architecture Review Checklist

Before finalizing architecture, validate:

**Separation of Concerns:**
- [ ] Data ingestion decoupled from transformation
- [ ] Transformation decoupled from serving layer
- [ ] Infrastructure decoupled from business logic

**Evaluation Loops:**
- [ ] Metrics collection at each stage (raw → silver → gold)
- [ ] Data quality gates with validation feedback
- [ ] Model performance monitoring (if ML component)
- [ ] User feedback mechanisms

**Reversibility Analysis:**
- [ ] Type 1 decisions identified and justified
- [ ] Type 2 decisions documented with migration paths
- [ ] Vendor lock-in risks assessed
- [ ] Data export/import mechanisms designed

**Python Application Best Practices:**
- [ ] Virtual environments for dependency isolation
- [ ] Type hints for critical functions
- [ ] Structured logging (JSON format for AWS CloudWatch)
- [ ] Configuration via environment variables + .env files
- [ ] Testing: Unit tests (pytest), integration tests, infrastructure tests

**AWS Well-Architected Framework:**
- [ ] **Operational Excellence**: IaC (CDK), monitoring (CloudWatch), CI/CD
- [ ] **Security**: IAM least privilege, Secrets Manager, VPC isolation
- [ ] **Reliability**: Multi-AZ where needed, retry logic, circuit breakers
- [ ] **Performance**: Right-sized compute, caching, async where beneficial
- [ ] **Cost Optimization**: Fargate Spot, ARM64, S3 lifecycle policies, serverless patterns
- [ ] **Sustainability**: ARM64, regional data residency, efficient compute

## Common Anti-Patterns to Avoid

❌ **Over-Engineering for Demo Stage:**
- Adding microservices when monolith works
- Complex event-driven architecture prematurely
- Enterprise patterns for POC

❌ **Polyglot for No Reason:**
- Node.js orchestration when Python Prefect exists
- Go data processing when Python Pandas/Polars sufficient
- Multiple languages in same repository

❌ **AWS Service Kitchen Sink:**
- Using every AWS service because it exists
- SQS when S3 event notifications sufficient
- Kinesis when batch processing works

❌ **Ignoring Local Development:**
- Requiring AWS for every test
- No local test data or mocks
- Slow feedback loops (>5 minutes)

❌ **Type 1 Decision Rushing:**
- Choosing managed database without evaluating self-hosted
- API contract without versioning strategy
- Data model without considering evolution

## Migration Paths (By Stage)

### Demo → Development
- DuckDB stays (still appropriate)
- Add observability (structured logs, metrics)
- Introduce proper CI/CD
- Type 2 decisions solidify

### Development → Scale
- Consider: DuckDB → Aurora/Redshift (if volume grows)
- Add: Caching layer, CDN
- Optimize: Database indexes, query patterns
- Monitor: Cost and performance metrics

### Scale → Production
- Add: Multi-region, disaster recovery
- Harden: Security audits, penetration testing
- Formalize: SLAs, on-call rotations, runbooks
- Invest: Managed services over self-hosted

## Example Technology Stack (Demo Stage)

```yaml
Language: Python 3.11
Infrastructure: AWS CDK (Python)
Compute: ECS Fargate (ARM64)
Storage: S3 + DuckDB (file-based analytics)
Orchestration: Prefect OSS (Python DAGs)
Data Transformation: dbt-duckdb (SQL + YAML)
API: FastAPI
Testing: pytest, LocalStack
Observability: CloudWatch Logs (structured JSON)
```

**Rationale:**
- 100% Python except domain-specific (SQL, YAML)
- Full local development support
- Fast iteration cycles
- Clear migration path to Aurora/Prefect Cloud
- Type 2 decisions dominate (reversible)

## AWS Well-Architected Best Practices

### 1. Operational Excellence
- **Infrastructure as Code**: AWS CDK (Python) for all infrastructure
- **Deployment**: Blue/green via ECS, canary via Lambda aliases
- **Monitoring**: CloudWatch dashboards, alarms on key metrics
- **Runbooks**: Document common operational tasks

### 2. Security
- **IAM**: Least privilege, no long-lived credentials, IAM roles for services
- **Secrets**: AWS Secrets Manager, rotate regularly
- **Network**: VPC with private subnets, security groups with minimal rules
- **Data**: Encryption at rest (S3, EBS), in transit (TLS)

### 3. Reliability
- **Multi-AZ**: RDS, ECS services across availability zones
- **Retry Logic**: Exponential backoff with jitter
- **Circuit Breakers**: Fail fast on downstream unavailability
- **Backups**: Automated snapshots, tested restore procedures

### 4. Performance
- **Compute**: Right-size Fargate tasks, use ARM64 Graviton
- **Storage**: S3 for data lake, DuckDB for analytics, DynamoDB for metadata
- **Caching**: API responses, query results where beneficial
- **Async**: Use async Python (asyncio) for I/O-bound operations

### 5. Cost Optimization
- **Serverless**: Prefer Lambda/Fargate over always-on EC2
- **Spot**: Fargate Spot for batch workloads (70% savings)
- **ARM64**: Graviton processors (20% savings)
- **S3 Lifecycle**: Transition to Glacier for archival
- **Right-Sizing**: Monitor CPU/memory utilization, adjust

### 6. Sustainability
- **Region**: Choose regions with renewable energy (e.g., us-west-2, eu-west-1)
- **ARM64**: More efficient than x86
- **Serverless**: Better resource utilization than always-on VMs
- **Data Residency**: Store data close to compute to reduce transfer

## Reference Architecture: AI/ML Data Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│  Data Ingestion (Lambda or ECS Fargate)                    │
│  - S3 event trigger or scheduled                            │
│  - Validate schema, write to S3 raw layer                   │
│  - Type 2: Can switch Lambda ↔ Fargate                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Orchestration (Prefect on ECS Fargate)                    │
│  - Python DAGs for workflow logic                           │
│  - Local testing support                                    │
│  - Type 2: Can switch to Step Functions                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Data Transformation (dbt-duckdb on Fargate)               │
│  - Raw → Silver → Gold medallion architecture               │
│  - SQL transformations, data quality tests                  │
│  - Type 2: Can switch DuckDB → Aurora                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Serving Layer (FastAPI on Fargate)                        │
│  - Query gold layer (DuckDB or Aurora)                      │
│  - REST API with Pydantic validation                        │
│  - Type 2: Can switch to Lambda if latency critical         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Observability (CloudWatch)                                 │
│  - Structured JSON logs                                     │
│  - Metrics: latency, error rate, data volume                │
│  - Alarms: Error thresholds, pipeline failures              │
└─────────────────────────────────────────────────────────────┘
```

**Key Characteristics:**
- Every component testable locally (DuckDB, Prefect, FastAPI)
- Python throughout (CDK, Prefect DAGs, FastAPI, dbt Python models)
- Type 2 decisions at each layer (can swap components)
- Clear data lineage (S3 raw → silver → gold)
- Evaluation loops at each transformation stage

## Evolution Strategy

**Version 1.0.0 (Current):**
- Initial architecture skill with AWS focus
- Python-first philosophy
- Type 1 vs Type 2 decision framework
- Stage-appropriate patterns

**Future Enhancements:**
- Add multi-cloud patterns (Azure, GCP)
- ML-specific architectures (training, inference, monitoring)
- Real-time vs batch trade-offs
- Cost optimization deep-dives

## When to Use This Skill

✅ **Use when:**
- Designing new AI/ML/Data features on AWS
- Evaluating technology choices with trade-offs
- Reviewing architecture for stage appropriateness
- Analyzing decision reversibility (Type 1 vs Type 2)

⚠️ **Consider alternatives when:**
- Non-AWS cloud platforms (adapt principles)
- Non-Python languages (adjust recommendations)
- Microservices migration (different patterns needed)

---

**Created**: 2025-11-12  
**Version**: 1.0.0  
**Maintainer**: Animis Analytics Agent Project
