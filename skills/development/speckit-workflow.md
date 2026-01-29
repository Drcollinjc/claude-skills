# SpecKit Workflow Skill v1.0.0

## Purpose
Maintain context continuity across SpecKit stages through mandatory session summary updates.

## Session Summary Maintenance

### Principle
Every feature MUST maintain a `session-summary.md` file that is automatically updated at the end of each SpecKit stage.

### Why This Matters
- Context is lost when conversation sessions are cleared
- Implicit decisions aren't captured in spec/plan alone
- Progress tracking enables accurate time estimates
- Onboarding new team members is faster

## Update Triggers

| Stage | Action | Update Content |
|-------|--------|----------------|
| `/speckit.specify` | CREATE | Initialize session-summary.md, set SPECIFY = ✅ |
| `/speckit.clarify` | UPDATE | Add clarifications captured, set CLARIFY = ✅ |
| `/speckit.architecture` | UPDATE | Add architecture decisions, set ARCHITECTURE = ✅ |
| `/speckit.plan` | UPDATE | Add artifacts list, decisions, set PLAN = ✅ |
| `/speckit.tasks` | UPDATE | Add task count, dependencies, set TASKS = ✅ |
| `/speckit.implement` | UPDATE | Track progress, set IMPLEMENT = ✅ when complete |

## Required Sections

```markdown
# Session Summary: [Feature Name]

**Feature ID**: [ID]
**Created**: [Date]
**Last Updated**: [Date]
**Branch**: `[branch-name]`

---

## SpecKit Flow Progress

| Stage | Status | Started | Completed | Duration | Artifacts |
|-------|--------|---------|-----------|----------|----------|
| SPECIFY | ⏳/✅ | - | - | - | spec.md |
| CLARIFY | ⏳/✅ | - | - | - | clarifications |
| ARCHITECTURE | ⏳/✅ | - | - | - | architecture.md |
| PLAN | ⏳/✅ | - | - | - | plan.md, etc. |
| TASKS | ⏳/✅ | - | - | - | tasks.md |
| IMPLEMENT | ⏳/✅ | - | - | - | source code |

**Current Stage**: [Stage] - [Status description]

---

## Feature Overview
[1-2 sentence summary]

---

## Decisions Log

| Date | Stage | Decision | Rationale | Impact |
|------|-------|----------|-----------|--------|

---

## Validation Checkpoints

| Checkpoint | Status | Notes |
|------------|--------|-------|

---

## Context for Next Session

**If continuing from here**:
1. [Current state]
2. [Next step]
3. [Key files to read]
```

## Lightweight vs Full Architecture Review

### When to Use Lightweight Review

Use lightweight architecture review (in plan.md) when ALL are true:
- Feature builds on existing patterns
- All new components are reversible
- No new external service integrations
- No data migration complexity

### When to Use Full /speckit.architecture

Use full architecture review when ANY are true:
- Introducing new technology stack
- Irreversible data changes
- External service integrations
- Multi-team coordination required
- Security-sensitive changes

## Anti-Patterns

- Skipping session summary creation at SPECIFY stage
- Not updating session summary after each stage
- Treating session summary as optional
- Starting new sessions without reading session-summary.md
- Capturing only "what" without "why" in decisions log

## Integration with Constitution

The session summary maintenance pattern should be reflected in:
- `.specify/memory/constitution.md` - Development Workflow section
- `.specify/templates/session-summary-template.md` - Standardized format
- Each `/speckit.*` command template - Update step at end

## Evolution
- v1.0.0: Initial skill from 003-nl-analytics-agent learnings
