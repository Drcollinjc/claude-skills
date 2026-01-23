# Lessons Learned: animis-analytics-agent

**Date**: 2026-01-23
**Features**: 001-health-check, 002-duckdb-medallion
**Project Type**: Data analytics agent with DuckDB medallion architecture

## Key Learnings

### 1. Validation Must Be Binary (HIGH PRIORITY)

**Pattern Frequency**: 2+ occurrences across both features

**Learning**:
- Spec/requirements are the source of truth
- Any deviation is an ERROR until user explicitly approves
- "Close enough" or "likely intentional" are not valid statuses
- When unsure, ASK rather than assume

**Evidence**:
- 001: CDK changes marked complete without running `cdk synth`
- 002: 57/58 column mismatch marked as "likely intentional" when it was an error

**User Feedback**: "We have stories to close and meet the requirements. Please stop saying that something is ok even though it is not working."

**Skill Updates**:
- `core/thinking.md`: Added validation checkpoint
- `core/verification.md`: Added status reporting rules

---

### 2. Infrastructure Validation Required (HIGH PRIORITY)

**Pattern Frequency**: 2+ occurrences

**Learning**:
- CDK/Terraform changes must be validated with synthesis before marking complete
- Data loading must be tested before building downstream models
- "It compiles" is not the same as "it works"

**Evidence**:
- 001: Had to run `cdk synth` after user questioned whether it was validated
- 002: CSV reading issues discovered only after building multiple models

**Skill Updates**:
- `core/verification.md`: Added infrastructure verification pattern
- `orchestrator/main.md`: Added validation reminders

---

### 3. DuckDB-Specific Patterns (NEW)

**Source**: 002-duckdb-medallion (4+ occurrences of DuckDB issues)

**Learning**:
- Use `header=1` not `header=TRUE` for CSV reading
- DuckDB SQL syntax differs from PostgreSQL (STRFTIME, QUARTER)
- Use read-only mode for analytics services
- File locking can block development workflows

**Critical Issue**: DuckDB's CSV auto-detection detected row 25 as header instead of row 1 due to empty values in early rows. Cost 2+ hours of debugging.

**Skill Updates**:
- NEW: `development/duckdb-patterns.md`

---

### 4. Pre-Implementation Validation (MEDIUM PRIORITY)

**Pattern Frequency**: 2+ occurrences

**Learning**:
- Validate data schemas BEFORE writing transformation code
- Test CSV reading with explicit parameters before building models
- Check foreign key columns exist in source data

**Time Saved**: Data model validation in 002 prevented 2-4 days of debugging.

**Skill Updates**:
- `development/duckdb-patterns.md`: Added validation section

---

### 5. Premature Success Declarations (MEDIUM PRIORITY)

**Pattern Frequency**: 2+ occurrences

**Learning**:
- Don't mark tasks complete without thorough validation
- Health checks passing ≠ system working
- Tests passing ≠ requirements met

**Evidence**:
- 002: Health endpoint showed "healthy" but actual usage failed due to file locking
- 002: Declared alignment "GOOD" when column count didn't match

**Skill Updates**:
- `core/verification.md`: Added anti-patterns section

---

## Metrics

| Metric | 001-health-check | 002-duckdb-medallion |
|--------|------------------|----------------------|
| Tasks Completed | 18/41 (44%) | 61/80 (76%) |
| Critical Issues | 1 (CDK validation) | 4 (CSV, schema, SQL, locking) |
| Tests Passing | Manual only | 91/91 (100%) |
| Time Saved by Validation | N/A | 2-4 days (schema validation) |
| Implementation Duration | ~1 hour | ~2 months |

## Recommendations Applied

1. Added validation checkpoint to thinking skill
2. Expanded verification skill with data patterns
3. Created DuckDB-specific patterns skill
4. Updated orchestrator to load data skills automatically
5. Added validation reminders to orchestrator

## Evolution Tracking

- Skills updated: 3 (thinking, verification, orchestrator)
- Skills created: 1 (duckdb-patterns)
- Version: v1.0.0 -> v1.2.0

---

**Lesson File Created**: 2026-01-23
**Next Review**: After next feature implementation
