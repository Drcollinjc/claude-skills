# Lessons Learned: 003-nl-analytics-agent

**Date**: 2026-01-28
**Feature**: 003-nl-analytics-agent (NL Analytics Agent with DuckDB Backend)
**Project Type**: Natural language query agent using Strands SDK + DuckDB
**Duration**: ~8.5 hours across SPECIFY → IMPLEMENT stages
**Tasks Completed**: 44/44 (100%)

## Key Learnings

### 1. Session Summary as Mandatory Artifact (HIGH PRIORITY)

**Pattern Frequency**: Used across all 6 SpecKit stages

**Learning**:
- Session summary should be created at SPECIFY stage, not optional
- Must be updated at the END of each SpecKit stage
- Critical for context continuity when sessions are cleared
- Captures implicit decisions not obvious from spec/plan alone

**Evidence**:
- Context was preserved across multiple conversation sessions
- Decisions log captured rationale for in-memory sessions, JSONL logging choices
- Time tracking enabled accurate progress reporting

**Proposed Changes**:
- Make session-summary.md mandatory in constitution
- Each /speckit.* command should include session summary update step
- Template should include SpecKit Flow Progress table at top

**Skill Updates**:
- NEW: `development/speckit-workflow.md`

---

### 2. DuckDB Per-Request Connection Pattern (HIGH PRIORITY)

**Pattern Frequency**: 3+ occurrences (agent requests, evaluation, health checks)

**Learning**:
- Web/agent applications should create fresh DuckDB connections per request
- Always use `read_only=True` for query-only services
- Connection pooling is NOT needed for DuckDB file-based databases
- Thread safety achieved via per-request connections, not locks

**Evidence**:
- Initial approach with shared connection caused file locking issues
- Per-request pattern enabled concurrent requests without issues
- Health checks can run independently of query sessions

**Pattern**:
```python
def execute_query(db_path: str, query: str) -> list[dict]:
    """Execute query with per-request connection."""
    conn = duckdb.connect(db_path, read_only=True)
    try:
        result = conn.execute(query).fetchdf()
        return result.to_dict('records')
    finally:
        conn.close()
```

**Skill Updates**:
- UPDATE: `development/duckdb-patterns.md` → v1.1.0

---

### 3. Dual Scoring for LLM Evaluation (MEDIUM PRIORITY)

**Pattern Frequency**: New pattern (first implementation)

**Learning**:
- Evaluating NL→SQL agents requires separating concerns:
  - **SQL Score**: Does generated SQL semantically match expected SQL?
  - **Result Score**: Do query results match expected data?
- SQL can be "wrong" but produce correct results (different approach)
- Results can match but SQL be inefficient or fragile

**Implementation**:
```python
@dataclass
class EvaluationResult:
    sql_score: float      # 0-1, LLM-based semantic comparison
    result_score: float   # 0-1, data comparison (row count, values)
    combined_score: float # Weighted average
```

**Skill Updates**:
- Consider NEW: `development/llm-evaluation-patterns.md` (future)

---

### 4. JSONL for Local Observability (LOW PRIORITY)

**Pattern Frequency**: 1 occurrence (new pattern)

**Learning**:
- For local-first development, JSONL files provide sufficient observability
- Session-partitioned logging: `data/logs/sessions/{session_id}/queries.jsonl`
- No external dependencies (no CloudWatch, Datadog for local dev)
- Easy to grep, tail, and analyze

**Pattern**:
```python
def log_query(session_id: str, entry: QueryLogEntry):
    log_dir = Path(f"data/logs/sessions/{session_id}")
    log_dir.mkdir(parents=True, exist_ok=True)
    with open(log_dir / "queries.jsonl", "a") as f:
        f.write(entry.model_dump_json() + "\n")
```

---

### 5. Lightweight Architecture Review (MEDIUM PRIORITY)

**Pattern Frequency**: 1 occurrence

**Learning**:
- Not every feature needs full /speckit.architecture
- Evolutionary features building on existing architecture can use "lightweight review"
- Key question: "Are all choices reversible?"
- If yes → proceed with lightweight review in plan.md
- If no → full architecture review needed

**Criteria for Lightweight Review**:
- Feature builds on existing patterns (not net-new architecture)
- All new components are reversible
- No external service integrations
- No data migration complexity

---

## Metrics

| Metric | Value |
|--------|-------|
| Total Tasks | 44 |
| Tasks Completed | 44 (100%) |
| Total Duration | ~8.5 hours |
| Stages | 6 (SPECIFY → IMPLEMENT) |
| Clarifications | 5 |
| Architecture Review | Lightweight |
| Net-New Files | 8 |
| Modified Files | 5 |

## Recommendations Applied

1. Created speckit-workflow skill for session summary maintenance
2. Updated duckdb-patterns with per-request connection pattern
3. Documented lightweight architecture review criteria
4. Added dual scoring pattern for LLM evaluation

## Evolution Tracking

- Skills updated: 1 (duckdb-patterns v1.0.0 → v1.1.0)
- Skills created: 1 (speckit-workflow v1.0.0)
- Constitution updates proposed: Session summary mandatory

---

**Lesson File Created**: 2026-01-28
**Next Review**: After next feature implementation
