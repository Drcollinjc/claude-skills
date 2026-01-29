# Verification Skill v1.2.0

## Purpose
Verify work meets requirements through systematic validation.

## Verification Patterns

### Infrastructure Verification
1. Run synthesis/plan command (`cdk synth`, `terraform plan`)
2. Parse output for errors or warnings
3. Extract relevant configuration sections
4. Compare against expected values
5. Report: PASS (100% match) or FAIL (with specific issues)

### Application Verification
1. Start application/service
2. Execute critical path manually (curl, API calls)
3. Check logs for expected output
4. Verify error handling works
5. Report: PASS or FAIL

### Data Pipeline Verification
1. Validate source schema matches spec (exact column count)
2. Test data loading with explicit parameters
3. Verify transformations produce expected output
4. Check foreign key relationships
5. Report: PASS or FAIL

### API Contract Verification (NEW in v1.2.0)

**When to Use**: Before building frontend against backend API endpoints.

**Process**:
1. Call actual API endpoint with test data
2. Capture actual response structure
3. Compare against contract/spec definition
4. Document any deviations
5. Update frontend types OR fix backend

**Checklist**:
```markdown
## API Contract Validation

- [ ] Endpoint returns expected HTTP status
- [ ] Response content-type matches spec (application/json)
- [ ] Top-level response structure matches contract
- [ ] Nested object shapes match contract
- [ ] Field names match (check camelCase vs snake_case)
- [ ] Field types match (string, number, array, object)
- [ ] Optional fields handled correctly (null vs missing)
- [ ] Array items have correct shape
- [ ] Error responses match contract format
```

**Example Validation**:
```bash
# Capture actual response
curl -s http://localhost:8000/api/endpoint | jq . > actual.json

# Compare key fields against contract
# Check: field names, nesting, types
```

**Common Issues**:
- Backend returns flat structure, contract specifies nested
- snake_case in Python, camelCase expected in contract
- Optional fields returned as null vs omitted entirely
- Arrays wrapped in extra object layer

## Status Reporting Rules

| Status | Meaning | When to Use |
|--------|---------|-------------|
| PASS | 100% match, zero issues | Everything exactly as specified |
| WARN | Partial match, needs decision | Minor deviation, user should decide |
| FAIL | Does not match, must fix | Any significant deviation from spec |

**CRITICAL**: Never use PASS for "close enough". If there's any doubt, use WARN and ask.

## Validation Principles

```yaml
validation:
  principle: "Validation is BINARY"
  source_of_truth: "Spec/requirements document"
  rules:
    - "Spec says X → implementation must have X"
    - "Any deviation is an ERROR until user explicitly approves"
    - "NEVER mark 'close enough' as passing"
    - "When unsure, ASK rather than assume"
    - "Tests passing ≠ requirements met (tests may be incomplete)"
```

## Anti-Patterns

- Marking tasks complete without running validation
- Saying "likely intentional" for spec deviations without asking
- Assuming tests passing = requirements met
- Optimistic reporting ("it should work") vs actual verification
- Using PASS status for "close enough" matches
- Declaring success before testing actual failure scenarios
- Building frontend before validating API contract (NEW)
- Assuming contract matches actual response without testing (NEW)

## Verification Checklist Template

```markdown
## Pre-Completion Verification

### Infrastructure
- [ ] Synthesis/plan runs without errors
- [ ] Generated config matches expected values
- [ ] No warnings or deprecations

### Application
- [ ] Service starts successfully
- [ ] Health endpoint responds
- [ ] Critical path tested manually
- [ ] Logs show expected behavior

### Data
- [ ] Column count matches spec exactly
- [ ] Data types are correct
- [ ] Foreign keys reference valid targets
- [ ] Sample queries return expected results

### API Contracts (NEW)
- [ ] Actual response structure matches contract
- [ ] Field names match expected casing
- [ ] Nested objects have correct shape
- [ ] Error responses match contract

### Status: [PASS/WARN/FAIL]
```

## Evolution
- v1.0.0: Initial version
- v1.1.0: Added data pipeline verification, status reporting rules, anti-patterns, validation principles
- v1.2.0: Added API contract verification patterns from 004-icp-decision-surface
