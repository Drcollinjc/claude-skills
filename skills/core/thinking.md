# Thinking Skill v1.1.0

## Purpose
Structured problem analysis and planning

## Process
1. **Understand Requirements**
   - What exactly needs to be done?
   - What are the acceptance criteria?
   - What constraints exist?

2. **Identify Edge Cases**
   - What could go wrong?
   - What are the boundary conditions?
   - What are the error scenarios?

3. **Plan Approach**
   - Break into smaller steps
   - Identify dependencies
   - Estimate complexity

4. **Define Success**
   - How will we verify completion?
   - What tests prove it works?
   - What metrics matter?

5. **Select Skills**
   - What expertise is needed?
   - What patterns apply?
   - What tools are required?

6. **Validation Checkpoint**

Before marking any task complete, verify:

### For Infrastructure Changes
- [ ] CDK/Terraform synthesis succeeds (`cdk synth`, `terraform plan`)
- [ ] Generated configuration matches expected changes
- [ ] No syntax errors or resource conflicts

### For Code Changes
- [ ] Application starts without errors
- [ ] Critical path manually tested (not just "it compiles")
- [ ] Logs show expected behavior

### For Data Changes
- [ ] Schema matches spec exactly (column count, types, names)
- [ ] Sample data loads correctly
- [ ] Foreign key relationships validated

### Validation Rules
```yaml
validation:
  principle: "Validation is BINARY"
  rules:
    - "Spec/requirements are ALWAYS the source of truth"
    - "Any deviation is an ERROR unless user explicitly approves"
    - "NEVER say 'OK', 'MATCH', or 'acceptable' if it doesn't meet spec"
    - "If unsure whether deviation is acceptable, ASK - don't assume"
    - "'Close enough' is NOT good enough when closing stories"
```

**Note**: This is component validation (required), not comprehensive testing (not required per most constitutions).

## Output Template
```yaml
analysis:
  requirement: [clear statement]
  edge_cases: [list]
  approach: [step-by-step plan]
  success_criteria: [measurable outcomes]
  required_skills: [list of skills needed]
  validation_checklist: [what to verify before marking complete]
```

## Evolution
- v1.0.0: Initial version
- v1.1.0: Added validation checkpoint with binary pass/fail rules
