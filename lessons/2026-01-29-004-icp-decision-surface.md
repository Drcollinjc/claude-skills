# Lessons Learned: 004-icp-decision-surface

**Date**: 2026-01-29
**Feature**: 004-icp-decision-surface (ICP Decision Surface MVP)
**Project Type**: React + FastAPI full-stack with AI chat integration
**Duration**: ~6 hours across SPECIFY → IMPLEMENT stages
**Tasks Completed**: 70/70 (100%)

## Key Learnings

### 1. API Contract Validation Against Actual Responses (HIGH PRIORITY)

**Pattern Frequency**: 3+ occurrences (generate, chat, action endpoints)

**Learning**:
- API contracts in spec define the DESIRED response shape
- Backend AI agent returns ACTUAL response shape (which may differ)
- Must validate actual API responses against contracts BEFORE building frontend
- Frontend that assumes contract shape will break on actual responses

**Evidence**:
- ICP generate endpoint returned flat structure, frontend expected nested
- Chat responses had different evidence format than contract specified
- Required multiple frontend fixes after integration

**Proposed Changes**:
- Add validation task to tasks.md: "Validate API response against contract"
- Use curl/httpie to capture actual responses before frontend integration
- Consider OpenAPI response validation tooling

**Skill Updates**:
- UPDATE: `core/verification.md` → Add API contract validation checklist

---

### 2. Data Schema Inspection Before Implementation (HIGH PRIORITY)

**Pattern Frequency**: 2+ occurrences (segment values, industry categories)

**Learning**:
- Never assume data values - always inspect actual data first
- Schema shows structure, but VALUES matter for business logic
- Enum-like fields (segment, industry) should be extracted from real data
- Hardcoded assumptions create silent failures

**Evidence**:
- Assumed segment values: "SMB", "Mid-Market", "Enterprise"
- Actual data had: "Small Business", "Mid-Market", "Enterprise", "Strategic"
- Queries returned empty results until values were corrected

**Pattern**:
```sql
-- Always run before implementing filters
SELECT DISTINCT segment, COUNT(*) as count 
FROM opportunities 
GROUP BY segment;
```

**Skill Updates**:
- UPDATE: `development/duckdb-patterns.md` → Add data discovery queries section

---

### 3. Pydantic CamelCase Serialization (MEDIUM PRIORITY)

**Pattern Frequency**: 4+ occurrences (all API models)

**Learning**:
- Python uses snake_case, JavaScript/TypeScript expects camelCase
- Pydantic v2 requires explicit config for camelCase serialization
- Must set BOTH `alias_generator` AND `by_alias=True` in model config
- Frontend TypeScript types must match the camelCase output

**Pattern**:
```python
from pydantic import BaseModel, ConfigDict

def to_camel(string: str) -> str:
    components = string.split('_')
    return components[0] + ''.join(x.title() for x in components[1:])

class APIResponse(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,  # Accept both formats on input
        by_alias=True,          # Output camelCase
    )
    user_name: str  # Outputs as "userName" in JSON
```

**Skill Updates**:
- NEW: `development/pydantic-patterns.md`

---

### 4. Docker Stop Timeout for AI Workloads (MEDIUM PRIORITY)

**Pattern Frequency**: 1 occurrence (but critical when it happens)

**Learning**:
- AI/LLM API calls can take 30+ seconds (especially Bedrock)
- Docker default stop timeout is 10 seconds
- If request exceeds stop timeout, container becomes zombie
- Must set `stop_grace_period` higher than max expected request time

**Evidence**:
- Container became unresponsive during long Bedrock request
- `docker compose down` hung, couldn't kill container
- Required Docker Desktop restart to clear zombie

**Pattern**:
```yaml
# docker-compose.yml
services:
  app:
    stop_grace_period: 60s  # Must exceed max AI request time
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

**Skill Updates**:
- NEW: `infrastructure/docker-patterns.md`

---

### 5. Playwright MCP for UI Validation (HIGH PRIORITY)

**Pattern Frequency**: 7+ occurrences (full demo walkthrough)

**Learning**:
- Playwright MCP provides excellent visual validation capability
- Can capture screenshots of each step in user flow
- Accessibility snapshots show element refs for interaction
- Ideal for validation tasks in tasks.md and demos

**Evidence**:
- Generated 7-step demo walkthrough with screenshots
- Captured Landing → Generate → Chat → Action → Save flow
- Screenshots provide visual proof of feature completion

**Use Cases**:
- Validation tasks: Verify UI matches acceptance criteria
- Demo generation: Automated walkthrough capture
- Regression testing: Visual baseline comparison
- Bug reproduction: Capture exact state

**Skill Updates**:
- NEW: `testing/playwright-validation.md`

---

## Metrics

| Metric | Value |
|--------|-------|
| Total Tasks | 70 |
| Tasks Completed | 70 (100%) |
| Total Duration | ~6 hours |
| Stages | 6 (SPECIFY → IMPLEMENT) |
| User Stories | 4 |
| Frontend Components | 12 |
| Backend Endpoints | 6 |
| Docker Fix | 1 (zombie container) |

## Skill Updates Summary

| Skill | Action | Priority |
|-------|--------|----------|
| core/verification.md | UPDATE: Add API contract validation | HIGH |
| development/duckdb-patterns.md | UPDATE: Add data discovery queries | HIGH |
| development/pydantic-patterns.md | NEW: CamelCase serialization | MEDIUM |
| infrastructure/docker-patterns.md | NEW: AI workload timeouts | MEDIUM |
| testing/playwright-validation.md | NEW: UI validation patterns | HIGH |

---

**Lesson File Created**: 2026-01-29
**Next Review**: After next feature implementation
